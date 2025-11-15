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
