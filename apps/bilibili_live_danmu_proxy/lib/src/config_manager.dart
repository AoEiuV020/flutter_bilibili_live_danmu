import 'package:args/args.dart';
import 'package:bilibili_live_api_server/bilibili_live_api_server.dart';
import 'config_loader.dart';

/// 加载配置
Future<ServerConfig> loadConfig(ArgResults args) async {
  final configPath = args['config'] as String;

  // 尝试从文件加载配置
  ServerConfig? fileConfig;
  try {
    fileConfig = await ConfigLoader.loadFromFile(configPath);
    if (fileConfig != null) {
      print('已加载配置文件: $configPath');
    }
  } catch (e) {
    print('配置文件解析失败: $e');
    // 继续尝试使用命令行参数
  }

  // 获取命令行参数
  final accessKeyId = args['access-key-id'] as String?;
  final accessKeySecret = args['access-key-secret'] as String?;
  final backendUrl = args['backend-url'] as String?;
  final code = args['code'] as String?;
  final appIdStr = args['app-id'] as String?;
  final enableLogging = args['logging'] as bool;

  int? appId;
  if (appIdStr != null && appIdStr.isNotEmpty) {
    appId = int.tryParse(appIdStr);
  }

  // 合并配置
  return ConfigLoader.mergeWithArgs(
    fileConfig: fileConfig,
    accessKeyId: accessKeyId,
    accessKeySecret: accessKeySecret,
    backendUrl: backendUrl,
    code: code,
    appId: appId,
    enableLogging: enableLogging,
  );
}
