import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'blocs/home_page_cubit.dart';
import 'blocs/settings/credentials_settings_cubit.dart';
import 'blocs/settings/display_settings_cubit.dart';
import 'blocs/settings/filter_settings_cubit.dart';
import 'blocs/settings/launch_settings_cubit.dart';
import 'blocs/settings/server_settings_cubit.dart';
import 'home_page.dart';
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

  // 解析命令行参数
  final settings = await parseAppOptions(args);

  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs, settings: settings));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final Map<String, String?> settings;

  const MyApp({super.key, required this.prefs, required this.settings});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => DisplaySettingsCubit(prefs, args: settings),
        ),
        BlocProvider(create: (_) => FilterSettingsCubit(prefs, args: settings)),
        BlocProvider(
          create: (_) => CredentialsSettingsCubit(prefs, args: settings),
        ),
        BlocProvider(create: (_) => ServerSettingsCubit(prefs, args: settings)),
        BlocProvider(create: (_) => LaunchSettingsCubit(args: settings)),
        BlocProvider(
          create: (context) => HomePageCubit(
            context.read<CredentialsSettingsCubit>(),
            context.read<ServerSettingsCubit>(),
            context.read<LaunchSettingsCubit>(),
          ),
        ),
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
