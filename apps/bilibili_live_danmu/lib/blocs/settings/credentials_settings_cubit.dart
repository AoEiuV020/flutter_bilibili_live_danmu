import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Keys (private to this file)
const String _kAppId = 'credentials.appId';
const String _kAccessKeyId = 'credentials.accessKeyId';
const String _kAccessKeySecret = 'credentials.accessKeySecret';
const String _kCode = 'credentials.code';

class CredentialsSettingsState extends Equatable {
  final String appId;
  final String accessKeyId;
  final String accessKeySecret;
  final String code;

  const CredentialsSettingsState({
    this.appId = '',
    this.accessKeyId = '',
    this.accessKeySecret = '',
    this.code = '',
  });

  CredentialsSettingsState copyWith({
    String? appId,
    String? accessKeyId,
    String? accessKeySecret,
    String? code,
  }) {
    return CredentialsSettingsState(
      appId: appId ?? this.appId,
      accessKeyId: accessKeyId ?? this.accessKeyId,
      accessKeySecret: accessKeySecret ?? this.accessKeySecret,
      code: code ?? this.code,
    );
  }

  @override
  List<Object> get props => [appId, accessKeyId, accessKeySecret, code];
}

class CredentialsSettingsCubit extends Cubit<CredentialsSettingsState> {
  final SharedPreferences _prefs;

  CredentialsSettingsCubit(this._prefs)
    : super(const CredentialsSettingsState()) {
    _load();
  }

  void _load() {
    emit(
      state.copyWith(
        appId: _prefs.getString(_kAppId),
        accessKeyId: _prefs.getString(_kAccessKeyId),
        accessKeySecret: _prefs.getString(_kAccessKeySecret),
        code: _prefs.getString(_kCode),
      ),
    );
  }

  Future<void> setAppId(String value) async {
    await _prefs.setString(_kAppId, value);
    emit(state.copyWith(appId: value));
  }

  Future<void> setAccessKeyId(String value) async {
    await _prefs.setString(_kAccessKeyId, value);
    emit(state.copyWith(accessKeyId: value));
  }

  Future<void> setAccessKeySecret(String value) async {
    await _prefs.setString(_kAccessKeySecret, value);
    emit(state.copyWith(accessKeySecret: value));
  }

  Future<void> setCode(String value) async {
    await _prefs.setString(_kCode, value);
    emit(state.copyWith(code: value));
  }
}
