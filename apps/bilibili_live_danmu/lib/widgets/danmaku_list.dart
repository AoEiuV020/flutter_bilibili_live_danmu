import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/tts_manager.dart';
import '../models/settings.dart';

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

  /// 获取播报文本
  String get speakText {
    if (type == MessageType.danmaku && username != null) {
      // 用户名超过10字符截断
      final truncatedUsername = username!.length > 10
          ? username!.substring(0, 10)
          : username!;
      return '$truncatedUsername说$content';
    }
    return content;
  }
}

/// 消息列表组件（弹幕+提示）
class MessageList extends StatefulWidget {
  final DisplaySettings displaySettings;

  const MessageList({super.key, required this.displaySettings});

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
    _updateCleanupTimer();
  }

  @override
  void didUpdateWidget(MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.displaySettings.displayDuration !=
        widget.displaySettings.displayDuration) {
      _updateCleanupTimer();
    }
  }

  void _updateCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupIntervalSeconds = (widget.displaySettings.displayDuration / 4)
        .ceil();
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

    // 播报消息（使用单例）
    TtsManager.instance.speak(message.speakText);

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

  /// 设置是否打断旧的播报
  void setInterruptOldSpeech(bool interrupt) {
    TtsManager.instance.setInterruptOldSpeech(interrupt);
  }

  /// 移除过期消息
  void _removeExpiredMessages() {
    if (!mounted) return;

    final now = DateTime.now();
    final expireTime = now.subtract(
      Duration(seconds: widget.displaySettings.displayDuration),
    );

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
    // 没有消息时显示空白
    if (_messages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: widget.displaySettings.backgroundColor,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        reverse: true, // 反转列表，使新消息在底部
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          // 因为列表反转了，所以索引也要反转
          final message = _messages[_messages.length - 1 - index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              message.displayText,
              style: TextStyle(
                color: widget.displaySettings.textColor,
                fontSize: widget.displaySettings.fontSize,
                height: 1.5,
              ),
            ),
          );
        },
      ),
    );
  }
}
