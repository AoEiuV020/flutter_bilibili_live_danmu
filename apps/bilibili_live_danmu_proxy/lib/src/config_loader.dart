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
  static ServerConfig mergeWithArgs({
    ServerConfig? fileConfig,
    String? accessKeyId,
    String? accessKeySecret,
    String? code,
    int? appId,
    bool? enableLogging,
  }) {
    // 如果有文件配置，基于文件配置覆盖
    if (fileConfig != null) {
      return ServerConfig(
        accessKeyId: accessKeyId ?? fileConfig.accessKeyId,
        accessKeySecret: accessKeySecret ?? fileConfig.accessKeySecret,
        code: code ?? fileConfig.code,
        appId: appId ?? fileConfig.appId,
        enableLogging: enableLogging ?? fileConfig.enableLogging,
      );
    }

    // 没有文件配置，完全使用命令行参数
    if (accessKeyId == null || accessKeyId.isEmpty) {
      throw ArgumentError('access_key_id 不能为空');
    }
    if (accessKeySecret == null || accessKeySecret.isEmpty) {
      throw ArgumentError('access_key_secret 不能为空');
    }

    return ServerConfig(
      accessKeyId: accessKeyId,
      accessKeySecret: accessKeySecret,
      code: code,
      appId: appId,
      enableLogging: enableLogging ?? true,
    );
  }
}
