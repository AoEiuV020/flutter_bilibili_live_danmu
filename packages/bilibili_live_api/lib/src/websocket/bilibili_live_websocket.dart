import 'dart:async';
import 'dart:convert';
import '../logger.dart';
import 'websocket_client.dart';
import 'messages/messages.dart';

/// WebSocket 连接管理器
class BilibiliLiveWebSocket {
  BilibiliWebSocketClient? _client;
  Timer? _reconnectTimer;
  bool _shouldReconnect = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);

  // 连接参数（用于重连）
  String? _url;
  String? _authBody;

  // 回调函数
  void Function(LiveMessage message)? onMessage;
  void Function(String error)? onError;
  void Function(bool connected)? onConnectionChanged;

  bool get isConnected => _client?.isConnected ?? false;

  /// 连接到直播间
  Future<void> connect({
    required String url,
    required Map<String, dynamic> authParams,
  }) async {
    try {
      _url = url;
      _authBody = jsonEncode(authParams);
      _shouldReconnect = true;
      _reconnectAttempts = 0;

      await _connectInternal();
    } catch (e, stackTrace) {
      logger.e('[LiveWebSocket] 连接失败: $e', error: e, stackTrace: stackTrace);
      onError?.call('连接失败: $e');
      _scheduleReconnect();
    }
  }

  /// 内部连接逻辑
  Future<void> _connectInternal() async {
    if (_url == null || _authBody == null) return;

    // 清理旧连接
    await _cleanupClient();

    // 创建新客户端
    _client = BilibiliWebSocketClient()
      ..onMessage = _handleMessage
      ..onError = _handleError
      ..onStateChange = _handleStateChange;

    // 连接
    await _client!.connect(_url!, _authBody!);
  }

  /// 断开连接（停止重连）
  Future<void> disconnect() async {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _cleanupClient();
  }

  /// 重新连接（关闭旧连接并建立新连接）
  Future<void> reconnect() async {
    if (_url == null || _authBody == null) {
      throw Exception('无法重连：缺少连接参数');
    }

    // 取消之前的自动重连定时器
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    // 暂时禁用自动重连，避免在清理时触发
    final shouldReconnectBackup = _shouldReconnect;
    _shouldReconnect = false;

    // 关闭旧连接
    await _cleanupClient();

    // 恢复自动重连标志并重置计数
    _shouldReconnect = shouldReconnectBackup;
    _reconnectAttempts = 0;

    // 建立新连接
    await _connectInternal();
  }

  /// 清理客户端
  Future<void> _cleanupClient() async {
    if (_client != null) {
      await _client!.disconnect();
      _client = null;
    }
  }

  /// 处理消息
  void _handleMessage(LiveMessage message) {
    try {
      onMessage?.call(message);
    } catch (e, stackTrace) {
      logger.e(
        '[LiveWebSocket] 处理消息回调失败: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 处理错误
  void _handleError(String error) {
    logger.e('[LiveWebSocket] WebSocket 错误: $error');
    onError?.call(error);

    // 错误时尝试重连
    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  /// 处理状态变化
  void _handleStateChange(WebSocketState state) {
    logger.i('[LiveWebSocket] 状态变化: $state');

    switch (state) {
      case WebSocketState.authenticated:
        _reconnectAttempts = 0; // 重置重连次数
        onConnectionChanged?.call(true);
        break;
      case WebSocketState.disconnected:
      case WebSocketState.error:
        onConnectionChanged?.call(false);
        if (_shouldReconnect) {
          _scheduleReconnect();
        }
        break;
      default:
        break;
    }
  }

  /// 安排重连
  void _scheduleReconnect() {
    // 取消之前的重连定时器
    _reconnectTimer?.cancel();

    // 检查重连次数
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      logger.w('[LiveWebSocket] 达到最大重连次数，停止重连');
      onError?.call('连接失败次数过多，已停止重连');
      _shouldReconnect = false;
      return;
    }

    _reconnectAttempts++;
    logger.i(
      '[LiveWebSocket] 将在 ${_reconnectDelay.inSeconds} 秒后重连 (第 $_reconnectAttempts 次)',
    );

    _reconnectTimer = Timer(_reconnectDelay, () {
      if (_shouldReconnect) {
        logger.i('[LiveWebSocket] 开始重连...');
        _connectInternal().catchError((e, stackTrace) {
          logger.e(
            '[LiveWebSocket] 重连失败: $e',
            error: e,
            stackTrace: stackTrace,
          );
        });
      }
    });
  }

  /// 释放资源
  void dispose() {
    disconnect();
  }
}
