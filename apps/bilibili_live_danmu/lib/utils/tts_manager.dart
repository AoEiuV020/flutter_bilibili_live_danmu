import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import '../src/logger.dart';

/// TTS 管理器（单例）
class TtsManager {
  static TtsManager? _instance;
  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  bool _isInitializing = false; // 防止并发初始化
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

  /// 获取初始化状态
  bool get isInitialized => _isInitialized;

  /// 初始化 TTS
  Future<void> initialize() async {
    // 如果已经初始化或正在初始化，直接返回
    if (_isInitialized) return;
    if (_isInitializing) {
      // 等待正在进行的初始化完成
      while (_isInitializing && !_isInitialized) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }

    _isInitializing = true;

    try {
      // 只创建一次FlutterTts实例
      _flutterTts ??= FlutterTts();

      // 添加超时保护，防止初始化卡死
      await Future.wait([
        // await _flutterTts!.setLanguage('zh-CN'),
        _flutterTts!.setSpeechRate(1.0), // 语速
        _flutterTts!.setVolume(1.0), // 音量
        _flutterTts!.setPitch(1.0), // 音调
      ]).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          logger.w('TTS 初始化超时');
          throw TimeoutException('TTS 初始化超时', const Duration(seconds: 5));
        },
      );

      _isInitialized = true;
      logger.i('TTS 初始化成功');
    } catch (e, stackTrace) {
      logger.e('TTS 初始化失败: $e', error: e, stackTrace: stackTrace);
      // 初始化失败时，清理FlutterTts实例
      _flutterTts = null;
    } finally {
      _isInitializing = false;
    }
  }

  /// 播报文本
  Future<void> speak(String text) async {
    if (!_isInitialized || _flutterTts == null) {
      logger.w('TTS 未初始化');
      return;
    }

    try {
      // 如果设置为打断旧的播报，先停止当前播报
      if (_interruptOldSpeech) {
        await _flutterTts!.stop();
      }

      await _flutterTts!.speak(text);
    } catch (e, stackTrace) {
      logger.e('TTS 播报失败: $e', error: e, stackTrace: stackTrace);
    }
  }

  /// 停止播报
  Future<void> stop() async {
    if (!_isInitialized || _flutterTts == null) return;

    try {
      await _flutterTts!.stop();
    } catch (e, stackTrace) {
      logger.e('TTS 停止失败: $e', error: e, stackTrace: stackTrace);
    }
  }

  /// 设置是否打断旧的播报
  void setInterruptOldSpeech(bool interrupt) {
    _interruptOldSpeech = interrupt;
  }

  /// 设置语速 (0.0 - 1.0)
  Future<void> setSpeechRate(double rate) async {
    if (!_isInitialized || _flutterTts == null) return;

    try {
      await _flutterTts!.setSpeechRate(rate);
    } catch (e, stackTrace) {
      logger.e('设置语速失败: $e', error: e, stackTrace: stackTrace);
    }
  }

  /// 设置音量 (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    if (!_isInitialized || _flutterTts == null) return;

    try {
      await _flutterTts!.setVolume(volume);
    } catch (e, stackTrace) {
      logger.e('设置音量失败: $e', error: e, stackTrace: stackTrace);
    }
  }

  /// 设置音调 (0.5 - 2.0)
  Future<void> setPitch(double pitch) async {
    if (!_isInitialized || _flutterTts == null) return;

    try {
      await _flutterTts!.setPitch(pitch);
    } catch (e, stackTrace) {
      logger.e('设置音调失败: $e', error: e, stackTrace: stackTrace);
    }
  }

  /// 释放资源
  void dispose() {
    if (_isInitialized && _flutterTts != null) {
      _flutterTts!.stop();
      _isInitialized = false;
    }
  }
}
