import 'dart:convert';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/setting/domain/hotkey_action.dart';
import 'package:bilimusic/feature/setting/domain/hotkey_binding.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hotkey_settings_logic.g.dart';

@riverpod
class HotkeySettingsLogic extends _$HotkeySettingsLogic {
  @override
  List<HotkeyBinding> build() {
    return _readBindings();
  }

  Future<void> setBinding(HotkeyBinding binding) async {
    final List<HotkeyBinding> next = <HotkeyBinding>[
      for (final HotkeyBinding item in state)
        if (item.action == binding.action) binding else item,
    ];
    state = _normalizeBindings(next);
    await _writeBindings(state);
  }

  Future<void> resetDefaults() async {
    state = defaultHotkeyBindings();
    await _writeBindings(state);
  }

  List<HotkeyBinding> _readBindings() {
    final String rawValue = ref
        .read(appSettingsStoreProvider)
        .readString(HiveKeys.desktopHotkeys, defaultValue: '');
    if (rawValue.isEmpty) {
      return defaultHotkeyBindings();
    }

    try {
      final Object? decoded = jsonDecode(rawValue);
      if (decoded is! List<dynamic>) {
        return defaultHotkeyBindings();
      }

      final List<HotkeyBinding> bindings = decoded
          .whereType<Map<String, dynamic>>()
          .map(HotkeyBinding.fromJson)
          .toList();
      return _normalizeBindings(bindings);
    } on Object {
      return defaultHotkeyBindings();
    }
  }

  Future<void> _writeBindings(List<HotkeyBinding> bindings) {
    return ref
        .read(appSettingsStoreProvider)
        .writeString(
          HiveKeys.desktopHotkeys,
          jsonEncode(
            bindings.map((HotkeyBinding item) => item.toJson()).toList(),
          ),
        );
  }

  List<HotkeyBinding> _normalizeBindings(List<HotkeyBinding> bindings) {
    final Map<HotkeyAction, HotkeyBinding> byAction =
        <HotkeyAction, HotkeyBinding>{
          for (final HotkeyBinding binding in defaultHotkeyBindings())
            binding.action: binding,
          for (final HotkeyBinding binding in bindings) binding.action: binding,
        };
    return HotkeyAction.values
        .map((HotkeyAction action) => byAction[action]!)
        .toList();
  }
}
