import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'home_page.dart';
import 'options/app_options.dart';
import 'options/parse.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 第一时间设置logger的默认printer（所有日志使用统一格式）
  Logger.defaultPrinter = () => PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  );
  Logger.level = Level.debug;

  // 解析命令行参数并保存为全局实例
  final options = await parseAppOptions(args);
  AppOptions.setInstance(options);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '哔哩哔哩直播弹幕',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
