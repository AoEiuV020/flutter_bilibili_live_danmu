/// 日志级别
enum LogLevel { debug, info, warning, error }

/// 简单的日志封装，不依赖 Flutter
class Logger {
  static const String _tag = 'BilibiliLiveApi';

  /// 输出调试信息 (DEBUG 级别)
  static void debug(String message) {
    _log(LogLevel.debug, message);
  }

  /// 输出信息 (INFO 级别)
  static void info(String message) {
    _log(LogLevel.info, message);
  }

  /// 输出警告信息 (WARNING 级别)
  static void warning(String message) {
    _log(LogLevel.warning, message);
  }

  /// 输出错误信息 (ERROR 级别)
  static void error(String message) {
    _log(LogLevel.error, message);
  }

  /// 内部日志输出方法
  static void _log(LogLevel level, String message) {
    final levelName = _getLevelName(level);
    print('[$_tag] [$levelName] $message');
  }

  /// 获取日志级别名称
  static String _getLevelName(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.error:
        return 'ERROR';
    }
  }
}
