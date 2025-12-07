import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../blocs/settings/display_settings_cubit.dart';
import '../blocs/settings/filter_settings_cubit.dart';
import '../blocs/settings/server_settings_cubit.dart';

/// 设置面板
class SettingsPanel extends StatefulWidget {
  /// 是否处于工作中（直播中）
  /// 非工作模式下会显示服务器设置
  final bool isWorking;

  const SettingsPanel({super.key, this.isWorking = true});

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  final _backendUrlController = TextEditingController();
  final _httpServerPortController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final serverSettings = context.read<ServerSettingsCubit>().state;
    _backendUrlController.text = serverSettings.backendUrl;
    _httpServerPortController.text = serverSettings.httpServerPort.toString();
  }

  @override
  void dispose() {
    _backendUrlController.dispose();
    _httpServerPortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 非工作模式下显示服务器设置
        if (!widget.isWorking) ...[
          _buildServerSection(),
          const SizedBox(height: 24),
        ],
        _buildDisplaySection(),
        const SizedBox(height: 24),
        _buildFilterSection(),
      ],
    );
  }

  Widget _buildDisplaySection() {
    return BlocBuilder<DisplaySettingsCubit, DisplaySettingsState>(
      builder: (context, state) {
        final cubit = context.read<DisplaySettingsCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '显示设置',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 字体大小
            _buildSliderSetting(
              '字体大小',
              state.fontSize,
              1,
              100,
              (newValue) => cubit.setFontSize(newValue),
              divisions: 99,
              sliderLabel: '${state.fontSize.toInt()}',
            ),

            // 显示时间
            _buildSliderSetting(
              '显示时间 (秒)',
              state.duration.toDouble(),
              1,
              300,
              (newValue) => cubit.setDuration(newValue.toInt()),
              divisions: 299,
              sliderLabel: '${state.duration}秒',
            ),

            // 文字颜色
            _buildColorSetting(
              '文字颜色',
              Color(state.textColor),
              (color) => cubit.setTextColor(color.toARGB32()),
            ),

            // 背景颜色
            _buildColorSetting(
              '背景颜色',
              Color(state.backgroundColor),
              (color) => cubit.setBackgroundColor(color.toARGB32()),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterSection() {
    return BlocBuilder<FilterSettingsCubit, FilterSettingsState>(
      builder: (context, state) {
        final cubit = context.read<FilterSettingsCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '消息过滤',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildSwitchSetting(
              '弹幕',
              state.showDanmaku,
              (newValue) => cubit.setShowDanmaku(newValue),
            ),

            _buildSwitchSetting(
              '礼物',
              state.showGift,
              (newValue) => cubit.setShowGift(newValue),
            ),

            _buildSwitchSetting(
              'SC(醒目留言)',
              state.showSuperChat,
              (newValue) => cubit.setShowSuperChat(newValue),
            ),

            _buildSwitchSetting(
              '大航海',
              state.showGuard,
              (newValue) => cubit.setShowGuard(newValue),
            ),

            _buildSwitchSetting(
              '点赞',
              state.showLike,
              (newValue) => cubit.setShowLike(newValue),
            ),

            _buildSwitchSetting(
              '进入房间',
              state.showEnter,
              (newValue) => cubit.setShowEnter(newValue),
            ),

            _buildSwitchSetting(
              '开播提醒',
              state.showLiveStart,
              (newValue) => cubit.setShowLiveStart(newValue),
            ),

            _buildSwitchSetting(
              '下播提醒',
              state.showLiveEnd,
              (newValue) => cubit.setShowLiveEnd(newValue),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSliderSetting(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    int? divisions,
    String? sliderLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: sliderLabel ?? value.toStringAsFixed(0),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildColorSetting(
    String label,
    Color color,
    ValueChanged<Color> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          GestureDetector(
            onTap: () => _showColorPicker(color, onChanged),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示颜色选择对话框
  ///
  /// 使用 [ColorPicker] 实现完整的颜色选择功能：
  /// - 支持色彩、饱和度、明度调整
  /// - 支持透明度（Alpha）调整
  /// - 对话框背景透明（barrierColor: Colors.transparent）
  ///
  /// 参数:
  ///   currentColor - 当前选中的颜色
  ///   onChanged - 颜色变化回调，实时更新设置
  void _showColorPicker(Color currentColor, ValueChanged<Color> onChanged) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题
              const Text(
                '选择颜色',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // 颜色选择器
              SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: currentColor,
                  onColorChanged: (color) {
                    onChanged(color);
                  },
                  pickerAreaHeightPercent: 0.8,
                  enableAlpha: true,
                  displayThumbColor: true,
                  portraitOnly: false,
                  hexInputController: TextEditingController(
                    text: currentColor.toHexString(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 确定按钮
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('确定'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建服务器设置区域（仅非工作模式下显示）
  Widget _buildServerSection() {
    return BlocBuilder<ServerSettingsCubit, ServerSettingsState>(
      builder: (context, state) {
        final cubit = context.read<ServerSettingsCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '服务器设置',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // 后端地址输入框
            TextField(
              controller: _backendUrlController,
              decoration: const InputDecoration(
                labelText: '后端地址（可选）',
                hintText: '留空使用官方 API',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cloud),
              ),
              onChanged: (value) {
                cubit.setBackendUrl(value);
              },
            ),
            const SizedBox(height: 16),
            // HTTP 服务开关（非 Web 端）
            _buildSwitchSetting(
              '启用 HTTP 代理服务',
              state.enableHttpServer,
              (newValue) => cubit.setEnableHttpServer(newValue),
            ),
            const SizedBox(height: 16),
            // 服务端口
            TextField(
              controller: _httpServerPortController,
              decoration: const InputDecoration(
                labelText: 'HTTP 服务端口',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
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
