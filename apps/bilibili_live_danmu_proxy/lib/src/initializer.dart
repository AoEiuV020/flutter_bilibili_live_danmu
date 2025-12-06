import 'package:logger/logger.dart';
import 'logger.dart';

/// 初始化日志系统
void initializeLogger() {
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

  // 然后初始化 logger 实例
  initializeLoggerInstance();
}
