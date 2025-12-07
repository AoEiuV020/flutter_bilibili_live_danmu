import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  /// 内容变化回调（用于自动保存）
  final VoidCallback onChanged;

  const HomeCredentialsPanel({
    super.key,
    required this.backendUrlController,
    required this.appIdController,
    required this.accessKeyIdController,
    required this.accessKeySecretController,
    required this.codeController,
    required this.onChanged,
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

  void _handleChanged() {
    _updateProxyMode();
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServerSettingsCubit, ServerSettingsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Web 端显示后端地址输入框（必填）
            if (kIsWeb) ...[
              buildBackendUrlInput(
                controller: widget.backendUrlController,
                onChanged: _handleChanged,
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
              onChanged: _handleChanged,
            ),
            const SizedBox(height: 16),

            // 非 Web 端且非代理模式时显示 AccessKey 字段
            if (!kIsWeb) ...[
              buildAccessKeyIdInput(
                controller: widget.accessKeyIdController,
                isProxyMode: _isProxyMode,
                onChanged: _handleChanged,
              ),
              const SizedBox(height: 16),
              buildAccessKeySecretInput(
                controller: widget.accessKeySecretController,
                isProxyMode: _isProxyMode,
                onChanged: _handleChanged,
              ),
              const SizedBox(height: 16),
            ],

            // Code
            buildCodeInput(
              controller: widget.codeController,
              isProxyMode: _isProxyMode,
              onChanged: _handleChanged,
            ),
          ],
        );
      },
    );
  }
}
