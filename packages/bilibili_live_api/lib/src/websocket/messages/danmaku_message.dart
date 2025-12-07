import 'live_message.dart';

/// 弹幕消息
class DanmakuMessage extends LiveMessage {
  final int roomId;
  final String openId;
  final String? unionId;
  final String uname;
  final String msg;
  final int timestamp;
  final String? uface;
  final int fansMedialLevel;
  final String? fansMedalName;
  final bool fansMedalWearingStatus;
  final int guardLevel;
  final String? emojiImgUrl;
  final int dmType;
  final int? gloryLevel;
  final String? replyOpenId;
  final String? replyUname;
  final int isAdmin;

  DanmakuMessage({
    required this.roomId,
    required this.openId,
    this.unionId,
    required this.uname,
    required this.msg,
    required String msgId,
    required this.timestamp,
    this.uface,
    required this.fansMedialLevel,
    this.fansMedalName,
    required this.fansMedalWearingStatus,
    required this.guardLevel,
    this.emojiImgUrl,
    required this.dmType,
    this.gloryLevel,
    this.replyOpenId,
    this.replyUname,
    required this.isAdmin,
  }) : super(cmd: 'LIVE_OPEN_PLATFORM_DM', msgId: msgId);

  factory DanmakuMessage.fromJson(Map<String, dynamic> json) {
    return DanmakuMessage(
      roomId: json['room_id'] as int,
      openId: json['open_id'] as String,
      unionId: json['union_id'] as String?,
      uname: json['uname'] as String,
      msg: json['msg'] as String,
      msgId: json['msg_id'] as String,
      timestamp: json['timestamp'] as int,
      uface: json['uface'] as String?,
      fansMedialLevel: json['fans_medal_level'] as int? ?? 0,
      fansMedalName: json['fans_medal_name'] as String?,
      fansMedalWearingStatus:
          json['fans_medal_wearing_status'] as bool? ?? false,
      guardLevel: json['guard_level'] as int? ?? 0,
      emojiImgUrl: json['emoji_img_url'] as String?,
      dmType: json['dm_type'] as int? ?? 0,
      gloryLevel: json['glory_level'] as int?,
      replyOpenId: json['reply_open_id'] as String?,
      replyUname: json['reply_uname'] as String?,
      isAdmin: json['is_admin'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return '【弹幕】$uname: $msg${isAdmin == 1 ? " [房管]" : ""}';
  }
}
