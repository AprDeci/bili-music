import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class ToastUtil {
  ToastUtil._();

  static void show(String message) {
    message = message.trim();
    if (message.isEmpty) {
      return;
    }
    SmartDialog.showToast(message);
  }

  /// 进度类提示：复用同一条 toast 原地刷新，避免高频调用排队堆积。
  static void showProgress(String message) {
    message = message.trim();
    if (message.isEmpty) {
      return;
    }
    SmartDialog.showToast(
      message,
      displayType: SmartToastType.onlyRefresh,
      displayTime: const Duration(seconds: 4),
    );
  }

  /// 关掉进度 toast
  static Future<void> dismissProgress() {
    return SmartDialog.dismiss(status: SmartStatus.toast);
  }
}
