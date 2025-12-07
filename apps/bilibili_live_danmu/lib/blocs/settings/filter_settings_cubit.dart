import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Keys (private to this file)
const String _kShowDanmaku = 'filter.showDanmaku';
const String _kShowGift = 'filter.showGift';
const String _kShowSuperChat = 'filter.showSuperChat';
const String _kShowGuard = 'filter.showGuard';
const String _kShowLike = 'filter.showLike';
const String _kShowEnter = 'filter.showEnter';
const String _kShowLiveStart = 'filter.showLiveStart';
const String _kShowLiveEnd = 'filter.showLiveEnd';

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

class FilterSettingsCubit extends Cubit<FilterSettingsState> {
  final SharedPreferences _prefs;

  FilterSettingsCubit(this._prefs) : super(const FilterSettingsState()) {
    _load();
  }

  void _load() {
    emit(
      state.copyWith(
        showDanmaku: _prefs.getBool(_kShowDanmaku),
        showGift: _prefs.getBool(_kShowGift),
        showSuperChat: _prefs.getBool(_kShowSuperChat),
        showGuard: _prefs.getBool(_kShowGuard),
        showLike: _prefs.getBool(_kShowLike),
        showEnter: _prefs.getBool(_kShowEnter),
        showLiveStart: _prefs.getBool(_kShowLiveStart),
        showLiveEnd: _prefs.getBool(_kShowLiveEnd),
      ),
    );
  }

  Future<void> setShowDanmaku(bool value) async {
    await _prefs.setBool(_kShowDanmaku, value);
    emit(state.copyWith(showDanmaku: value));
  }

  Future<void> setShowGift(bool value) async {
    await _prefs.setBool(_kShowGift, value);
    emit(state.copyWith(showGift: value));
  }

  Future<void> setShowSuperChat(bool value) async {
    await _prefs.setBool(_kShowSuperChat, value);
    emit(state.copyWith(showSuperChat: value));
  }

  Future<void> setShowGuard(bool value) async {
    await _prefs.setBool(_kShowGuard, value);
    emit(state.copyWith(showGuard: value));
  }

  Future<void> setShowLike(bool value) async {
    await _prefs.setBool(_kShowLike, value);
    emit(state.copyWith(showLike: value));
  }

  Future<void> setShowEnter(bool value) async {
    await _prefs.setBool(_kShowEnter, value);
    emit(state.copyWith(showEnter: value));
  }

  Future<void> setShowLiveStart(bool value) async {
    await _prefs.setBool(_kShowLiveStart, value);
    emit(state.copyWith(showLiveStart: value));
  }

  Future<void> setShowLiveEnd(bool value) async {
    await _prefs.setBool(_kShowLiveEnd, value);
    emit(state.copyWith(showLiveEnd: value));
  }
}
