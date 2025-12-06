import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 显示设置
class DisplaySettings {
  final double fontSize;
  final Color textColor;
  final Color backgroundColor;
  final int displayDuration; // 秒

  const DisplaySettings({
    required this.fontSize,
    required this.textColor,
    required this.backgroundColor,
    required this.displayDuration,
  });

  factory DisplaySettings.defaultSettings() {
    return const DisplaySettings(
      fontSize: 20,
      textColor: Colors.white,
      backgroundColor: Colors.black,
      displayDuration: 120, // 2分钟
    );
  }

  DisplaySettings copyWith({
    double? fontSize,
    Color? textColor,
    Color? backgroundColor,
    int? displayDuration,
  }) {
    return DisplaySettings(
      fontSize: fontSize ?? this.fontSize,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      displayDuration: displayDuration ?? this.displayDuration,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize,
      'textColor': textColor.value,
      'backgroundColor': backgroundColor.value,
      'displayDuration': displayDuration,
    };
  }

  factory DisplaySettings.fromJson(Map<String, dynamic> json) {
    return DisplaySettings(
      fontSize: json['fontSize'] as double? ?? 20,
      textColor: Color(json['textColor'] as int? ?? Colors.white.value),
      backgroundColor: Color(
        json['backgroundColor'] as int? ?? Colors.black.value,
      ),
      displayDuration: json['displayDuration'] as int? ?? 120,
    );
  }
}

/// 消息过滤设置
class MessageFilterSettings {
  final bool showDanmaku;
  final bool showGift;
  final bool showSuperChat;
  final bool showGuard;
  final bool showLike;
  final bool showEnter;
  final bool showLiveStart;
  final bool showLiveEnd;

  const MessageFilterSettings({
    required this.showDanmaku,
    required this.showGift,
    required this.showSuperChat,
    required this.showGuard,
    required this.showLike,
    required this.showEnter,
    required this.showLiveStart,
    required this.showLiveEnd,
  });

  factory MessageFilterSettings.defaultSettings() {
    return const MessageFilterSettings(
      showDanmaku: true,
      showGift: true,
      showSuperChat: true,
      showGuard: true,
      showLike: true,
      showEnter: true,
      showLiveStart: true,
      showLiveEnd: true,
    );
  }

  MessageFilterSettings copyWith({
    bool? showDanmaku,
    bool? showGift,
    bool? showSuperChat,
    bool? showGuard,
    bool? showLike,
    bool? showEnter,
    bool? showLiveStart,
    bool? showLiveEnd,
  }) {
    return MessageFilterSettings(
      showDanmaku: showDanmaku ?? this.showDanmaku,
      showGift: showGift ?? this.showGift,
      showSuperChat: showSuperChat ?? this.showSuperChat,
      showGuard: showGuard ?? this.showGuard,
      showLike: showLike ?? this.showLike,
      showEnter: showEnter ?? this.showEnter,
      showLiveStart: showLiveStart ?? this.showLiveStart,
      showLiveEnd: showLiveEnd ?? this.showLiveEnd,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showDanmaku': showDanmaku,
      'showGift': showGift,
      'showSuperChat': showSuperChat,
      'showGuard': showGuard,
      'showLike': showLike,
      'showEnter': showEnter,
      'showLiveStart': showLiveStart,
      'showLiveEnd': showLiveEnd,
    };
  }

  factory MessageFilterSettings.fromJson(Map<String, dynamic> json) {
    return MessageFilterSettings(
      showDanmaku: json['showDanmaku'] as bool? ?? true,
      showGift: json['showGift'] as bool? ?? true,
      showSuperChat: json['showSuperChat'] as bool? ?? true,
      showGuard: json['showGuard'] as bool? ?? true,
      showLike: json['showLike'] as bool? ?? false,
      showEnter: json['showEnter'] as bool? ?? true,
      showLiveStart: json['showLiveStart'] as bool? ?? true,
      showLiveEnd: json['showLiveEnd'] as bool? ?? true,
    );
  }
}

/// 凭证设置（API credentials）
class CredentialsSettings {
  final String appId;
  final String accessKeyId;
  final String accessKeySecret;
  final String code;

  const CredentialsSettings({
    required this.appId,
    required this.accessKeyId,
    required this.accessKeySecret,
    required this.code,
  });

  factory CredentialsSettings.defaultSettings() {
    return const CredentialsSettings(
      appId: '',
      accessKeyId: '',
      accessKeySecret: '',
      code: '',
    );
  }

  CredentialsSettings copyWith({
    String? appId,
    String? accessKeyId,
    String? accessKeySecret,
    String? code,
  }) {
    return CredentialsSettings(
      appId: appId ?? this.appId,
      accessKeyId: accessKeyId ?? this.accessKeyId,
      accessKeySecret: accessKeySecret ?? this.accessKeySecret,
      code: code ?? this.code,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appId': appId,
      'accessKeyId': accessKeyId,
      'accessKeySecret': accessKeySecret,
      'code': code,
    };
  }

  factory CredentialsSettings.fromJson(Map<String, dynamic> json) {
    return CredentialsSettings(
      appId: json['appId'] as String? ?? '',
      accessKeyId: json['accessKeyId'] as String? ?? '',
      accessKeySecret: json['accessKeySecret'] as String? ?? '',
      code: json['code'] as String? ?? '',
    );
  }
}

/// 服务器设置
class ServerSettings {
  final String backendUrl;
  final bool enableHttpServer;
  final int httpServerPort;

  const ServerSettings({
    required this.backendUrl,
    required this.enableHttpServer,
    required this.httpServerPort,
  });

  factory ServerSettings.defaultSettings() {
    return const ServerSettings(
      backendUrl: '',
      enableHttpServer: false,
      httpServerPort: 18080,
    );
  }

  ServerSettings copyWith({
    String? backendUrl,
    bool? enableHttpServer,
    int? httpServerPort,
  }) {
    return ServerSettings(
      backendUrl: backendUrl ?? this.backendUrl,
      enableHttpServer: enableHttpServer ?? this.enableHttpServer,
      httpServerPort: httpServerPort ?? this.httpServerPort,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'backendUrl': backendUrl,
      'enableHttpServer': enableHttpServer,
      'httpServerPort': httpServerPort,
    };
  }

  factory ServerSettings.fromJson(Map<String, dynamic> json) {
    return ServerSettings(
      backendUrl: json['backendUrl'] as String? ?? '',
      enableHttpServer: json['enableHttpServer'] as bool? ?? false,
      httpServerPort: json['httpServerPort'] as int? ?? 18080,
    );
  }
}

/// 设置管理器
class SettingsManager {
  // SharedPreferences keys for display settings
  static const String _displaySettingsKey = 'display_settings';

  // SharedPreferences keys for filter settings
  static const String _filterSettingsKey = 'filter_settings';

  // SharedPreferences keys for credentials settings
  static const String _credentialsSettingsKey = 'credentials_settings';

  // SharedPreferences keys for server settings
  static const String _serverSettingsKey = 'server_settings';

  DisplaySettings _displaySettings = DisplaySettings.defaultSettings();
  MessageFilterSettings _filterSettings =
      MessageFilterSettings.defaultSettings();
  CredentialsSettings _credentialsSettings =
      CredentialsSettings.defaultSettings();
  ServerSettings _serverSettings = ServerSettings.defaultSettings();

  DisplaySettings get displaySettings => _displaySettings;
  MessageFilterSettings get filterSettings => _filterSettings;
  CredentialsSettings get credentialsSettings => _credentialsSettings;
  ServerSettings get serverSettings => _serverSettings;

  /// 加载设置
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    // 加载显示设置
    final displayJson = prefs.getString(_displaySettingsKey);
    if (displayJson != null) {
      try {
        // ignore: inference_failure_on_untyped_parameter
        _displaySettings = DisplaySettings.fromJson(
          Map<String, dynamic>.from(jsonDecode(displayJson)),
        );
      } catch (e) {
        // 解析失败，使用默认设置
      }
    }

    // 加载过滤设置
    final filterJson = prefs.getString(_filterSettingsKey);
    if (filterJson != null) {
      try {
        // ignore: inference_failure_on_untyped_parameter
        _filterSettings = MessageFilterSettings.fromJson(
          Map<String, dynamic>.from(jsonDecode(filterJson)),
        );
      } catch (e) {
        // 解析失败，使用默认设置
      }
    }

    // 加载凭证设置
    final credentialsJson = prefs.getString(_credentialsSettingsKey);
    if (credentialsJson != null) {
      try {
        // ignore: inference_failure_on_untyped_parameter
        _credentialsSettings = CredentialsSettings.fromJson(
          Map<String, dynamic>.from(jsonDecode(credentialsJson)),
        );
      } catch (e) {
        // 解析失败，使用默认设置
      }
    }

    // 加载服务器设置
    final serverJson = prefs.getString(_serverSettingsKey);
    if (serverJson != null) {
      try {
        // ignore: inference_failure_on_untyped_parameter
        _serverSettings = ServerSettings.fromJson(
          Map<String, dynamic>.from(jsonDecode(serverJson)),
        );
      } catch (e) {
        // 解析失败，使用默认设置
      }
    }
  }

  /// 保存显示设置
  Future<void> saveDisplaySettings(DisplaySettings settings) async {
    _displaySettings = settings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_displaySettingsKey, jsonEncode(settings.toJson()));
  }

  /// 保存过滤设置
  Future<void> saveFilterSettings(MessageFilterSettings settings) async {
    _filterSettings = settings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_filterSettingsKey, jsonEncode(settings.toJson()));
  }

  /// 保存凭证设置
  Future<void> saveCredentialsSettings(CredentialsSettings settings) async {
    _credentialsSettings = settings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _credentialsSettingsKey,
      jsonEncode(settings.toJson()),
    );
  }

  /// 保存服务器设置
  Future<void> saveServerSettings(ServerSettings settings) async {
    _serverSettings = settings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverSettingsKey, jsonEncode(settings.toJson()));
  }
}
