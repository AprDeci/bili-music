import 'dart:async';

import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/setting/domain/hotkey_action.dart';
import 'package:bilimusic/feature/setting/domain/hotkey_binding.dart';
import 'package:bilimusic/feature/setting/logic/hotkey_settings_logic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

class DesktopHotkeyController {
  final AppLogger _logger = AppLogger('DesktopHotkeyController');
  final List<HotKey> _registeredHotKeys = <HotKey>[];
  ProviderSubscription<List<HotkeyBinding>>? _subscription;
  WidgetRef? _ref;

  Future<void> attach(WidgetRef ref) async {
    _ref = ref;
    await hotKeyManager.unregisterAll();
    await _registerBindings(ref.read(hotkeySettingsLogicProvider));
    _subscription = ref.listenManual<List<HotkeyBinding>>(
      hotkeySettingsLogicProvider,
      (List<HotkeyBinding>? previous, List<HotkeyBinding> next) {
        unawaited(_registerBindings(next));
      },
    );
  }

  Future<void> detach() async {
    _subscription?.close();
    _subscription = null;
    await _unregisterRegisteredHotKeys();
    _ref = null;
  }

  Future<void> _registerBindings(List<HotkeyBinding> bindings) async {
    await _unregisterRegisteredHotKeys();

    for (final HotkeyBinding binding in bindings) {
      final HotKey? hotKey = binding.toHotKey();
      if (hotKey == null) {
        continue;
      }

      try {
        await hotKeyManager.register(
          hotKey,
          keyDownHandler: (_) => _handleHotkey(binding.action),
        );
        _registeredHotKeys.add(hotKey);
      } on Object catch (error, stackTrace) {
        _logger.w(
          'Register hotkey failed: ${binding.action.name}',
          error,
          stackTrace,
        );
      }
    }
  }

  Future<void> _unregisterRegisteredHotKeys() async {
    for (final HotKey hotKey in _registeredHotKeys) {
      try {
        await hotKeyManager.unregister(hotKey);
      } on Object catch (error, stackTrace) {
        _logger.w('Unregister hotkey failed', error, stackTrace);
      }
    }
    _registeredHotKeys.clear();
  }

  void _handleHotkey(HotkeyAction action) {
    final WidgetRef? ref = _ref;
    if (ref == null) {
      return;
    }

    switch (action) {
      case HotkeyAction.playPause:
        unawaited(ref.read(playerControllerProvider.notifier).togglePlayback());
      case HotkeyAction.previousTrack:
        unawaited(ref.read(playerControllerProvider.notifier).skipToPrevious());
      case HotkeyAction.nextTrack:
        unawaited(ref.read(playerControllerProvider.notifier).skipToNext());
      case HotkeyAction.toggleDesktop:
        unawaited(_toggleWindow());
    }
  }

  Future<void> _toggleWindow() async {
    if (await windowManager.isVisible()) {
      await windowManager.hide();
      return;
    }

    await windowManager.show();
    if (await windowManager.isMinimized()) {
      await windowManager.restore();
    }
    await windowManager.focus();
  }
}
