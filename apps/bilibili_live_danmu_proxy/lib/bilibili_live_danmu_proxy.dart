/// Bilibili Live Danmu Proxy 库
library;

import 'dart:async';

import 'package:logger/logger.dart';
import 'src/server_runner.dart';
import 'src/logger.dart';

/// 主函数
Future<void> main(List<String> arguments) async {
  // 第一时间设置logger的默认printer（所有日志使用统一格式）
  Logger.defaultPrinter = () => SimplePrinter();
  Logger.defaultFilter = () => ProductionFilter();
  Logger.level = Level.debug;

  try {
    // 运行服务器
    await runServer(arguments);
  } catch (e, stackTrace) {
    logger.e('未捕获的异常', error: e, stackTrace: stackTrace);
    rethrow;
  }
}
