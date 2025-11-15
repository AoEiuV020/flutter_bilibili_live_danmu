/// 项目开启响应模型
class AppStartResponse {
  final int code;
  final String message;
  final AppStartData? data;

  AppStartResponse({required this.code, required this.message, this.data});

  factory AppStartResponse.fromJson(Map<String, dynamic> json) {
    return AppStartResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'] != null
          ? AppStartData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      if (data != null) 'data': data!.toJson(),
    };
  }

  bool get isSuccess => code == 0;
}

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

/// 长连信息
class WebsocketInfo {
  final String authBody;
  final List<String> wssLink;

  WebsocketInfo({required this.authBody, required this.wssLink});

  factory WebsocketInfo.fromJson(Map<String, dynamic> json) {
    return WebsocketInfo(
      authBody: json['auth_body'] as String,
      wssLink: (json['wss_link'] as List).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'auth_body': authBody, 'wss_link': wssLink};
  }
}

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
