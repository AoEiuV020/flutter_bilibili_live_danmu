/// 基础响应模型
class BaseResponse<T> {
  final int code;
  final String message;
  final T? data;

  BaseResponse({required this.code, required this.message, this.data});

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? dataParser,
  ) {
    return BaseResponse<T>(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'] != null && dataParser != null
          ? dataParser(json['data'])
          : json['data'] as T?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'message': message, if (data != null) 'data': data};
  }

  bool get isSuccess => code == 0;
}

/// 批量心跳响应数据
class BatchHeartbeatData {
  final List<String> failedGameIds;

  BatchHeartbeatData({required this.failedGameIds});

  factory BatchHeartbeatData.fromJson(Map<String, dynamic> json) {
    return BatchHeartbeatData(
      failedGameIds: (json['failed_game_ids'] as List).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'failed_game_ids': failedGameIds};
  }
}
