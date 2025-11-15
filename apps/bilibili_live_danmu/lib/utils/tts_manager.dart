import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// TTS 管理器（单例）
class TtsManager {
  static TtsManager? _instance;
  late final FlutterTts _flutterTts;
  bool _isInitialized = false;
  bool _interruptOldSpeech; // 是否打断旧的播报

  // 私有构造函数
  TtsManager._({bool interruptOldSpeech = true})
    : _interruptOldSpeech = interruptOldSpeech;

  /// 获取单例实例
  static TtsManager get instance {
    _instance ??= TtsManager._(interruptOldSpeech: true);
    return _instance!;
  }

  /// 重置单例（主要用于测试）
  static void reset() {
    _instance?.dispose();
    _instance = null;
  }

  /// 初始化 TTS
  Future<void> initialize() async {
    if (_isInitialized) return;

    _flutterTts = FlutterTts();

    try {
      await _flutterTts.setLanguage('zh-CN');
      await _flutterTts.setSpeechRate(0.5); // 语速
      await _flutterTts.setVolume(1.0); // 音量
      await _flutterTts.setPitch(1.0); // 音调

      _isInitialized = true;
      debugPrint('TTS 初始化成功');
    } catch (e) {
      debugPrint('TTS 初始化失败: $e');
    }
  }

  /// 播报文本
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      debugPrint('TTS 未初始化');
      return;
    }

    try {
      // 如果设置为打断旧的播报，先停止当前播报
      if (_interruptOldSpeech) {
        await _flutterTts.stop();
      }

      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS 播报失败: $e');
    }
  }

  /// 停止播报
  Future<void> stop() async {
    if (!_isInitialized) return;

    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TTS 停止失败: $e');
    }
  }

  /// 设置是否打断旧的播报
  void setInterruptOldSpeech(bool interrupt) {
    _interruptOldSpeech = interrupt;
  }

  /// 设置语速 (0.0 - 1.0)
  Future<void> setSpeechRate(double rate) async {
    if (!_isInitialized) return;

    try {
      await _flutterTts.setSpeechRate(rate);
    } catch (e) {
      debugPrint('设置语速失败: $e');
    }
  }

  /// 设置音量 (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    if (!_isInitialized) return;

    try {
      await _flutterTts.setVolume(volume);
    } catch (e) {
      debugPrint('设置音量失败: $e');
    }
  }

  /// 设置音调 (0.5 - 2.0)
  Future<void> setPitch(double pitch) async {
    if (!_isInitialized) return;

    try {
      await _flutterTts.setPitch(pitch);
    } catch (e) {
      debugPrint('设置音调失败: $e');
    }
  }

  /// 释放资源
  void dispose() {
    if (_isInitialized) {
      _flutterTts.stop();
      _isInitialized = false;
    }
  }
}
