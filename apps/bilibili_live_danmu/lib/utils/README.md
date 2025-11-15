# TTS 管理器使用说明

## 概述

`TtsManager` 是一个封装了 Flutter TTS 功能的管理器，用于处理文本转语音播报。

## 特性

- ✅ 自动初始化 TTS 引擎
- ✅ 支持中文播报
- ✅ **新消息自动打断旧播报**（默认开启）
- ✅ 可配置语速、音量、音调
- ✅ 错误处理和日志记录

## 使用方法

### 基本使用（单例模式）

```dart
// 获取单例实例并初始化
await TtsManager.instance.initialize();

// 播报文本
await TtsManager.instance.speak('你好世界');

// 在应用退出时释放资源（可选）
TtsManager.instance.dispose();
```

**注意：** TtsManager 使用单例模式，整个应用共享一个实例，无需多次创建。

### 配置选项

#### 1. 是否打断旧的播报

```dart
// 运行时修改
TtsManager.instance.setInterruptOldSpeech(false); // 等待旧播报完成
TtsManager.instance.setInterruptOldSpeech(true);  // 新消息立即打断（默认）
```

#### 2. 调整语速

```dart
await TtsManager.instance.setSpeechRate(0.5); // 0.0 - 1.0，默认 0.5
```

#### 3. 调整音量

```dart
await TtsManager.instance.setVolume(1.0); // 0.0 - 1.0，默认 1.0
```

#### 4. 调整音调

```dart
await TtsManager.instance.setPitch(1.0); // 0.5 - 2.0，默认 1.0
```

### 停止播报

```dart
await TtsManager.instance.stop();
```

## 在 MessageList 中的应用

`MessageList` 组件默认使用 `TtsManager` 并启用了打断功能：

- 新弹幕或提示消息到达时，会**立即打断**正在播报的旧消息
- 这样可以避免消息堆积，确保用户听到的是最新内容
- 如果需要等待播报完成，可以通过以下方式修改：

```dart
// 在 MessageListState 中
_messageListKey.currentState?.setInterruptOldSpeech(false);
```

## 播报行为说明

### 打断模式（默认，推荐）

- ✅ 新消息立即播报
- ✅ 自动停止旧消息
- ✅ 适合快速刷屏的弹幕场景
- ✅ 避免播报延迟累积

### 等待模式

- ⏳ 新消息排队等待
- ⏳ 等待旧消息播报完成
- ⚠️ 消息多时会有明显延迟
- ⚠️ 可能导致播报落后实际消息很多条

## 实现原理

打断功能通过在每次 `speak()` 前调用 `stop()` 实现：

```dart
Future<void> speak(String text) async {
  if (_interruptOldSpeech) {
    await _flutterTts.stop(); // 先停止当前播报
  }
  await _flutterTts.speak(text); // 再播报新内容
}
```

## 最佳实践

### 在 LivePage 中初始化

为了确保第一条消息能够正常播报，建议在页面初始化时异步等待 TTS 初始化完成：

```dart
@override
void initState() {
  super.initState();
  _initializeAndShowWelcome();
}

Future<void> _initializeAndShowWelcome() async {
  // 先初始化 TTS
  await TtsManager.instance.initialize();
  
  // 初始化完成后再添加欢迎消息
  if (mounted) {
    _addInfo('已连接到房间');
  }
}
```

## 注意事项

1. **单例模式**：整个应用共享一个 TtsManager 实例
2. **异步初始化**：必须在使用前 `await initialize()`
3. **初始化时机**：建议在页面加载时完成初始化，避免第一条消息无法播报
4. **mounted 检查**：异步操作后记得检查 `mounted` 状态
5. **平台权限**：某些平台可能对 TTS 有特殊权限要求
