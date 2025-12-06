/// 应用启动参数配置
///
/// 保存从命令行或 URL 解析的参数，作为静态变量全局访问
class AppOptions {
  /// 全局单例实例
  static AppOptions? _instance;

  /// 获取全局实例
  static AppOptions get instance {
    _instance ??= AppOptions();
    return _instance!;
  }

  /// 设置全局实例
  static void setInstance(AppOptions options) {
    _instance = options;
  }

  /// 项目 ID
  final String? appId;

  /// Access Key ID
  final String? accessKeyId;

  /// Access Key Secret
  final String? accessKeySecret;

  /// 主播身份码
  final String? code;

  /// 后端代理地址
  final String? backendUrl;

  /// 是否自动开始直播
  final bool autoStart;

  AppOptions({
    this.appId,
    this.accessKeyId,
    this.accessKeySecret,
    this.code,
    this.backendUrl,
    this.autoStart = false,
  });

  /// 是否使用后端代理模式
  bool get isProxyMode => backendUrl != null && backendUrl!.isNotEmpty;

  /// 判断是否有足够的参数自动启动（直连模式或代理模式）
  bool get canAutoStart {
    if (!autoStart) return false;
    if (isProxyMode) {
      // 代理模式只需要后端地址
      return true;
    } else {
      // 直连模式需要 accessKey 和 code
      return accessKeyId != null &&
          accessKeyId!.isNotEmpty &&
          accessKeySecret != null &&
          accessKeySecret!.isNotEmpty &&
          code != null &&
          code!.isNotEmpty;
    }
  }

  @override
  String toString() {
    return 'AppOptions(appId: $appId, accessKeyId: ${accessKeyId != null ? "***" : null}, '
        'accessKeySecret: ${accessKeySecret != null ? "***" : null}, code: $code, '
        'backendUrl: $backendUrl, autoStart: $autoStart)';
  }
}
