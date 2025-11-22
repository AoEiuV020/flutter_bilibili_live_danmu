import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bilibili_live_api/bilibili_live_api.dart';
import 'widgets/danmaku_list.dart';
import 'widgets/settings_panel.dart';
import 'models/settings.dart';
import 'utils/message_dispatcher.dart';
import 'utils/log_consumer.dart';
import 'utils/ui_consumer.dart';
import 'utils/tts_consumer.dart';
import 'viewmodels/live_page_viewmodel.dart';

class LivePage extends StatefulWidget {
  final int appId;
  final AppStartData startData;
  final BilibiliLiveApiClient apiClient;

  const LivePage({
    super.key,
    required this.appId,
    required this.startData,
    required this.apiClient,
  });

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  Timer? _hideTimer;
  bool _showBackButton = true;
  bool _showSettings = false;
  final GlobalKey<MessageListState> _messageListKey = GlobalKey();

  late SettingsManager _settingsManager;
  late MessageDispatcher _messageDispatcher;
  late LivePageViewModel _viewModel;

  DisplaySettings _displaySettings = DisplaySettings.defaultSettings();

  @override
  void initState() {
    super.initState();
    _initializeComponentsSync();
    _initializeAsync();
    _startHideTimer();
  }

  /// 同步初始化组件（立即完成，UI渲染不会出错）
  void _initializeComponentsSync() {
    // 初始化设置管理器
    _settingsManager = SettingsManager();

    // 初始化消息分发器
    _messageDispatcher = MessageDispatcher();
    _setupMessageConsumers();

    // 同步创建 ViewModel（不执行异步初始化）
    _viewModel = LivePageViewModel(
      appId: widget.appId,
      startData: widget.startData,
      apiClient: widget.apiClient,
      messageDispatcher: _messageDispatcher,
      settingsManager: _settingsManager,
    );
  }

  /// 异步初始化（加载设置、连接WebSocket等）
  Future<void> _initializeAsync() async {
    // 加载设置
    await _settingsManager.load();

    // 初始化 ViewModel（启动 WebSocket 等）
    await _viewModel.initialize();

    // 更新UI状态
    if (mounted) {
      setState(() {
        _displaySettings = _settingsManager.displaySettings;
      });
    }
  }

  /// 设置消息消费者
  void _setupMessageConsumers() {
    _messageDispatcher.register(LogConsumer());
    _messageDispatcher.register(TtsConsumer());
    // 直接注册UI消费者，传入GlobalKey
    _messageDispatcher.register(UiConsumer(messageListKey: _messageListKey));
  }

  @override
  void dispose() {
    _stopHideTimer();
    _messageDispatcher.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  /// 启动隐藏计时器
  void _startHideTimer() {
    _stopHideTimer();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showBackButton = false;
        });
      }
    });
  }

  /// 停止隐藏计时器
  void _stopHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  /// 显示返回按钮
  void _showBack() {
    setState(() {
      _showBackButton = true;
    });
    _startHideTimer();
  }

  /// 退出
  void _exit() {
    Navigator.of(context).pop();
  }

  /// 清空消息列表
  void _clearMessages() {
    _messageListKey.currentState?.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final screenSize = MediaQuery.of(context).size;

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: GestureDetector(
            onTap: _showBack,
            onPanDown: (_) => _showBack(),
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                // 主内容区域
                _buildMainContent(isPortrait, screenSize),
                // 顶部按钮栏
                _buildTopButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建主内容区域
  Widget _buildMainContent(bool isPortrait, Size screenSize) {
    if (isPortrait) {
      return Column(
        children: [
          Expanded(
            child: MessageList(
              key: _messageListKey,
              displaySettings: _displaySettings,
            ),
          ),
          if (_showSettings) _buildSettingsPanel(screenSize.height / 2, null),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: MessageList(
              key: _messageListKey,
              displaySettings: _displaySettings,
            ),
          ),
          if (_showSettings) _buildSettingsPanel(null, screenSize.width / 2),
        ],
      );
    }
  }

  /// 构建设置面板
  Widget _buildSettingsPanel(double? height, double? width) {
    return SizedBox(
      height: height,
      width: width,
      child: SettingsPanel(
        settingsManager: _settingsManager,
        onDisplaySettingsChanged: (settings) {
          setState(() {
            _displaySettings = settings;
          });
        },
        onFilterSettingsChanged: (settings) {
          _viewModel.updateFilterSettings(settings);
        },
        onClose: () {
          setState(() {
            _showSettings = false;
          });
        },
      ),
    );
  }

  /// 构建顶部按钮
  Widget _buildTopButtons() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: _showBackButton ? 16 : -60,
      left: 16,
      child: Row(
        children: [
          _buildIconButton(Icons.arrow_back, _exit),
          const SizedBox(width: 12),
          _buildIconButton(Icons.settings, () {
            setState(() {
              _showSettings = !_showSettings;
            });
          }),
          const SizedBox(width: 12),
          _buildIconButton(Icons.clear_all, _clearMessages),
          const SizedBox(width: 12),
          _buildTextButton('测试', _viewModel.addTestDanmaku),
        ],
      ),
    );
  }

  /// 构建图标按钮
  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  /// 构建文本按钮
  Widget _buildTextButton(String text, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
