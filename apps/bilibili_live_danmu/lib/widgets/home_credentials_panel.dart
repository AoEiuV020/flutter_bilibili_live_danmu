import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/home_page_cubit.dart';
import '../blocs/settings/credentials_settings_cubit.dart';
import '../blocs/settings/server_settings_cubit.dart';
import 'home_input_fields.dart';

/// Home 页面凭证输入板块
///
/// 包括：
/// - 后端地址（Web端和非代理模式下必填）
/// - App ID
/// - Access Key ID（非Web端）
/// - Access Key Secret（非Web端）
/// - Code
///
/// 直接从 Cubit 读取状态，无需从外部传入 controller
class HomeCredentialsPanel extends StatefulWidget {
  const HomeCredentialsPanel({super.key});

  @override
  State<HomeCredentialsPanel> createState() => _HomeCredentialsPanelState();
}

class _HomeCredentialsPanelState extends State<HomeCredentialsPanel> {
  late TextEditingController _backendUrlController;
  late TextEditingController _appIdController;
  late TextEditingController _accessKeyIdController;
  late TextEditingController _accessKeySecretController;
  late TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _backendUrlController = TextEditingController();
    _appIdController = TextEditingController();
    _accessKeyIdController = TextEditingController();
    _accessKeySecretController = TextEditingController();
    _codeController = TextEditingController();
    _syncControllers();
  }

  @override
  void dispose() {
    _backendUrlController.dispose();
    _appIdController.dispose();
    _accessKeyIdController.dispose();
    _accessKeySecretController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  /// 从 Cubit 状态同步控制器的值
  void _syncControllers() {
    final homePageCubit = context.read<HomePageCubit>();
    final state = homePageCubit.state;

    if (_backendUrlController.text != state.serverState.backendUrl) {
      _backendUrlController.text = state.serverState.backendUrl;
    }
    if (_appIdController.text != state.credentialsState.appId) {
      _appIdController.text = state.credentialsState.appId;
    }
    if (_accessKeyIdController.text != state.credentialsState.accessKeyId) {
      _accessKeyIdController.text = state.credentialsState.accessKeyId;
    }
    if (_accessKeySecretController.text !=
        state.credentialsState.accessKeySecret) {
      _accessKeySecretController.text = state.credentialsState.accessKeySecret;
    }
    if (_codeController.text != state.credentialsState.code) {
      _codeController.text = state.credentialsState.code;
    }
  }

  void _handleInputChanged(String fieldName, String value) {
    // 直接更新底层 Cubit（自动保存）
    final serverCubit = context.read<ServerSettingsCubit>();
    final credentialsCubit = context.read<CredentialsSettingsCubit>();

    switch (fieldName) {
      case 'backendUrl':
        serverCubit.setBackendUrl(value);
      case 'appId':
        credentialsCubit.setAppId(value);
      case 'accessKeyId':
        credentialsCubit.setAccessKeyId(value);
      case 'accessKeySecret':
        credentialsCubit.setAccessKeySecret(value);
      case 'code':
        credentialsCubit.setCode(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomePageCubit, HomePageState>(
      listener: (context, state) {
        // 状态改变时同步控制器
        _syncControllers();
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Web 端显示后端地址输入框（必填）
        if (kIsWeb) ...[
          buildBackendUrlInput(
            controller: _backendUrlController,
            onChanged: (value) => _handleInputChanged('backendUrl', value),
          ),
          if (_backendUrlController.text.trim().isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Web 端需要配置后端代理地址',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          const SizedBox(height: 16),
        ],

        // App ID
        buildAppIdInput(
          controller: _appIdController,
          onChanged: (value) => _handleInputChanged('appId', value),
        ),
        const SizedBox(height: 16),

        // 非 Web 端且非代理模式时显示 AccessKey 字段
        if (!kIsWeb) ...[
          buildAccessKeyIdInput(
            controller: _accessKeyIdController,
            onChanged: (value) => _handleInputChanged('accessKeyId', value),
          ),
          const SizedBox(height: 16),
          buildAccessKeySecretInput(
            controller: _accessKeySecretController,
            onChanged: (value) => _handleInputChanged('accessKeySecret', value),
          ),
          const SizedBox(height: 16),
        ],

        // Code
        buildCodeInput(
          controller: _codeController,
          onChanged: (value) => _handleInputChanged('code', value),
        ),
      ],
    );
  }
}
