import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/settings/display_settings_cubit.dart';
import 'settings_section.dart';

/// 显示设置板块
///
/// 包括：
/// - 字体大小
/// - 显示时间
/// - 文字颜色
/// - 背景颜色
/// - 弹幕背景颜色
class DisplaySettingsSection extends StatelessWidget {
  const DisplaySettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DisplaySettingsCubit, DisplaySettingsState>(
      builder: (context, state) {
        final cubit = context.read<DisplaySettingsCubit>();
        return SettingsSection(
          title: '显示设置',
          children: [
            // 字体大小
            buildSliderSetting(
              '字体大小',
              state.fontSize,
              1,
              100,
              (newValue) => cubit.setFontSize(newValue),
              divisions: 99,
              sliderLabel: '${state.fontSize.toInt()}',
            ),

            // 显示时间
            buildSliderSetting(
              '显示时间 (秒)',
              state.duration.toDouble(),
              1,
              300,
              (newValue) => cubit.setDuration(newValue.toInt()),
              divisions: 299,
              sliderLabel: '${state.duration}秒',
            ),

            // 文字颜色
            buildColorSetting(
              '文字颜色',
              Color(state.textColor),
              (color) => cubit.setTextColor(color.toARGB32()),
              context: context,
            ),

            // 背景颜色
            buildColorSetting(
              '背景颜色',
              Color(state.backgroundColor),
              (color) => cubit.setBackgroundColor(color.toARGB32()),
              context: context,
            ),

            // 弹幕背景颜色
            buildColorSetting(
              '弹幕背景颜色',
              Color(state.danmakuBackgroundColor),
              (color) => cubit.setDanmakuBackgroundColor(color.toARGB32()),
              context: context,
            ),
          ],
        );
      },
    );
  }
}
