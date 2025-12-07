import 'package:flutter/material.dart';
import 'display_settings_section.dart';
import 'filter_settings_section.dart';
import 'server_settings_section.dart';
import 'credentials_settings_section.dart';

/// 设置面板
///
/// 整合多个设置板块：
/// - 凭证设置（始终显示）
/// - 显示设置（始终显示）
/// - 消息过滤（始终显示）
/// - 服务器设置（仅非工作模式下显示）
class SettingsPanel extends StatelessWidget {
  /// 是否处于工作中（直播中）
  /// 非工作模式下会显示服务器设置
  final bool isWorking;

  const SettingsPanel({super.key, this.isWorking = true});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 非工作模式下显示凭证设置
        if (!isWorking) const CredentialsSettingsSection(),
        // 非工作模式下显示服务器设置
        if (!isWorking) const ServerSettingsSection(),

        // 显示设置
        const DisplaySettingsSection(),

        // 消息过滤
        const FilterSettingsSection(),
      ],
    );
  }
}
