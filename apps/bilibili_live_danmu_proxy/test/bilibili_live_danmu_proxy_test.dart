import 'package:bilibili_live_api_server/bilibili_live_api_server.dart';
import 'package:bilibili_live_danmu_proxy/bilibili_live_danmu_proxy.dart';
import 'package:test/test.dart';

void main() {
  group('ConfigLoader', () {
    test('mergeWithArgs uses command line args over file config', () {
      final fileConfig = ServerConfig(
        accessKeyId: 'file_key_id',
        accessKeySecret: 'file_key_secret',
        code: 'file_code',
        appId: 111,
      );

      final merged = ConfigLoader.mergeWithArgs(
        fileConfig: fileConfig,
        accessKeyId: 'arg_key_id',
        accessKeySecret: null, // 使用文件配置
        code: 'arg_code',
        appId: null, // 使用文件配置
      );

      expect(merged.accessKeyId, 'arg_key_id');
      expect(merged.accessKeySecret, 'file_key_secret');
      expect(merged.code, 'arg_code');
      expect(merged.appId, 111);
    });

    test('mergeWithArgs works without file config with accessKey', () {
      final config = ConfigLoader.mergeWithArgs(
        fileConfig: null,
        accessKeyId: 'arg_key_id',
        accessKeySecret: 'arg_key_secret',
        code: 'arg_code',
        appId: 222,
      );

      expect(config.accessKeyId, 'arg_key_id');
      expect(config.accessKeySecret, 'arg_key_secret');
      expect(config.code, 'arg_code');
      expect(config.appId, 222);
    });

    test('mergeWithArgs works with backendUrl only', () {
      final config = ConfigLoader.mergeWithArgs(
        fileConfig: null,
        backendUrl: 'http://localhost:3000',
        code: 'arg_code',
      );

      expect(config.backendUrl, 'http://localhost:3000');
      expect(config.accessKeyId, isNull);
      expect(config.accessKeySecret, isNull);
      expect(config.code, 'arg_code');
    });

    test('mergeWithArgs throws on missing both backendUrl and accessKey', () {
      expect(
        () => ConfigLoader.mergeWithArgs(
          fileConfig: null,
          accessKeyId: null,
          accessKeySecret: null,
          backendUrl: null,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
