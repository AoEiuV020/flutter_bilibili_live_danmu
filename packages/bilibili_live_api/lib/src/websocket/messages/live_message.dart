import 'danmaku_message.dart';
import 'gift_message.dart';
import 'super_chat_message.dart';
import 'super_chat_delete_message.dart';
import 'guard_message.dart';
import 'like_message.dart';
import 'enter_room_message.dart';
import 'live_start_message.dart';
import 'live_end_message.dart';
import 'interaction_end_message.dart';
import 'unknown_message.dart';

/// WebSocket 消息基类
abstract class LiveMessage {
  final String cmd;
  final String? msgId;

  LiveMessage({required this.cmd, this.msgId});

  factory LiveMessage.fromJson(Map<String, dynamic> json) {
    final cmd = json['cmd'] as String;
    final data = json['data'] as Map<String, dynamic>;

    switch (cmd) {
      case 'LIVE_OPEN_PLATFORM_DM':
        return DanmakuMessage.fromJson(data);
      case 'LIVE_OPEN_PLATFORM_SEND_GIFT':
        return GiftMessage.fromJson(data);
      case 'LIVE_OPEN_PLATFORM_SUPER_CHAT':
        return SuperChatMessage.fromJson(data);
      case 'LIVE_OPEN_PLATFORM_SUPER_CHAT_DEL':
        return SuperChatDeleteMessage.fromJson(data);
      case 'LIVE_OPEN_PLATFORM_GUARD':
        return GuardMessage.fromJson(data);
      case 'LIVE_OPEN_PLATFORM_LIKE':
        return LikeMessage.fromJson(data);
      case 'LIVE_OPEN_PLATFORM_LIVE_ROOM_ENTER':
        return EnterRoomMessage.fromJson(data);
      case 'LIVE_OPEN_PLATFORM_LIVE_START':
        return LiveStartMessage.fromJson(data);
      case 'LIVE_OPEN_PLATFORM_LIVE_END':
        return LiveEndMessage.fromJson(data);
      case 'LIVE_OPEN_PLATFORM_INTERACTION_END':
        return InteractionEndMessage.fromJson(data);
      default:
        return UnknownMessage(cmd: cmd, data: data);
    }
  }
}
