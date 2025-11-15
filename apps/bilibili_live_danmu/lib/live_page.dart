import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bilibili_live_api/bilibili_live_api.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'widgets/danmaku_list.dart';

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
  final GlobalKey<MessageListState> _messageListKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _setFullScreen();
    _enableWakelock();
    _startHeartbeat();
    _startHideTimer();

    // 添加初始提示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addInfo(
        '已连接到 ${widget.startData.anchorInfo.uname} 的房间 ${widget.startData.anchorInfo.roomId}',
      );
    });
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
                // 消息列表（弹幕+提示）
                MessageList(key: _messageListKey),

                // 返回按钮和测试按钮
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
