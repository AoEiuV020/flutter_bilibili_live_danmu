/// B站API异常
class BilibiliApiException implements Exception {
  final int code;
  final String message;

  BilibiliApiException(this.code, this.message);

  @override
  String toString() => 'BilibiliApiException: [$code] $message';
}

/// 解析响应并自动处理错误
/// 如果 code != 0 则抛出异常
/// 如果 code == 0 则返回 data
T parseResponse<T>(Map<String, dynamic> json, T Function(dynamic)? dataParser) {
  final code = json['code'] as int;
  final message = json['message'] as String;

  // 如果返回码不为 0，抛出异常
  if (code != 0) {
    throw BilibiliApiException(code, message);
  }

  // 解析并返回 data
  if (dataParser != null && json['data'] != null) {
    return dataParser(json['data']);
  }

  return json['data'] as T;
}
