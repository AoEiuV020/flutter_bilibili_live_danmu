import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bilibili_live_api/bilibili_live_api.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'widgets/danmaku_list.dart';
import 'widgets/settings_panel.dart';
import 'models/settings.dart';
import 'utils/tts_manager.dart';

class LivePage extends StatefulWidget {
  final int appId;
  final AppStartData startData;
  final BilibiliLiveApiClient apiClient;

  const LivePage({
    super.key,
    required this.appId,
    required this.startData,
    required this.apiClient,
  });

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  Timer? _heartbeatTimer;
  Timer? _hideTimer;
  bool _showBackButton = true;
  bool _showSettings = false;
  bool _isFirstConnection = true;
  final GlobalKey<MessageListState> _messageListKey = GlobalKey();

  late SettingsManager _settingsManager;
  DisplaySettings _displaySettings = DisplaySettings.defaultSettings();
  MessageFilterSettings _filterSettings =
      MessageFilterSettings.defaultSettings();

  @override
  void initState() {
    super.initState();
    _settingsManager = SettingsManager();
    _loadSettings();
    _setFullScreen();
    _enableWakelock();
    _startHeartbeat();
    _startHideTimer();
    _initializeAndShowWelcome();
  }

  /// 加载设置
  Future<void> _loadSettings() async {
    await _settingsManager.load();
    if (mounted) {
      setState(() {
        _displaySettings = _settingsManager.displaySettings;
        _filterSettings = _settingsManager.filterSettings;
      });
    }
  }

  /// 初始化 TTS 并连接 WebSocket
  Future<void> _initializeAndShowWelcome() async {
    try {
      // 先初始化 TTS
      await TtsManager.instance.initialize();

      // 创建并连接 WebSocket
      await widget.apiClient.createWebSocket(
        startData: widget.startData,
        onMessage: _handleWebSocketMessage,
        onError: _handleWebSocketError,
        onConnectionChanged: _handleConnectionChanged,
      );
    } catch (e) {
      debugPrint('[LivePage] 初始化失败: $e');
      if (mounted) {
        _addInfo('初始化失败: $e');
      }
    }
  }

  /// 处理 WebSocket 消息
  void _handleWebSocketMessage(dynamic message) {
    if (message is DanmakuMessage && _filterSettings.showDanmaku) {
      _addDanmaku(message.uname, message.msg);
    } else if (message is GiftMessage && _filterSettings.showGift) {
      _addInfo('${message.uname} 赠送了 ${message.giftNum} 个 ${message.giftName}');
    } else if (message is SuperChatMessage && _filterSettings.showSuperChat) {
      _addInfo('${message.uname} 发送了 ¥${message.rmb} 的SC: ${message.message}');
    } else if (message is GuardMessage && _filterSettings.showGuard) {
      _addInfo(
        '${message.uname} 开通了 ${message.guardNum}${message.guardUnit} ${message.guardLevelName}',
      );
    } else if (message is LikeMessage && _filterSettings.showLike) {
      _addInfo('${message.uname} 点赞了');
    } else if (message is EnterRoomMessage && _filterSettings.showEnter) {
      _addInfo('${message.uname} 进入了直播间');
    } else if (message is LiveStartMessage && _filterSettings.showLiveStart) {
      _addInfo('直播开始了: ${message.title}');
    } else if (message is LiveEndMessage && _filterSettings.showLiveEnd) {
      _addInfo('直播结束了');
    } else if (message is InteractionEndMessage) {
      _addInfo('消息推送已结束，请重新开启');
    }
  }

  /// 处理 WebSocket 错误
  void _handleWebSocketError(String error) {
    debugPrint('[LivePage] WebSocket 错误: $error');
    _addInfo('连接异常: $error');
  }

  /// 处理连接状态变化
  void _handleConnectionChanged(bool connected) {
    debugPrint('[LivePage] 连接状态: ${connected ? "已连接" : "已断开"}');
    if (!connected) {
      _addInfo('连接已断开，正在重连...');
    } else {
      // 首次连接
      if (_isFirstConnection) {
        _isFirstConnection = false;
        _addInfo(
          '已连接到 ${widget.startData.anchorInfo.uname} 的房间 ${widget.startData.anchorInfo.roomId}',
        );
      } else {
        // 重连成功
        _addInfo('连接已恢复');
      }
    }
  }

  @override
  void dispose() {
    _stopHeartbeat();
    _stopHideTimer();
    _exitFullScreen();
    _disableWakelock();
    _endSession();
    super.dispose();
  }

  /// 设置全屏
  void _setFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  /// 退出全屏
  void _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  /// 启用防锁屏
  void _enableWakelock() {
    WakelockPlus.enable();
  }

  /// 禁用防锁屏
  void _disableWakelock() {
    WakelockPlus.disable();
  }

  /// 开始心跳
  void _startHeartbeat() {
    // 每20秒发送一次心跳
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _sendHeartbeat(),
    );

    // 立即发送第一次心跳
    _sendHeartbeat();
  }

  /// 停止心跳
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// 发送心跳
  Future<void> _sendHeartbeat() async {
    try {
      await widget.apiClient.heartbeat(
        gameId: widget.startData.gameInfo.gameId,
      );
      debugPrint('心跳成功');
    } catch (e) {
      debugPrint('心跳失败: $e');
      _addInfo('心跳失败: $e');
    }
  }

  /// 结束会话
  Future<void> _endSession() async {
    try {
      await widget.apiClient.end(
        appId: widget.appId,
        gameId: widget.startData.gameInfo.gameId,
      );
      debugPrint('会话结束');
    } catch (e) {
      debugPrint('结束会话失败: $e');
    } finally {
      widget.apiClient.dispose();
    }
  }

  /// 启动隐藏计时器
  void _startHideTimer() {
    _stopHideTimer();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showBackButton = false;
        });
      }
    });
  }

  /// 停止隐藏计时器
  void _stopHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  /// 显示返回按钮
  void _showBack() {
    setState(() {
      _showBackButton = true;
    });
    _startHideTimer();
  }

  /// 退出
  void _exit() {
    Navigator.of(context).pop();
  }

  /// 添加弹幕
  void _addDanmaku(String username, String content) {
    _messageListKey.currentState?.addDanmaku(username, content);
  }

  /// 添加提示信息
  void _addInfo(String content) {
    _messageListKey.currentState?.addInfo(content);
  }

  /// 添加测试弹幕
  void _addTestDanmaku() {
    final usernames = ['测试用户', '观众A', '粉丝B', '路人C', '土豪D', '超长用户名测试12345'];
    final contents = ['666', '主播好厉害', '这是什么操作', '学到了', '送给主播一个火箭', '哈哈哈'];
    final username = usernames[DateTime.now().millisecond % usernames.length];
    final content = contents[DateTime.now().millisecond % contents.length];
    _addDanmaku(username, content);
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final screenSize = MediaQuery.of(context).size;

    return PopScope(
      canPop: true,
      child: GestureDetector(
        onTap: _showBack,
        onPanDown: (_) => _showBack(),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                // 主内容区域
                isPortrait
                    ? Column(
                        children: [
                          // 竖屏：消息列表在上，设置在下
                          Expanded(
                            child: MessageList(
                              key: _messageListKey,
                              displaySettings: _displaySettings,
                            ),
                          ),
                          if (_showSettings)
                            SizedBox(
                              height: screenSize.height / 2,
                              child: SettingsPanel(
                                settingsManager: _settingsManager,
                                onDisplaySettingsChanged: (settings) {
                                  setState(() {
                                    _displaySettings = settings;
                                  });
                                },
                                onFilterSettingsChanged: (settings) {
                                  setState(() {
                                    _filterSettings = settings;
                                  });
                                },
                                onClose: () {
                                  setState(() {
                                    _showSettings = false;
                                  });
                                },
                              ),
                            ),
                        ],
                      )
                    : Row(
                        children: [
                          // 横屏：消息列表在左，设置在右
                          Expanded(
                            child: MessageList(
                              key: _messageListKey,
                              displaySettings: _displaySettings,
                            ),
                          ),
                          if (_showSettings)
                            SizedBox(
                              width: screenSize.width / 2,
                              child: SettingsPanel(
                                settingsManager: _settingsManager,
                                onDisplaySettingsChanged: (settings) {
                                  setState(() {
                                    _displaySettings = settings;
                                  });
                                },
                                onFilterSettingsChanged: (settings) {
                                  setState(() {
                                    _filterSettings = settings;
                                  });
                                },
                                onClose: () {
                                  setState(() {
                                    _showSettings = false;
                                  });
                                },
                              ),
                            ),
                        ],
                      ),

                // 返回按钮、测试按钮、设置按钮
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  top: _showBackButton ? 16 : -60,
                  left: 16,
                  child: Row(
                    children: [
                      // 返回按钮
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _exit,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 设置按钮
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _showSettings = !_showSettings;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 测试按钮
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _addTestDanmaku,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '测试',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
