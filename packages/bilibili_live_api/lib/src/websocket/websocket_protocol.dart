import 'dart:typed_data';

/// WebSocket 操作码
class Operation {
  static const int heartbeat = 2; // 心跳
  static const int heartbeatReply = 3; // 心跳回复
  static const int message = 5; // 消息
  static const int auth = 7; // 认证
  static const int authReply = 8; // 认证回复
}

/// WebSocket 协议版本
class ProtocolVersion {
  static const int json = 0; // JSON 格式
  static const int heartbeat = 1; // 心跳
  static const int deflate = 2; // zlib 压缩
  static const int brotli = 3; // brotli 压缩
}

/// 协议包结构
class ProtoPacket {
  int packetLength; // 包长度
  int headerLength; // 头长度
  int version; // 协议版本
  int operation; // 操作码
  int sequenceId; // 序列号
  Uint8List body; // 包体

  ProtoPacket({
    required this.packetLength,
    required this.headerLength,
    required this.version,
    required this.operation,
    required this.sequenceId,
    required this.body,
  });

  /// 从字节数组解码
  factory ProtoPacket.decode(Uint8List data) {
    final buffer = data.buffer.asByteData();

    final packetLength = buffer.getUint32(0);
    final headerLength = buffer.getUint16(4);
    final version = buffer.getUint16(6);
    final operation = buffer.getUint32(8);
    final sequenceId = buffer.getUint32(12);

    final body = data.sublist(headerLength);

    return ProtoPacket(
      packetLength: packetLength,
      headerLength: headerLength,
      version: version,
      operation: operation,
      sequenceId: sequenceId,
      body: body,
    );
  }

  /// 编码为字节数组
  Uint8List encode() {
    const headerLength = 16; // 固定头长度
    final packetLength = headerLength + body.length;

    final buffer = ByteData(packetLength);

    // 写入头部
    buffer.setUint32(0, packetLength); // 包长度
    buffer.setUint16(4, headerLength); // 头长度
    buffer.setUint16(6, version); // 协议版本
    buffer.setUint32(8, operation); // 操作码
    buffer.setUint32(12, sequenceId); // 序列号

    // 写入包体
    final result = Uint8List(packetLength);
    result.setRange(0, headerLength, buffer.buffer.asUint8List());
    result.setRange(headerLength, packetLength, body);

    return result;
  }

  @override
  String toString() {
    return 'ProtoPacket{length: $packetLength, operation: $operation, version: $version, seq: $sequenceId}';
  }
}
