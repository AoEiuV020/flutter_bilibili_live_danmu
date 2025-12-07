import 'live_message.dart';

/// 醒目留言(SC)消息
class SuperChatMessage extends LiveMessage {
  final int roomId;
  final String openId;
  final String? unionId;
  final String uname;
  final String? uface;
  final int messageId;
  final String message;
  final int rmb;
  final int timestamp;
  final int startTime;
  final int endTime;
  final int guardLevel;
  final int fansMedialLevel;
  final String? fansMedalName;
  final bool fansMedalWearingStatus;

  SuperChatMessage({
    required this.roomId,
    required this.openId,
    this.unionId,
    required this.uname,
    this.uface,
    required this.messageId,
    required this.message,
    required String msgId,
    required this.rmb,
    required this.timestamp,
    required this.startTime,
    required this.endTime,
    required this.guardLevel,
    required this.fansMedialLevel,
    this.fansMedalName,
    required this.fansMedalWearingStatus,
  }) : super(cmd: 'LIVE_OPEN_PLATFORM_SUPER_CHAT', msgId: msgId);

  factory SuperChatMessage.fromJson(Map<String, dynamic> json) {
    return SuperChatMessage(
      roomId: json['room_id'] as int,
      openId: json['open_id'] as String,
      unionId: json['union_id'] as String?,
      uname: json['uname'] as String,
      uface: json['uface'] as String?,
      messageId: json['message_id'] as int,
      message: json['message'] as String,
      msgId: json['msg_id'] as String,
      rmb: json['rmb'] as int,
      timestamp: json['timestamp'] as int,
      startTime: json['start_time'] as int,
      endTime: json['end_time'] as int,
      guardLevel: json['guard_level'] as int? ?? 0,
      fansMedialLevel: json['fans_medal_level'] as int? ?? 0,
      fansMedalName: json['fans_medal_name'] as String?,
      fansMedalWearingStatus:
          json['fans_medal_wearing_status'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return '【SC ¥$rmb】$uname: $message';
  }
}
