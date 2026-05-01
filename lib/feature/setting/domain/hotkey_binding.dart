import 'package:bilimusic/feature/setting/domain/hotkey_action.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

part 'hotkey_binding.freezed.dart';
part 'hotkey_binding.g.dart';

@freezed
abstract class HotkeyBinding with _$HotkeyBinding {
  const factory HotkeyBinding({
    required HotkeyAction action,
    required int keyCode,
    required List<String> modifiers,
    @Default(true) bool enabled,
  }) = _HotkeyBinding;

  const HotkeyBinding._();

  factory HotkeyBinding.fromJson(Map<String, dynamic> json) =>
      _$HotkeyBindingFromJson(json);

  HotKey? toHotKey() {
    if (!enabled) {
      return null;
    }

    final PhysicalKeyboardKey? key = PhysicalKeyboardKey.findKeyByCode(keyCode);
    if (key == null) {
      return null;
    }

    return HotKey(
      identifier: action.name,
      key: key,
      modifiers: modifiers
          .map(
            (String modifier) => HotKeyModifier.values
                .where((HotKeyModifier value) => value.name == modifier)
                .firstOrNull,
          )
          .nonNulls
          .toList(),
    );
  }

  static HotkeyBinding fromHotKey({
    required HotkeyAction action,
    required HotKey hotKey,
  }) {
    return HotkeyBinding(
      action: action,
      keyCode: hotKey.physicalKey.usbHidUsage,
      modifiers: (hotKey.modifiers ?? const <HotKeyModifier>[])
          .map((HotKeyModifier modifier) => modifier.name)
          .toList(),
    );
  }
}

List<HotkeyBinding> defaultHotkeyBindings() {
  return <HotkeyBinding>[
    _binding(
      action: HotkeyAction.playPause,
      key: PhysicalKeyboardKey.space,
      modifiers: const <HotKeyModifier>[
        HotKeyModifier.control,
        HotKeyModifier.alt,
      ],
    ),
    _binding(
      action: HotkeyAction.previousTrack,
      key: PhysicalKeyboardKey.arrowLeft,
      modifiers: const <HotKeyModifier>[
        HotKeyModifier.control,
        HotKeyModifier.alt,
      ],
    ),
    _binding(
      action: HotkeyAction.nextTrack,
      key: PhysicalKeyboardKey.arrowRight,
      modifiers: const <HotKeyModifier>[
        HotKeyModifier.control,
        HotKeyModifier.alt,
      ],
    ),
    _binding(
      action: HotkeyAction.toggleDesktop,
      key: PhysicalKeyboardKey.keyB,
      modifiers: const <HotKeyModifier>[
        HotKeyModifier.control,
        HotKeyModifier.alt,
      ],
    ),
  ];
}

HotkeyBinding _binding({
  required HotkeyAction action,
  required PhysicalKeyboardKey key,
  required List<HotKeyModifier> modifiers,
}) {
  return HotkeyBinding(
    action: action,
    keyCode: key.usbHidUsage,
    modifiers: modifiers
        .map((HotKeyModifier modifier) => modifier.name)
        .toList(),
  );
}
