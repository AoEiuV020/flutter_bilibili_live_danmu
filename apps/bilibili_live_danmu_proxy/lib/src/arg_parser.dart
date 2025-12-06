import 'package:args/args.dart';

/// 默认配置文件路径
const String defaultConfigPath = 'config.properties';

/// 默认监听端口
const int defaultPort = 8080;

/// 默认监听地址
const String defaultAddress = '0.0.0.0';

/// 创建命令行参数解析器
ArgParser createArgParser() {
  return ArgParser()
    ..addOption(
      'config',
      abbr: 'c',
      help: '配置文件路径',
      defaultsTo: defaultConfigPath,
    )
    ..addOption(
      'port',
      abbr: 'p',
      help: '监听端口',
      defaultsTo: defaultPort.toString(),
    )
    ..addOption('address', abbr: 'a', help: '监听地址', defaultsTo: defaultAddress)
    ..addOption('access-key-id', help: 'Access Key ID（与 backend-url 二选一）')
    ..addOption(
      'access-key-secret',
      help: 'Access Key Secret（与 backend-url 二选一）',
    )
    ..addOption('backend-url', help: '后端代理地址（与 accessKey 二选一）')
    ..addOption('code', help: '主播身份码')
    ..addOption('app-id', help: '项目 ID')
    ..addFlag('logging', help: '启用请求日志', defaultsTo: true)
    ..addFlag('help', abbr: 'h', negatable: false, help: '显示帮助信息');
}

/// 打印使用说明
void printUsage(ArgParser parser) {
  print('Bilibili Live API Proxy Server');
  print('');
  print('用法: bilibili_live_danmu_proxy [选项]');
  print('');
  print(parser.usage);
  print('');
  print('示例:');
  print('  bilibili_live_danmu_proxy -c config.properties');
  print(
    '  bilibili_live_danmu_proxy --access-key-id=xxx --access-key-secret=yyy',
  );
  print('  bilibili_live_danmu_proxy --backend-url=http://localhost:3000');
  print('  bilibili_live_danmu_proxy -p 3000 -a localhost');
}
