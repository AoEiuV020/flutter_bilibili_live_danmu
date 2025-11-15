import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bilibili_live_api/bilibili_live_api.dart';

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
  String _status = '连接中...';
  int _heartbeatCount = 0;

  @override
  void initState() {
    super.initState();
    _setFullScreen();
    _startHeartbeat();
  }

  @override
  void dispose() {
    _stopHeartbeat();
    _exitFullScreen();
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
      final response = await widget.apiClient.heartbeat(
        gameId: widget.startData.gameInfo.gameId,
      );

      if (mounted) {
        setState(() {
          _heartbeatCount++;
          if (response.isSuccess) {
            _status = '心跳正常 ($_heartbeatCount)';
          } else {
            _status = '心跳异常: ${response.message}';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = '心跳失败: $e';
        });
      }
    }
  }

  /// 结束会话
  Future<void> _endSession() async {
    try {
      await widget.apiClient.end(
        appId: widget.appId,
        gameId: widget.startData.gameInfo.gameId,
      );
    } catch (e) {
      debugPrint('结束会话失败: $e');
    } finally {
      widget.apiClient.dispose();
    }
  }

  /// 退出
  Future<void> _exit() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出直播吗?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _exit();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // 主播信息
              Positioned(
                top: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // 主播头像
                        if (widget.startData.anchorInfo.uface.isNotEmpty)
                          ClipOval(
                            child: Image.network(
                              widget.startData.anchorInfo.uface,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey,
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(width: 12),
                        // 主播信息
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.startData.anchorInfo.uname,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '房间号: ${widget.startData.anchorInfo.roomId}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 状态信息
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            '场次ID',
                            widget.startData.gameInfo.gameId,
                          ),
                          const SizedBox(height: 4),
                          _buildInfoRow('状态', _status),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 退出按钮
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _exit,
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('退出'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
