import 'dart:io';

import 'package:args/args.dart';

import '../blocs/settings/credentials_settings_cubit.dart';
import '../blocs/settings/display_settings_cubit.dart';
import '../blocs/settings/filter_settings_cubit.dart';
import '../blocs/settings/launch_settings_cubit.dart';
import '../blocs/settings/server_settings_cubit.dart';
import '../src/logger.dart';
import 'parse_util.dart' if (dart.library.html) 'parse_util_web.dart';

/// 所有支持从参数读取的 key（从各 Cubit 整合）
///
/// 参数的 key 必须恰好与这些值相同才有效
List<String> get _allSupportedSettingKeys => [
  ...CredentialsSettingsCubit.settingKeys,
  ...ServerSettingsCubit.settingKeys,
  ...DisplaySettingsCubit.settingKeys,
  ...FilterSettingsCubit.settingKeys,
  ...LaunchSettingsCubit.settingKeys,
];

/// 从配置文件读取参数
///
/// 配置文件格式：
/// ```
/// key=value
/// ```
///
/// 只有在 [_supportedSettingKeys] 中的 key 才会被读取
Future<Map<String, String?>> _loadConfigFile(String? configPath) async {
  if (configPath == null || configPath.isEmpty) {
    return {};
  }

  try {
    final file = File(configPath);
    if (!await file.exists()) {
      logger.w('警告: 配置文件不存在: $configPath');
      return {};
    }

    final config = <String, String?>{};
    final lines = await file.readAsLines();

    for (final line in lines) {
      if (line.trim().isEmpty || line.startsWith('#')) continue;
      final parts = line.split('=');
      if (parts.length == 2) {
        final key = parts[0].trim();
        final value = parts[1].trim();
        // 只读取支持的 key
        if (value.isNotEmpty && _allSupportedSettingKeys.contains(key)) {
          config[key] = value;
        }
      }
    }

    return config;
  } catch (e, stackTrace) {
    logger.e('警告: 读取配置文件失败: $e', error: e, stackTrace: stackTrace);
    return {};
  }
}

/// 解析命令行参数
///
/// 桌面端使用命令行参数，Web 端从 URL 查询参数解析
///
/// 返回参数 Map，key 为各个 Cubit 的静态 key
///
/// 优先级（从高到低）：
/// 1. 命令行参数
/// 2. 配置文件参数（--config 指定的文件）
///
/// 示例:
/// - 桌面: app --credentials-app_id=123 --credentials-code=abc --launch-auto_start=true
/// - 桌面配置文件: app --config=/path/to/config.properties
/// - Web: ?credentials-app_id=123&credentials-code=abc&launch-auto_start=true
Future<Map<String, String?>> parseAppOptions(List<String> args) async {
  final parser = ArgParser()..addOption('config', abbr: 'c', help: '配置文件路径');

  // 动态添加所有支持的 key 为选项
  for (final key in _allSupportedSettingKeys) {
    parser.addOption(key);
  }

  ArgResults parseResult;
  try {
    args = await prepareArgs(args);
    parseResult = parser.parse(args);
  } catch (error, stackTrace) {
    logger.e('Could not parse args: $error\n$stackTrace');
    parseResult = parser.parse([]);
  }

  // 先从配置文件读取（优先级最低）
  final configFile = parseResult['config'] as String?;
  final settings = await _loadConfigFile(configFile);

  // 命令行参数覆盖配置文件
  for (final key in _allSupportedSettingKeys) {
    final value = parseResult[key] as String?;
    if (value != null && value.isNotEmpty) {
      settings[key] = value;
    }
  }

  return settings;
}
