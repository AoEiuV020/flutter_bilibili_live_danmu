import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_parser.dart';

/// 启动参数状态
class LaunchSettingsState extends Equatable {
  final bool autoStart;

  const LaunchSettingsState({this.autoStart = false});

  LaunchSettingsState copyWith({bool? autoStart}) {
    return LaunchSettingsState(autoStart: autoStart ?? this.autoStart);
  }

  @override
  List<Object> get props => [autoStart];
}

/// 启动参数 Cubit
///
/// 管理应用启动相关的参数，如自动开始直播等
class LaunchSettingsCubit extends Cubit<LaunchSettingsState> {
  /// SharedPreferences key: 自动开始直播
  static const String keyAutoStart = 'launch-auto_start';

  /// 所有支持从参数读取的 launch keys
  static const List<String> settingKeys = [keyAutoStart];

  /// 创建启动参数 Cubit
  ///
  /// [args] 命令行参数 Map，包含启动参数
  LaunchSettingsCubit({Map<String, String?> args = const {}})
    : super(const LaunchSettingsState()) {
    // 从参数读取 autoStart 标志，使用 SettingsParser 统一处理
    emit(
      state.copyWith(
        autoStart: SettingsParser.parseBool(args[keyAutoStart], null),
      ),
    );
  }
}
