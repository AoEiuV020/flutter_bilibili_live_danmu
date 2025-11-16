import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// 系统UI管理器 - 管理全屏和防锁屏
class SystemUiManager {
  /// 设置全屏
  void setFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  /// 退出全屏
  void exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  /// 启用防锁屏
  void enableWakelock() {
    WakelockPlus.enable();
  }

  /// 禁用防锁屏
  void disableWakelock() {
    WakelockPlus.disable();
  }

  /// 释放资源
  void dispose() {
    exitFullScreen();
    disableWakelock();
  }
}
