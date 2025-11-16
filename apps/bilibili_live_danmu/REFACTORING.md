# 代码重构说明

## 架构设计

重构后的代码采用 **MVVM** 架构模式，实现了业务逻辑与UI的完全分离。

## 目录结构

```
lib/
├── managers/              # 管理器层 - 单一职责的功能模块
│   ├── system_ui_manager.dart          # 系统UI管理（全屏、防锁屏）
│   ├── heartbeat_manager.dart          # 心跳管理
│   ├── websocket_message_handler.dart  # WebSocket消息处理
│   └── managers.dart                   # 统一导出
│
├── viewmodels/           # ViewModel层 - 业务逻辑编排
│   └── live_page_viewmodel.dart        # LivePage的业务逻辑
│
├── utils/                # 工具层 - 消息分发和消费
│   ├── message_consumer.dart           # 消息消费者接口
│   ├── message_dispatcher.dart         # 消息分发器
│   ├── log_consumer.dart               # 日志消费者
│   ├── ui_consumer.dart                # UI消费者
│   ├── tts_consumer.dart               # TTS消费者
│   └── tts_manager.dart                # TTS管理器
│
├── widgets/              # UI组件层
├── models/               # 数据模型层
└── live_page.dart        # View层 - 纯UI展示

```

## 核心设计模式

### 1. MVVM 模式

- **View** (`live_page.dart`): 只负责UI渲染和用户交互
- **ViewModel** (`live_page_viewmodel.dart`): 处理所有业务逻辑
- **Model**: 数据模型和API调用

### 2. 消费者模式

消息分发采用观察者模式的变体 - 消费者模式：

```
MessageDispatcher (分发器)
    ├── LogConsumer (日志消费者)
    ├── UiConsumer (UI消费者)
    └── TtsConsumer (语音消费者)
```

**优点**:
- 解耦：各消费者互不影响
- 扩展：新增消费者无需修改现有代码
- 容错：单个消费者异常不影响其他消费者

### 3. 单一职责原则

每个类只负责一件事：

- `SystemUiManager`: 只管系统UI状态
- `HeartbeatManager`: 只管心跳逻辑
- `WebSocketMessageHandler`: 只处理消息解析和分发
- `LivePageViewModel`: 编排和协调各个管理器

## 重构对比

### 重构前 (`live_page_old.dart`)
- **502行** 代码
- 所有逻辑混在一起
- 难以测试和维护

### 重构后 (`live_page.dart`)
- **283行** 代码（减少 **43%**）
- 业务逻辑完全分离
- 每个文件职责清晰

## 各文件职责

### Managers (管理器层)

#### `system_ui_manager.dart` (35行)
```dart
- setFullScreen()      // 设置全屏
- exitFullScreen()     // 退出全屏
- enableWakelock()     // 启用防锁屏
- disableWakelock()    // 禁用防锁屏
```

#### `heartbeat_manager.dart` (52行)
```dart
- start()              // 开始心跳（每20秒）
- stop()               // 停止心跳
```

#### `websocket_message_handler.dart` (45行)
```dart
- handleMessage()      // 处理各种WebSocket消息类型
```

### ViewModel (业务逻辑层)

#### `live_page_viewmodel.dart` (172行)
```dart
- initialize()                   // 初始化所有管理器
- updateFilterSettings()         // 更新过滤设置
- addTestDanmaku()              // 添加测试弹幕
- dispose()                      // 释放资源
```

### View (UI层)

#### `live_page.dart` (283行)
```dart
- 纯UI渲染
- 用户交互处理
- 调用ViewModel方法
```

## 消息流转

```
WebSocket消息
    ↓
WebSocketMessageHandler (解析)
    ↓
MessageDispatcher (分发)
    ↓
    ├→ LogConsumer (打印日志)
    ├→ UiConsumer (更新界面)
    └→ TtsConsumer (语音播报，用户名最多10字符)
```

## 优势

### 1. **可维护性**
- 每个文件小而专注
- 修改某个功能只需改对应文件
- 代码结构清晰易懂

### 2. **可测试性**
- 业务逻辑独立，方便单元测试
- 各管理器可独立测试
- Mock更简单

### 3. **可扩展性**
- 新增消费者：实现 `MessageConsumer` 接口
- 新增管理器：在 ViewModel 中注册
- 不影响现有代码

### 4. **可复用性**
- 各管理器可在其他页面复用
- 消费者模式可应用到其他场景

## 使用示例

### 添加新的消息消费者

```dart
// 1. 实现消费者接口
class DatabaseConsumer implements MessageConsumer {
  @override
  void consumeDanmaku(DanmakuMessageData message) {
    // 保存到数据库
  }
  
  @override
  void consumeInfo(InfoMessageData message) {
    // 保存到数据库
  }
}

// 2. 注册消费者
_messageDispatcher.register(DatabaseConsumer());
```

### 添加新的管理器

```dart
// 1. 创建管理器
class StatisticsManager {
  void recordDanmaku() { /* ... */ }
}

// 2. 在ViewModel中使用
late StatisticsManager _statisticsManager;

void initialize() {
  _statisticsManager = StatisticsManager();
  // ...
}
```

## 注意事项

1. **生命周期管理**: 所有管理器都在 ViewModel 的 `dispose()` 中释放
2. **错误处理**: 消费者异常不影响其他消费者
3. **UI更新**: 通过 `setState()` 或状态管理工具
4. **用户名处理**: TtsConsumer 统一将用户名缩短到最多10字符

## 后续优化建议

1. 引入状态管理（Provider/Riverpod/Bloc）替代 setState
2. 使用依赖注入（GetIt）管理单例
3. 添加单元测试和集成测试
4. 考虑使用 freezed 处理数据模型
