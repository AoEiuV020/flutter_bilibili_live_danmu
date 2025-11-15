import 'live_message.dart';

/// 进入房间消息
class EnterRoomMessage extends LiveMessage {
  final int roomId;
  final String openId;
  final String? unionId;
  final String uname;
  final String? uface;
  final int timestamp;

  EnterRoomMessage({
    required this.roomId,
    required this.openId,
    this.unionId,
    required this.uname,
    this.uface,
    required this.timestamp,
  }) : super(cmd: 'LIVE_OPEN_PLATFORM_LIVE_ROOM_ENTER');

  factory EnterRoomMessage.fromJson(Map<String, dynamic> json) {
    return EnterRoomMessage(
      roomId: json['room_id'] as int,
      openId: json['open_id'] as String,
      unionId: json['union_id'] as String?,
      uname: json['uname'] as String,
      uface: json['uface'] as String?,
      timestamp: json['timestamp'] as int,
    );
  }

  @override
  String toString() {
    return '【进入】$uname 进入了直播间';
  }
}
