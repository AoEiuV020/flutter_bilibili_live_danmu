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

/// 设置管理器
class SettingsManager {
  static const String _displaySettingsKey = 'display_settings';
  static const String _filterSettingsKey = 'filter_settings';

  DisplaySettings _displaySettings = DisplaySettings.defaultSettings();
  MessageFilterSettings _filterSettings =
      MessageFilterSettings.defaultSettings();

  DisplaySettings get displaySettings => _displaySettings;
  MessageFilterSettings get filterSettings => _filterSettings;

  /// 加载设置
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    // 加载显示设置
    final displayJson = prefs.getString(_displaySettingsKey);
    if (displayJson != null) {
      try {
        _displaySettings = DisplaySettings.fromJson(
          Map<String, dynamic>.from(
            // ignore: inference_failure_on_untyped_parameter
            Uri.decodeComponent(
              displayJson,
            ).split('&').fold<Map<String, dynamic>>({}, (map, item) {
              final parts = item.split('=');
              if (parts.length == 2) {
                map[parts[0]] =
                    int.tryParse(parts[1]) ??
                    double.tryParse(parts[1]) ??
                    parts[1];
              }
              return map;
            }),
          ),
        );
      } catch (e) {
        // 解析失败，使用默认设置
      }
    }

    // 加载过滤设置
    final filterJson = prefs.getString(_filterSettingsKey);
    if (filterJson != null) {
      try {
        _filterSettings = MessageFilterSettings.fromJson(
          Map<String, dynamic>.from(
            // ignore: inference_failure_on_untyped_parameter
            Uri.decodeComponent(
              filterJson,
            ).split('&').fold<Map<String, dynamic>>({}, (map, item) {
              final parts = item.split('=');
              if (parts.length == 2) {
                map[parts[0]] = parts[1] == 'true';
              }
              return map;
            }),
          ),
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
    final json = settings.toJson();
    await prefs.setString(
      _displaySettingsKey,
      Uri.encodeComponent(
        json.entries.map((e) => '${e.key}=${e.value}').join('&'),
      ),
    );
  }

  /// 保存过滤设置
  Future<void> saveFilterSettings(MessageFilterSettings settings) async {
    _filterSettings = settings;
    final prefs = await SharedPreferences.getInstance();
    final json = settings.toJson();
    await prefs.setString(
      _filterSettingsKey,
      Uri.encodeComponent(
        json.entries.map((e) => '${e.key}=${e.value}').join('&'),
      ),
    );
  }
}
