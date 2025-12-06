import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../logger.dart';
import 'websocket_protocol.dart';
import 'messages/messages.dart';

/// WebSocket 客户端状态
enum WebSocketState {
  disconnected, // 未连接
  connecting, // 连接中
  connected, // 已连接
  authenticated, // 已认证
  error, // 错误
}

/// WebSocket 消息回调
typedef OnMessageCallback = void Function(LiveMessage message);

/// WebSocket 错误回调
typedef OnErrorCallback = void Function(String error);

/// WebSocket 状态变化回调
typedef OnStateChangeCallback = void Function(WebSocketState state);

/// B站直播 WebSocket 客户端
class BilibiliWebSocketClient {
  WebSocketChannel? _channel;
  WebSocketState _state = WebSocketState.disconnected;
  Timer? _heartbeatTimer;
  int _sequenceId = 0;
  bool _isAuthenticated = false;

  // 回调函数
  OnMessageCallback? onMessage;
  OnErrorCallback? onError;
  OnStateChangeCallback? onStateChange;

  WebSocketState get state => _state;
  bool get isConnected => _state == WebSocketState.authenticated;

  /// 连接 WebSocket
  Future<void> connect(String url, String authBody) async {
    try {
      _updateState(WebSocketState.connecting);

      // 建立 WebSocket 连接
      _channel = WebSocketChannel.connect(Uri.parse(url));

      // 监听消息
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
        cancelOnError: false,
      );

      _updateState(WebSocketState.connected);

      // 发送认证
      await _sendAuth(authBody);

      logger.i('[WebSocket] 已连接并发送认证');
    } catch (e) {
      _handleError('连接失败: $e');
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    _stopHeartbeat();
    await _channel?.sink.close();
    _channel = null;
    _isAuthenticated = false;
    _updateState(WebSocketState.disconnected);
    logger.i('[WebSocket] 已断开连接');
  }

  /// 发送认证
  Future<void> _sendAuth(String authBody) async {
    final packet = ProtoPacket(
      packetLength: 0,
      headerLength: 16,
      version: ProtocolVersion.json,
      operation: Operation.auth,
      sequenceId: _sequenceId++,
      body: Uint8List.fromList(utf8.encode(authBody)),
    );

    _sendPacket(packet);
  }

  /// 发送心跳
  void _sendHeartbeat() {
    if (!_isAuthenticated) return;

    final packet = ProtoPacket(
      packetLength: 0,
      headerLength: 16,
      version: ProtocolVersion.heartbeat,
      operation: Operation.heartbeat,
      sequenceId: _sequenceId++,
      body: Uint8List(0),
    );

    _sendPacket(packet);
    logger.d('[WebSocket] 发送心跳 seq: ${packet.sequenceId}');
  }

  /// 发送数据包
  void _sendPacket(ProtoPacket packet) {
    if (_channel == null) return;

    try {
      final data = packet.encode();
      _channel!.sink.add(data);
    } catch (e) {
      _handleError('发送数据失败: $e');
    }
  }

  /// 处理接收到的消息
  void _handleMessage(dynamic message) {
    try {
      if (message is! Uint8List) return;

      final packet = ProtoPacket.decode(message);

      switch (packet.operation) {
        case Operation.authReply:
          _handleAuthReply(packet);
          break;
        case Operation.heartbeatReply:
          _handleHeartbeatReply(packet);
          break;
        case Operation.message:
          _handleMessageReply(packet);
          break;
      }
    } catch (e, stackTrace) {
      logger.e('[WebSocket] 处理消息失败: $e', error: e, stackTrace: stackTrace);
    }
  }

  /// 处理认证回复
  void _handleAuthReply(ProtoPacket packet) {
    try {
      final jsonStr = utf8.decode(packet.body);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final code = json['code'] as int?;

      if (code == 0) {
        _isAuthenticated = true;
        _updateState(WebSocketState.authenticated);
        _startHeartbeat();
        logger.i('[WebSocket] 认证成功');
      } else {
        _handleError('认证失败: code=$code');
      }
    } catch (e) {
      _handleError('处理认证回复失败: $e');
    }
  }

  /// 处理心跳回复
  void _handleHeartbeatReply(ProtoPacket packet) {
    // 心跳回复包含在线人数
    if (packet.body.length >= 4) {
      final online = packet.body.buffer.asByteData().getUint32(0);
      logger.d('[WebSocket] 心跳回复, 在线人数: $online');
    }
  }

  /// 处理消息回复
  void _handleMessageReply(ProtoPacket packet) {
    try {
      // 根据协议版本解析
      if (packet.version == ProtocolVersion.json) {
        final jsonStr = utf8.decode(packet.body);
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;

        // 解析为消息对象
        final message = LiveMessage.fromJson(json);

        // 打印日志
        logger.d('[WebSocket] 收到消息: $message');

        // 回调
        onMessage?.call(message);
      } else if (packet.version == ProtocolVersion.deflate ||
          packet.version == ProtocolVersion.brotli) {
        // TODO: 处理压缩消息
        logger.w('[WebSocket] 收到压缩消息，暂不支持');
      }
    } catch (e, stackTrace) {
      logger.e('[WebSocket] 处理消息失败: $e', error: e, stackTrace: stackTrace);
    }
  }

  /// 处理错误
  void _handleError(dynamic error) {
    final errorMsg = error.toString();
    logger.e('[WebSocket] 错误: $errorMsg');
    _updateState(WebSocketState.error);
    onError?.call(errorMsg);
  }

  /// 处理连接关闭
  void _handleDone() {
    logger.i('[WebSocket] 连接已关闭');
    _stopHeartbeat();
    _isAuthenticated = false;
    _updateState(WebSocketState.disconnected);
  }

  /// 开始心跳
  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _sendHeartbeat(),
    );
    // 立即发送一次心跳
    _sendHeartbeat();
  }

  /// 停止心跳
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// 更新状态
  void _updateState(WebSocketState newState) {
    if (_state != newState) {
      _state = newState;
      onStateChange?.call(newState);
    }
  }
}
