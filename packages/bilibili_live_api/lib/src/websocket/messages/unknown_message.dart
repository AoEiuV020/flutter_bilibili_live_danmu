import 'live_message.dart';

/// 未知消息
class UnknownMessage extends LiveMessage {
  final Map<String, dynamic> data;

  UnknownMessage({required String cmd, required this.data}) : super(cmd: cmd);

  @override
  String toString() {
    return '【未知】$cmd: $data';
  }
}
