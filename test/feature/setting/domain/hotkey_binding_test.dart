import 'package:bilimusic/feature/setting/domain/hotkey_action.dart';
import 'package:bilimusic/feature/setting/domain/hotkey_binding.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

void main() {
  test('global and foreground play/pause defaults coexist', () {
    final HotkeyBinding globalPlayPause = _bindingFor(HotkeyAction.playPause);
    final HotkeyBinding foregroundPlayPause = _bindingFor(
      HotkeyAction.foregroundPlayPause,
    );

    expect(globalPlayPause.scope, HotKeyScope.system);
    expect(globalPlayPause.toHotKey()!.physicalKey, PhysicalKeyboardKey.space);
    expect(globalPlayPause.modifiers, contains('control'));
    expect(globalPlayPause.modifiers, contains('alt'));

    expect(foregroundPlayPause.scope, HotKeyScope.inapp);
    expect(
      foregroundPlayPause.toHotKey()!.physicalKey,
      PhysicalKeyboardKey.space,
    );
    expect(foregroundPlayPause.modifiers, isEmpty);
  });

  test('other defaults stay global', () {
    for (final HotkeyAction action in HotkeyAction.values) {
      if (action == HotkeyAction.playPause ||
          action == HotkeyAction.foregroundPlayPause) {
        continue;
      }
      expect(_bindingFor(action).scope, HotKeyScope.system);
    }
  });

  test('fromJson defaults missing scope to global', () {
    final HotkeyBinding binding = HotkeyBinding.fromJson(<String, dynamic>{
      'action': 'playPause',
      'keyCode': PhysicalKeyboardKey.space.usbHidUsage,
      'modifiers': <String>[],
    });

    expect(binding.scope, HotKeyScope.system);
  });

  test('toHotKey and fromHotKey round-trip the scope', () {
    final HotkeyBinding binding = HotkeyBinding.fromHotKey(
      action: HotkeyAction.playPause,
      hotKey: HotKey(key: PhysicalKeyboardKey.space, scope: HotKeyScope.inapp),
    );

    expect(binding.scope, HotKeyScope.inapp);
    expect(binding.toHotKey()!.scope, HotKeyScope.inapp);
  });
}

HotkeyBinding _bindingFor(HotkeyAction action) {
  return defaultHotkeyBindings().firstWhere(
    (HotkeyBinding binding) => binding.action == action,
  );
}
