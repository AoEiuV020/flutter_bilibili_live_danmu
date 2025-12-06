import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bilibili_live_api/bilibili_live_api.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'server_config.dart';

/// Bilibili Live API HTTP 代理服务器
///
/// 监听 HTTP 端口，转发请求到 [BilibiliLiveApiClient]
class BilibiliLiveApiServer {
  final ServerConfig _config;
  HttpServer? _server;
  BilibiliLiveApiClient? _apiClient;

  /// 服务器是否正在运行
  bool get isRunning => _server != null;

  /// 当前监听的端口
  int? get port => _server?.port;

  BilibiliLiveApiServer({required ServerConfig config}) : _config = config;

  /// 启动服务器
  ///
  /// [port] 监听端口，默认 8080
  /// [address] 监听地址，默认 'localhost'
  Future<void> start({int port = 8080, String address = 'localhost'}) async {
    if (_server != null) {
      throw StateError('服务器已经在运行');
    }

    // 初始化 API 客户端
    _apiClient = BilibiliLiveApiClient(
      accessKeyId: _config.accessKeyId,
      accessKeySecret: _config.accessKeySecret,
      enableLogging: _config.enableLogging,
    );

    // 创建路由
    final router = _createRouter();

    // 添加 CORS 中间件
    final handler = const Pipeline()
        .addMiddleware(_corsMiddleware())
        .addMiddleware(logRequests())
        .addHandler(router.call);

    // 启动服务器
    _server = await shelf_io.serve(handler, address, port);
    print('服务器已启动: http://${_server!.address.host}:${_server!.port}');
  }

  /// 停止服务器
  Future<void> stop() async {
    if (_server == null) {
      return;
    }

    await _server!.close(force: true);
    _server = null;
    _apiClient?.dispose();
    _apiClient = null;
    print('服务器已停止');
  }

  /// 创建路由
  Router _createRouter() {
    final router = Router();

    // 项目开启
    router.post('/v2/app/start', _handleStart);

    // 项目关闭
    router.post('/v2/app/end', _handleEnd);

    // 项目心跳
    router.post('/v2/app/heartbeat', _handleHeartbeat);

    // 项目批量心跳
    router.post('/v2/app/batchHeartbeat', _handleBatchHeartbeat);

    // 通用 POST 请求
    router.post('/api/<path|.*>', _handleGenericPost);

    // 健康检查
    router.get('/health', _handleHealth);

    return router;
  }

  /// CORS 中间件，允许任意来源请求
  Middleware _corsMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        // 处理预检请求
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: _corsHeaders);
        }

        final response = await innerHandler(request);
        return response.change(headers: _corsHeaders);
      };
    };
  }

  /// CORS 响应头
  Map<String, String> get _corsHeaders => {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers':
        'Origin, Content-Type, Accept, Authorization, X-Requested-With',
    'Access-Control-Max-Age': '86400',
  };

  /// 处理项目开启请求
  Future<Response> _handleStart(Request request) async {
    try {
      final body = await _parseRequestBody(request);

      final code = _getStringParam(body, 'code', _config.code);
      final appId = _getIntParam(body, 'app_id', _config.appId);

      final result = await _apiClient!.start(code: code, appId: appId);
      return _jsonResponse({'code': 0, 'data': result.toJson()});
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// 处理项目关闭请求
  Future<Response> _handleEnd(Request request) async {
    try {
      final body = await _parseRequestBody(request);

      final appId = _getIntParam(body, 'app_id', _config.appId);
      final gameId = _getStringParam(body, 'game_id', null);

      await _apiClient!.end(appId: appId, gameId: gameId);
      return _jsonResponse({'code': 0, 'data': {}});
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// 处理项目心跳请求
  Future<Response> _handleHeartbeat(Request request) async {
    try {
      final body = await _parseRequestBody(request);

      final gameId = _getStringParam(body, 'game_id', null);

      await _apiClient!.heartbeat(gameId: gameId);
      return _jsonResponse({'code': 0, 'data': {}});
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// 处理项目批量心跳请求
  Future<Response> _handleBatchHeartbeat(Request request) async {
    try {
      final body = await _parseRequestBody(request);

      final gameIds = body['game_ids'] as List<dynamic>?;
      if (gameIds == null || gameIds.isEmpty) {
        return _errorResponse(ArgumentError('game_ids 不能为空'));
      }

      final result = await _apiClient!.batchHeartbeat(
        gameIds: gameIds.cast<String>(),
      );
      return _jsonResponse({'code': 0, 'data': result.toJson()});
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// 处理通用 POST 请求
  Future<Response> _handleGenericPost(Request request, String path) async {
    try {
      final body = await _parseRequestBody(request);
      final result = await _apiClient!.post(path: '/$path', data: body);
      return _jsonResponse(result);
    } catch (e) {
      return _errorResponse(e);
    }
  }

  /// 处理健康检查请求
  Response _handleHealth(Request request) {
    return _jsonResponse({
      'status': 'ok',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// 解析请求体
  Future<Map<String, dynamic>> _parseRequestBody(Request request) async {
    final bodyString = await request.readAsString();
    if (bodyString.isEmpty) {
      return {};
    }
    return jsonDecode(bodyString) as Map<String, dynamic>;
  }

  /// 获取字符串参数
  ///
  /// 优先使用请求中的参数，如果没有则使用配置中的参数
  /// 如果都没有则返回空字符串
  String _getStringParam(
    Map<String, dynamic> body,
    String key,
    String? configValue,
  ) {
    final value = body[key];
    if (value != null) {
      return value.toString();
    }
    return configValue ?? '';
  }

  /// 获取整数参数
  ///
  /// 优先使用请求中的参数，如果没有则使用配置中的参数
  /// 如果都没有则返回 0
  int _getIntParam(Map<String, dynamic> body, String key, int? configValue) {
    final value = body[key];
    if (value != null) {
      if (value is int) {
        return value;
      }
      return int.tryParse(value.toString()) ?? configValue ?? 0;
    }
    return configValue ?? 0;
  }

  /// 构造 JSON 响应
  Response _jsonResponse(Map<String, dynamic> data) {
    return Response.ok(
      jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// 构造错误响应
  Response _errorResponse(Object error) {
    return Response.internalServerError(
      body: jsonEncode({'code': -1, 'message': error.toString()}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
