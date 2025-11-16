import 'message_consumer.dart';
import 'tts_manager.dart';

/// TTS消费者 - 负责语音播报
class TtsConsumer implements MessageConsumer {
  @override
  void consumeDanmaku(DanmakuMessageData message) {
    final speakText = _formatDanmakuText(message.username, message.content);
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

  /// 格式化弹幕播报文本
  /// 用户名统一缩短到最多10字符
  String _formatDanmakuText(String username, String content) {
    final truncatedUsername = _truncateUsername(username);
    return '$truncatedUsername说$content';
  }

  /// 截断用户名到最多10个字符
  String _truncateUsername(String username) {
    if (username.length <= 10) {
      return username;
    }
    return username.substring(0, 10);
  }
}
