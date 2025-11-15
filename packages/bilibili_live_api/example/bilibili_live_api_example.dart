import 'package:bilibili_live_api/bilibili_live_api.dart';

void main() async {
  // 创建API客户端
  final client = BilibiliLiveApiClient(
    accessKeyId: 'your_access_key_id',
    accessKeySecret: 'your_access_key_secret',
    enableLogging: true,
  );

  try {
    // 1. 项目开启
    print('开启项目...');
    final startResponse = await client.start(
      code: 'your_code',
      appId: 123456789,
    );

    if (startResponse.isSuccess && startResponse.data != null) {
      print('项目开启成功!');
      final data = startResponse.data!;
      print('场次ID: ${data.gameInfo.gameId}');
      print('主播昵称: ${data.anchorInfo.uname}');
      print('房间号: ${data.anchorInfo.roomId}');

      // 2. 发送心跳
      print('\n发送心跳...');
      final heartbeatResponse = await client.heartbeat(
        gameId: data.gameInfo.gameId,
      );
      if (heartbeatResponse.isSuccess) {
        print('心跳成功!');
      }

      // 3. 批量心跳
      print('\n批量心跳...');
      final batchResponse = await client.batchHeartbeat(
        gameIds: [data.gameInfo.gameId],
      );
      if (batchResponse.isSuccess) {
        print('批量心跳成功!');
        if (batchResponse.data != null) {
          print('失败的场次: ${batchResponse.data!.failedGameIds}');
        }
      }

      // 4. 项目关闭
      print('\n关闭项目...');
      final endResponse = await client.end(
        appId: 123456789,
        gameId: data.gameInfo.gameId,
      );
      if (endResponse.isSuccess) {
        print('项目关闭成功!');
      }
    } else {
      print('项目开启失败: ${startResponse.message}');
    }
  } catch (e) {
    print('错误: $e');
  } finally {
    // 释放资源
    client.dispose();
  }
}
