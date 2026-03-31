import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

const String playerRoutePath = '/player';

final AppLogger _logger = AppLogger('PlayerNavigation');
final ValueNotifier<bool> _playerPageVisible = ValueNotifier<bool>(false);
bool _playerPageOpening = false;

ValueListenable<bool> get playerPageVisibilityListenable => _playerPageVisible;

Future<void> openPlayerPage(BuildContext context, {PlayableItem? item}) async {
  final bool blocked = _playerPageVisible.value || _playerPageOpening;
  _logger.d(
    'openPlayerPage | blocked=$blocked, visible=${_playerPageVisible.value}, '
    'opening=$_playerPageOpening, item=${item?.stableId}',
  );

  if (blocked) {
    return;
  }

  _playerPageOpening = true;
  try {
    await context.push(playerRoutePath, extra: item);
  } finally {
    _playerPageOpening = false;
  }
}

void markPlayerPageVisible() {
  _setPlayerPageVisible(true, logLabel: 'markPlayerPageVisible');
}

void markPlayerPageHidden() {
  _setPlayerPageVisible(false, logLabel: 'markPlayerPageHidden');
}

bool get isPlayerPageVisible => _playerPageVisible.value;

void _setPlayerPageVisible(bool value, {required String logLabel}) {
  _playerPageOpening = false;

  void applyVisibility() {
    if (_playerPageVisible.value == value) {
      return;
    }

    _playerPageVisible.value = value;
    _logger.d(logLabel);
  }

  final SchedulerPhase schedulerPhase =
      WidgetsBinding.instance.schedulerPhase;
  final bool shouldDefer =
      schedulerPhase == SchedulerPhase.transientCallbacks ||
      schedulerPhase == SchedulerPhase.midFrameMicrotasks ||
      schedulerPhase == SchedulerPhase.persistentCallbacks;

  if (shouldDefer) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      applyVisibility();
    });
    return;
  }

  applyVisibility();
}
