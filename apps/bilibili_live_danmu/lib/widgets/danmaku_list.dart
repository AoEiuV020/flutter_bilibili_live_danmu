import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/settings/display_settings_cubit.dart';

/// 消息类型
enum MessageType {
  danmaku, // 弹幕
  info, // 提示信息
}

/// 消息项
class MessageItem {
  final String id;
  final String content;
  final String? username; // 用户名（仅弹幕有）
  final DateTime timestamp;
  final MessageType type;

  MessageItem({required this.content, required this.type, this.username})
    : id = DateTime.now().microsecondsSinceEpoch.toString(),
      timestamp = DateTime.now();

  /// 获取显示文本
  String get displayText {
    if (type == MessageType.danmaku && username != null) {
      return '$username: $content';
    }
    return content;
  }
}

/// 消息列表组件（弹幕+提示）
class MessageList extends StatefulWidget {
  const MessageList({super.key});

  @override
  State<MessageList> createState() => MessageListState();
}

class MessageListState extends State<MessageList> {
  final List<MessageItem> _messages = [];
  final ScrollController _scrollController = ScrollController();
  Timer? _cleanupTimer;
  int _cleanupIntervalSeconds = 30;

  @override
  void initState() {
    super.initState();
    final duration = context.read<DisplaySettingsCubit>().state.duration;
    _startCleanupTimer(duration);
  }

  void _startCleanupTimer(int duration) {
    _cleanupTimer?.cancel();
    _cleanupIntervalSeconds = (duration / 4).ceil();
    if (_cleanupIntervalSeconds < 1) _cleanupIntervalSeconds = 1;
    _cleanupTimer = Timer.periodic(
      Duration(seconds: _cleanupIntervalSeconds),
      (_) => _removeExpiredMessages(),
    );
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  /// 添加弹幕
  void addDanmaku(String username, String content) {
    _addMessage(content, MessageType.danmaku, username: username);
  }

  /// 添加提示信息
  void addInfo(String content) {
    _addMessage(content, MessageType.info);
  }

  /// 添加消息
  void _addMessage(String content, MessageType type, {String? username}) {
    if (!mounted) return;

    final message = MessageItem(
      content: content,
      type: type,
      username: username,
    );

    setState(() {
      _messages.add(message);
    });

    // 自动滚动到底部（因为使用了 reverse，所以滚动到 0 就是底部）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 移除过期消息
  void _removeExpiredMessages() {
    if (!mounted) return;

    final duration = context.read<DisplaySettingsCubit>().state.duration;
    final now = DateTime.now();
    final expireTime = now.subtract(Duration(seconds: duration));

    setState(() {
      _messages.removeWhere((msg) => msg.timestamp.isBefore(expireTime));
    });
  }

  /// 清空所有消息
  void clear() {
    if (!mounted) return;
    setState(() {
      _messages.clear();
    });
  }

  /// 清空所有消息
  void clearAll() {
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DisplaySettingsCubit, DisplaySettingsState>(
      listenWhen: (previous, current) => previous.duration != current.duration,
      listener: (context, state) {
        _startCleanupTimer(state.duration);
      },
      builder: (context, state) {
        return Container(
          color: Color(state.backgroundColor),
          child: _messages.isEmpty
              ? const SizedBox.expand() // 空消息时占满整个区域
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  reverse: true, // 反转列表，使新消息在底部
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    // 因为列表反转了，所以索引也要反转
                    final message = _messages[_messages.length - 1 - index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(state.danmakuBackgroundColor),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text(
                          message.displayText,
                          style: TextStyle(
                            color: Color(state.textColor),
                            fontSize: state.fontSize,
                            height: 1.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
