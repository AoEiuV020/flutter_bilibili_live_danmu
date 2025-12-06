import 'dart:io';

import 'package:bilibili_live_api_server/bilibili_live_api_server.dart';

/// 配置加载器
class ConfigLoader {
  /// 从文件加载配置
  ///
  /// 如果文件不存在返回 null
  static Future<ServerConfig?> loadFromFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return null;
    }
    final content = await file.readAsString();
    return ServerConfig.fromProperties(content);
  }

  /// 合并命令行参数到配置
  ///
  /// 命令行参数优先级高于配置文件
  /// 必须提供 backendUrl 或同时提供 accessKeyId 和 accessKeySecret
  static ServerConfig mergeWithArgs({
    ServerConfig? fileConfig,
    String? accessKeyId,
    String? accessKeySecret,
    String? backendUrl,
    String? code,
    int? appId,
    bool? enableLogging,
  }) {
    // 合并后的值
    final mergedAccessKeyId = accessKeyId ?? fileConfig?.accessKeyId;
    final mergedAccessKeySecret =
        accessKeySecret ?? fileConfig?.accessKeySecret;
    final mergedBackendUrl = backendUrl ?? fileConfig?.backendUrl;
    final mergedCode = code ?? fileConfig?.code;
    final mergedAppId = appId ?? fileConfig?.appId;
    final mergedEnableLogging =
        enableLogging ?? fileConfig?.enableLogging ?? true;

    // 验证：必须有后端地址或完整的 accessKey
    final hasBackend = mergedBackendUrl != null && mergedBackendUrl.isNotEmpty;
    final hasAccessKey =
        mergedAccessKeyId != null &&
        mergedAccessKeyId.isNotEmpty &&
        mergedAccessKeySecret != null &&
        mergedAccessKeySecret.isNotEmpty;

    if (!hasBackend && !hasAccessKey) {
      throw ArgumentError(
        '必须提供 backend-url 或同时提供 access-key-id 和 access-key-secret',
      );
    }

    return ServerConfig(
      accessKeyId: mergedAccessKeyId,
      accessKeySecret: mergedAccessKeySecret,
      backendUrl: mergedBackendUrl,
      code: mergedCode,
      appId: mergedAppId,
      enableLogging: mergedEnableLogging,
    );
  }
}
