import 'message_consumer.dart';
import '../src/logger.dart';

/// 日志消费者 - 负责打印消息日志
class LogConsumer implements MessageConsumer {
  @override
  void consumeDanmaku(DanmakuMessageData message) {
    logger.d('[弹幕] ${message.username}: ${message.content}');
  }

  @override
  void consumeInfo(InfoMessageData message) {
    logger.d('[提示] ${message.content}');
  }

  @override
  void dispose() {
    // 日志消费者无需释放资源
  }
}
