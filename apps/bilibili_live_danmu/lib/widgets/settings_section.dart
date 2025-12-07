import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// 设置板块基础组件
///
/// 提供统一的板块样式和布局，包含：
/// - 标题
/// - 内容列表
/// - 统一的间距
class SettingsSection extends StatelessWidget {
  /// 板块标题
  final String title;

  /// 板块内容
  final List<Widget> children;

  /// 是否显示分隔线
  final bool showDivider;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...children,
        if (showDivider) const SizedBox(height: 24),
      ],
    );
  }
}

/// 滑块设置项
///
/// 用于设置范围值，如字体大小、显示时间等
Widget buildSliderSetting(
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

/// 开关设置项
///
/// 用于布尔值设置，如启用/禁用某功能
Widget buildSwitchSetting(
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

/// 颜色选择设置项
///
/// 用于选择颜色，点击时打开颜色选择器
Widget buildColorSetting(
  String label,
  Color color,
  ValueChanged<Color> onChanged, {
  required BuildContext context,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        GestureDetector(
          onTap: () => _showColorPicker(context, color, onChanged),
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

/// 文本输入设置项
///
/// 用于输入文本内容
Widget buildTextInputSetting(
  String label,
  String hintText,
  TextEditingController controller, {
  IconData? prefixIcon,
  TextInputType keyboardType = TextInputType.text,
  ValueChanged<String>? onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
    ),
  );
}

/// 显示颜色选择对话框
///
/// 使用 [ColorPicker] 实现完整的颜色选择功能
void _showColorPicker(
  BuildContext context,
  Color currentColor,
  ValueChanged<Color> onChanged,
) {
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
            const Text(
              '选择颜色',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // 简单颜色网格
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
