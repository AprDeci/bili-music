import 'dart:async';

import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/setting/domain/hotkey_action.dart';
import 'package:bilimusic/feature/setting/domain/hotkey_binding.dart';
import 'package:bilimusic/feature/setting/logic/hotkey_settings_logic.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

class DesktopHotkeyController {
  final AppLogger _logger = AppLogger('DesktopHotkeyController');
  final List<HotKey> _registeredHotKeys = <HotKey>[];
  List<HotkeyBinding> _inAppBindings = <HotkeyBinding>[];
  ProviderSubscription<List<HotkeyBinding>>? _subscription;
  WidgetRef? _ref;

  Future<void> attach(WidgetRef ref) async {
    _ref = ref;
    await hotKeyManager.unregisterAll();
    await _registerBindings(ref.read(hotkeySettingsLogicProvider));
    HardwareKeyboard.instance.addHandler(_handleInAppKeyEvent);
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
    HardwareKeyboard.instance.removeHandler(_handleInAppKeyEvent);
    await _unregisterRegisteredHotKeys();
    _inAppBindings = <HotkeyBinding>[];
    _ref = null;
  }

  Future<void> _registerBindings(List<HotkeyBinding> bindings) async {
    await _unregisterRegisteredHotKeys();
    _inAppBindings = <HotkeyBinding>[
      for (final HotkeyBinding binding in bindings)
        if (binding.scope == HotKeyScope.inapp) binding,
    ];

    for (final HotkeyBinding binding in bindings) {
      if (binding.scope != HotKeyScope.system) {
        continue;
      }

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

  bool _handleInAppKeyEvent(KeyEvent keyEvent) {
    if (keyEvent is KeyUpEvent || keyEvent is KeyRepeatEvent) {
      return false;
    }
    if (_inAppBindings.isEmpty || _isEditingText()) {
      return false;
    }

    final Set<PhysicalKeyboardKey> pressedKeys =
        HardwareKeyboard.instance.physicalKeysPressed;
    final List<HotKeyModifier> pressedModifiers = HotKeyModifier.values
        .where(
          (HotKeyModifier modifier) =>
              modifier.physicalKeys.any(pressedKeys.contains),
        )
        .toList();

    for (final HotkeyBinding binding in _inAppBindings) {
      final HotKey? hotKey = binding.toHotKey();
      if (hotKey == null) {
        continue;
      }
      final List<HotKeyModifier> modifiers = hotKey.modifiers ?? const [];
      if (keyEvent.logicalKey != hotKey.logicalKey ||
          pressedModifiers.length != modifiers.length ||
          pressedModifiers.any(
            (HotKeyModifier modifier) => !modifiers.contains(modifier),
          )) {
        continue;
      }

      _handleHotkey(binding.action);
      return true;
    }
    return false;
  }

  static bool _isEditingText() {
    final BuildContext? context = FocusManager.instance.primaryFocus?.context;
    return context != null &&
        context.findAncestorWidgetOfExactType<EditableText>() != null;
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
      case HotkeyAction.foregroundPlayPause:
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
