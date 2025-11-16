import 'package:bilibili_live_api/bilibili_live_api.dart';
import '../models/settings.dart';

/// WebSocket消息处理器 - 处理各种消息类型
class WebSocketMessageHandler {
  final MessageFilterSettings _filterSettings;
  final Function(String username, String content) onDanmaku;
  final Function(String content) onInfo;

  WebSocketMessageHandler({
    required MessageFilterSettings filterSettings,
    required this.onDanmaku,
    required this.onInfo,
  }) : _filterSettings = filterSettings;

  /// 处理 WebSocket 消息
  void handleMessage(dynamic message) {
    if (message is DanmakuMessage && _filterSettings.showDanmaku) {
      onDanmaku(_truncateUsername(message.uname), message.msg);
    } else if (message is GiftMessage && _filterSettings.showGift) {
      final username = _truncateUsername(message.uname);
      onInfo('$username 赠送了 ${message.giftNum} 个 ${message.giftName}');
    } else if (message is SuperChatMessage && _filterSettings.showSuperChat) {
      final username = _truncateUsername(message.uname);
      onInfo('$username 发送了 ¥${message.rmb} 的SC: ${message.message}');
    } else if (message is GuardMessage && _filterSettings.showGuard) {
      final username = _truncateUsername(message.uname);
      onInfo(
        '$username 开通了 ${message.guardNum}${message.guardUnit} ${message.guardLevelName}',
      );
    } else if (message is LikeMessage && _filterSettings.showLike) {
      final username = _truncateUsername(message.uname);
      onInfo('$username 点赞了');
    } else if (message is EnterRoomMessage && _filterSettings.showEnter) {
      final username = _truncateUsername(message.uname);
      onInfo('$username 进入了直播间');
    } else if (message is LiveStartMessage && _filterSettings.showLiveStart) {
      onInfo('直播开始了: ${message.title}');
    } else if (message is LiveEndMessage && _filterSettings.showLiveEnd) {
      onInfo('直播结束了');
    }
  }

  /// 处理弹幕消息（供外部调用，如测试弹幕）
  void handleDanmaku(String username, String content) {
    if (_filterSettings.showDanmaku) {
      onDanmaku(_truncateUsername(username), content);
    }
  }

  /// 截断用户名到最多10个字符
  String _truncateUsername(String username) {
    if (username.length <= 10) {
      return username;
    }
    return username.substring(0, 10);
  }
}
