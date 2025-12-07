import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_parser.dart';

/// 服务器设置状态
class ServerSettingsState extends Equatable {
  final String backendUrl;
  final bool enableHttpServer;
  final int httpServerPort;

  const ServerSettingsState({
    this.backendUrl = '',
    this.enableHttpServer = false,
    this.httpServerPort = 18080,
  });

  ServerSettingsState copyWith({
    String? backendUrl,
    bool? enableHttpServer,
    int? httpServerPort,
  }) {
    return ServerSettingsState(
      backendUrl: backendUrl ?? this.backendUrl,
      enableHttpServer: enableHttpServer ?? this.enableHttpServer,
      httpServerPort: httpServerPort ?? this.httpServerPort,
    );
  }

  @override
  List<Object> get props => [backendUrl, enableHttpServer, httpServerPort];
}

/// 服务器设置 Cubit
///
/// 管理后端代理和 HTTP 服务器相关设置
class ServerSettingsCubit extends Cubit<ServerSettingsState> {
  /// SharedPreferences key: 后端 URL
  static const String keyBackendUrl = 'server-backend_url';

  /// SharedPreferences key: 启用 HTTP 服务器
  static const String keyEnableHttpServer = 'server-enable_http_server';

  /// SharedPreferences key: HTTP 服务器端口
  static const String keyHttpServerPort = 'server-http_server_port';

  /// 所有支持从参数读取的 setting keys
  static const List<String> settingKeys = [
    keyBackendUrl,
    keyEnableHttpServer,
    keyHttpServerPort,
  ];

  final SharedPreferences _prefs;

  /// 创建服务器设置 Cubit
  ///
  /// [prefs] SharedPreferences 实例
  /// [args] 命令行参数 Map，优先级高于 SharedPreferences
  ServerSettingsCubit(this._prefs, {Map<String, String?> args = const {}})
    : super(const ServerSettingsState()) {
    // 优先级: 参数传入 > SharedPreferences > 默认值(copyWith 传 null 时保持默认)
    emit(
      state.copyWith(
        backendUrl: SettingsParser.parseString(
          args[keyBackendUrl],
          _prefs.getString(keyBackendUrl),
        ),
        enableHttpServer: SettingsParser.parseBool(
          args[keyEnableHttpServer],
          _prefs.getBool(keyEnableHttpServer),
        ),
        httpServerPort: SettingsParser.parseInt(
          args[keyHttpServerPort],
          _prefs.getInt(keyHttpServerPort),
        ),
      ),
    );
  }

  /// 设置后端代理地址
  Future<void> setBackendUrl(String value) async {
    await _prefs.setString(keyBackendUrl, value);
    emit(state.copyWith(backendUrl: value));
  }

  /// 设置是否启用 HTTP 服务器
  Future<void> setEnableHttpServer(bool value) async {
    await _prefs.setBool(keyEnableHttpServer, value);
    emit(state.copyWith(enableHttpServer: value));
  }

  /// 设置 HTTP 服务器端口
  Future<void> setHttpServerPort(int value) async {
    await _prefs.setInt(keyHttpServerPort, value);
    emit(state.copyWith(httpServerPort: value));
  }
}
