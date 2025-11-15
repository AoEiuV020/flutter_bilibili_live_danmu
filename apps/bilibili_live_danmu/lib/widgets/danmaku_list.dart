import 'dart:async';
import 'package:flutter/material.dart';

/// 消息类型
enum MessageType {
  danmaku, // 弹幕
  info, // 提示信息
}

/// 消息项
class MessageItem {
  final String id;
  final String content;
  final DateTime timestamp;
  final MessageType type;

  MessageItem({required this.content, required this.type})
    : id = DateTime.now().microsecondsSinceEpoch.toString(),
      timestamp = DateTime.now();
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

  @override
  void initState() {
    super.initState();
    // 每30秒清理一次过期消息
    _cleanupTimer = Timer.periodic(
      const Duration(seconds: 30),
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
  void addDanmaku(String content) {
    _addMessage(content, MessageType.danmaku);
  }

  /// 添加提示信息
  void addInfo(String content) {
    _addMessage(content, MessageType.info);
  }

  /// 添加消息
  void _addMessage(String content, MessageType type) {
    setState(() {
      _messages.add(MessageItem(content: content, type: type));
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

  /// 移除过期消息（2分钟前的消息）
  void _removeExpiredMessages() {
    final now = DateTime.now();
    final expireTime = now.subtract(const Duration(minutes: 2));

    setState(() {
      _messages.removeWhere((msg) => msg.timestamp.isBefore(expireTime));
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
    // 没有消息时显示全黑屏幕
    if (_messages.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
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
            message.content,
            style: const TextStyle(
              color: Colors.white, // 全部使用纯白色
              fontSize: 20, // 加大字体
              height: 1.5,
            ),
          ),
        );
      },
    );
  }
}
