import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_notification_controller.g.dart';

@Riverpod(keepAlive: true)
class AppNotificationController extends _$AppNotificationController {
  int _nextId = 0;

  @override
  AppNotification? build() => null;

  void showToast(String message) {
    final String trimmed = message.trim();
    if (trimmed.isEmpty) {
      return;
    }

    _nextId += 1;
    state = AppToastNotification(id: _nextId, message: trimmed);
  }

  void consume(int id) {
    if (state?.id == id) {
      state = null;
    }
  }
}

sealed class AppNotification {
  const AppNotification({required this.id});

  final int id;
}

class AppToastNotification extends AppNotification {
  const AppToastNotification({required super.id, required this.message});

  final String message;
}
