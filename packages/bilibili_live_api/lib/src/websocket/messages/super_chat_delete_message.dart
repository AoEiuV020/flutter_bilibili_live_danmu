import 'live_message.dart';

/// SC 删除消息
class SuperChatDeleteMessage extends LiveMessage {
  final int roomId;
  final List<int> messageIds;
  final String msgId;

  SuperChatDeleteMessage({
    required this.roomId,
    required this.messageIds,
    required this.msgId,
  }) : super(cmd: 'LIVE_OPEN_PLATFORM_SUPER_CHAT_DEL', msgId: msgId);

  factory SuperChatDeleteMessage.fromJson(Map<String, dynamic> json) {
    return SuperChatDeleteMessage(
      roomId: json['room_id'] as int,
      messageIds: (json['message_ids'] as List).cast<int>(),
      msgId: json['msg_id'] as String,
    );
  }

  @override
  String toString() {
    return '【SC删除】删除了 ${messageIds.length} 条留言';
  }
}
