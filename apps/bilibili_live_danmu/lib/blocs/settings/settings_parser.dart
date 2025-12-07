/// 设置参数解析工具类
///
/// 用于在 Cubit 构造函数中统一处理参数解析，避免重复代码
class SettingsParser {
  /// 解析布尔值字符串
  ///
  /// - 如果 [argValue] 不为 null，将其作为命令行参数解析
  /// - 否则，返回 SharedPreferences 中的值
  /// - 如果都没有，返回 null（让 copyWith 保持默认值）
  static bool? parseBool(String? argValue, bool? prefValue) {
    if (argValue != null) {
      return argValue.toLowerCase() == 'true';
    }
    return prefValue;
  }

  /// 解析整数字符串
  ///
  /// - 如果 [argValue] 不为 null，将其作为命令行参数解析
  /// - 否则，返回 SharedPreferences 中的值
  /// - 如果都没有，返回 null（让 copyWith 保持默认值）
  static int? parseInt(String? argValue, int? prefValue) {
    if (argValue != null) {
      return int.tryParse(argValue);
    }
    return prefValue;
  }

  /// 解析浮点数字符串
  ///
  /// - 如果 [argValue] 不为 null，将其作为命令行参数解析
  /// - 否则，返回 SharedPreferences 中的值
  /// - 如果都没有，返回 null（让 copyWith 保持默认值）
  static double? parseDouble(String? argValue, double? prefValue) {
    if (argValue != null) {
      return double.tryParse(argValue);
    }
    return prefValue;
  }

  /// 解析字符串
  ///
  /// - 如果 [argValue] 不为 null，直接返回
  /// - 否则，返回 SharedPreferences 中的值
  /// - 如果都没有，返回 null（让 copyWith 保持默认值）
  static String? parseString(String? argValue, String? prefValue) {
    if (argValue != null) {
      return argValue;
    }
    return prefValue;
  }
}
