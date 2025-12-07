# bilibili_live_danmu

哔哩哔哩直播弹幕应用 - 使用 B站直播开放平台 API

## 功能特性

- ✅ 配置管理（App ID、Access Key ID、Access Key Secret、身份码）
- ✅ 自动保存和加载配置
- ✅ 项目开启/关闭
- ✅ 自动心跳（每 20 秒）
- ✅ 全屏直播界面
- ✅ 显示主播信息
- ✅ 实时状态显示

## 使用说明

### 1. 启动应用

首页会显示四个输入框：
- **App ID**: 项目 ID
- **Access Key ID**: 访问密钥 ID
- **Access Key Secret**: 访问密钥
- **身份码 (Code)**: 主播身份码

填写完毕后点击"开始直播"按钮。

### 2. 直播页面

成功启动后会进入全屏黑色界面，显示：
- 主播头像和昵称
- 房间号
- 场次 ID
- 心跳状态

应用会自动每 20 秒发送一次心跳，退出时自动调用 end 接口关闭项目。

## 运行

```bash
cd apps/bilibili_live_danmu
flutter run
```

## 项目结构

```
lib/
├── main.dart          # 应用入口
├── home_page.dart     # 首页（配置页面）
└── live_page.dart     # 直播页面
```

## 依赖

- `bilibili_live_api` - B站直播开放平台 API 封装
- `shared_preferences` - 本地配置存储

## 注意事项

1. 确保填写正确的 App ID、Access Key 和身份码
2. 互动玩法超过 60 秒未收到心跳会自动关闭
3. 退出直播页面时会自动调用 end 接口
4. 配置会自动保存，下次启动时自动加载
