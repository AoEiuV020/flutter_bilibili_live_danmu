import 'package:flutter/foundation.dart';
import 'package:bilibili_live_api/bilibili_live_api.dart';
import '../managers/system_ui_manager.dart';
import '../managers/heartbeat_manager.dart';
import '../managers/websocket_message_handler.dart';
import '../models/settings.dart';
import '../utils/message_dispatcher.dart';
import '../utils/tts_manager.dart';

/// LivePage ViewModel - 管理所有业务逻辑
class LivePageViewModel {
  final int appId;
  final AppStartData startData;
  final BilibiliLiveApiClient apiClient;
  final MessageDispatcher messageDispatcher;
  final SettingsManager settingsManager;

  late SystemUiManager _systemUiManager;
  late HeartbeatManager _heartbeatManager;
  late WebSocketMessageHandler _messageHandler;
  BilibiliLiveWebSocket? _webSocket;
  bool _isFirstConnection = true;

  LivePageViewModel({
    required this.appId,
    required this.startData,
    required this.apiClient,
    required this.messageDispatcher,
    required this.settingsManager,
  });

  /// 初始化
  Future<void> initialize() async {
    // 初始化系统UI管理器
    _systemUiManager = SystemUiManager();
    _systemUiManager.setFullScreen();
    _systemUiManager.enableWakelock();

    // 初始化心跳管理器
    _heartbeatManager = HeartbeatManager(
      apiClient: apiClient,
      gameId: startData.gameInfo.gameId,
    );
    _heartbeatManager.start();

    // 初始化消息处理器
    _messageHandler = WebSocketMessageHandler(
      filterSettings: settingsManager.filterSettings,
      onDanmaku: (username, content) {
        messageDispatcher.dispatchDanmaku(username, content);
      },
      onInfo: (content) {
        messageDispatcher.dispatchInfo(content);
      },
    );

    // 检查 TTS 初始化状态
    _checkTtsStatus();

    // 连接 WebSocket
    await _initializeWebSocket();
  }

  /// 检查 TTS 初始化状态
  void _checkTtsStatus() {
    final ttsManager = TtsManager.instance;
    if (!ttsManager.isInitialized) {
      messageDispatcher.dispatchInfo('⚠️ TTS 未初始化成功，语音播报功能不可用');
      debugPrint('[LivePageViewModel] TTS 未初始化');
    } else {
      debugPrint('[LivePageViewModel] TTS 已就绪');
    }
  }

  /// 初始化 WebSocket
  Future<void> _initializeWebSocket() async {
    try {
      // 创建并连接 WebSocket（TTS 已在 HomePage 初始化）
      _webSocket = await apiClient.createWebSocket(
        startData: startData,
        onMessage: _handleWebSocketMessage,
        onError: _handleWebSocketError,
        onConnectionChanged: _handleConnectionChanged,
      );
    } catch (e) {
      debugPrint('[LivePageViewModel] 初始化失败: $e');
      messageDispatcher.dispatchInfo('初始化失败: $e');
    }
  }

  /// 处理 WebSocket 消息
  void _handleWebSocketMessage(dynamic message) {
    if (message is InteractionEndMessage) {
      // 交互结束，当前连接已废弃，需要重新连接
      _handleInteractionEnd();
    } else {
      _messageHandler.handleMessage(message);
    }
  }

  /// 处理交互结束消息
  Future<void> _handleInteractionEnd() async {
    messageDispatcher.dispatchInfo('消息推送已结束，正在重新连接...');
    try {
      await _webSocket?.reconnect();
    } catch (e) {
      debugPrint('[LivePageViewModel] 重连失败: $e');
      messageDispatcher.dispatchInfo('重连失败: $e');
    }
  }

  /// 处理 WebSocket 错误
  void _handleWebSocketError(String error) {
    debugPrint('[LivePageViewModel] WebSocket 错误: $error');
    messageDispatcher.dispatchInfo('连接异常: $error');
  }

  /// 处理连接状态变化
  void _handleConnectionChanged(bool connected) {
    debugPrint('[LivePageViewModel] 连接状态: ${connected ? "已连接" : "已断开"}');
    if (!connected) {
      messageDispatcher.dispatchInfo('连接已断开，正在重连...');
    } else {
      // 首次连接
      if (_isFirstConnection) {
        _isFirstConnection = false;
        messageDispatcher.dispatchInfo(
          '已连接到 ${startData.anchorInfo.uname} 的房间 ${startData.anchorInfo.roomId}',
        );
      } else {
        // 重连成功
        messageDispatcher.dispatchInfo('连接已恢复');
      }
    }
  }

  /// 更新消息过滤设置
  void updateFilterSettings(MessageFilterSettings filterSettings) {
    _messageHandler = WebSocketMessageHandler(
      filterSettings: filterSettings,
      onDanmaku: (username, content) {
        messageDispatcher.dispatchDanmaku(username, content);
      },
      onInfo: (content) {
        messageDispatcher.dispatchInfo(content);
      },
    );
  }

  /// 添加测试弹幕
  void addTestDanmaku() {
    final usernames = ['测试用户', '观众A', '粉丝B', '路人C', '土豪D', '超长用户名测试12345'];
    final contents = ['666', '主播好厉害', '这是什么操作', '学到了', '送给主播一个火箭', '哈哈哈'];
    final username = usernames[DateTime.now().millisecond % usernames.length];
    final content = contents[DateTime.now().millisecond % contents.length];
    // 通过消息处理器处理，确保用户名被统一截断
    _messageHandler.handleDanmaku(username, content);
  }

  /// 结束会话
  Future<void> endSession() async {
    try {
      await apiClient.end(appId: appId, gameId: startData.gameInfo.gameId);
      debugPrint('[LivePageViewModel] 会话结束');
    } catch (e) {
      debugPrint('[LivePageViewModel] 结束会话失败: $e');
    } finally {
      apiClient.dispose();
    }
  }

  /// 释放资源
  void dispose() {
    _heartbeatManager.dispose();
    _systemUiManager.dispose();
    _webSocket?.dispose();
    endSession();
  }
}
