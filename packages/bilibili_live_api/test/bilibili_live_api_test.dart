import 'package:bilibili_live_api/bilibili_live_api.dart';
import 'package:test/test.dart';

void main() {
  group('BilibiliLiveApiClient Tests', () {
    test('SignatureUtil generates valid MD5', () {
      final result = SignatureUtil.getMd5Content('{}');
      expect(result, isNotEmpty);
      expect(result.length, equals(32)); // MD5 hash length
    });

    test('SignatureUtil generates valid headers', () {
      final headers = SignatureUtil.getEncodeHeader(
        params: {'test': 'value'},
        accessKeyId: 'test_key_id',
        accessKeySecret: 'test_secret',
      );

      expect(headers['x-bili-accesskeyid'], equals('test_key_id'));
      expect(headers['x-bili-signature-method'], equals('HMAC-SHA256'));
      expect(headers['x-bili-signature-version'], equals('1.0'));
      expect(headers['Authorization'], isNotEmpty);
    });
  });
}
