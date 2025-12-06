import 'package:bilibili_live_api/bilibili_live_api.dart';
import 'package:bilibili_live_api/src/logger.dart';
import 'example_config.dart';

void main() async {
  // 创建API客户端
  final client = BilibiliLiveApiClient(
    accessKeyId: ExampleConfig.accessKeyId,
    accessKeySecret: ExampleConfig.accessKeySecret,
    enableLogging: true,
  );

  try {
    // 1. 项目开启（自动处理错误，code != 0 会抛出异常）
    logger.i('开启项目...');
    final data = await client.start(
      code: ExampleConfig.code,
      appId: ExampleConfig.appId,
    );

    logger.i('项目开启成功!');
    logger.i('场次ID: ${data.gameInfo.gameId}');
    logger.i('主播昵称: ${data.anchorInfo.uname}');
    logger.i('房间号: ${data.anchorInfo.roomId}');

    // 2. 发送心跳
    logger.i('\n发送心跳...');
    await client.heartbeat(gameId: data.gameInfo.gameId);
    logger.i('心跳成功!');

    // 3. 批量心跳
    logger.i('\n批量心跳...');
    final batchResult = await client.batchHeartbeat(
      gameIds: [data.gameInfo.gameId],
    );
    logger.i('批量心跳成功!');
    logger.i('失败的场次: ${batchResult.failedGameIds}');

    // 4. 项目关闭
    logger.i('\n关闭项目...');
    await client.end(appId: ExampleConfig.appId, gameId: data.gameInfo.gameId);
    logger.i('项目关闭true!');
  } on BilibiliApiException catch (e) {
    logger.e('API错误: $e');
  } catch (e) {
    logger.e('错误: $e');
  } finally {
    // 释放资源
    client.dispose();
  }
}
