# bilibili_live_api_server

**B站直播开放平台 HTTP 代理服务器 - 跨语言、跨平台调用直播 API**

[![pub package](https://img.shields.io/pub/v/bilibili_live_api_server.svg)](https://pub.dev/packages/bilibili_live_api_server)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 🎯 解决什么问题？

这个包提供了一个 HTTP 代理服务器，让你能够：
- **跨语言调用** - 任何语言都可以通过 HTTP 请求调用 B站直播 API
- **去除认证依赖** - 服务器端负责认证，前端/移动端无需存储密钥
- **支持 CORS** - 原生支持跨域请求，便于浏览器端使用
- **简化集成** - 统一的 HTTP 接口，避免每种语言都需要独立的 SDK

**一句话：让任何客户端都能安全地调用 B站直播 API！**

---

## ✨ 核心功能

### 📡 代理的 HTTP 接口

| 接口 | 说明 | 请求方式 |
|------|------|----------|
| `/v2/app/start` | 项目开启 - 获取场次信息和WebSocket连接 | POST |
| `/v2/app/heartbeat` | 单场次心跳 - 保持项目在线 | POST |
| `/v2/app/batchHeartbeat` | 批量心跳 - 多场次同时保活 | POST |
| `/v2/app/end` | 项目关闭 - 正常结束场次 | POST |
| `/api/<path>` | 通用 POST 接口 - 转发任意请求 | POST |
| `/health` | 健康检查 | GET |

### 🔌 特性

- ✅ **CORS 支持** - 允许任意来源的跨域请求
- ✅ **参数灵活** - 支持从配置或请求体中读取认证参数
- ✅ **代理模式** - 支持转发到自定义后端服务
- ✅ **日志记录** - 可选的请求/响应日志
- ✅ **错误处理** - 统一的错误响应格式

---

## 🚀 快速开始

### 1. 安装依赖

```yaml
dependencies:
  bilibili_live_api_server: ^1.0.0
```

### 2. 创建并启动服务器

```dart
import 'package:bilibili_live_api_server/bilibili_live_api_server.dart';

void main() async {
  // 创建配置 - 使用 B站开放平台的认证信息
  final config = ServerConfig(
    accessKeyId: 'your_access_key_id',
    accessKeySecret: 'your_access_key_secret',
    code: 'your_code',  // 可选，可在请求时覆盖
    appId: 123456789,   // 可选，可在请求时覆盖
    enableLogging: true, // 启用日志
  );

  // 创建服务器
  final server = BilibiliLiveApiServer(config: config);

  // 启动服务器（默认监听 localhost:8080）
  await server.start(port: 8080, address: '0.0.0.0');

  print('✅ 服务器已启动: http://0.0.0.0:8080');
  print('📍 健康检查: GET http://0.0.0.0:8080/health');
}
```

### 3. 通过 HTTP 调用 API

#### 项目开启 (POST /v2/app/start)

```bash
curl -X POST http://localhost:8080/v2/app/start \
  -H "Content-Type: application/json" \
  -d '{
    "code": "your_auth_code",
    "app_id": 123456789
  }'
```

**响应示例：**
```json
{
  "code": 0,
  "data": {
    "game_id": "xxx",
    "anchor_info": {
      "room_id": 12345,
      "uname": "主播昵称",
      "uface": "https://..."
    },
    "websocket_info": {
      "auth_body": "...",
      "wss_link": ["wss://frge.livepush.myqcloud.com/..."]
    }
  }
}
```

#### 项目心跳 (POST /v2/app/heartbeat)

```bash
curl -X POST http://localhost:8080/v2/app/heartbeat \
  -H "Content-Type: application/json" \
  -d '{
    "game_id": "xxx"
  }'
```

#### 项目批量心跳 (POST /v2/app/batchHeartbeat)

```bash
curl -X POST http://localhost:8080/v2/app/batchHeartbeat \
  -H "Content-Type: application/json" \
  -d '{
    "game_ids": ["game_id_1", "game_id_2", "game_id_3"]
  }'
```

#### 项目关闭 (POST /v2/app/end)

```bash
curl -X POST http://localhost:8080/v2/app/end \
  -H "Content-Type: application/json" \
  -d '{
    "app_id": 123456789,
    "game_id": "xxx"
  }'
```

---

## 🔌 WebSocket 连接

服务器返回的 `websocket_info` 包含连接 WebSocket 所需的信息。使用 `bilibili_live_api` 包中的 `createWebSocket()` 方法连接：

```dart
// 从 /v2/app/start 获取的 startData
final wsClient = await apiClient.createWebSocket(
  startData: startData,
  onMessage: (message) {
    if (message is DanmakuMessage) {
      print('💬 ${message.uname}: ${message.msg}');
    } else if (message is GiftMessage) {
      print('🎁 ${message.uname} 送了 ${message.giftNum} 个 ${message.giftName}');
    }
  },
);
```

---

## 🔒 安全性考虑

### 认证信息保护

- **服务器端存储** - 将 `accessKeyId` 和 `accessKeySecret` 存储在服务器，**不要**泄露给客户端
- **参数校验** - 可在服务器配置中设置 `code` 和 `appId`，防止客户端随意修改
- **请求验证** - 可扩展服务器添加额外的身份验证逻辑（如 Token、签名等）

### CORS 跨域

默认允许所有跨域请求。生产环境建议：

```dart
// 修改 _corsMiddleware() 方法以限制来源
'Access-Control-Allow-Origin': 'https://yourdomain.com',
```

---

## 🌐 代理模式

如果有现有的后端服务，可以配置服务器转发到自定义后端：

```dart
final config = ServerConfig(
  backendUrl: 'http://your-backend:8080',  // 转发地址
  enableLogging: true,
);
```

此时 `accessKeyId` 和 `accessKeySecret` 将被忽略。

---

## 📚 相关资源

- [bilibili_live_api](https://pub.dev/packages/bilibili_live_api) - 核心 API 库
- [B站直播开放平台](https://open-live.bilibili.com/) - 官方文档
- [Shelf 框架](https://pub.dev/packages/shelf) - HTTP 服务框架

---

## 📝 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件
