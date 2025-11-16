/// 消息数据基类
abstract class MessageData {
  final DateTime timestamp;

  MessageData() : timestamp = DateTime.now();
}

/// 弹幕消息
class DanmakuMessageData extends MessageData {
  final String username;
  final String content;

  DanmakuMessageData({required this.username, required this.content});
}

/// 提示消息
class InfoMessageData extends MessageData {
  final String content;

  InfoMessageData({required this.content});
}

/// 消息消费者接口
abstract class MessageConsumer {
  /// 消费弹幕消息
  void consumeDanmaku(DanmakuMessageData message);

  /// 消费提示消息
  void consumeInfo(InfoMessageData message);

  /// 释放资源
  void dispose() {}
}
