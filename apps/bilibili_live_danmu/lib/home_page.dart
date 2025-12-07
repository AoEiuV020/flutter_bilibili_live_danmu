import 'dart:developer';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bilibili_live_api/bilibili_live_api.dart';
import 'blocs/settings/credentials_settings_cubit.dart';
import 'blocs/settings/server_settings_cubit.dart';
import 'live_page.dart';
import 'options/app_options.dart';
import 'settings_page.dart';
import 'utils/tts_manager.dart';
import 'src/logger.dart';
import 'widgets/home_credentials_panel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _appIdController = TextEditingController();
  final _accessKeyIdController = TextEditingController();
  final _accessKeySecretController = TextEditingController();
  final _codeController = TextEditingController();
  final _backendUrlController = TextEditingController();

  bool _isLoading = false;
  bool _argsProcessed = false;

  /// 命令行参数
  AppOptions get _appOptions => AppOptions.instance;

  /// 是否使用后端代理模式
  bool get _isProxyMode => _backendUrlController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _initializeAsync();
  }

  @override
  void dispose() {
    _appIdController.dispose();
    _accessKeyIdController.dispose();
    _accessKeySecretController.dispose();
    _codeController.dispose();
    _backendUrlController.dispose();
    super.dispose();
  }

  /// 异步初始化：加载配置和 TTS，完成后检查自动连接
  void _initializeAsync() async {
    try {
      await Future.wait([_loadConfig(), _initializeTts()]);
      if (!mounted) return;
      // 初始化完成后处理命令行参数
      _processArgs();
      // 参数处理完成后检查是否需要自动开始
      _checkAutoStart();
    } catch (e, stackTrace) {
      logger.e('初始化异常: $e', error: e, stackTrace: stackTrace);
    }
  }

  /// 初始化 TTS（异步）
  Future<void> _initializeTts() async {
    try {
      await TtsManager.instance.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          logger.w('TTS 初始化超时（10秒）');
        },
      );
    } catch (e, stackTrace) {
      logger.e('TTS 初始化失败: $e', error: e, stackTrace: stackTrace);
    }
  }

  /// 处理命令行参数（仅初始化时处理一次）
  void _processArgs() {
    if (_argsProcessed) return;

    // 仅初始化时处理一次
    if (_appOptions.appId != null) {
      _appIdController.text = _appOptions.appId!;
    }
    if (_appOptions.accessKeyId != null) {
      _accessKeyIdController.text = _appOptions.accessKeyId!;
    }
    if (_appOptions.accessKeySecret != null) {
      _accessKeySecretController.text = _appOptions.accessKeySecret!;
    }
    if (_appOptions.code != null) {
      _codeController.text = _appOptions.code!;
    }
    if (_appOptions.backendUrl != null) {
      _backendUrlController.text = _appOptions.backendUrl!;
    }

    _argsProcessed = true;
  }

  /// 加载默认配置
  ///
  /// 优先级：已保存设置 > assets 配置
  /// 命令行参数在 _processArgs 中单独处理
  Future<void> _loadConfig() async {
    try {
      // 从assets加载配置文件（优先级最低，作为兜底）
      final assetsConfig = <String, String>{};
      try {
        final configString = await rootBundle.loadString(
          'assets/config.properties',
        );
        final lines = configString.split('\n');

        for (final line in lines) {
          if (line.trim().isEmpty || line.startsWith('#')) continue;
          final parts = line.split('=');
          if (parts.length == 2) {
            assetsConfig[parts[0].trim()] = parts[1].trim();
          }
        }
      } catch (e) {
        // assets 配置文件可能不存在，不影响继续执行
        logger.w('assets 配置文件读取失败: $e');
      }

      if (!mounted) return;
      final credState = context.read<CredentialsSettingsCubit>().state;
      final serverState = context.read<ServerSettingsCubit>().state;

      setState(() {
        // 优先级：已保存设置 > assets 配置
        // 命令行参数在 _processArgs 中处理，不在这里加载
        _appIdController.text = credState.appId.isNotEmpty
            ? credState.appId
            : (assetsConfig['app_id'] ?? '');
        _accessKeyIdController.text = credState.accessKeyId.isNotEmpty
            ? credState.accessKeyId
            : (assetsConfig['access_key_id'] ?? '');
        _accessKeySecretController.text = credState.accessKeySecret.isNotEmpty
            ? credState.accessKeySecret
            : (assetsConfig['access_key_secret'] ?? '');
        _codeController.text = credState.code.isNotEmpty
            ? credState.code
            : (assetsConfig['code'] ?? '');
        // 加载后端地址（使用已保存设置）
        _backendUrlController.text = serverState.backendUrl;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载配置失败: $e')));
      }
    }
  }

  /// 检查是否自动开始直播
  ///
  /// 仅在初始化完成且参数处理完成后检查一次
  void _checkAutoStart() {
    if (_appOptions.canAutoStart && mounted && !_isLoading) {
      // 延迟执行，确保 UI 已经构建完成
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isLoading) {
          _startLive();
        }
      });
    }
  }

  /// 保存配置到存储
  ///
  /// 每次输入变化时自动调用
  Future<void> _saveConfig() async {
    final credCubit = context.read<CredentialsSettingsCubit>();
    final serverCubit = context.read<ServerSettingsCubit>();

    await credCubit.setAppId(_appIdController.text);
    await credCubit.setAccessKeyId(_accessKeyIdController.text);
    await credCubit.setAccessKeySecret(_accessKeySecretController.text);
    await credCubit.setCode(_codeController.text);
    await serverCubit.setBackendUrl(_backendUrlController.text);
  }

  /// 处理输入变化，自动保存
  void _handleInputChanged() {
    _saveConfig();
  }

  /// 开始直播
  ///
  /// 验证表单 -> 创建API客户端 -> 调用start接口 -> 跳转到直播页面
  Future<void> _startLive() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 创建API客户端
      final BilibiliLiveApiClient client;
      if (_isProxyMode) {
        // 使用后端代理模式
        client = BilibiliLiveApiClient(
          baseUrl: _backendUrlController.text.trim(),
        );
      } else {
        // 直连官方 API 模式
        client = BilibiliLiveApiClient(
          accessKeyId: _accessKeyIdController.text,
          accessKeySecret: _accessKeySecretController.text,
        );
      }

      // 调用start接口
      final startData = await client.start(
        code: _codeController.text.isEmpty ? null : _codeController.text,
        appId: _appIdController.text.isEmpty
            ? null
            : int.tryParse(_appIdController.text),
      );

      if (!mounted) return;

      final serverState = context.read<ServerSettingsCubit>().state;

      // 成功后跳转到第二页
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LivePage(
            appId: _appIdController.text.isEmpty
                ? null
                : int.tryParse(_appIdController.text),
            startData: startData,
            apiClient: client,
            enableHttpServer: serverState.enableHttpServer && !kIsWeb,
            accessKeyId: _accessKeyIdController.text.isEmpty
                ? null
                : _accessKeyIdController.text,
            accessKeySecret: _accessKeySecretController.text.isEmpty
                ? null
                : _accessKeySecretController.text,
            code: _codeController.text.isEmpty ? null : _codeController.text,
            httpServerPort: serverState.httpServerPort,
          ),
        ),
      );
    } catch (e) {
      log('启动失败', error: e, stackTrace: e is Error ? e.stackTrace : null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('启动失败: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 打开设置页面
  Future<void> _openSettings() async {
    if (!mounted) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SettingsPage()));
    // 返回后重新加载配置（不处理参数，参数只初始化一次）
    await _loadConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('哔哩哔哩直播弹幕'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: '设置',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.live_tv, size: 80, color: Colors.blue),
                  const SizedBox(height: 32),

                  // 凭证输入板块
                  HomeCredentialsPanel(
                    backendUrlController: _backendUrlController,
                    appIdController: _appIdController,
                    accessKeyIdController: _accessKeyIdController,
                    accessKeySecretController: _accessKeySecretController,
                    codeController: _codeController,
                    onChanged: _handleInputChanged,
                  ),

                  const SizedBox(height: 24),

                  // 开始按钮
                  ElevatedButton(
                    onPressed: _isLoading ? null : _startLive,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('开始直播', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
