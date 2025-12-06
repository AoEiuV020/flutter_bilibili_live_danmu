import 'package:flutter/material.dart';
import 'models/settings.dart';
import 'widgets/settings_panel.dart';

/// 设置页面（独立页面，非工作模式）
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsManager _settingsManager;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _settingsManager = SettingsManager();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _settingsManager.load();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('设置'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SettingsPanel(
        settingsManager: _settingsManager,
        onClose: () => Navigator.of(context).pop(),
        isWorking: false,
      ),
    );
  }
}
