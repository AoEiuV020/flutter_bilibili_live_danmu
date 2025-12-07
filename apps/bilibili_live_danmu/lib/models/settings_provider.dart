import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_keys.dart';

/// 设置值 Provider
///
/// 使用 ValueNotifier 提供设置值的变化通知
class SettingsProvider {
  static SettingsProvider? _instance;

  /// 获取全局单例
  static SettingsProvider get instance {
    _instance ??= SettingsProvider._();
    return _instance!;
  }

  SettingsProvider._();

  /// 重置单例（仅用于测试）
  @visibleForTesting
  static void resetInstance() {
    _instance?._dispose();
    _instance = null;
  }

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  final Map<String, ValueNotifier<dynamic>> _notifiers = {};

  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 初始化
  Future<void> initialize() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'SettingsProvider not initialized. Call initialize() first.',
      );
    }
  }

  // ==================== Generic Getters ====================

  /// 获取 bool 值的 ValueNotifier
  ValueNotifier<bool> getBool(String key, {required bool defaultValue}) {
    _ensureInitialized();
    return _getNotifier<bool>(key, () => _prefs!.getBool(key) ?? defaultValue);
  }

  /// 获取 int 值的 ValueNotifier
  ValueNotifier<int> getInt(String key, {required int defaultValue}) {
    _ensureInitialized();
    return _getNotifier<int>(key, () => _prefs!.getInt(key) ?? defaultValue);
  }

  /// 获取 double 值的 ValueNotifier
  ValueNotifier<double> getDouble(String key, {required double defaultValue}) {
    _ensureInitialized();
    return _getNotifier<double>(
      key,
      () => _prefs!.getDouble(key) ?? defaultValue,
    );
  }

  /// 获取 String 值的 ValueNotifier
  ValueNotifier<String> getString(String key, {required String defaultValue}) {
    _ensureInitialized();
    return _getNotifier<String>(
      key,
      () => _prefs!.getString(key) ?? defaultValue,
    );
  }

  ValueNotifier<T> _getNotifier<T>(String key, T Function() getValue) {
    if (!_notifiers.containsKey(key)) {
      _notifiers[key] = ValueNotifier<T>(getValue());
    }
    return _notifiers[key]! as ValueNotifier<T>;
  }

  // ==================== Generic Setters ====================

  /// 设置 bool 值
  Future<void> setBool(String key, bool value) async {
    _ensureInitialized();
    await _prefs!.setBool(key, value);
    _updateNotifier<bool>(key, value);
  }

  /// 设置 int 值
  Future<void> setInt(String key, int value) async {
    _ensureInitialized();
    await _prefs!.setInt(key, value);
    _updateNotifier<int>(key, value);
  }

  /// 设置 double 值
  Future<void> setDouble(String key, double value) async {
    _ensureInitialized();
    await _prefs!.setDouble(key, value);
    _updateNotifier<double>(key, value);
  }

  /// 设置 String 值
  Future<void> setString(String key, String value) async {
    _ensureInitialized();
    await _prefs!.setString(key, value);
    _updateNotifier<String>(key, value);
  }

  void _updateNotifier<T>(String key, T value) {
    final notifier = _notifiers[key];
    if (notifier != null) {
      (notifier as ValueNotifier<T>).value = value;
    }
  }

  // ==================== Convenience Accessors ====================
  // Display Settings

  /// 字体大小
  ValueNotifier<double> get displayFontSize => getDouble(
    SettingsKeys.displayFontSize,
    defaultValue: SettingsKeys.displayFontSizeDefault,
  );

  /// 文字颜色
  ValueNotifier<int> get displayTextColor => getInt(
    SettingsKeys.displayTextColor,
    defaultValue: SettingsKeys.displayTextColorDefault,
  );

  /// 背景颜色
  ValueNotifier<int> get displayBackgroundColor => getInt(
    SettingsKeys.displayBackgroundColor,
    defaultValue: SettingsKeys.displayBackgroundColorDefault,
  );

  /// 显示时间（秒）
  ValueNotifier<int> get displayDuration => getInt(
    SettingsKeys.displayDuration,
    defaultValue: SettingsKeys.displayDurationDefault,
  );

  // Filter Settings

  /// 显示弹幕
  ValueNotifier<bool> get filterShowDanmaku => getBool(
    SettingsKeys.filterShowDanmaku,
    defaultValue: SettingsKeys.filterShowDanmakuDefault,
  );

  /// 显示礼物
  ValueNotifier<bool> get filterShowGift => getBool(
    SettingsKeys.filterShowGift,
    defaultValue: SettingsKeys.filterShowGiftDefault,
  );

  /// 显示 SuperChat
  ValueNotifier<bool> get filterShowSuperChat => getBool(
    SettingsKeys.filterShowSuperChat,
    defaultValue: SettingsKeys.filterShowSuperChatDefault,
  );

  /// 显示大航海
  ValueNotifier<bool> get filterShowGuard => getBool(
    SettingsKeys.filterShowGuard,
    defaultValue: SettingsKeys.filterShowGuardDefault,
  );

  /// 显示点赞
  ValueNotifier<bool> get filterShowLike => getBool(
    SettingsKeys.filterShowLike,
    defaultValue: SettingsKeys.filterShowLikeDefault,
  );

  /// 显示进入
  ValueNotifier<bool> get filterShowEnter => getBool(
    SettingsKeys.filterShowEnter,
    defaultValue: SettingsKeys.filterShowEnterDefault,
  );

  /// 显示开播
  ValueNotifier<bool> get filterShowLiveStart => getBool(
    SettingsKeys.filterShowLiveStart,
    defaultValue: SettingsKeys.filterShowLiveStartDefault,
  );

  /// 显示下播
  ValueNotifier<bool> get filterShowLiveEnd => getBool(
    SettingsKeys.filterShowLiveEnd,
    defaultValue: SettingsKeys.filterShowLiveEndDefault,
  );

  // Credentials Settings

  /// App ID
  ValueNotifier<String> get credentialsAppId => getString(
    SettingsKeys.credentialsAppId,
    defaultValue: SettingsKeys.credentialsAppIdDefault,
  );

  /// Access Key ID
  ValueNotifier<String> get credentialsAccessKeyId => getString(
    SettingsKeys.credentialsAccessKeyId,
    defaultValue: SettingsKeys.credentialsAccessKeyIdDefault,
  );

  /// Access Key Secret
  ValueNotifier<String> get credentialsAccessKeySecret => getString(
    SettingsKeys.credentialsAccessKeySecret,
    defaultValue: SettingsKeys.credentialsAccessKeySecretDefault,
  );

  /// 身份码
  ValueNotifier<String> get credentialsCode => getString(
    SettingsKeys.credentialsCode,
    defaultValue: SettingsKeys.credentialsCodeDefault,
  );

  // Server Settings

  /// 后端地址
  ValueNotifier<String> get serverBackendUrl => getString(
    SettingsKeys.serverBackendUrl,
    defaultValue: SettingsKeys.serverBackendUrlDefault,
  );

  /// 启用 HTTP 服务
  ValueNotifier<bool> get serverEnableHttpServer => getBool(
    SettingsKeys.serverEnableHttpServer,
    defaultValue: SettingsKeys.serverEnableHttpServerDefault,
  );

  /// HTTP 服务端口
  ValueNotifier<int> get serverHttpServerPort => getInt(
    SettingsKeys.serverHttpServerPort,
    defaultValue: SettingsKeys.serverHttpServerPortDefault,
  );

  // ==================== Convenience Setters ====================
  // Display Settings

  /// 设置字体大小
  Future<void> setDisplayFontSize(double value) =>
      setDouble(SettingsKeys.displayFontSize, value);

  /// 设置文字颜色
  Future<void> setDisplayTextColor(int value) =>
      setInt(SettingsKeys.displayTextColor, value);

  /// 设置背景颜色
  Future<void> setDisplayBackgroundColor(int value) =>
      setInt(SettingsKeys.displayBackgroundColor, value);

  /// 设置显示时间
  Future<void> setDisplayDuration(int value) =>
      setInt(SettingsKeys.displayDuration, value);

  // Filter Settings

  /// 设置显示弹幕
  Future<void> setFilterShowDanmaku(bool value) =>
      setBool(SettingsKeys.filterShowDanmaku, value);

  /// 设置显示礼物
  Future<void> setFilterShowGift(bool value) =>
      setBool(SettingsKeys.filterShowGift, value);

  /// 设置显示 SuperChat
  Future<void> setFilterShowSuperChat(bool value) =>
      setBool(SettingsKeys.filterShowSuperChat, value);

  /// 设置显示大航海
  Future<void> setFilterShowGuard(bool value) =>
      setBool(SettingsKeys.filterShowGuard, value);

  /// 设置显示点赞
  Future<void> setFilterShowLike(bool value) =>
      setBool(SettingsKeys.filterShowLike, value);

  /// 设置显示进入
  Future<void> setFilterShowEnter(bool value) =>
      setBool(SettingsKeys.filterShowEnter, value);

  /// 设置显示开播
  Future<void> setFilterShowLiveStart(bool value) =>
      setBool(SettingsKeys.filterShowLiveStart, value);

  /// 设置显示下播
  Future<void> setFilterShowLiveEnd(bool value) =>
      setBool(SettingsKeys.filterShowLiveEnd, value);

  // Credentials Settings

  /// 设置 App ID
  Future<void> setCredentialsAppId(String value) =>
      setString(SettingsKeys.credentialsAppId, value);

  /// 设置 Access Key ID
  Future<void> setCredentialsAccessKeyId(String value) =>
      setString(SettingsKeys.credentialsAccessKeyId, value);

  /// 设置 Access Key Secret
  Future<void> setCredentialsAccessKeySecret(String value) =>
      setString(SettingsKeys.credentialsAccessKeySecret, value);

  /// 设置身份码
  Future<void> setCredentialsCode(String value) =>
      setString(SettingsKeys.credentialsCode, value);

  // Server Settings

  /// 设置后端地址
  Future<void> setServerBackendUrl(String value) =>
      setString(SettingsKeys.serverBackendUrl, value);

  /// 设置启用 HTTP 服务
  Future<void> setServerEnableHttpServer(bool value) =>
      setBool(SettingsKeys.serverEnableHttpServer, value);

  /// 设置 HTTP 服务端口
  Future<void> setServerHttpServerPort(int value) =>
      setInt(SettingsKeys.serverHttpServerPort, value);

  void _dispose() {
    for (final notifier in _notifiers.values) {
      notifier.dispose();
    }
    _notifiers.clear();
    _isInitialized = false;
    _prefs = null;
  }
}
