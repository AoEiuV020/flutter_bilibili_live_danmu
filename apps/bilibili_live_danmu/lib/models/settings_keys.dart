import 'package:flutter/material.dart';

/// 设置项常量类
///
/// 包含所有设置项的 key 和默认值
abstract final class SettingsKeys {
  // ==================== Display Settings ====================

  /// 字体大小
  static const String displayFontSize = 'display.fontSize';
  static const double displayFontSizeDefault = 20.0;

  /// 文字颜色
  static const String displayTextColor = 'display.textColor';
  static final int displayTextColorDefault = Colors.white.toARGB32();

  /// 背景颜色
  static const String displayBackgroundColor = 'display.backgroundColor';
  static final int displayBackgroundColorDefault = Colors.black.toARGB32();

  /// 显示时间（秒）
  static const String displayDuration = 'display.duration';
  static const int displayDurationDefault = 120;

  // ==================== Filter Settings ====================

  /// 显示弹幕
  static const String filterShowDanmaku = 'filter.showDanmaku';
  static const bool filterShowDanmakuDefault = true;

  /// 显示礼物
  static const String filterShowGift = 'filter.showGift';
  static const bool filterShowGiftDefault = true;

  /// 显示 SuperChat
  static const String filterShowSuperChat = 'filter.showSuperChat';
  static const bool filterShowSuperChatDefault = true;

  /// 显示大航海
  static const String filterShowGuard = 'filter.showGuard';
  static const bool filterShowGuardDefault = true;

  /// 显示点赞
  static const String filterShowLike = 'filter.showLike';
  static const bool filterShowLikeDefault = false;

  /// 显示进入
  static const String filterShowEnter = 'filter.showEnter';
  static const bool filterShowEnterDefault = true;

  /// 显示开播
  static const String filterShowLiveStart = 'filter.showLiveStart';
  static const bool filterShowLiveStartDefault = true;

  /// 显示下播
  static const String filterShowLiveEnd = 'filter.showLiveEnd';
  static const bool filterShowLiveEndDefault = true;

  // ==================== Credentials Settings ====================

  /// App ID
  static const String credentialsAppId = 'credentials.appId';
  static const String credentialsAppIdDefault = '';

  /// Access Key ID
  static const String credentialsAccessKeyId = 'credentials.accessKeyId';
  static const String credentialsAccessKeyIdDefault = '';

  /// Access Key Secret
  static const String credentialsAccessKeySecret =
      'credentials.accessKeySecret';
  static const String credentialsAccessKeySecretDefault = '';

  /// 身份码
  static const String credentialsCode = 'credentials.code';
  static const String credentialsCodeDefault = '';

  // ==================== Server Settings ====================

  /// 后端地址
  static const String serverBackendUrl = 'server.backendUrl';
  static const String serverBackendUrlDefault = '';

  /// 启用 HTTP 服务
  static const String serverEnableHttpServer = 'server.enableHttpServer';
  static const bool serverEnableHttpServerDefault = false;

  /// HTTP 服务端口
  static const String serverHttpServerPort = 'server.httpServerPort';
  static const int serverHttpServerPortDefault = 18080;
}
