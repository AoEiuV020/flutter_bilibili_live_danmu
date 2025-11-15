import 'package:flutter/material.dart';
import '../models/settings.dart';

/// 设置面板
class SettingsPanel extends StatefulWidget {
  final SettingsManager settingsManager;
  final VoidCallback onClose;
  final Function(DisplaySettings) onDisplaySettingsChanged;
  final Function(MessageFilterSettings) onFilterSettingsChanged;

  const SettingsPanel({
    super.key,
    required this.settingsManager,
    required this.onClose,
    required this.onDisplaySettingsChanged,
    required this.onFilterSettingsChanged,
  });

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  late DisplaySettings _displaySettings;
  late MessageFilterSettings _filterSettings;

  @override
  void initState() {
    super.initState();
    _displaySettings = widget.settingsManager.displaySettings;
    _filterSettings = widget.settingsManager.filterSettings;
  }

  void _updateDisplaySettings(DisplaySettings settings) {
    setState(() {
      _displaySettings = settings;
    });
    widget.settingsManager.saveDisplaySettings(settings);
    widget.onDisplaySettingsChanged(settings);
  }

  void _updateFilterSettings(MessageFilterSettings settings) {
    setState(() {
      _filterSettings = settings;
    });
    widget.settingsManager.saveFilterSettings(settings);
    widget.onFilterSettingsChanged(settings);
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: isPortrait ? const Radius.circular(16) : Radius.zero,
          topRight: const Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '设置',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          // 设置内容
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDisplaySection(),
                const SizedBox(height: 24),
                _buildFilterSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplaySection() {
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
          _displaySettings.fontSize,
          1,
          100,
          (value) => _updateDisplaySettings(
            _displaySettings.copyWith(fontSize: value),
          ),
          divisions: 99,
          sliderLabel: '${_displaySettings.fontSize.toInt()}',
        ),

        // 显示时间
        _buildSliderSetting(
          '显示时间 (秒)',
          _displaySettings.displayDuration.toDouble(),
          30,
          300,
          (value) => _updateDisplaySettings(
            _displaySettings.copyWith(displayDuration: value.toInt()),
          ),
          divisions: 27,
          sliderLabel: '${_displaySettings.displayDuration}秒',
        ),

        // 文字颜色
        _buildColorSetting(
          '文字颜色',
          _displaySettings.textColor,
          (color) => _updateDisplaySettings(
            _displaySettings.copyWith(textColor: color),
          ),
        ),

        // 背景颜色
        _buildColorSetting(
          '背景颜色',
          _displaySettings.backgroundColor,
          (color) => _updateDisplaySettings(
            _displaySettings.copyWith(backgroundColor: color),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
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
          _filterSettings.showDanmaku,
          (value) => _updateFilterSettings(
            _filterSettings.copyWith(showDanmaku: value),
          ),
        ),

        _buildSwitchSetting(
          '礼物',
          _filterSettings.showGift,
          (value) =>
              _updateFilterSettings(_filterSettings.copyWith(showGift: value)),
        ),

        _buildSwitchSetting(
          'SC(醒目留言)',
          _filterSettings.showSuperChat,
          (value) => _updateFilterSettings(
            _filterSettings.copyWith(showSuperChat: value),
          ),
        ),

        _buildSwitchSetting(
          '大航海',
          _filterSettings.showGuard,
          (value) =>
              _updateFilterSettings(_filterSettings.copyWith(showGuard: value)),
        ),

        _buildSwitchSetting(
          '点赞',
          _filterSettings.showLike,
          (value) =>
              _updateFilterSettings(_filterSettings.copyWith(showLike: value)),
        ),

        _buildSwitchSetting(
          '进入房间',
          _filterSettings.showEnter,
          (value) =>
              _updateFilterSettings(_filterSettings.copyWith(showEnter: value)),
        ),

        _buildSwitchSetting(
          '开播提醒',
          _filterSettings.showLiveStart,
          (value) => _updateFilterSettings(
            _filterSettings.copyWith(showLiveStart: value),
          ),
        ),

        _buildSwitchSetting(
          '下播提醒',
          _filterSettings.showLiveEnd,
          (value) => _updateFilterSettings(
            _filterSettings.copyWith(showLiveEnd: value),
          ),
        ),
      ],
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

  void _showColorPicker(Color currentColor, ValueChanged<Color> onChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择颜色'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildColorOption('白色', Colors.white, onChanged),
              _buildColorOption('黑色', Colors.black, onChanged),
              _buildColorOption('红色', Colors.red, onChanged),
              _buildColorOption('绿色', Colors.green, onChanged),
              _buildColorOption('蓝色', Colors.blue, onChanged),
              _buildColorOption('黄色', Colors.yellow, onChanged),
              _buildColorOption('紫色', Colors.purple, onChanged),
              _buildColorOption('橙色', Colors.orange, onChanged),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(
    String name,
    Color color,
    ValueChanged<Color> onChanged,
  ) {
    return ListTile(
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      title: Text(name),
      onTap: () {
        onChanged(color);
        Navigator.of(context).pop();
      },
    );
  }
}
