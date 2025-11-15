/// 批量心跳响应数据
class BatchHeartbeatData {
  final List<String> failedGameIds;

  BatchHeartbeatData({required this.failedGameIds});

  factory BatchHeartbeatData.fromJson(Map<String, dynamic> json) {
    // 处理 null 值情况，默认返回空列表
    final gameIds = json['failed_game_ids'];
    return BatchHeartbeatData(
      failedGameIds: gameIds != null ? (gameIds as List).cast<String>() : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'failed_game_ids': failedGameIds};
  }
}
