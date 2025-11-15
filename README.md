# Flutter Bilibili Live Danmu

哔哩哔哩直播弹幕应用 - 基于 B站直播开放平台 API

## 项目结构

本项目使用 **Melos** 管理多模块工作空间：

```
flutter_bilibili_live_danmu/
├── apps/                           # 应用目录
│   └── bilibili_live_danmu/       # 主应用：弹幕显示界面
├── packages/                       # 公共包目录
│   └── bilibili_live_api/         # B站直播开放平台 API 封装
├── melos.yaml                      # Melos 配置文件
└── pubspec.yaml                    # 工作空间配置
```

## 关于 Melos

[Melos](https://melos.invertase.dev/) 是一个 Dart/Flutter 项目管理工具，用于管理多包（monorepo）工作空间。

### 主要优势

- **统一依赖管理**：一次性获取所有包的依赖
- **批量操作**：可以对所有包执行相同的命令
- **版本控制**：统一管理包版本
- **脚本支持**：自定义常用操作脚本

### 常用命令

```bash
# 安装 melos（首次使用）
dart pub global activate melos

# 引导项目（获取所有依赖）
melos bootstrap

# 清理所有包
melos clean

# 运行所有测试
melos run test

# 分析所有包
melos run analyze

# 格式化所有代码
melos run format
```

## 快速开始

### 1. 安装依赖

```bash
# 使用 melos（推荐）
melos bootstrap

# 或者使用 flutter
flutter pub get
```

### 2. 配置应用

编辑 `apps/bilibili_live_danmu/assets/config.properties`：

```properties
app_id=你的_app_id
access_key_id=你的_access_key_id
access_key_secret=你的_access_key_secret
code=你的_code
```

### 3. 运行应用

```bash
cd apps/bilibili_live_danmu
flutter run
```

## 模块说明

### 📦 packages/bilibili_live_api

B站直播开放平台 API 客户端封装包。

**功能：**
- 完整的鉴权签名机制（HMAC-SHA256）
- 项目开启/关闭
- 心跳维持
- 自动错误处理

**文档：** [packages/bilibili_live_api/README.md](packages/bilibili_live_api/README.md)

### 📱 apps/bilibili_live_danmu

直播弹幕显示应用。

**功能：**
- 配置管理（App ID、密钥等）
- 实时弹幕显示
- 消息自动过期
- 全屏黑色背景

**文档：** [apps/bilibili_live_danmu/README.md](apps/bilibili_live_danmu/README.md)

## 文档

- [快速启动指南](QUICK_START.md)
- [项目详细文档](PROJECT_DOCS.md)
- [API 使用示例](packages/bilibili_live_api/example/bilibili_live_api_example.dart)

## 许可证

MIT License  
