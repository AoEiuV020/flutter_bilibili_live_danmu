import 'message_consumer.dart';
import 'tts_manager.dart';

/// TTS消费者 - 负责语音播报
class TtsConsumer implements MessageConsumer {
  @override
  void consumeDanmaku(DanmakuMessageData message) {
    // 用户名已经在 WebSocketMessageHandler 中被截断
    final speakText = '${message.username}说${message.content}';
    TtsManager.instance.speak(speakText);
  }

  @override
  void consumeInfo(InfoMessageData message) {
    TtsManager.instance.speak(message.content);
  }

  @override
  void dispose() {
    // TTS 由 TtsManager 单例管理，此处无需释放
  }
}
