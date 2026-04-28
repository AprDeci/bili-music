import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

typedef ToastDispatcher = void Function(String message);

class ToastUtil {
  ToastUtil._();

  static ToastDispatcher? _dispatcher;

  static void installDispatcher(ToastDispatcher dispatcher) {
    _dispatcher = dispatcher;
  }

  static void uninstallDispatcher(ToastDispatcher dispatcher) {
    if (identical(_dispatcher, dispatcher)) {
      _dispatcher = null;
    }
  }

  static void show(String message) {
    message = message.trim();
    if (message.isEmpty) {
      return;
    }

    _dispatcher?.call(message);
  }
}

class ToastPresenter {
  ToastPresenter._();

  static void showRaw(String message) {
    message = message.trim();
    if (message.isEmpty) {
      return;
    }

    SmartDialog.showToast(message);
  }
}
