import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/ui/player_page.dart';
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

Future<void> openPlayerPage(
  BuildContext context, {
  PlayableItem? item,
  NavigatorState? navigator,
}) async {
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
    if (PlatformUtil.isDesktop) {
      await context.push(playerRoutePath, extra: item);
      return;
    }
    markPlayerPageVisible();
    await (navigator ?? Navigator.of(context)).push<void>(
      _createMobilePlayerRoute(item),
    );
  } finally {
    if (PlatformUtil.isMobile) {
      markPlayerPageHidden();
    }
    _playerPageOpening = false;
  }
}

// 适用navigator进入player页面 不进入主路由栈
Route<void> _createMobilePlayerRoute(PlayableItem? item) {
  return PageRouteBuilder<void>(
    settings: const RouteSettings(name: playerNativeRouteName),
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (BuildContext context, Animation<double> animation, _) {
      return PlayerPage(initialItem: item);
    },
    transitionsBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          final Animation<Offset> offsetAnimation =
              Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                ),
              );

          return SlideTransition(position: offsetAnimation, child: child);
        },
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
