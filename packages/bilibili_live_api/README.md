# bilibili_live_api

**B站直播开放平台完整封装 - 轻松接入B站直播互动玩法**

[![pub package](https://img.shields.io/pub/v/bilibili_live_api.svg)](https://pub.dev/packages/bilibili_live_api)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 🎯 解决什么问题？

这个库让你能够快速接入B站直播开放平台，实现：
- **接收实时弹幕** - 弹幕消息实时推送
- **接收礼物互动** - 礼物、SC、大航海等实时通知
- **直播间状态监控** - 开播、下播、点赞、进入等事件
- **HTTP接口调用** - 项目开启/关闭、心跳保活等
- **WebSocket消息推送** - 完整的协议解析和自动重连

**一句话：让你专注于业务逻辑，而不是协议细节！**

---

## ✨ 核心功能

### 📡 HTTP 接口（完整实现）

| 接口 | 方法 | 说明 |
|------|------|------|
| `/v2/app/start` | `client.start()` | 项目开启 - 获取场次信息和WebSocket连接 |
| `/v2/app/heartbeat` | `client.heartbeat()` | 单场次心跳 - 保持项目在线（20秒/次） |
| `/v2/app/batchHeartbeat` | `client.batchHeartbeat()` | 批量心跳 - 多场次同时保活（<200条） |
| `/v2/app/end` | `client.end()` | 项目关闭 - 正常结束场次 |

### 🔌 WebSocket 实时消息（12种消息类型）

| CMD | 类型 | 说明 | 包含字段 |
|-----|------|------|----------|
| `LIVE_OPEN_PLATFORM_DM` | 弹幕消息 | 用户发送的弹幕 | `uname`, `msg`, `fansMedalName`, `fansMedalLevel` |
| `LIVE_OPEN_PLATFORM_SEND_GIFT` | 礼物消息 | 用户赠送的礼物 | `uname`, `giftName`, `giftNum`, `price`, `paid` |
| `LIVE_OPEN_PLATFORM_SUPER_CHAT` | 醒目留言 | SC（Super Chat） | `uname`, `message`, `rmb`, `startTime`, `endTime` |
| `LIVE_OPEN_PLATFORM_SUPER_CHAT_DEL` | SC删除 | SC被删除 | `messageIds` |
| `LIVE_OPEN_PLATFORM_GUARD` | 大航海 | 舰长/提督/总督 | `uname`, `guardLevel`, `guardNum`, `guardUnit`, `price` |
| `LIVE_OPEN_PLATFORM_LIKE` | 点赞 | 用户点赞直播间 | `uname`, `likeText` |
| `LIVE_OPEN_PLATFORM_ENTER_ROOM` | 进入房间 | 用户进入直播间 | `uname`, `timestamp` |
| `LIVE_OPEN_PLATFORM_LIVE` | 开播 | 主播开始直播 | `roomId`, `title`, `liveStartTime` |
| `LIVE_OPEN_PLATFORM_LIVE_OFF` | 下播 | 主播停止直播 | `roomId`, `liveCloseTime` |
| `LIVE_OPEN_PLATFORM_INTERACTION_END` | 交互结束 | 消息推送结束 | `timestamp` |
| `LIVE_OPEN_PLATFORM_GAME_START` | 游戏开始 | 场次开始 | `gameId` |
| `LIVE_OPEN_PLATFORM_GAME_END` | 游戏结束 | 场次结束 | `gameId` |

**特性：**
- ✅ 自动心跳（Protocol 2）
- ✅ 自动重连（最多5次，间隔3秒）
- ✅ 自动解压缩（zlib/brotli）
- ✅ 完整的协议编解码
- ✅ 类型安全的消息模型

---

## 🚀 快速开始

### 1. 安装依赖

```yaml
dependencies:
  bilibili_live_api: ^1.0.0
```

### 2. 创建客户端

```dart
import 'package:bilibili_live_api/bilibili_live_api.dart';

final client = BilibiliLiveApiClient(
  accessKeyId: 'your_access_key_id',      // 从B站开放平台获取
  accessKeySecret: 'your_access_key_secret',
  enableLogging: true,  // 开启日志（可选）
);
```

### 3. 开启项目并接收消息

```dart
// 1. 开启项目
final response = await client.start(
  code: 'your_auth_code',  // 用户授权码
  appId: 123456789,        // 应用ID
);

if (response.isSuccess && response.data != null) {
  final startData = response.data!;
  print('✅ 连接到房间: ${startData.anchorInfo.roomId}');
  print('👤 主播: ${startData.anchorInfo.uname}');
  
  // 2. 连接 WebSocket 接收实时消息
  await client.createWebSocket(
    startData: startData,
    onMessage: (message) {
      if (message is DanmakuMessage) {
        print('💬 ${message.uname}: ${message.msg}');
      } else if (message is GiftMessage) {
        print('🎁 ${message.uname} 送了 ${message.giftNum} 个 ${message.giftName}');
      } else if (message is SuperChatMessage) {
        print('⭐ ${message.uname} SC: ${message.message} (¥${message.rmb})');
      } else if (message is GuardMessage) {
        print('🚢 ${message.uname} 开通了 ${message.guardLevelName}');
      }
    },
    onError: (error) => print('❌ 错误: $error'),
    onConnectionChanged: (connected) {
      print(connected ? '🔗 已连接' : '🔌 已断开');
    },
  );
  
  // 3. 定时发送心跳（每20秒）
  Timer.periodic(Duration(seconds: 20), (_) async {
    await client.heartbeat(gameId: startData.gameInfo.gameId);
  });
}
```

### 4. 结束项目

```dart
await client.end(
  appId: appId,
  gameId: startData.gameInfo.gameId,
);
client.dispose();  // 释放资源
```

---

## 📚 完整示例

查看 [example/bilibili_live_api_example.dart](example/bilibili_live_api_example.dart) 获取完整代码示例。

---

## 🏗️ 架构设计

```
┌─────────────────────────────────────────────────────────┐
│                  BilibiliLiveApiClient                  │
│  ┌──────────────────┐      ┌──────────────────────┐   │
│  │  HTTP Client     │      │  WebSocket Manager   │   │
│  │  - start()       │      │  - Protocol Codec    │   │
│  │  - heartbeat()   │      │  - Auto Reconnect    │   │
│  │  - end()         │      │  - Message Parser    │   │
│  └──────────────────┘      └──────────────────────┘   │
└─────────────────────────────────────────────────────────┘
         │                              │
         ↓                              ↓
  ┌──────────────┐            ┌──────────────────┐
  │  HTTP APIs   │            │  WebSocket       │
  │  - 签名验证   │            │  - 12种消息类型   │
  │  - 自动重试   │            │  - 自动心跳       │
  │  - 日志记录   │            │  - 连接管理       │
  └──────────────┘            └──────────────────┘
```

---

## ⚙️ 高级功能

### WebSocket 三层架构

```dart
// 第一层：Protocol - 协议编解码
ProtoPacket.encode(operation, body)   // 编码
ProtoPacket.decode(buffer)            // 解码

// 第二层：Client - 连接管理
BilibiliWebSocketClient(
  url: 'wss://...',
  authBody: authBody,
  onMessage: (msg) {},
)

// 第三层：Manager - 自动重连
BilibiliLiveWebSocket(
  url: 'wss://...',
  authBody: authBody,
  maxReconnectAttempts: 5,    // 最多重连5次
  reconnectInterval: 3,        // 间隔3秒
)
```

### 批量心跳

```dart
await client.batchHeartbeat(
  gameIds: [gameId1, gameId2, gameId3],  // 最多200条
);
```

### 自定义 POST 请求

```dart
final response = await client.post(
  path: '/custom/endpoint',
  body: {'custom': 'data'},
);
```

---

## 📝 注意事项

| 规则 | 说明 |
|------|------|
| ⏱️ 心跳间隔 | 互动玩法：20秒/次（超60秒自动关闭）<br>插件工具：60秒/次（超180秒自动关闭） |
| 📊 批量限制 | 单次批量心跳最多 200 条 `game_id` |
| 🔗 连接管理 | WebSocket 自动重连最多 5 次，间隔 3 秒 |
| 🔐 签名机制 | HMAC-SHA256 + MD5，自动处理 |
| 🌐 Base URL | 固定：`https://live-open.biliapi.com` |

---

## 🔗 相关链接

- **官方文档**: [B站开放平台文档](https://open-live.bilibili.com/document/)
- **项目地址**: [GitHub Repository](https://github.com/AoEiuV020/flutter_bilibili_live_danmu)
- **示例应用**: [apps/bilibili_live_danmu](https://github.com/AoEiuV020/flutter_bilibili_live_danmu/tree/main/apps/bilibili_live_danmu)

---

## 📄 License

MIT License - 详见 [LICENSE](LICENSE) 文件
