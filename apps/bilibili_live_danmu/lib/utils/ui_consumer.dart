import 'package:flutter/material.dart';
import '../widgets/danmaku_list.dart';
import 'message_consumer.dart';

/// UI消费者 - 负责显示消息到界面
class UiConsumer implements MessageConsumer {
  final GlobalKey<MessageListState> messageListKey;

  UiConsumer({required this.messageListKey});

  @override
  void consumeDanmaku(DanmakuMessageData message) {
    messageListKey.currentState?.addDanmaku(message.username, message.content);
  }

  @override
  void consumeInfo(InfoMessageData message) {
    messageListKey.currentState?.addInfo(message.content);
  }

  @override
  void dispose() {
    // UI消费者无需释放资源
  }
}
