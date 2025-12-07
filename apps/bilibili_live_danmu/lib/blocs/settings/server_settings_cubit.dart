import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Keys (private to this file)
const String _kBackendUrl = 'server.backendUrl';
const String _kEnableHttpServer = 'server.enableHttpServer';
const String _kHttpServerPort = 'server.httpServerPort';

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

class ServerSettingsCubit extends Cubit<ServerSettingsState> {
  final SharedPreferences _prefs;

  ServerSettingsCubit(this._prefs) : super(const ServerSettingsState()) {
    _load();
  }

  void _load() {
    emit(
      state.copyWith(
        backendUrl: _prefs.getString(_kBackendUrl),
        enableHttpServer: _prefs.getBool(_kEnableHttpServer),
        httpServerPort: _prefs.getInt(_kHttpServerPort),
      ),
    );
  }

  Future<void> setBackendUrl(String value) async {
    await _prefs.setString(_kBackendUrl, value);
    emit(state.copyWith(backendUrl: value));
  }

  Future<void> setEnableHttpServer(bool value) async {
    await _prefs.setBool(_kEnableHttpServer, value);
    emit(state.copyWith(enableHttpServer: value));
  }

  Future<void> setHttpServerPort(int value) async {
    await _prefs.setInt(_kHttpServerPort, value);
    emit(state.copyWith(httpServerPort: value));
  }
}
