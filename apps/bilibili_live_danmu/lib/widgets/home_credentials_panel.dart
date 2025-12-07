import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
/// 直接与底层 Cubit 通信进行状态更新和自动保存
class HomeCredentialsPanel extends StatefulWidget {
  /// 后端地址控制器
  final TextEditingController backendUrlController;

  /// App ID 控制器
  final TextEditingController appIdController;

  /// Access Key ID 控制器
  final TextEditingController accessKeyIdController;

  /// Access Key Secret 控制器
  final TextEditingController accessKeySecretController;

  /// Code 控制器
  final TextEditingController codeController;

  const HomeCredentialsPanel({
    super.key,
    required this.backendUrlController,
    required this.appIdController,
    required this.accessKeyIdController,
    required this.accessKeySecretController,
    required this.codeController,
  });

  @override
  State<HomeCredentialsPanel> createState() => _HomeCredentialsPanelState();
}

class _HomeCredentialsPanelState extends State<HomeCredentialsPanel> {
  late bool _isProxyMode;

  @override
  void initState() {
    super.initState();
    _updateProxyMode();
  }

  void _updateProxyMode() {
    setState(() {
      _isProxyMode = widget.backendUrlController.text.trim().isNotEmpty;
    });
  }

  void _handleInputChanged(String fieldName, String value) {
    _updateProxyMode();

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Web 端显示后端地址输入框（必填）
        if (kIsWeb) ...[
          buildBackendUrlInput(
            controller: widget.backendUrlController,
            onChanged: (value) => _handleInputChanged('backendUrl', value),
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

        // App ID
        buildAppIdInput(
          controller: widget.appIdController,
          isProxyMode: _isProxyMode,
          onChanged: (value) => _handleInputChanged('appId', value),
        ),
        const SizedBox(height: 16),

        // 非 Web 端且非代理模式时显示 AccessKey 字段
        if (!kIsWeb) ...[
          buildAccessKeyIdInput(
            controller: widget.accessKeyIdController,
            isProxyMode: _isProxyMode,
            onChanged: (value) => _handleInputChanged('accessKeyId', value),
          ),
          const SizedBox(height: 16),
          buildAccessKeySecretInput(
            controller: widget.accessKeySecretController,
            isProxyMode: _isProxyMode,
            onChanged: (value) => _handleInputChanged('accessKeySecret', value),
          ),
          const SizedBox(height: 16),
        ],

        // Code
        buildCodeInput(
          controller: widget.codeController,
          isProxyMode: _isProxyMode,
          onChanged: (value) => _handleInputChanged('code', value),
        ),
      ],
    );
  }
}
