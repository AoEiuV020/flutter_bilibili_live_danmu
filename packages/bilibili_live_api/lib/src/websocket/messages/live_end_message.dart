import 'live_message.dart';

/// 下播消息
class LiveEndMessage extends LiveMessage {
  final int roomId;
  final String openId;
  final String? unionId;
  final int timestamp;
  final String areaName;
  final String title;

  LiveEndMessage({
    required this.roomId,
    required this.openId,
    this.unionId,
    required this.timestamp,
    required this.areaName,
    required this.title,
  }) : super(cmd: 'LIVE_OPEN_PLATFORM_LIVE_END');

  factory LiveEndMessage.fromJson(Map<String, dynamic> json) {
    return LiveEndMessage(
      roomId: json['room_id'] as int,
      openId: json['open_id'] as String,
      unionId: json['union_id'] as String?,
      timestamp: json['timestamp'] as int,
      areaName: json['area_name'] as String,
      title: json['title'] as String,
    );
  }

  @override
  String toString() {
    return '【下播】直播结束了';
  }
}
