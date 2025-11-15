import 'package:bilibili_live_api/bilibili_live_api.dart';

void main() async {
  // 创建API客户端
  final client = BilibiliLiveApiClient(
    accessKeyId: 'your_access_key_id',
    accessKeySecret: 'your_access_key_secret',
    enableLogging: true,
  );

  try {
    // 1. 项目开启（自动处理错误，code != 0 会抛出异常）
    print('开启项目...');
    final data = await client.start(code: 'your_code', appId: 123456789);

    print('项目开启成功!');
    print('场次ID: ${data.gameInfo.gameId}');
    print('主播昵称: ${data.anchorInfo.uname}');
    print('房间号: ${data.anchorInfo.roomId}');

    // 2. 发送心跳
    print('\n发送心跳...');
    await client.heartbeat(gameId: data.gameInfo.gameId);
    print('心跳成功!');

    // 3. 批量心跳
    print('\n批量心跳...');
    final batchResult = await client.batchHeartbeat(
      gameIds: [data.gameInfo.gameId],
    );
    print('批量心跳成功!');
    print('失败的场次: ${batchResult.failedGameIds}');

    // 4. 项目关闭
    print('\n关闭项目...');
    await client.end(appId: 123456789, gameId: data.gameInfo.gameId);
    print('项目关闭成功!');
  } on BilibiliApiException catch (e) {
    print('API错误: $e');
  } catch (e) {
    print('错误: $e');
  } finally {
    // 释放资源
    client.dispose();
  }
}
