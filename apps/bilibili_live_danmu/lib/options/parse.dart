import 'dart:io';

import 'package:args/args.dart';

import 'app_options.dart';
import 'parse_util.dart' if (dart.library.html) 'parse_util_web.dart';
import '../src/logger.dart';

/// 从配置文件读取参数
///
/// 配置文件格式：
/// ```
/// app_id=value
/// access_key_id=value
/// access_key_secret=value
/// code=value
/// backend_url=value
/// ```
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
        if (value.isNotEmpty) {
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
/// 优先级（从高到低）：
/// 1. 命令行参数（--app-id 等）
/// 2. 配置文件参数（--config 指定的文件）
///
/// 示例:
/// - 桌面: app --app-id=123 --code=abc --access-key-id=xxx --access-key-secret=yyy --auto-start
/// - 桌面配置文件: app --config=/path/to/config.properties
/// - Web: ?app-id=123&code=abc&backend-url=http://localhost:8080&auto-start
Future<AppOptions> parseAppOptions(List<String> args) async {
  final parser = ArgParser()
    ..addOption('config', abbr: 'c', help: '配置文件路径')
    ..addOption('app-id', help: '项目 ID')
    ..addOption('access-key-id', help: 'Access Key ID')
    ..addOption('access-key-secret', help: 'Access Key Secret')
    ..addOption('code', help: '主播身份码')
    ..addOption('backend-url', help: '后端代理地址')
    ..addFlag('auto-start', help: '自动开始直播', defaultsTo: false);

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
  final fileConfig = await _loadConfigFile(configFile);

  // 命令行参数覆盖配置文件
  final appId = parseResult['app-id'] as String? ?? fileConfig['app_id'];
  final accessKeyId =
      parseResult['access-key-id'] as String? ?? fileConfig['access_key_id'];
  final accessKeySecret =
      parseResult['access-key-secret'] as String? ??
      fileConfig['access_key_secret'];
  final code = parseResult['code'] as String? ?? fileConfig['code'];
  final backendUrl =
      parseResult['backend-url'] as String? ?? fileConfig['backend_url'];

  return AppOptions(
    appId: appId,
    accessKeyId: accessKeyId,
    accessKeySecret: accessKeySecret,
    code: code,
    backendUrl: backendUrl,
    autoStart: parseResult.flag('auto-start'),
  );
}
