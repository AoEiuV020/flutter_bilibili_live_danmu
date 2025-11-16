import 'message_consumer.dart';

/// 消息分发器 - 管理所有消费者并分发消息
class MessageDispatcher {
  final List<MessageConsumer> _consumers = [];

  /// 注册消费者
  void register(MessageConsumer consumer) {
    _consumers.add(consumer);
  }

  /// 取消注册消费者
  void unregister(MessageConsumer consumer) {
    _consumers.remove(consumer);
  }

  /// 分发弹幕消息到所有消费者
  void dispatchDanmaku(String username, String content) {
    final message = DanmakuMessageData(username: username, content: content);

    for (final consumer in _consumers) {
      try {
        consumer.consumeDanmaku(message);
      } catch (e) {
        // 确保单个消费者的异常不影响其他消费者
        // debugPrint('[MessageDispatcher] 消费者处理弹幕异常: $e');
      }
    }
  }

  /// 分发提示消息到所有消费者
  void dispatchInfo(String content) {
    final message = InfoMessageData(content: content);

    for (final consumer in _consumers) {
      try {
        consumer.consumeInfo(message);
      } catch (e) {
        // 确保单个消费者的异常不影响其他消费者
        // debugPrint('[MessageDispatcher] 消费者处理提示异常: $e');
      }
    }
  }

  /// 清空所有消费者
  void clear() {
    _consumers.clear();
  }

  /// 释放资源
  void dispose() {
    for (final consumer in _consumers) {
      consumer.dispose();
    }
    _consumers.clear();
  }
}
