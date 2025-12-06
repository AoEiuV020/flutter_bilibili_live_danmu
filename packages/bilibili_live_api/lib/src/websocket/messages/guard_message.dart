import 'live_message.dart';

/// 大航海消息
class GuardMessage extends LiveMessage {
  final int roomId;
  final String openId;
  final String? unionId;
  final String uname;
  final String? uface;
  final int guardLevel;
  final int guardNum;
  final String guardUnit;
  final int price;
  final int fansMedialLevel;
  final String? fansMedalName;
  final bool fansMedalWearingStatus;
  @override
  final String msgId;
  final int timestamp;

  GuardMessage({
    required this.roomId,
    required this.openId,
    this.unionId,
    required this.uname,
    this.uface,
    required this.guardLevel,
    required this.guardNum,
    required this.guardUnit,
    required this.price,
    required this.fansMedialLevel,
    this.fansMedalName,
    required this.fansMedalWearingStatus,
    required this.msgId,
    required this.timestamp,
  }) : super(cmd: 'LIVE_OPEN_PLATFORM_GUARD', msgId: msgId);

  factory GuardMessage.fromJson(Map<String, dynamic> json) {
    final userInfo = json['user_info'] as Map<String, dynamic>;
    return GuardMessage(
      roomId: json['room_id'] as int,
      openId: userInfo['open_id'] as String,
      unionId: userInfo['union_id'] as String?,
      uname: userInfo['uname'] as String,
      uface: userInfo['uface'] as String?,
      guardLevel: json['guard_level'] as int,
      guardNum: json['guard_num'] as int,
      guardUnit: json['guard_unit'] as String,
      price: json['price'] as int,
      fansMedialLevel: json['fans_medal_level'] as int? ?? 0,
      fansMedalName: json['fans_medal_name'] as String?,
      fansMedalWearingStatus:
          json['fans_medal_wearing_status'] as bool? ?? false,
      msgId: json['msg_id'] as String,
      timestamp: json['timestamp'] as int,
    );
  }

  String get guardLevelName {
    switch (guardLevel) {
      case 1:
        return '总督';
      case 2:
        return '提督';
      case 3:
        return '舰长';
      default:
        return '未知';
    }
  }

  @override
  String toString() {
    return '【上舰】$uname 开通了 $guardNum$guardUnit $guardLevelName';
  }
}
