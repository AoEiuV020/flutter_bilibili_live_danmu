import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/settings/server_settings_cubit.dart';
import 'settings_section.dart';

/// 服务器设置板块
///
/// 仅在非工作模式下显示
/// 包括：
/// - 后端地址
/// - 启用 HTTP 代理服务
/// - HTTP 服务端口
class ServerSettingsSection extends StatefulWidget {
  const ServerSettingsSection({super.key});

  @override
  State<ServerSettingsSection> createState() => _ServerSettingsSectionState();
}

class _ServerSettingsSectionState extends State<ServerSettingsSection> {
  late TextEditingController _backendUrlController;
  late TextEditingController _httpServerPortController;

  @override
  void initState() {
    super.initState();
    final serverSettings = context.read<ServerSettingsCubit>().state;
    _backendUrlController = TextEditingController(
      text: serverSettings.backendUrl,
    );
    _httpServerPortController = TextEditingController(
      text: serverSettings.httpServerPort.toString(),
    );
  }

  @override
  void dispose() {
    _backendUrlController.dispose();
    _httpServerPortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServerSettingsCubit, ServerSettingsState>(
      builder: (context, state) {
        final cubit = context.read<ServerSettingsCubit>();
        return SettingsSection(
          title: '服务器设置',
          children: [
            // 后端地址输入框
            buildTextInputSetting(
              '后端地址（可选）',
              '留空使用官方 API',
              _backendUrlController,
              prefixIcon: Icons.cloud,
              onChanged: (value) => cubit.setBackendUrl(value),
            ),

            // HTTP 服务开关
            buildSwitchSetting(
              '启用 HTTP 代理服务',
              state.enableHttpServer,
              (newValue) => cubit.setEnableHttpServer(newValue),
            ),

            // 服务端口
            buildTextInputSetting(
              'HTTP 服务端口',
              '8080',
              _httpServerPortController,
              prefixIcon: Icons.numbers,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final port = int.tryParse(value);
                if (port != null) {
                  cubit.setHttpServerPort(port);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
