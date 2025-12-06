import 'package:dio/dio.dart';
import '../logger.dart';

/// 日志拦截器
class LoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.d(
      '📤 REQUEST ${options.method} ${options.uri}\n'
      'Headers: ${options.headers}\n'
      'Body: ${options.data}',
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.i(
      '📥 RESPONSE [${response.statusCode}] ${response.requestOptions.uri}\n'
      'Data: ${response.data}',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e(
      '❌ ERROR ${err.type} ${err.requestOptions.uri}\n'
      'Message: ${err.message}\n'
      'Response: ${err.response?.data}',
      error: err,
      stackTrace: err.stackTrace,
    );
    super.onError(err, handler);
  }
}
