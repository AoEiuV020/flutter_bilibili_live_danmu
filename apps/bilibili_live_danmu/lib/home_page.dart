import 'dart:developer';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bilibili_live_api/bilibili_live_api.dart';
import 'blocs/home_page_cubit.dart';
import 'blocs/settings/server_settings_cubit.dart';
import 'live_page.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeAsync();
  }

  /// 异步初始化：初始化 TTS 并同步控制器
  void _initializeAsync() async {
    try {
      // 初始化 TTS
      await _initializeTts();

      if (!mounted) return;

      // 同步 UI 控制器的值
      _syncControllers();

      // 检查是否需要自动开始
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

  /// 从 Cubit 状态同步控制器的值
  void _syncControllers() {
    final homePageCubit = context.read<HomePageCubit>();
    final state = homePageCubit.state;

    _appIdController.text = state.credentialsState.appId;
    _accessKeyIdController.text = state.credentialsState.accessKeyId;
    _accessKeySecretController.text = state.credentialsState.accessKeySecret;
    _codeController.text = state.credentialsState.code;
    _backendUrlController.text = state.serverState.backendUrl;
  }

  /// 检查是否自动开始直播
  void _checkAutoStart() {
    final homePageCubit = context.read<HomePageCubit>();

    if (homePageCubit.canAutoStart() && mounted && !_isLoading) {
      // 延迟执行，确保 UI 已经构建完成
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isLoading) {
          _startLive();
        }
      });
    }
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

  /// 获取代理模式状态
  bool _isProxyMode() {
    final homePageCubit = context.read<HomePageCubit>();
    return homePageCubit.isProxyMode();
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
      if (_isProxyMode()) {
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
    // 返回后同步 UI（配置可能有变化）
    _syncControllers();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomePageCubit, HomePageState>(
      listener: (context, state) {
        // 只在值实际不同时才更新，避免选中所有文本
        if (_appIdController.text != state.credentialsState.appId) {
          _appIdController.text = state.credentialsState.appId;
        }
        if (_accessKeyIdController.text != state.credentialsState.accessKeyId) {
          _accessKeyIdController.text = state.credentialsState.accessKeyId;
        }
        if (_accessKeySecretController.text !=
            state.credentialsState.accessKeySecret) {
          _accessKeySecretController.text =
              state.credentialsState.accessKeySecret;
        }
        if (_codeController.text != state.credentialsState.code) {
          _codeController.text = state.credentialsState.code;
        }
        if (_backendUrlController.text != state.serverState.backendUrl) {
          _backendUrlController.text = state.serverState.backendUrl;
        }
      },
      child: Scaffold(
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
      ),
    );
  }
}
