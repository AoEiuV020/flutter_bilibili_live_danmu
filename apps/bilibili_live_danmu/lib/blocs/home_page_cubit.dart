import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings/credentials_settings_cubit.dart';
import 'settings/launch_settings_cubit.dart';
import 'settings/server_settings_cubit.dart';

/// Home 页面状态
///
/// 直接持有其他 Cubit 的状态，避免重复平铺字段
class HomePageState extends Equatable {
  /// 凭证设置状态
  final CredentialsSettingsState credentialsState;

  /// 服务器设置状态
  final ServerSettingsState serverState;

  /// 启动参数状态
  final LaunchSettingsState launchState;

  const HomePageState({
    required this.credentialsState,
    required this.serverState,
    required this.launchState,
  });

  HomePageState copyWith({
    CredentialsSettingsState? credentialsState,
    ServerSettingsState? serverState,
    LaunchSettingsState? launchState,
  }) {
    return HomePageState(
      credentialsState: credentialsState ?? this.credentialsState,
      serverState: serverState ?? this.serverState,
      launchState: launchState ?? this.launchState,
    );
  }

  @override
  List<Object> get props => [credentialsState, serverState, launchState];
}

/// Home 页面业务逻辑 Cubit
///
/// 职责：
/// - 同步其他 Cubit 的状态变化
/// - 判断是否可以自动开始
class HomePageCubit extends Cubit<HomePageState> {
  final CredentialsSettingsCubit _credentialsCubit;
  final ServerSettingsCubit _serverCubit;
  final LaunchSettingsCubit _launchCubit;

  HomePageCubit(this._credentialsCubit, this._serverCubit, this._launchCubit)
    : super(
        HomePageState(
          credentialsState: _credentialsCubit.state,
          serverState: _serverCubit.state,
          launchState: _launchCubit.state,
        ),
      ) {
    // 监听其他 Cubit 的状态变化
    _setupListeners();
  }

  /// 设置监听其他 Cubit 的状态变化
  void _setupListeners() {
    _credentialsCubit.stream.listen((credState) {
      emit(state.copyWith(credentialsState: credState));
    });

    _serverCubit.stream.listen((serverState) {
      emit(state.copyWith(serverState: serverState));
    });

    _launchCubit.stream.listen((launchState) {
      emit(state.copyWith(launchState: launchState));
    });
  }

  /// 检查是否可以自动开始
  ///
  /// 返回 true 表示应该自动开始直播
  bool canAutoStart() {
    return state.launchState.autoStart;
  }

  /// 检查是否处于代理模式
  bool isProxyMode() {
    return state.serverState.backendUrl.trim().isNotEmpty;
  }
}
