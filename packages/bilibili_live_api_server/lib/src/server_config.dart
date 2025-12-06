/// 服务器配置
class ServerConfig {
  /// Access Key ID（必需）
  final String accessKeyId;

  /// Access Key Secret（必需）
  final String accessKeySecret;

  /// 主播身份码（可选）
  final String? code;

  /// 项目 ID（可选）
  final int? appId;

  /// 是否启用日志（可选，默认 true）
  final bool enableLogging;

  ServerConfig({
    required this.accessKeyId,
    required this.accessKeySecret,
    this.code,
    this.appId,
    this.enableLogging = true,
  });

  /// 从 Map 创建配置
  factory ServerConfig.fromMap(Map<String, String?> map) {
    final accessKeyId = map['access_key_id'];
    final accessKeySecret = map['access_key_secret'];

    if (accessKeyId == null || accessKeyId.isEmpty) {
      throw ArgumentError('access_key_id 不能为空');
    }
    if (accessKeySecret == null || accessKeySecret.isEmpty) {
      throw ArgumentError('access_key_secret 不能为空');
    }

    return ServerConfig(
      accessKeyId: accessKeyId,
      accessKeySecret: accessKeySecret,
      code: map['code'],
      appId: _parseIntOrNull(map['app_id']),
      enableLogging: map['enable_logging'] != 'false',
    );
  }

  /// 从 properties 文件内容解析配置
  factory ServerConfig.fromProperties(String content) {
    final map = <String, String?>{};
    for (final line in content.split('\n')) {
      final trimmed = line.trim();
      // 跳过注释和空行
      if (trimmed.isEmpty || trimmed.startsWith('#')) {
        continue;
      }
      final index = trimmed.indexOf('=');
      if (index > 0) {
        final key = trimmed.substring(0, index).trim();
        final value = trimmed.substring(index + 1).trim();
        map[key] = value.isEmpty ? null : value;
      }
    }
    return ServerConfig.fromMap(map);
  }

  static int? _parseIntOrNull(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return int.tryParse(value);
  }

  /// 复制并覆盖部分配置
  ServerConfig copyWith({
    String? accessKeyId,
    String? accessKeySecret,
    String? code,
    int? appId,
    bool? enableLogging,
  }) {
    return ServerConfig(
      accessKeyId: accessKeyId ?? this.accessKeyId,
      accessKeySecret: accessKeySecret ?? this.accessKeySecret,
      code: code ?? this.code,
      appId: appId ?? this.appId,
      enableLogging: enableLogging ?? this.enableLogging,
    );
  }
}
