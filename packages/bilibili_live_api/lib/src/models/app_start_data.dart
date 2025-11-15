import 'game_info.dart';
import 'websocket_info.dart';
import 'anchor_info.dart';

/// 项目开启数据
class AppStartData {
  final GameInfo gameInfo;
  final WebsocketInfo websocketInfo;
  final AnchorInfo anchorInfo;

  AppStartData({
    required this.gameInfo,
    required this.websocketInfo,
    required this.anchorInfo,
  });

  factory AppStartData.fromJson(Map<String, dynamic> json) {
    return AppStartData(
      gameInfo: GameInfo.fromJson(json['game_info'] as Map<String, dynamic>),
      websocketInfo: WebsocketInfo.fromJson(
        json['websocket_info'] as Map<String, dynamic>,
      ),
      anchorInfo: AnchorInfo.fromJson(
        json['anchor_info'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'game_info': gameInfo.toJson(),
      'websocket_info': websocketInfo.toJson(),
      'anchor_info': anchorInfo.toJson(),
    };
  }
}
