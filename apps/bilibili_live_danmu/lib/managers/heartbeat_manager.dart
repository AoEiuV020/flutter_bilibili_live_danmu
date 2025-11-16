import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:bilibili_live_api/bilibili_live_api.dart';

/// 心跳管理器 - 管理心跳定时器和发送
class HeartbeatManager {
  final BilibiliLiveApiClient _apiClient;
  final String _gameId;
  Timer? _heartbeatTimer;

  HeartbeatManager({
    required BilibiliLiveApiClient apiClient,
    required String gameId,
  }) : _apiClient = apiClient,
       _gameId = gameId;

  /// 开始心跳（每20秒一次）
  void start() {
    // 每20秒发送一次心跳
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _sendHeartbeat(),
    );

    // 立即发送第一次心跳
    _sendHeartbeat();
  }

  /// 停止心跳
  void stop() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// 发送心跳
  Future<void> _sendHeartbeat() async {
    try {
      await _apiClient.heartbeat(gameId: _gameId);
      debugPrint('[HeartbeatManager] 心跳成功');
    } catch (e) {
      debugPrint('[HeartbeatManager] 心跳失败: $e');
    }
  }

  /// 释放资源
  void dispose() {
    stop();
  }
}
