import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/home_page_cubit.dart';

/// Home 页面输入项通用组件
///
/// 支持文本输入、验证和自动保存

/// 文本输入字段组件
///
/// 提供统一的输入框样式和验证
Widget buildHomeTextField({
  required String label,
  required String hintText,
  required TextEditingController controller,
  required String? Function(String?)? validator,
  TextInputType keyboardType = TextInputType.text,
  IconData? prefixIcon,
  bool obscureText = false,
  ValueChanged<String>? onChanged,
  bool enabled = true,
  String? helperText,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      hintText: hintText,
      border: const OutlineInputBorder(),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      enabled: enabled,
      helperText: helperText,
    ),
    keyboardType: keyboardType,
    obscureText: obscureText,
    validator: validator,
    onChanged: onChanged,
  );
}

/// 代理模式的后端地址输入
Widget buildBackendUrlInput({
  required TextEditingController controller,
  required ValueChanged<String> onChanged,
}) {
  return buildHomeTextField(
    label: '后端地址',
    hintText: '留空使用官方 API',
    controller: controller,
    prefixIcon: Icons.cloud,
    onChanged: onChanged,
    validator: (value) => null, // 可选字段
  );
}

/// App ID 输入
Widget buildAppIdInput({
  required TextEditingController controller,
  required ValueChanged<String> onChanged,
}) {
  return BlocBuilder<HomePageCubit, HomePageState>(
    builder: (context, state) {
      final homePageCubit = context.read<HomePageCubit>();
      final isProxyMode = homePageCubit.isProxyMode();
      return buildHomeTextField(
        label: 'App ID',
        hintText: '请输入 App ID',
        controller: controller,
        keyboardType: TextInputType.number,
        prefixIcon: Icons.apps,
        onChanged: onChanged,
        validator: (value) {
          // 代理模式下可以为空
          if (isProxyMode) return null;
          if (value == null || value.isEmpty) {
            return '请输入App ID';
          }
          if (int.tryParse(value) == null) {
            return '请输入有效的数字';
          }
          return null;
        },
      );
    },
  );
}

/// Access Key ID 输入
Widget buildAccessKeyIdInput({
  required TextEditingController controller,
  required ValueChanged<String> onChanged,
}) {
  return BlocBuilder<HomePageCubit, HomePageState>(
    builder: (context, state) {
      final homePageCubit = context.read<HomePageCubit>();
      final isProxyMode = homePageCubit.isProxyMode();
      return buildHomeTextField(
        label: 'Access Key ID',
        hintText: '请输入 Access Key ID',
        controller: controller,
        prefixIcon: Icons.key,
        enabled: !isProxyMode,
        helperText: isProxyMode ? '使用后端代理模式' : null,
        onChanged: onChanged,
        validator: (value) {
          // 代理模式下不需要验证
          if (isProxyMode) return null;
          if (value == null || value.isEmpty) {
            return '请输入Access Key ID';
          }
          return null;
        },
      );
    },
  );
}

/// Access Key Secret 输入
Widget buildAccessKeySecretInput({
  required TextEditingController controller,
  required ValueChanged<String> onChanged,
}) {
  return BlocBuilder<HomePageCubit, HomePageState>(
    builder: (context, state) {
      final homePageCubit = context.read<HomePageCubit>();
      final isProxyMode = homePageCubit.isProxyMode();
      return buildHomeTextField(
        label: 'Access Key Secret',
        hintText: '请输入 Access Key Secret',
        controller: controller,
        prefixIcon: Icons.lock,
        obscureText: true,
        enabled: !isProxyMode,
        helperText: isProxyMode ? '使用后端代理模式' : null,
        onChanged: onChanged,
        validator: (value) {
          // 代理模式下不需要验证
          if (isProxyMode) return null;
          if (value == null || value.isEmpty) {
            return '请输入Access Key Secret';
          }
          return null;
        },
      );
    },
  );
}

/// Code 输入
Widget buildCodeInput({
  required TextEditingController controller,
  required ValueChanged<String> onChanged,
}) {
  return BlocBuilder<HomePageCubit, HomePageState>(
    builder: (context, state) {
      final homePageCubit = context.read<HomePageCubit>();
      final isProxyMode = homePageCubit.isProxyMode();
      return buildHomeTextField(
        label: '身份码 (Code)',
        hintText: '请输入身份码',
        controller: controller,
        prefixIcon: Icons.code,
        onChanged: onChanged,
        validator: (value) {
          // 代理模式下可以为空
          if (isProxyMode) return null;
          if (value == null || value.isEmpty) {
            return '请输入身份码';
          }
          return null;
        },
      );
    },
  );
}
