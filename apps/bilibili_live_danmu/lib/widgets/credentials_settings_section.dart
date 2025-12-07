import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/settings/credentials_settings_cubit.dart';
import 'settings_section.dart';

/// 凭证设置板块
///
/// 包括：
/// - App ID
/// - Access Key ID
/// - Access Key Secret
/// - Code
class CredentialsSettingsSection extends StatefulWidget {
  const CredentialsSettingsSection({super.key});

  @override
  State<CredentialsSettingsSection> createState() =>
      _CredentialsSettingsSectionState();
}

class _CredentialsSettingsSectionState
    extends State<CredentialsSettingsSection> {
  late TextEditingController _appIdController;
  late TextEditingController _accessKeyIdController;
  late TextEditingController _accessKeySecretController;
  late TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    final state = context.read<CredentialsSettingsCubit>().state;
    _appIdController = TextEditingController(text: state.appId);
    _accessKeyIdController = TextEditingController(text: state.accessKeyId);
    _accessKeySecretController = TextEditingController(
      text: state.accessKeySecret,
    );
    _codeController = TextEditingController(text: state.code);
  }

  @override
  void dispose() {
    _appIdController.dispose();
    _accessKeyIdController.dispose();
    _accessKeySecretController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CredentialsSettingsCubit, CredentialsSettingsState>(
      builder: (context, state) {
        final cubit = context.read<CredentialsSettingsCubit>();
        return SettingsSection(
          title: '凭证设置',
          children: [
            buildTextInputSetting(
              'App ID',
              '请输入 App ID',
              _appIdController,
              prefixIcon: Icons.key,
              onChanged: (value) => cubit.setAppId(value),
            ),

            buildTextInputSetting(
              'Access Key ID',
              '请输入 Access Key ID',
              _accessKeyIdController,
              prefixIcon: Icons.security,
              onChanged: (value) => cubit.setAccessKeyId(value),
            ),

            buildTextInputSetting(
              'Access Key Secret',
              '请输入 Access Key Secret',
              _accessKeySecretController,
              prefixIcon: Icons.lock,
              onChanged: (value) => cubit.setAccessKeySecret(value),
            ),

            buildTextInputSetting(
              'Code',
              '请输入 Code',
              _codeController,
              prefixIcon: Icons.code,
              onChanged: (value) => cubit.setCode(value),
            ),
          ],
        );
      },
    );
  }
}
