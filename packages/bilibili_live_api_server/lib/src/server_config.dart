/// 服务器配置
class ServerConfig {
  /// Access Key ID（使用后端代理时可为空）
  final String? accessKeyId;

  /// Access Key Secret（使用后端代理时可为空）
  final String? accessKeySecret;

  /// 后端地址（可选，用于转发到另一个代理服务器）
  final String? backendUrl;

  /// 主播身份码（可选）
  final String? code;

  /// 项目 ID（可选）
  final int? appId;

  /// 是否启用日志（可选，默认 true）
  final bool enableLogging;

  /// 是否使用代理模式（有后端地址或有完整的 accessKey）
  bool get isValid =>
      (backendUrl != null && backendUrl!.isNotEmpty) ||
      (accessKeyId != null &&
          accessKeyId!.isNotEmpty &&
          accessKeySecret != null &&
          accessKeySecret!.isNotEmpty);

  ServerConfig({
    this.accessKeyId,
    this.accessKeySecret,
    this.backendUrl,
    this.code,
    this.appId,
    this.enableLogging = true,
  });

  /// 从 Map 创建配置
  factory ServerConfig.fromMap(Map<String, String?> map) {
    final accessKeyId = map['access_key_id'];
    final accessKeySecret = map['access_key_secret'];
    final backendUrl = map['backend_url'];

    // 必须有后端地址或完整的 accessKey
    final hasBackend = backendUrl != null && backendUrl.isNotEmpty;
    final hasAccessKey =
        accessKeyId != null &&
        accessKeyId.isNotEmpty &&
        accessKeySecret != null &&
        accessKeySecret.isNotEmpty;

    if (!hasBackend && !hasAccessKey) {
      throw ArgumentError(
        '必须提供 backend_url 或同时提供 access_key_id 和 access_key_secret',
      );
    }

    return ServerConfig(
      accessKeyId: accessKeyId,
      accessKeySecret: accessKeySecret,
      backendUrl: backendUrl,
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
    String? backendUrl,
    String? code,
    int? appId,
    bool? enableLogging,
  }) {
    return ServerConfig(
      accessKeyId: accessKeyId ?? this.accessKeyId,
      accessKeySecret: accessKeySecret ?? this.accessKeySecret,
      backendUrl: backendUrl ?? this.backendUrl,
      code: code ?? this.code,
      appId: appId ?? this.appId,
      enableLogging: enableLogging ?? this.enableLogging,
    );
  }
}
