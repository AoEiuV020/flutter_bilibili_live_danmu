import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_parser.dart';

/// 显示设置状态
class DisplaySettingsState extends Equatable {
  final double fontSize;
  final int textColor;
  final int backgroundColor;
  final int danmakuBackgroundColor;
  final int duration;

  const DisplaySettingsState({
    this.fontSize = 20.0,
    this.textColor = 0xFFFFFFFF, // Colors.white
    this.backgroundColor = 0x00000000, // 透明，实际是黑色，
    this.danmakuBackgroundColor = 0x33000000, // 黑色半透明
    this.duration = 120,
  });

  DisplaySettingsState copyWith({
    double? fontSize,
    int? textColor,
    int? backgroundColor,
    int? danmakuBackgroundColor,
    int? duration,
  }) {
    return DisplaySettingsState(
      fontSize: fontSize ?? this.fontSize,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      danmakuBackgroundColor:
          danmakuBackgroundColor ?? this.danmakuBackgroundColor,
      duration: duration ?? this.duration,
    );
  }

  @override
  List<Object> get props => [
    fontSize,
    textColor,
    backgroundColor,
    danmakuBackgroundColor,
    duration,
  ];
}

/// 显示设置 Cubit
///
/// 管理弹幕显示相关设置
class DisplaySettingsCubit extends Cubit<DisplaySettingsState> {
  /// SharedPreferences key: 字体大小
  static const String keyFontSize = 'display-font_size';

  /// SharedPreferences key: 文字颜色
  static const String keyTextColor = 'display-text_color';

  /// SharedPreferences key: 背景色
  static const String keyBackgroundColor = 'display-background_color';

  /// SharedPreferences key: 弹幕背景色
  static const String keyDanmakuBackgroundColor =
      'display-danmaku_background_color';

  /// SharedPreferences key: 弹幕持续时间
  static const String keyDuration = 'display-duration';

  /// 所有支持从参数读取的 setting keys
  static const List<String> settingKeys = [
    keyFontSize,
    keyTextColor,
    keyBackgroundColor,
    keyDanmakuBackgroundColor,
    keyDuration,
  ];

  final SharedPreferences _prefs;

  /// 创建显示设置 Cubit
  ///
  /// [prefs] SharedPreferences 实例
  /// [args] 命令行参数 Map，优先级高于 SharedPreferences
  DisplaySettingsCubit(this._prefs, {Map<String, String?> args = const {}})
    : super(const DisplaySettingsState()) {
    // 优先级: 参数传入 > SharedPreferences > 默认值(copyWith 传 null 时保持默认)
    emit(
      state.copyWith(
        fontSize: SettingsParser.parseDouble(
          args[keyFontSize],
          _prefs.getDouble(keyFontSize),
        ),
        textColor: SettingsParser.parseInt(
          args[keyTextColor],
          _prefs.getInt(keyTextColor),
        ),
        backgroundColor: SettingsParser.parseInt(
          args[keyBackgroundColor],
          _prefs.getInt(keyBackgroundColor),
        ),
        danmakuBackgroundColor: SettingsParser.parseInt(
          args[keyDanmakuBackgroundColor],
          _prefs.getInt(keyDanmakuBackgroundColor),
        ),
        duration: SettingsParser.parseInt(
          args[keyDuration],
          _prefs.getInt(keyDuration),
        ),
      ),
    );
  }

  /// 设置字体大小
  Future<void> setFontSize(double value) async {
    await _prefs.setDouble(keyFontSize, value);
    emit(state.copyWith(fontSize: value));
  }

  /// 设置文字颜色
  Future<void> setTextColor(int value) async {
    await _prefs.setInt(keyTextColor, value);
    emit(state.copyWith(textColor: value));
  }

  /// 设置背景颜色
  Future<void> setBackgroundColor(int value) async {
    await _prefs.setInt(keyBackgroundColor, value);
    emit(state.copyWith(backgroundColor: value));
  }

  /// 设置弹幕背景颜色
  Future<void> setDanmakuBackgroundColor(int value) async {
    await _prefs.setInt(keyDanmakuBackgroundColor, value);
    emit(state.copyWith(danmakuBackgroundColor: value));
  }

  /// 设置弹幕持续时间
  Future<void> setDuration(int value) async {
    await _prefs.setInt(keyDuration, value);
    emit(state.copyWith(duration: value));
  }
}
