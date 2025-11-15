/// 主播信息
class AnchorInfo {
  final int roomId;
  final String uname;
  final String uface;
  final int uid;
  final String openId;
  final String unionId;

  AnchorInfo({
    required this.roomId,
    required this.uname,
    required this.uface,
    required this.uid,
    required this.openId,
    required this.unionId,
  });

  factory AnchorInfo.fromJson(Map<String, dynamic> json) {
    return AnchorInfo(
      roomId: json['room_id'] as int,
      uname: json['uname'] as String,
      uface: json['uface'] as String,
      uid: json['uid'] as int,
      openId: json['open_id'] as String,
      unionId: json['union_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'uname': uname,
      'uface': uface,
      'uid': uid,
      'open_id': openId,
      'union_id': unionId,
    };
  }
}
