# Flutter Bilibili Live Danmu 项目

哔哩哔哩直播弹幕应用 - 基于 B站直播开放平台 API

## 项目结构

```
flutter_bilibili_live_danmu/
├── apps/
│   └── bilibili_live_danmu/        # 主应用
│       ├── lib/
│       │   ├── main.dart           # 应用入口
│       │   ├── home_page.dart      # 首页（配置页面）
│       │   └── live_page.dart      # 直播页面
│       └── assets/
│           └── config.properties   # 配置文件
│
├── packages/
│   └── bilibili_live_api/          # B站直播 API 封装
│       ├── lib/
│       │   ├── src/
│       │   │   ├── bilibili_live_api_client.dart  # API 客户端
│       │   │   ├── interceptors/   # 拦截器
│       │   │   │   ├── logger_interceptor.dart
│       │   │   │   └── signature_interceptor.dart
│       │   │   ├── models/         # 数据模型
│       │   │   │   ├── app_start_response.dart
│       │   │   │   └── base_response.dart
│       │   │   └── utils/          # 工具类
│       │   │       └── signature_util.dart
│       │   └── bilibili_live_api.dart
│       └── example/
│           └── bilibili_live_api_example.dart
│
└── js/                             # 参考实现（TypeScript）
    ├── routes/getAuth.ts
    ├── tool/index.ts
    └── interceptor.ts
```

## 功能特性

### bilibili_live_api 包

- ✅ **完整的鉴权签名机制**
  - HMAC-SHA256 签名
  - 自动生成 nonce 和 timestamp
  - MD5 内容摘要

- ✅ **自动请求头配置**
  - x-bili-accesskeyid
  - x-bili-content-md5
  - x-bili-signature-method
  - x-bili-signature-nonce
  - x-bili-signature-version
  - x-bili-timestamp
  - Authorization

- ✅ **详细的日志输出**
  - 请求日志
  - 响应日志
  - 错误日志

- ✅ **完善的异常处理**
  - 连接超时
  - 请求超时
  - 网络错误
  - 响应错误

- ✅ **封装的 API 方法**
  - `start()` - 项目开启
  - `end()` - 项目关闭
  - `heartbeat()` - 项目心跳
  - `batchHeartbeat()` - 批量心跳
  - `post()` - 通用 POST 请求

### bilibili_live_danmu 应用

- ✅ **配置管理**
  - App ID
  - Access Key ID
  - Access Key Secret
  - 身份码（Code）

- ✅ **自动保存和加载配置**
  - 从 assets 加载默认配置
  - 使用 SharedPreferences 保存用户配置

- ✅ **直播功能**
  - 项目开启/关闭
  - 自动心跳（每 20 秒）
  - 全屏直播界面
  - 显示主播信息
  - 实时状态显示

## 快速开始

### 1. 安装依赖

```bash
cd /Users/aoeiuv/git/flutter_bilibili_live_danmu
flutter pub get
```

### 2. 配置默认值（可选）

编辑 `apps/bilibili_live_danmu/assets/config.properties`：

```properties
app_id=your_app_id
access_key_id=your_access_key_id
access_key_secret=your_access_key_secret
code=your_code
```

### 3. 运行应用

```bash
cd apps/bilibili_live_danmu
flutter run
```

## API 使用示例

### 基础使用

```dart
import 'package:bilibili_live_api/bilibili_live_api.dart';

// 创建客户端
final client = BilibiliLiveApiClient(
  accessKeyId: 'your_access_key_id',
  accessKeySecret: 'your_access_key_secret',
  enableLogging: true,
);

// 项目开启
final response = await client.start(
  code: 'your_code',
  appId: 123456789,
);

if (response.isSuccess && response.data != null) {
  final gameId = response.data!.gameInfo.gameId;
  
  // 发送心跳
  await client.heartbeat(gameId: gameId);
  
  // 项目关闭
  await client.end(appId: 123456789, gameId: gameId);
}

// 释放资源
client.dispose();
```

## 技术栈

- **Flutter** - 跨平台 UI 框架
- **Dio** - HTTP 客户端
- **crypto** - 加密库（MD5, HMAC-SHA256）
- **logger** - 日志库
- **shared_preferences** - 本地存储

## API 文档

### Base URL

```
https://live-open.biliapi.com
```

### 接口列表

| 接口 | 路径 | 方法 | 说明 |
|------|------|------|------|
| 项目开启 | `/v2/app/start` | POST | 开启项目，返回场次信息 |
| 项目关闭 | `/v2/app/end` | POST | 关闭项目 |
| 项目心跳 | `/v2/app/heartbeat` | POST | 发送心跳（推荐 20 秒） |
| 批量心跳 | `/v2/app/batchHeartbeat` | POST | 批量发送心跳（最多 200 个） |

## 注意事项

1. **心跳时间**
   - 互动玩法：超过 60 秒未收到心跳会自动关闭
   - 互动插件/工具：超过 180 秒未收到心跳会自动关闭
   - 推荐每 20 秒发送一次心跳

2. **并发限制**
   - 互动玩法：一个直播间只能同时启动一个
   - 互动插件：一个直播间可启动多个，单个插件最多 5 个连接

3. **批量心跳**
   - 单次请求 game_id 数量要小于 200 条

4. **项目关闭**
   - 必须主动调用 end 接口关闭项目
   - 关闭后才能进行下一场次互动

## 开发指南

### 添加新的 API 接口

1. 在 `BilibiliLiveApiClient` 中添加方法
2. 使用 `_dio.post()` 发送请求
3. 处理响应和异常
4. 添加文档注释

```dart
/// 新接口描述
Future<BaseResponse<T>> newApi({
  required String param,
}) async {
  try {
    final response = await _dio.post(
      '/v2/app/new',
      data: {'param': param},
    );
    return BaseResponse<T>.fromJson(response.data, parser);
  } on DioException catch (e) {
    throw _handleError(e);
  }
}
```

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！
