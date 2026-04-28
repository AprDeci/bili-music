import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/notification/app_notification_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppNotificationHost extends ConsumerStatefulWidget {
  const AppNotificationHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppNotificationHost> createState() =>
      _AppNotificationHostState();
}

class _AppNotificationHostState extends ConsumerState<AppNotificationHost> {
  late final ToastDispatcher _toastDispatcher;

  @override
  void initState() {
    super.initState();
    _toastDispatcher = (String message) {
      ref.read(appNotificationControllerProvider.notifier).showToast(message);
    };
    ToastUtil.installDispatcher(_toastDispatcher);
  }

  @override
  void dispose() {
    ToastUtil.uninstallDispatcher(_toastDispatcher);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(appNotificationControllerProvider, (previous, next) {
      if (next == null) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        switch (next) {
          case AppToastNotification(:final id, :final message):
            ToastPresenter.showRaw(message);
            ref.read(appNotificationControllerProvider.notifier).consume(id);
        }
      });
    });

    return widget.child;
  }
}
