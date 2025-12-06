import 'dart:developer';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bilibili_live_api/bilibili_live_api.dart';
import 'models/settings.dart';
import 'live_page.dart';
import 'settings_page.dart';
import 'utils/tts_manager.dart';

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

  /// 是否使用后端代理模式
  bool get _isProxyMode => _backendUrlController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _settingsManager = SettingsManager();
    _loadConfig();
    _initializeTts();
  }

  /// 初始化 TTS（不阻塞页面加载）
  void _initializeTts() {
    // 在后台初始化 TTS，不等待结果，不影响页面加载
    TtsManager.instance
        .initialize()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('TTS 初始化超时（10秒）');
          },
        )
        .catchError((e) {
          debugPrint('TTS 初始化失败: $e');
        });
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
      // 从assets加载配置文件
      final configString = await rootBundle.loadString(
        'assets/config.properties',
      );
      final lines = configString.split('\n');
      final config = <String, String>{};

      for (final line in lines) {
        if (line.trim().isEmpty || line.startsWith('#')) continue;
        final parts = line.split('=');
        if (parts.length == 2) {
          config[parts[0].trim()] = parts[1].trim();
        }
      }

      // 加载 SettingsManager
      await _settingsManager.load();

      // 从SharedPreferences加载保存的配置
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _appIdController.text =
            prefs.getString('app_id') ?? config['app_id'] ?? '';
        _accessKeyIdController.text =
            prefs.getString('access_key_id') ?? config['access_key_id'] ?? '';
        _accessKeySecretController.text =
            prefs.getString('access_key_secret') ??
            config['access_key_secret'] ??
            '';
        _codeController.text = prefs.getString('code') ?? config['code'] ?? '';
        // 加载后端地址
        _backendUrlController.text = _settingsManager.serverSettings.backendUrl;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载配置失败: $e')));
      }
    }
  }

  /// 保存配置
  Future<void> _saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_id', _appIdController.text);
    await prefs.setString('access_key_id', _accessKeyIdController.text);
    await prefs.setString('access_key_secret', _accessKeySecretController.text);
    await prefs.setString('code', _codeController.text);
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
        code: _codeController.text,
        appId: int.parse(_appIdController.text),
      );

      if (!mounted) return;

      // 成功后跳转到第二页
      final serverSettings = _settingsManager.serverSettings;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LivePage(
            appId: int.parse(_appIdController.text),
            startData: startData,
            apiClient: client,
            enableHttpServer: serverSettings.enableHttpServer && !kIsWeb,
            accessKeyId: _accessKeyIdController.text,
            accessKeySecret: _accessKeySecretController.text,
            code: _codeController.text,
            httpServerPort: serverSettings.httpServerPort,
          ),
        ),
      );
    } catch (e) {
      debugPrint('启动失败: $e');
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
