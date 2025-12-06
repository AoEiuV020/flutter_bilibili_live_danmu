import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:logger/logger.dart';
import 'package:bilibili_live_api_server/bilibili_live_api_server.dart';
import 'package:bilibili_live_danmu_proxy/bilibili_live_danmu_proxy.dart';
import 'package:bilibili_live_danmu_proxy/src/logger.dart';

/// 默认配置文件路径
const String _defaultConfigPath = 'config.properties';

/// 默认监听端口
const int _defaultPort = 8080;

/// 默认监听地址
const String _defaultAddress = '0.0.0.0';

void main(List<String> arguments) async {
  // 第一时间设置logger的默认printer（所有日志使用统一格式）
  Logger.defaultPrinter = () => PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  );

  final parser = ArgParser()
    ..addOption(
      'config',
      abbr: 'c',
      help: '配置文件路径',
      defaultsTo: _defaultConfigPath,
    )
    ..addOption(
      'port',
      abbr: 'p',
      help: '监听端口',
      defaultsTo: _defaultPort.toString(),
    )
    ..addOption('address', abbr: 'a', help: '监听地址', defaultsTo: _defaultAddress)
    ..addOption('access-key-id', help: 'Access Key ID（与 backend-url 二选一）')
    ..addOption(
      'access-key-secret',
      help: 'Access Key Secret（与 backend-url 二选一）',
    )
    ..addOption('backend-url', help: '后端代理地址（与 accessKey 二选一）')
    ..addOption('code', help: '主播身份码')
    ..addOption('app-id', help: '项目 ID')
    ..addFlag('logging', help: '启用请求日志', defaultsTo: true)
    ..addFlag('help', abbr: 'h', negatable: false, help: '显示帮助信息');

  ArgResults args;
  try {
    args = parser.parse(arguments);
  } catch (e, stackTrace) {
    logger.e('参数解析错误: $e', error: e, stackTrace: stackTrace);
    print('');
    _printUsage(parser);
    exit(1);
  }

  if (args['help'] as bool) {
    _printUsage(parser);
    exit(0);
  }

  // 加载配置
  ServerConfig config;
  try {
    config = await _loadConfig(args);
  } catch (e, stackTrace) {
    logger.e('配置加载失败: $e', error: e, stackTrace: stackTrace);
    exit(1);
  }

  // 解析端口和地址
  final port = int.tryParse(args['port'] as String) ?? _defaultPort;
  final address = args['address'] as String;

  // 创建服务器
  final server = BilibiliLiveApiServer(config: config);

  // 注册信号处理器，优雅关闭
  _setupSignalHandlers(server);

  // 启动服务器
  try {
    await server.start(port: port, address: address);
    logger.i('服务器运行中，按 Ctrl+C 停止...');
  } catch (e, stackTrace) {
    logger.e('服务器启动失败: $e', error: e, stackTrace: stackTrace);
    exit(1);
  }
}

/// 打印使用说明
void _printUsage(ArgParser parser) {
  print('Bilibili Live API Proxy Server');
  print('');
  print('用法: bilibili_live_danmu_proxy [选项]');
  print('');
  print(parser.usage);
  print('');
  print('示例:');
  print('  bilibili_live_danmu_proxy -c config.properties');
  print(
    '  bilibili_live_danmu_proxy --access-key-id=xxx --access-key-secret=yyy',
  );
  print('  bilibili_live_danmu_proxy --backend-url=http://localhost:3000');
  print('  bilibili_live_danmu_proxy -p 3000 -a localhost');
}

/// 加载配置
Future<ServerConfig> _loadConfig(ArgResults args) async {
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

/// 设置信号处理器
void _setupSignalHandlers(BilibiliLiveApiServer server) {
  // 用于防止重复关闭
  var isShuttingDown = false;

  Future<void> shutdown(String signal) async {
    if (isShuttingDown) return;
    isShuttingDown = true;

    print('');
    print('收到 $signal 信号，正在关闭服务器...');

    try {
      await server.stop();
      print('服务器已优雅关闭');
      exit(0);
    } catch (e) {
      print('关闭服务器时出错: $e');
      exit(1);
    }
  }

  // 监听 SIGINT (Ctrl+C)
  ProcessSignal.sigint.watch().listen((_) => shutdown('SIGINT'));

  // 监听 SIGTERM
  if (!Platform.isWindows) {
    ProcessSignal.sigterm.watch().listen((_) => shutdown('SIGTERM'));
  }
}
