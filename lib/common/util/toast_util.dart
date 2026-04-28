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
}
