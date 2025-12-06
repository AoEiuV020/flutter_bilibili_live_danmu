import 'package:bilibili_live_api_server/bilibili_live_api_server.dart';
import 'package:test/test.dart';

void main() {
  group('ServerConfig', () {
    test('fromProperties parses correctly with accessKey', () {
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
      expect(config.backendUrl, isNull);
    });

    test('fromProperties parses correctly with backendUrl', () {
      const content = '''
backend_url=http://localhost:3000
code=TEST_CODE
''';
      final config = ServerConfig.fromProperties(content);
      expect(config.backendUrl, 'http://localhost:3000');
      expect(config.accessKeyId, isNull);
      expect(config.accessKeySecret, isNull);
      expect(config.code, 'TEST_CODE');
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
      expect(config.backendUrl, isNull);
    });

    test('fromProperties throws on missing both backendUrl and accessKey', () {
      const content = '''
code=TEST_CODE
''';
      expect(
        () => ServerConfig.fromProperties(content),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('isValid returns true with accessKey', () {
      final config = ServerConfig(
        accessKeyId: 'key_id',
        accessKeySecret: 'key_secret',
      );
      expect(config.isValid, isTrue);
    });

    test('isValid returns true with backendUrl', () {
      final config = ServerConfig(backendUrl: 'http://localhost:3000');
      expect(config.isValid, isTrue);
    });

    test('isValid returns false without both', () {
      final config = ServerConfig();
      expect(config.isValid, isFalse);
    });
  });
}
