import 'package:flutter/material.dart';
import 'widgets/settings_panel.dart';

/// 设置页面（独立页面，非工作模式）
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const SettingsPanel(isWorking: false),
    );
  }
}
