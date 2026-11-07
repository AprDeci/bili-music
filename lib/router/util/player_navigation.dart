import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/core/layout/app_layout.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/ui/player_page.dart';
import 'package:bilimusic/feature/player/ui/car/car_player_page.dart';
import 'package:bilimusic/router/car_ui_page.dart';
import 'package:bilimusic/router/util/player_page_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

const String playerRoutePath = '/player';
const String playerNativeRouteName = 'native-player';

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
    if (AppLayout.isDesktopPlatform) {
      await context.push(playerRoutePath, extra: item);
      return;
    }
    markPlayerPageVisible();
    await Navigator.of(context, rootNavigator: true).push<void>(
      AppLayoutScope.of(context) == AppLayout.car
          ? MaterialPageRoute<void>(
              settings: const RouteSettings(name: playerNativeRouteName),
              builder: (_) => CarUiPage(
                carBuilder: (_) => CarPlayerPage(initialItem: item),
                standardBuilder: (_) => PlayerPage(initialItem: item),
              ),
            )
          : _createMobilePlayerRoute(item),
    );
  } finally {
    if (!AppLayout.isDesktopPlatform) {
      markPlayerPageHidden();
    }
    _playerPageOpening = false;
  }
}

// 适用navigator进入player页面 不进入主路由栈
Route<void> _createMobilePlayerRoute(PlayableItem? item) {
  return PlayerPageRoute(
    settings: const RouteSettings(name: playerNativeRouteName),
    builder: (_) => CarUiPage(
      carBuilder: (_) => CarPlayerPage(initialItem: item),
      standardBuilder: (_) => PlayerPage(initialItem: item),
    ),
  );
}

void markPlayerPageVisible() {
  _setPlayerPageVisible(true, logLabel: 'markPlayerPageVisible');
}

void markPlayerPageHidden() {
  _setPlayerPageVisible(false, logLabel: 'markPlayerPageHidden');
}

void _setPlayerPageVisible(bool value, {required String logLabel}) {
  void applyVisibility() {
    if (_playerPageVisible.value == value) {
      return;
    }

    _playerPageVisible.value = value;
    _logger.d(logLabel);
  }

  final SchedulerPhase schedulerPhase = WidgetsBinding.instance.schedulerPhase;
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
