/// 批量心跳响应数据
class BatchHeartbeatData {
  final List<String> failedGameIds;

  BatchHeartbeatData({required this.failedGameIds});

  factory BatchHeartbeatData.fromJson(Map<String, dynamic> json) {
    return BatchHeartbeatData(
      failedGameIds: (json['failed_game_ids'] as List).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'failed_game_ids': failedGameIds};
  }
}
