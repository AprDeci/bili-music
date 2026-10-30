import 'package:flutter/material.dart';
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

  static void showCenter(String message, {required IconData icon}) {
    message = message.trim();
    if (message.isEmpty) {
      return;
    }
    SmartDialog.showToast(
      message,
      alignment: Alignment.center,
      displayType: SmartToastType.onlyRefresh,
      builder: (BuildContext context) {
        final ColorScheme colors = Theme.of(context).colorScheme;
        return Semantics(
          liveRegion: true,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            constraints: const BoxConstraints(minWidth: 160, maxWidth: 280),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: colors.inverseSurface.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: 40, color: colors.onInverseSurface),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.onInverseSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
