import 'live_message.dart';

/// 点赞消息
class LikeMessage extends LiveMessage {
  final int roomId;
  final String openId;
  final String? unionId;
  final String uname;
  final String? uface;
  final int timestamp;
  final String likeText;
  final int likeCount;
  final bool fansMedalWearingStatus;
  final String? fansMedalName;
  final int fansMedialLevel;

  LikeMessage({
    required this.roomId,
    required this.openId,
    this.unionId,
    required this.uname,
    this.uface,
    required this.timestamp,
    required this.likeText,
    required this.likeCount,
    required this.fansMedalWearingStatus,
    this.fansMedalName,
    required this.fansMedialLevel,
    required String msgId,
  }) : super(cmd: 'LIVE_OPEN_PLATFORM_LIKE', msgId: msgId);

  factory LikeMessage.fromJson(Map<String, dynamic> json) {
    return LikeMessage(
      roomId: json['room_id'] as int,
      openId: json['open_id'] as String,
      unionId: json['union_id'] as String?,
      uname: json['uname'] as String,
      uface: json['uface'] as String?,
      timestamp: json['timestamp'] as int,
      likeText: json['like_text'] as String,
      likeCount: json['like_count'] as int,
      fansMedalWearingStatus:
          json['fans_medal_wearing_status'] as bool? ?? false,
      fansMedalName: json['fans_medal_name'] as String?,
      fansMedialLevel: json['fans_medal_level'] as int? ?? 0,
      msgId: json['msg_id'] as String,
    );
  }

  @override
  String toString() {
    return '【点赞】$uname $likeText (x$likeCount)';
  }
}
