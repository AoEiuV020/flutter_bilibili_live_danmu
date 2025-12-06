import 'live_message.dart';

/// 未知消息
class UnknownMessage extends LiveMessage {
  final Map<String, dynamic> data;

  UnknownMessage({required super.cmd, required this.data});

  @override
  String toString() {
    return '【未知】$cmd: $data';
  }
}
