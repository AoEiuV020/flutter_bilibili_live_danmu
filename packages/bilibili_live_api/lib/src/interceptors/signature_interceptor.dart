import 'package:dio/dio.dart';
import '../utils/signature_util.dart';

/// 签名拦截器
class SignatureInterceptor extends Interceptor {
  final String accessKeyId;
  final String accessKeySecret;

  SignatureInterceptor({
    required this.accessKeyId,
    required this.accessKeySecret,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 获取请求体数据
    final data = options.data is Map<String, dynamic>
        ? options.data as Map<String, dynamic>
        : <String, dynamic>{};

    // 生成鉴权请求头
    final headers = SignatureUtil.getEncodeHeader(
      params: data,
      accessKeyId: accessKeyId,
      accessKeySecret: accessKeySecret,
    );

    // 添加到请求头
    options.headers.addAll(headers);

    super.onRequest(options, handler);
  }
}
