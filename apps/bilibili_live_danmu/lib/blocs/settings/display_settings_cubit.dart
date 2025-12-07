import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Keys (private to this file)
const String _kFontSize = 'display.fontSize';
const String _kTextColor = 'display.textColor';
const String _kBackgroundColor = 'display.backgroundColor';
const String _kDanmakuBackgroundColor = 'display.danmakuBackgroundColor';
const String _kDuration = 'display.duration';

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

class DisplaySettingsCubit extends Cubit<DisplaySettingsState> {
  final SharedPreferences _prefs;

  DisplaySettingsCubit(this._prefs) : super(const DisplaySettingsState()) {
    _load();
  }

  void _load() {
    emit(
      state.copyWith(
        fontSize: _prefs.getDouble(_kFontSize),
        textColor: _prefs.getInt(_kTextColor),
        backgroundColor: _prefs.getInt(_kBackgroundColor),
        danmakuBackgroundColor: _prefs.getInt(_kDanmakuBackgroundColor),
        duration: _prefs.getInt(_kDuration),
      ),
    );
  }

  Future<void> setFontSize(double value) async {
    await _prefs.setDouble(_kFontSize, value);
    emit(state.copyWith(fontSize: value));
  }

  Future<void> setTextColor(int value) async {
    await _prefs.setInt(_kTextColor, value);
    emit(state.copyWith(textColor: value));
  }

  Future<void> setBackgroundColor(int value) async {
    await _prefs.setInt(_kBackgroundColor, value);
    emit(state.copyWith(backgroundColor: value));
  }

  Future<void> setDanmakuBackgroundColor(int value) async {
    await _prefs.setInt(_kDanmakuBackgroundColor, value);
    emit(state.copyWith(danmakuBackgroundColor: value));
  }

  Future<void> setDuration(int value) async {
    await _prefs.setInt(_kDuration, value);
    emit(state.copyWith(duration: value));
  }
}
