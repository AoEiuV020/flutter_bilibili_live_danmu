import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bilibili_live_api/bilibili_live_api.dart';
import 'live_page.dart';

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

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _appIdController.dispose();
    _accessKeyIdController.dispose();
    _accessKeySecretController.dispose();
    _codeController.dispose();
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
      final client = BilibiliLiveApiClient(
        accessKeyId: _accessKeyIdController.text,
        accessKeySecret: _accessKeySecretController.text,
      );

      // 调用start接口
      final response = await client.start(
        code: _codeController.text,
        appId: int.parse(_appIdController.text),
      );

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        // 成功后跳转到第二页
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LivePage(
              appId: int.parse(_appIdController.text),
              startData: response.data!,
              apiClient: client,
            ),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('启动失败: ${response.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('哔哩哔哩直播弹幕'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                  TextFormField(
                    controller: _accessKeyIdController,
                    decoration: const InputDecoration(
                      labelText: 'Access Key ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.key),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入Access Key ID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _accessKeySecretController,
                    decoration: const InputDecoration(
                      labelText: 'Access Key Secret',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入Access Key Secret';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 32),
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
