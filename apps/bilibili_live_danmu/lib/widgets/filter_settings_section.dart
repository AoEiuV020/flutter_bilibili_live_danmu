import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/settings/filter_settings_cubit.dart';
import 'settings_section.dart';

/// 消息过滤设置板块
///
/// 包括：
/// - 弹幕
/// - 礼物
/// - SC(醒目留言)
/// - 大航海
/// - 点赞
/// - 进入房间
/// - 开播提醒
/// - 下播提醒
class FilterSettingsSection extends StatelessWidget {
  const FilterSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterSettingsCubit, FilterSettingsState>(
      builder: (context, state) {
        final cubit = context.read<FilterSettingsCubit>();
        return SettingsSection(
          title: '消息过滤',
          children: [
            buildSwitchSetting(
              '弹幕',
              state.showDanmaku,
              (newValue) => cubit.setShowDanmaku(newValue),
            ),

            buildSwitchSetting(
              '礼物',
              state.showGift,
              (newValue) => cubit.setShowGift(newValue),
            ),

            buildSwitchSetting(
              'SC(醒目留言)',
              state.showSuperChat,
              (newValue) => cubit.setShowSuperChat(newValue),
            ),

            buildSwitchSetting(
              '大航海',
              state.showGuard,
              (newValue) => cubit.setShowGuard(newValue),
            ),

            buildSwitchSetting(
              '点赞',
              state.showLike,
              (newValue) => cubit.setShowLike(newValue),
            ),

            buildSwitchSetting(
              '进入房间',
              state.showEnter,
              (newValue) => cubit.setShowEnter(newValue),
            ),

            buildSwitchSetting(
              '开播提醒',
              state.showLiveStart,
              (newValue) => cubit.setShowLiveStart(newValue),
            ),

            buildSwitchSetting(
              '下播提醒',
              state.showLiveEnd,
              (newValue) => cubit.setShowLiveEnd(newValue),
            ),
          ],
        );
      },
    );
  }
}
