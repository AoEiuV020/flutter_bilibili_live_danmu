import 'package:bilibili_live_api_server/bilibili_live_api_server.dart';
import 'package:test/test.dart';

void main() {
  group('ServerConfig', () {
    test('fromProperties parses correctly', () {
      const content = '''
# 测试配置
access_key_id=test_key_id
access_key_secret=test_key_secret
code=TEST_CODE
app_id=12345
''';
      final config = ServerConfig.fromProperties(content);
      expect(config.accessKeyId, 'test_key_id');
      expect(config.accessKeySecret, 'test_key_secret');
      expect(config.code, 'TEST_CODE');
      expect(config.appId, 12345);
    });

    test('fromProperties handles missing optional fields', () {
      const content = '''
access_key_id=test_key_id
access_key_secret=test_key_secret
''';
      final config = ServerConfig.fromProperties(content);
      expect(config.accessKeyId, 'test_key_id');
      expect(config.accessKeySecret, 'test_key_secret');
      expect(config.code, isNull);
      expect(config.appId, isNull);
    });

    test('fromProperties throws on missing access_key_id', () {
      const content = '''
access_key_secret=test_key_secret
''';
      expect(
        () => ServerConfig.fromProperties(content),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
