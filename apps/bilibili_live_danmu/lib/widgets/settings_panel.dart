import 'package:flutter/material.dart';
import '../models/settings_provider.dart';

/// 设置面板
class SettingsPanel extends StatefulWidget {
  final VoidCallback onClose;

  /// 是否处于工作中（直播中）
  /// 非工作模式下会显示服务器设置
  final bool isWorking;

  const SettingsPanel({
    super.key,
    required this.onClose,
    this.isWorking = true,
  });

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  final _backendUrlController = TextEditingController();
  final _httpServerPortController = TextEditingController();

  SettingsProvider get _settings => SettingsProvider.instance;

  @override
  void initState() {
    super.initState();
    _backendUrlController.text = _settings.serverBackendUrl.value;
    _httpServerPortController.text = _settings.serverHttpServerPort.value
        .toString();
  }

  @override
  void dispose() {
    _backendUrlController.dispose();
    _httpServerPortController.dispose();
    super.dispose();
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
                // 非工作模式下显示服务器设置
                if (!widget.isWorking) ...[
                  _buildServerSection(),
                  const SizedBox(height: 24),
                ],
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
        ValueListenableBuilder<double>(
          valueListenable: _settings.displayFontSize,
          builder: (context, value, _) {
            return _buildSliderSetting(
              '字体大小',
              value,
              1,
              100,
              (newValue) => _settings.setDisplayFontSize(newValue),
              divisions: 99,
              sliderLabel: '${value.toInt()}',
            );
          },
        ),

        // 显示时间
        ValueListenableBuilder<int>(
          valueListenable: _settings.displayDuration,
          builder: (context, value, _) {
            return _buildSliderSetting(
              '显示时间 (秒)',
              value.toDouble(),
              30,
              300,
              (newValue) => _settings.setDisplayDuration(newValue.toInt()),
              divisions: 27,
              sliderLabel: '$value秒',
            );
          },
        ),

        // 文字颜色
        ValueListenableBuilder<int>(
          valueListenable: _settings.displayTextColor,
          builder: (context, value, _) {
            return _buildColorSetting(
              '文字颜色',
              Color(value),
              (color) => _settings.setDisplayTextColor(color.toARGB32()),
            );
          },
        ),

        // 背景颜色
        ValueListenableBuilder<int>(
          valueListenable: _settings.displayBackgroundColor,
          builder: (context, value, _) {
            return _buildColorSetting(
              '背景颜色',
              Color(value),
              (color) => _settings.setDisplayBackgroundColor(color.toARGB32()),
            );
          },
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

        ValueListenableBuilder<bool>(
          valueListenable: _settings.filterShowDanmaku,
          builder: (context, value, _) {
            return _buildSwitchSetting(
              '弹幕',
              value,
              (newValue) => _settings.setFilterShowDanmaku(newValue),
            );
          },
        ),

        ValueListenableBuilder<bool>(
          valueListenable: _settings.filterShowGift,
          builder: (context, value, _) {
            return _buildSwitchSetting(
              '礼物',
              value,
              (newValue) => _settings.setFilterShowGift(newValue),
            );
          },
        ),

        ValueListenableBuilder<bool>(
          valueListenable: _settings.filterShowSuperChat,
          builder: (context, value, _) {
            return _buildSwitchSetting(
              'SC(醒目留言)',
              value,
              (newValue) => _settings.setFilterShowSuperChat(newValue),
            );
          },
        ),

        ValueListenableBuilder<bool>(
          valueListenable: _settings.filterShowGuard,
          builder: (context, value, _) {
            return _buildSwitchSetting(
              '大航海',
              value,
              (newValue) => _settings.setFilterShowGuard(newValue),
            );
          },
        ),

        ValueListenableBuilder<bool>(
          valueListenable: _settings.filterShowLike,
          builder: (context, value, _) {
            return _buildSwitchSetting(
              '点赞',
              value,
              (newValue) => _settings.setFilterShowLike(newValue),
            );
          },
        ),

        ValueListenableBuilder<bool>(
          valueListenable: _settings.filterShowEnter,
          builder: (context, value, _) {
            return _buildSwitchSetting(
              '进入房间',
              value,
              (newValue) => _settings.setFilterShowEnter(newValue),
            );
          },
        ),

        ValueListenableBuilder<bool>(
          valueListenable: _settings.filterShowLiveStart,
          builder: (context, value, _) {
            return _buildSwitchSetting(
              '开播提醒',
              value,
              (newValue) => _settings.setFilterShowLiveStart(newValue),
            );
          },
        ),

        ValueListenableBuilder<bool>(
          valueListenable: _settings.filterShowLiveEnd,
          builder: (context, value, _) {
            return _buildSwitchSetting(
              '下播提醒',
              value,
              (newValue) => _settings.setFilterShowLiveEnd(newValue),
            );
          },
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

  /// 构建服务器设置区域（仅非工作模式下显示）
  Widget _buildServerSection() {
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
            _settings.setServerBackendUrl(value);
          },
        ),
        const SizedBox(height: 16),
        // HTTP 服务开关（非 Web 端）
        ValueListenableBuilder<bool>(
          valueListenable: _settings.serverEnableHttpServer,
          builder: (context, value, _) {
            return _buildSwitchSetting(
              '启用 HTTP 代理服务',
              value,
              (newValue) => _settings.setServerEnableHttpServer(newValue),
            );
          },
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
              _settings.setServerHttpServerPort(port);
            }
          },
        ),
      ],
    );
  }
}
