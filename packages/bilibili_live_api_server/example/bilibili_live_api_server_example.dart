import 'dart:async';

import 'package:bilibili_live_api_server/bilibili_live_api_server.dart';

void main() async {
  // 创建配置
  final config = ServerConfig(
    accessKeyId: 'your_access_key_id',
    accessKeySecret: 'your_access_key_secret',
    code: 'your_code', // 可选
    appId: 12345, // 可选
  );

  // 创建服务器
  final server = BilibiliLiveApiServer(config: config);

  // 启动服务器
  await server.start(port: 8080, address: 'localhost');

  print('服务器已启动，访问 http://localhost:8080/health 检查状态');

  // 按需停止服务器
  Timer(Duration(seconds: 3), () async {
    await server.stop(); // 关闭监听套接字
    print('服务器已关闭，程序即将退出');
  });
}
