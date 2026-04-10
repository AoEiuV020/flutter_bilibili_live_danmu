# AGENTS.md

## 命令

```bash
# 初始化
melos bootstrap

# 构建
cd apps/bilibili_live_danmu && flutter build web
cd apps/bilibili_live_danmu && flutter build apk
cd apps/bilibili_live_danmu_proxy && dart compile exe bin/bilibili_live_danmu_proxy.dart

# 测试（仅跑有 test/ 目录的包）
melos test

# 代码质量
melos analyze                # dart analyze
melos fix                    # dart fix --apply
melos sort                   # import_sorter 排序
melos precommit              # fix + format + sort

# Docker（代理服务器）
cd docker && docker-compose up -d --build
docker/buildx-push.sh <用户名> <镜像名> <标签...>
```

## 技术栈

Dart SDK ≥3.10.0, Flutter, Melos 7.3.0 workspace

| 包 | 关键依赖 |
|---|---------|
| bilibili_live_api | dio 5.7, crypto 3.0, web_socket_channel 3.0 |
| bilibili_live_api_server | shelf 1.4, shelf_router 1.1 |
| bilibili_live_danmu | flutter_bloc 9.1, shared_preferences 2.3, flutter_tts 3.8 |

## 项目结构

```
apps/
  bilibili_live_danmu/        # Flutter 主应用（弹幕显示、语音播报）
  bilibili_live_danmu_proxy/  # CLI 代理服务器入口
packages/
  bilibili_live_api/          # B站直播开放平台 API 封装
  bilibili_live_api_server/   # shelf HTTP 代理服务器
docker/                       # Dockerfile + Compose + buildx 脚本
script/                       # 初始化/发布脚本
```

## 代码风格

Linter: `flutter_lints`（app）/ `lints/recommended`（包）

```dart
// ✅ 相对导入（linter 强制）
import '../blocs/home_page_cubit.dart';

// ❌ 包导入同项目文件
import 'package:bilibili_live_danmu/blocs/home_page_cubit.dart';
```

```dart
// ✅ BLoC 状态管理命名
class CredentialsSettingsCubit extends Cubit<CredentialsSettingsState> { ... }
class CredentialsSettingsState extends Equatable { ... }

// ✅ 中文文档注释
/// B站直播开放平台API客户端
class BilibiliLiveApiClient { ... }
```

- 文件名 snake_case，类名 PascalCase
- State 类以 `State` 后缀，Cubit 类以 `Cubit` 后缀
- 提交前运行 `melos precommit`（fix + format + sort）

## 边界

- ✅ **始终执行**：改代码后 `melos analyze` 确认无错误
- ✅ **始终执行**：提交前 `melos precommit`
- ✅ **始终执行**：使用相对导入（`prefer_relative_imports` 规则）
- ⚠️ **先问再做**：修改 pubspec.yaml 依赖版本
- ⚠️ **先问再做**：修改 Docker 配置或 CI workflow
- 🚫 **禁止**：提交 `docker/config.properties`（含密钥，已 gitignore）
- 🚫 **禁止**：修改 `md/指令/` 目录内容
