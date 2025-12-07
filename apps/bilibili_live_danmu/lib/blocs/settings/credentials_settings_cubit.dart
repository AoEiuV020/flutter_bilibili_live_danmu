import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_parser.dart';

/// 凭证设置状态
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

/// 凭证设置 Cubit
///
/// 管理 B 站 API 凭证相关设置
class CredentialsSettingsCubit extends Cubit<CredentialsSettingsState> {
  /// SharedPreferences key: App ID
  static const String keyAppId = 'credentials-app_id';

  /// SharedPreferences key: Access Key ID
  static const String keyAccessKeyId = 'credentials-access_key_id';

  /// SharedPreferences key: Access Key Secret
  static const String keyAccessKeySecret = 'credentials-access_key_secret';

  /// SharedPreferences key: 主播身份码
  static const String keyCode = 'credentials-code';

  /// 所有支持从参数读取的 setting keys
  static const List<String> settingKeys = [
    keyAppId,
    keyAccessKeyId,
    keyAccessKeySecret,
    keyCode,
  ];

  final SharedPreferences _prefs;

  /// 创建凭证设置 Cubit
  ///
  /// [prefs] SharedPreferences 实例
  /// [args] 命令行参数 Map，优先级高于 SharedPreferences
  CredentialsSettingsCubit(this._prefs, {Map<String, String?> args = const {}})
    : super(const CredentialsSettingsState()) {
    // 优先级: 参数传入 > SharedPreferences > 默认值(copyWith 传 null 时保持默认)
    emit(
      state.copyWith(
        appId: SettingsParser.parseString(
          args[keyAppId],
          _prefs.getString(keyAppId),
        ),
        accessKeyId: SettingsParser.parseString(
          args[keyAccessKeyId],
          _prefs.getString(keyAccessKeyId),
        ),
        accessKeySecret: SettingsParser.parseString(
          args[keyAccessKeySecret],
          _prefs.getString(keyAccessKeySecret),
        ),
        code: SettingsParser.parseString(
          args[keyCode],
          _prefs.getString(keyCode),
        ),
      ),
    );
  }

  /// 设置 App ID
  Future<void> setAppId(String value) async {
    await _prefs.setString(keyAppId, value);
    emit(state.copyWith(appId: value));
  }

  /// 设置 Access Key ID
  Future<void> setAccessKeyId(String value) async {
    await _prefs.setString(keyAccessKeyId, value);
    emit(state.copyWith(accessKeyId: value));
  }

  /// 设置 Access Key Secret
  Future<void> setAccessKeySecret(String value) async {
    await _prefs.setString(keyAccessKeySecret, value);
    emit(state.copyWith(accessKeySecret: value));
  }

  /// 设置主播身份码
  Future<void> setCode(String value) async {
    await _prefs.setString(keyCode, value);
    emit(state.copyWith(code: value));
  }
}
