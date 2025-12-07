import 'dart:js' as js;

import 'package:flutter_tts/flutter_tts.dart';

var _synth = new js.JsObject.fromBrowserObject(
  js.context["speechSynthesis"] as js.JsObject,
);

Future<void> ttsStop(FlutterTts tts) async {
  // 不知道为什么FlutterTts里面的stop会延迟500毫秒才调用cancel, 太慢了，这里直接调用JS API， mac chrome测试正常，
  _synth.callMethod('cancel');
  // 浏览器js直接调用是不用延迟的， 但flutter隔了一层， 不延迟还是无法播放下一个，
  await Future.delayed(Duration(milliseconds: 100));
}
