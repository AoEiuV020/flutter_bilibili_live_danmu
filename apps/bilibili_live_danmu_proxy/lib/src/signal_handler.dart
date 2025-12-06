import 'dart:async';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:bilibili_live_api_server/bilibili_live_api_server.dart';
import 'logger.dart';

/// 设置信号处理器
void setupSignalHandlers(BilibiliLiveApiServer server) {
  // 用于防止重复关闭
  var isShuttingDown = false;

  Future<void> shutdown(String signal) async {
    if (isShuttingDown) return;
    isShuttingDown = true;

    logger.i('收到 $signal 信号，正在关闭服务器...');

    try {
      await server.stop();
      logger.i('服务器已优雅关闭');
    } catch (e, stackTrace) {
      logger.e('关闭服务器时出错: $e', error: e, stackTrace: stackTrace);
    }
  }

  // 监听 SIGINT (Ctrl+C)
  ProcessSignal.sigint.watch().listen((_) => shutdown('SIGINT'));

  // 监听 SIGTERM
  if (!Platform.isWindows) {
    ProcessSignal.sigterm.watch().listen((_) => shutdown('SIGTERM'));
  }
}
