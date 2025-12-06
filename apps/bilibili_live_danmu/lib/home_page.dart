import 'dart:developer';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bilibili_live_api/bilibili_live_api.dart';
import 'models/settings.dart';
import 'live_page.dart';
import 'options/app_options.dart';
import 'settings_page.dart';
import 'utils/tts_manager.dart';
import 'src/logger.dart';

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

  // 服务器设置
  late SettingsManager _settingsManager;

  /// 命令行参数
  AppOptions get _appOptions => AppOptions.instance;

  /// 是否使用后端代理模式
  bool get _isProxyMode => _backendUrlController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _settingsManager = SettingsManager();
    _initializeAsync();
  }

  /// 异步初始化：加载配置和 TTS，完成后检查自动连接
  void _initializeAsync() async {
    try {
      await Future.wait([_loadConfig(), _initializeTts()]);
      // 所有初始化完成后，检查是否需要自动开始
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

  @override
  void dispose() {
    _appIdController.dispose();
    _accessKeyIdController.dispose();
    _accessKeySecretController.dispose();
    _codeController.dispose();
    _backendUrlController.dispose();
    super.dispose();
  }

  /// 加载默认配置
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

      // 加载 SettingsManager
      await _settingsManager.load();

      setState(() {
        final creds = _settingsManager.credentialsSettings;
        // 优先级：命令行参数 > --config 文件 > 已保存设置 > assets 配置
        _appIdController.text =
            _appOptions.appId ??
            (creds.appId.isNotEmpty
                ? creds.appId
                : (assetsConfig['app_id'] ?? ''));
        _accessKeyIdController.text =
            _appOptions.accessKeyId ??
            (creds.accessKeyId.isNotEmpty
                ? creds.accessKeyId
                : (assetsConfig['access_key_id'] ?? ''));
        _accessKeySecretController.text =
            _appOptions.accessKeySecret ??
            (creds.accessKeySecret.isNotEmpty
                ? creds.accessKeySecret
                : (assetsConfig['access_key_secret'] ?? ''));
        _codeController.text =
            _appOptions.code ??
            (creds.code.isNotEmpty ? creds.code : (assetsConfig['code'] ?? ''));
        // 加载后端地址（优先使用命令行参数或已保存设置）
        _backendUrlController.text =
            _appOptions.backendUrl ??
            _settingsManager.serverSettings.backendUrl;
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
  void _checkAutoStart() {
    if (_appOptions.canAutoStart && mounted) {
      // 延迟执行，确保 UI 已经构建完成
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isLoading) {
          _startLive();
        }
      });
    }
  }

  /// 保存配置
  Future<void> _saveConfig() async {
    final credentials = CredentialsSettings(
      appId: _appIdController.text,
      accessKeyId: _accessKeyIdController.text,
      accessKeySecret: _accessKeySecretController.text,
      code: _codeController.text,
    );
    await _settingsManager.saveCredentialsSettings(credentials);

    final serverSettings = ServerSettings(
      backendUrl: _backendUrlController.text,
      enableHttpServer: _settingsManager.serverSettings.enableHttpServer,
      httpServerPort: _settingsManager.serverSettings.httpServerPort,
    );
    await _settingsManager.saveServerSettings(serverSettings);
  }

  /// 开始直播
  Future<void> _startLive() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 保存配置
      await _saveConfig();

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

      // 调用start接口，直接返回数据或抛出异常
      final startData = await client.start(
        code: _codeController.text.isEmpty ? null : _codeController.text,
        appId: _appIdController.text.isEmpty
            ? null
            : int.tryParse(_appIdController.text),
      );

      if (!mounted) return;

      // 成功后跳转到第二页
      final serverSettings = _settingsManager.serverSettings;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LivePage(
            appId: _appIdController.text.isEmpty
                ? null
                : int.tryParse(_appIdController.text),
            startData: startData,
            apiClient: client,
            enableHttpServer: serverSettings.enableHttpServer && !kIsWeb,
            accessKeyId: _accessKeyIdController.text,
            accessKeySecret: _accessKeySecretController.text,
            code: _codeController.text.isEmpty ? null : _codeController.text,
            httpServerPort: serverSettings.httpServerPort,
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
    // 进入设置页前先保存当前输入
    await _saveConfig();
    if (!mounted) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SettingsPage()));
    // 返回后重新加载配置
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
                  // Web 端显示后端地址输入框（必填）
                  if (kIsWeb) ...[
                    TextFormField(
                      controller: _backendUrlController,
                      decoration: const InputDecoration(
                        labelText: '后端地址',
                        hintText: '留空使用官方 API（Web 端需配置）',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.cloud),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    if (!_isProxyMode)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Web 端需要配置后端代理地址',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _appIdController,
                    decoration: const InputDecoration(
                      labelText: 'App ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.apps),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      // 代理模式下可以为空
                      if (_isProxyMode) return null;
                      if (value == null || value.isEmpty) {
                        return '请输入App ID';
                      }
                      if (int.tryParse(value) == null) {
                        return '请输入有效的数字';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // 非 Web 端且非代理模式时显示 AccessKey 字段
                  if (!kIsWeb) ...[
                    TextFormField(
                      controller: _accessKeyIdController,
                      decoration: InputDecoration(
                        labelText: 'Access Key ID',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.key),
                        enabled: !_isProxyMode,
                        helperText: _isProxyMode ? '使用后端代理模式' : null,
                      ),
                      validator: (value) {
                        // 代理模式下不需要验证
                        if (_isProxyMode) return null;
                        if (value == null || value.isEmpty) {
                          return '请输入Access Key ID';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _accessKeySecretController,
                      decoration: InputDecoration(
                        labelText: 'Access Key Secret',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        enabled: !_isProxyMode,
                        helperText: _isProxyMode ? '使用后端代理模式' : null,
                      ),
                      obscureText: true,
                      validator: (value) {
                        // 代理模式下不需要验证
                        if (_isProxyMode) return null;
                        if (value == null || value.isEmpty) {
                          return '请输入Access Key Secret';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: '身份码 (Code)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.code),
                    ),
                    validator: (value) {
                      // 代理模式下可以为空
                      if (_isProxyMode) return null;
                      if (value == null || value.isEmpty) {
                        return '请输入身份码';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
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
