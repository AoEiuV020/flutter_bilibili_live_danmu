import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_parser.dart';

/// 过滤设置状态
class FilterSettingsState extends Equatable {
  final bool showDanmaku;
  final bool showGift;
  final bool showSuperChat;
  final bool showGuard;
  final bool showLike;
  final bool showEnter;
  final bool showLiveStart;
  final bool showLiveEnd;

  const FilterSettingsState({
    this.showDanmaku = true,
    this.showGift = true,
    this.showSuperChat = true,
    this.showGuard = true,
    this.showLike = false,
    this.showEnter = true,
    this.showLiveStart = true,
    this.showLiveEnd = true,
  });

  FilterSettingsState copyWith({
    bool? showDanmaku,
    bool? showGift,
    bool? showSuperChat,
    bool? showGuard,
    bool? showLike,
    bool? showEnter,
    bool? showLiveStart,
    bool? showLiveEnd,
  }) {
    return FilterSettingsState(
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

  @override
  List<Object> get props => [
    showDanmaku,
    showGift,
    showSuperChat,
    showGuard,
    showLike,
    showEnter,
    showLiveStart,
    showLiveEnd,
  ];
}

/// 过滤设置 Cubit
///
/// 管理弹幕过滤相关设置
class FilterSettingsCubit extends Cubit<FilterSettingsState> {
  /// SharedPreferences key: 显示弹幕
  static const String keyShowDanmaku = 'filter-show_danmaku';

  /// SharedPreferences key: 显示礼物
  static const String keyShowGift = 'filter-show_gift';

  /// SharedPreferences key: 显示醒目留言
  static const String keyShowSuperChat = 'filter-show_super_chat';

  /// SharedPreferences key: 显示舰长
  static const String keyShowGuard = 'filter-show_guard';

  /// SharedPreferences key: 显示点赞
  static const String keyShowLike = 'filter-show_like';

  /// SharedPreferences key: 显示入场
  static const String keyShowEnter = 'filter-show_enter';

  /// SharedPreferences key: 显示开播
  static const String keyShowLiveStart = 'filter-show_live_start';

  /// SharedPreferences key: 显示下播
  static const String keyShowLiveEnd = 'filter-show_live_end';

  /// 所有支持从参数读取的 setting keys
  static const List<String> settingKeys = [
    keyShowDanmaku,
    keyShowGift,
    keyShowSuperChat,
    keyShowGuard,
    keyShowLike,
    keyShowEnter,
    keyShowLiveStart,
    keyShowLiveEnd,
  ];

  final SharedPreferences _prefs;

  /// 创建过滤设置 Cubit
  ///
  /// [prefs] SharedPreferences 实例
  /// [args] 命令行参数 Map，优先级高于 SharedPreferences
  FilterSettingsCubit(this._prefs, {Map<String, String?> args = const {}})
    : super(const FilterSettingsState()) {
    // 优先级: 参数传入 > SharedPreferences > 默认值(copyWith 传 null 时保持默认)
    emit(
      state.copyWith(
        showDanmaku: SettingsParser.parseBool(
          args[keyShowDanmaku],
          _prefs.getBool(keyShowDanmaku),
        ),
        showGift: SettingsParser.parseBool(
          args[keyShowGift],
          _prefs.getBool(keyShowGift),
        ),
        showSuperChat: SettingsParser.parseBool(
          args[keyShowSuperChat],
          _prefs.getBool(keyShowSuperChat),
        ),
        showGuard: SettingsParser.parseBool(
          args[keyShowGuard],
          _prefs.getBool(keyShowGuard),
        ),
        showLike: SettingsParser.parseBool(
          args[keyShowLike],
          _prefs.getBool(keyShowLike),
        ),
        showEnter: SettingsParser.parseBool(
          args[keyShowEnter],
          _prefs.getBool(keyShowEnter),
        ),
        showLiveStart: SettingsParser.parseBool(
          args[keyShowLiveStart],
          _prefs.getBool(keyShowLiveStart),
        ),
        showLiveEnd: SettingsParser.parseBool(
          args[keyShowLiveEnd],
          _prefs.getBool(keyShowLiveEnd),
        ),
      ),
    );
  }

  /// 设置是否显示弹幕
  Future<void> setShowDanmaku(bool value) async {
    await _prefs.setBool(keyShowDanmaku, value);
    emit(state.copyWith(showDanmaku: value));
  }

  /// 设置是否显示礼物
  Future<void> setShowGift(bool value) async {
    await _prefs.setBool(keyShowGift, value);
    emit(state.copyWith(showGift: value));
  }

  /// 设置是否显示醒目留言
  Future<void> setShowSuperChat(bool value) async {
    await _prefs.setBool(keyShowSuperChat, value);
    emit(state.copyWith(showSuperChat: value));
  }

  /// 设置是否显示舰长
  Future<void> setShowGuard(bool value) async {
    await _prefs.setBool(keyShowGuard, value);
    emit(state.copyWith(showGuard: value));
  }

  /// 设置是否显示点赞
  Future<void> setShowLike(bool value) async {
    await _prefs.setBool(keyShowLike, value);
    emit(state.copyWith(showLike: value));
  }

  /// 设置是否显示入场
  Future<void> setShowEnter(bool value) async {
    await _prefs.setBool(keyShowEnter, value);
    emit(state.copyWith(showEnter: value));
  }

  /// 设置是否显示开播
  Future<void> setShowLiveStart(bool value) async {
    await _prefs.setBool(keyShowLiveStart, value);
    emit(state.copyWith(showLiveStart: value));
  }

  /// 设置是否显示下播
  Future<void> setShowLiveEnd(bool value) async {
    await _prefs.setBool(keyShowLiveEnd, value);
    emit(state.copyWith(showLiveEnd: value));
  }
}
