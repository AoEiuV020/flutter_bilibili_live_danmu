# 快速启动指南

## 1. 前置准备

确保已安装：
- Flutter SDK (>= 3.10.0)
- Dart SDK

## 2. 获取 B站直播开放平台凭证

访问 [B站直播开放平台](https://live-open.biliapi.com/) 获取：
- **App ID**: 项目 ID
- **Access Key ID**: 访问密钥 ID
- **Access Key Secret**: 访问密钥
- **Code**: 主播身份码

## 3. 配置应用

编辑 `apps/bilibili_live_danmu/assets/config.properties`：

```properties
app_id=你的_app_id
access_key_id=你的_access_key_id
access_key_secret=你的_access_key_secret
code=你的_code
```

## 4. 安装依赖

```bash
cd /Users/aoeiuv/git/flutter_bilibili_live_danmu
flutter pub get
```

## 5. 运行应用

### 方式一：命令行运行

```bash
cd apps/bilibili_live_danmu
flutter run
```

### 方式二：选择设备运行

```bash
# 查看可用设备
flutter devices

# 在指定设备上运行
flutter run -d <device_id>

# 例如：在 Chrome 上运行
flutter run -d chrome

# 在 macOS 上运行
flutter run -d macos
```

## 6. 使用应用

1. **启动后**会显示配置页面
2. **填写配置**（如果 config.properties 有默认值会自动填充）
   - App ID
   - Access Key ID
   - Access Key Secret
   - 身份码
3. **点击"开始直播"**按钮
4. **进入直播页面**（全屏黑色界面）
   - 显示主播信息
   - 显示心跳状态
   - 每 20 秒自动发送心跳
5. **点击"退出"按钮**离开
   - 自动调用 end 接口关闭项目
   - 返回配置页面

## 7. 开发模式

### 启用热重载

运行应用后，在终端输入：
- `r` - 热重载
- `R` - 热重启
- `h` - 显示帮助
- `q` - 退出

### 查看日志

应用内置了详细的日志输出，包括：
- 📤 请求日志（URL、Headers、Body）
- 📥 响应日志（Status Code、Data）
- ❌ 错误日志（Error Type、Message、Stack Trace）

## 8. 测试

### 运行单元测试

```bash
cd packages/bilibili_live_api
flutter test
```

### 运行代码分析

```bash
cd apps/bilibili_live_danmu
flutter analyze
```

## 9. 常见问题

### Q: 启动失败，提示鉴权失败？
A: 检查 Access Key ID 和 Access Key Secret 是否正确。

### Q: 心跳失败？
A: 确保项目已成功开启，game_id 正确。

### Q: 提示超时？
A: 检查网络连接，确保可以访问 https://live-open.biliapi.com

### Q: 如何查看详细日志？
A: 日志会自动打印到控制台，包含完整的请求和响应信息。

## 10. 项目结构说明

```
flutter_bilibili_live_danmu/
├── apps/bilibili_live_danmu/      # 主应用
│   ├── lib/
│   │   ├── main.dart              # 入口
│   │   ├── home_page.dart         # 首页
│   │   └── live_page.dart         # 直播页
│   └── assets/
│       └── config.properties      # 配置文件
│
└── packages/bilibili_live_api/    # API 封装
    ├── lib/src/
    │   ├── bilibili_live_api_client.dart
    │   ├── interceptors/          # 拦截器
    │   ├── models/                # 数据模型
    │   └── utils/                 # 工具类
    └── example/                   # 示例代码
```

## 11. 下一步

查看完整文档：
- [项目文档](PROJECT_DOCS.md)
- [API 文档](packages/bilibili_live_api/README.md)
- [应用文档](apps/bilibili_live_danmu/README.md)
- [示例代码](packages/bilibili_live_api/example/bilibili_live_api_example.dart)

## 12. 获取帮助

如有问题，请：
1. 查看日志输出
2. 检查网络连接
3. 验证配置信息
4. 提交 Issue
