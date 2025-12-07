import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'blocs/settings/credentials_settings_cubit.dart';
import 'blocs/settings/display_settings_cubit.dart';
import 'blocs/settings/filter_settings_cubit.dart';
import 'blocs/settings/server_settings_cubit.dart';
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

  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DisplaySettingsCubit(prefs)),
        BlocProvider(create: (_) => FilterSettingsCubit(prefs)),
        BlocProvider(create: (_) => CredentialsSettingsCubit(prefs)),
        BlocProvider(create: (_) => ServerSettingsCubit(prefs)),
      ],
      child: MaterialApp(
        title: '哔哩哔哩直播弹幕',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}
