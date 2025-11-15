import 'dart:convert';
import 'package:crypto/crypto.dart';

/// 鉴权加密工具类
class SignatureUtil {
  /// 生成鉴权请求头
  static Map<String, String> getEncodeHeader({
    required Map<String, dynamic> params,
    required String accessKeyId,
    required String accessKeySecret,
  }) {
    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    final nonce =
        ((DateTime.now().millisecondsSinceEpoch / 10).floor() % 100000) +
        timestamp;

    final contentMd5 = getMd5Content(jsonEncode(params));

    final header = {
      'x-bili-accesskeyid': accessKeyId,
      'x-bili-content-md5': contentMd5,
      'x-bili-signature-method': 'HMAC-SHA256',
      'x-bili-signature-nonce': nonce.toString(),
      'x-bili-signature-version': '1.0',
      'x-bili-timestamp': timestamp.toString(),
    };

    final data = <String>[];
    header.forEach((key, value) {
      data.add('$key:$value');
    });

    final signature = _hmacSha256(data.join('\n'), accessKeySecret);

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      ...header,
      'Authorization': signature,
    };
  }

  /// MD5加密
  static String getMd5Content(String str) {
    final bytes = utf8.encode(str);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// HMAC-SHA256加密
  static String _hmacSha256(String data, String secret) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(data);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return digest.toString();
  }
}
