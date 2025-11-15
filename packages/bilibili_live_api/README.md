# bilibili_live_api

哔哩哔哩直播开放平台 API 客户端库

## 功能特性

- ✅ 完整的鉴权签名机制（HMAC-SHA256）
- ✅ 自动请求头配置
- ✅ 详细的日志输出
- ✅ 完善的异常处理
- ✅ 项目开启/关闭
- ✅ 单个/批量心跳
- ✅ 支持任意 POST 请求

## 使用示例

### 1. 创建客户端

```dart
import 'package:bilibili_live_api/bilibili_live_api.dart';

final client = BilibiliLiveApiClient(
  accessKeyId: 'your_access_key_id',
  accessKeySecret: 'your_access_key_secret',
  enableLogging: true,
);
```

### 2. 项目开启

```dart
final response = await client.start(
  code: 'your_code',
  appId: 123456789,
);

if (response.isSuccess && response.data != null) {
  print('场次ID: ${response.data!.gameInfo.gameId}');
  print('主播昵称: ${response.data!.anchorInfo.uname}');
}
```

### 3. 发送心跳（推荐每 20 秒调用一次）

```dart
final heartbeatResponse = await client.heartbeat(gameId: gameId);
```

### 4. 项目关闭

```dart
final endResponse = await client.end(appId: appId, gameId: gameId);
```

更多示例请查看 `/example` 文件夹。

## 注意事项

1. 互动玩法超过 60 秒未收到心跳会自动关闭
2. 互动插件和工具超过 180 秒未收到心跳会自动关闭
3. 批量心跳单次请求 game_id 数量要小于 200 条
4. Base URL 固定为：`https://live-open.biliapi.com`
