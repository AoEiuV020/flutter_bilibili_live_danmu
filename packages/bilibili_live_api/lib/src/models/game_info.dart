/// 场次信息
class GameInfo {
  final String gameId;

  GameInfo({required this.gameId});

  factory GameInfo.fromJson(Map<String, dynamic> json) {
    return GameInfo(gameId: json['game_id'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'game_id': gameId};
  }
}
