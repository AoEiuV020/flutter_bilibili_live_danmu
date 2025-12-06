import 'dart:async';

import 'package:args/args.dart';
import 'package:bilibili_live_api_server/bilibili_live_api_server.dart';
import 'arg_parser.dart';
import 'config_manager.dart';
import 'signal_handler.dart';
import 'logger.dart';

/// 运行服务器
Future<void> runServer(List<String> arguments) async {
  final parser = createArgParser();

  ArgResults args;
  try {
    args = parser.parse(arguments);
  } catch (e, stackTrace) {
    logger.e('参数解析错误: $e', error: e, stackTrace: stackTrace);
    print('');
    printUsage(parser);
    throw Exception('参数解析失败');
  }

  if (args['help'] as bool) {
    printUsage(parser);
    return;
  }

  // 加载配置
  ServerConfig config;
  try {
    config = await loadConfig(args);
  } catch (e, stackTrace) {
    logger.e('配置加载失败: $e', error: e, stackTrace: stackTrace);
    throw Exception('配置加载失败');
  }

  // 解析端口和地址
  final port = int.tryParse(args['port'] as String) ?? defaultPort;
  final address = args['address'] as String;

  // 创建服务器
  final server = BilibiliLiveApiServer(config: config);

  // 注册信号处理器，优雅关闭
  setupSignalHandlers(server);

  // 启动服务器
  try {
    await server.start(port: port, address: address);
    logger.i('服务器运行中，按 Ctrl+C 停止...');
  } catch (e, stackTrace) {
    logger.e('服务器启动失败: $e', error: e, stackTrace: stackTrace);
    throw Exception('服务器启动失败: $e');
  }
}
