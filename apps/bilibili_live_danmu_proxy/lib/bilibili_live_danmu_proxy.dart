/// Bilibili Live Danmu Proxy 库
library bilibili_live_danmu_proxy;

import 'dart:async';

import 'package:logger/logger.dart';
import 'src/server_runner.dart';
import 'src/logger.dart';

/// 主函数
Future<void> main(List<String> arguments) async {
  // 第一时间设置logger的默认printer（所有日志使用统一格式）
  Logger.defaultPrinter = () => PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  );
  Logger.level = Level.debug;

  try {
    // 运行服务器
    await runServer(arguments);
  } catch (e, stackTrace) {
    logger.e('未捕获的异常', error: e, stackTrace: stackTrace);
    rethrow;
  }
}
