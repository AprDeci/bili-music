import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const String playerRoutePath = '/player';

final AppLogger _logger = AppLogger('PlayerNavigation');
final ValueNotifier<bool> _playerPageVisible = ValueNotifier<bool>(false);
bool _playerPageOpening = false;

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
  _playerPageVisible.value = true;
  _playerPageOpening = false;
  _logger.d('markPlayerPageVisible');
}

void markPlayerPageHidden() {
  _playerPageVisible.value = false;
  _playerPageOpening = false;
  _logger.d('markPlayerPageHidden');
}

bool get isPlayerPageVisible => _playerPageVisible.value;
