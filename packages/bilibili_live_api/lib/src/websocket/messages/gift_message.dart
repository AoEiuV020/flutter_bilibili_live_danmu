import 'live_message.dart';

/// 礼物消息
class GiftMessage extends LiveMessage {
  final int roomId;
  final String openId;
  final String? unionId;
  final String uname;
  final String? uface;
  final int giftId;
  final String giftName;
  final int giftNum;
  final int price;
  final bool paid;
  final int fansMedialLevel;
  final String? fansMedalName;
  final bool fansMedalWearingStatus;
  final int guardLevel;
  final int timestamp;
  @override
  final String msgId;
  final String? giftIcon;

  GiftMessage({
    required this.roomId,
    required this.openId,
    this.unionId,
    required this.uname,
    this.uface,
    required this.giftId,
    required this.giftName,
    required this.giftNum,
    required this.price,
    required this.paid,
    required this.fansMedialLevel,
    this.fansMedalName,
    required this.fansMedalWearingStatus,
    required this.guardLevel,
    required this.timestamp,
    required this.msgId,
    this.giftIcon,
  }) : super(cmd: 'LIVE_OPEN_PLATFORM_SEND_GIFT', msgId: msgId);

  factory GiftMessage.fromJson(Map<String, dynamic> json) {
    return GiftMessage(
      roomId: json['room_id'] as int,
      openId: json['open_id'] as String,
      unionId: json['union_id'] as String?,
      uname: json['uname'] as String,
      uface: json['uface'] as String?,
      giftId: json['gift_id'] as int,
      giftName: json['gift_name'] as String,
      giftNum: json['gift_num'] as int,
      price: json['price'] as int,
      paid: json['paid'] as bool,
      fansMedialLevel: json['fans_medal_level'] as int? ?? 0,
      fansMedalName: json['fans_medal_name'] as String?,
      fansMedalWearingStatus:
          json['fans_medal_wearing_status'] as bool? ?? false,
      guardLevel: json['guard_level'] as int? ?? 0,
      timestamp: json['timestamp'] as int,
      msgId: json['msg_id'] as String,
      giftIcon: json['gift_icon'] as String?,
    );
  }

  @override
  String toString() {
    return '【礼物】$uname 赠送了 $giftNum 个 $giftName';
  }
}
