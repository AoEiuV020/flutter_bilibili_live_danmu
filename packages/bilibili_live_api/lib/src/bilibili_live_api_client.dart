import 'dart:convert';
import 'package:dio/dio.dart';
import 'interceptors/logger_interceptor.dart';
import 'interceptors/signature_interceptor.dart';
import 'models/response_parser.dart';
import 'models/app_start_data.dart';
import 'models/batch_heartbeat_data.dart';
import 'websocket/bilibili_live_websocket.dart';

/// B站直播开放平台API客户端
class BilibiliLiveApiClient {
  static const String _baseUrl = 'https://live-open.biliapi.com';

  late final Dio _dio;
  final String accessKeyId;
  final String accessKeySecret;

  BilibiliLiveApiClient({
    required this.accessKeyId,
    required this.accessKeySecret,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    bool enableLogging = true,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: connectTimeout ?? const Duration(seconds: 30),
        receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );

    // 添加签名拦截器
    _dio.interceptors.add(
      SignatureInterceptor(
        accessKeyId: accessKeyId,
        accessKeySecret: accessKeySecret,
      ),
    );

    // 添加日志拦截器
    if (enableLogging) {
      _dio.interceptors.add(LoggerInterceptor());
    }
  }

  /// 项目开启
  ///
  /// 开启项目第一步，平台会根据入参进行鉴权校验。
  /// 鉴权通过后，返回长连信息、场次信息和主播信息。
  ///
  /// [code] 主播身份码
  /// [appId] 项目ID (int64)
  /// 返回 [AppStartData] 项目开启数据
  Future<AppStartData> start({required String code, required int appId}) async {
    try {
      final response = await _dio.post(
        '/v2/app/start',
        data: {'code': code, 'app_id': appId},
      );

      return parseResponse<AppStartData>(
        response.data as Map<String, dynamic>,
        (data) => AppStartData.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 项目关闭
  ///
  /// 项目关闭时需要主动调用此接口，使用对应项目Id及项目开启时返回的game_id作为唯一标识。
  /// 调用后会同步下线互动道具等内容，项目关闭后才能进行下一场次互动。
  ///
  /// [appId] 项目ID (int64)
  /// [gameId] 场次ID
  Future<void> end({required int appId, required String gameId}) async {
    try {
      final response = await _dio.post(
        '/v2/app/end',
        data: {'app_id': appId, 'game_id': gameId},
      );

      parseResponse<Map<String, dynamic>>(
        response.data as Map<String, dynamic>,
        null,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 项目心跳
  ///
  /// 项目开启后，推荐持续间隔20秒调用一次该接口。
  /// 互动玩法超过60秒，互动插件和互动工具超过180s未收到项目心跳，会自动关闭当前场次。
  ///
  /// [gameId] 场次ID
  Future<void> heartbeat({required String gameId}) async {
    try {
      final response = await _dio.post(
        '/v2/app/heartbeat',
        data: {'game_id': gameId},
      );

      parseResponse<Map<String, dynamic>>(
        response.data as Map<String, dynamic>,
        null,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 项目批量心跳
  ///
  /// 为项目心跳的批量请求版本。
  ///
  /// [gameIds] 场次ID列表 (单次请求game_id数量要小于200条)
  /// 返回 [BatchHeartbeatData] 包含失败的场次ID列表
  Future<BatchHeartbeatData> batchHeartbeat({
    required List<String> gameIds,
  }) async {
    if (gameIds.length > 200) {
      throw ArgumentError('gameIds数量不能超过200条');
    }

    try {
      final response = await _dio.post(
        '/v2/app/batchHeartbeat',
        data: {'game_ids': gameIds},
      );

      return parseResponse<BatchHeartbeatData>(
        response.data as Map<String, dynamic>,
        (data) => BatchHeartbeatData.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 通用POST请求
  ///
  /// 用于调用任意接口
  ///
  /// [path] 接口路径
  /// [data] 请求数据
  Future<Map<String, dynamic>> post({
    required String path,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post(path, data: data ?? {});

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 错误处理
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('请求超时: ${error.message}');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? error.message;
        return Exception('请求失败 [$statusCode]: $message');
      case DioExceptionType.cancel:
        return Exception('请求已取消');
      case DioExceptionType.connectionError:
        return Exception('网络连接失败: ${error.message}');
      default:
        return Exception('未知错误: ${error.message}');
    }
  }

  /// 创建 WebSocket 连接（工厂方法）
  ///
  /// 返回一个新的 WebSocket 实例，由调用方自行管理生命周期
  ///
  /// [startData] 项目开启返回的数据
  /// [onMessage] 消息回调
  /// [onError] 错误回调
  /// [onConnectionChanged] 连接状态变化回调
  Future<BilibiliLiveWebSocket> createWebSocket({
    required AppStartData startData,
    required void Function(dynamic message) onMessage,
    void Function(String error)? onError,
    void Function(bool connected)? onConnectionChanged,
  }) async {
    final webSocket = BilibiliLiveWebSocket()
      ..onMessage = onMessage
      ..onError = onError
      ..onConnectionChanged = onConnectionChanged;

    // 连接 WebSocket
    final authParams =
        jsonDecode(startData.websocketInfo.authBody) as Map<String, dynamic>;
    await webSocket.connect(
      url: startData.websocketInfo.wssLink.first,
      authParams: authParams,
    );

    return webSocket;
  }

  /// 关闭客户端
  void dispose() {
    _dio.close();
  }
}
