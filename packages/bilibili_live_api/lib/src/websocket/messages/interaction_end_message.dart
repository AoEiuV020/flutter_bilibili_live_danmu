import 'live_message.dart';

/// 交互结束消息
class InteractionEndMessage extends LiveMessage {
  final String gameId;
  final int timestamp;

  InteractionEndMessage({required this.gameId, required this.timestamp})
    : super(cmd: 'LIVE_OPEN_PLATFORM_INTERACTION_END');

  factory InteractionEndMessage.fromJson(Map<String, dynamic> json) {
    return InteractionEndMessage(
      gameId: json['game_id'] as String,
      timestamp: json['timestamp'] as int,
    );
  }

  @override
  String toString() {
    return '【结束】消息推送已结束 (game_id: $gameId)';
  }
}
