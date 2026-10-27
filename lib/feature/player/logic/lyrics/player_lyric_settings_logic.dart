import 'dart:convert';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/player/domain/player_lyric_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_lyric_settings_logic.g.dart';

@Riverpod(keepAlive: true)
class PlayerLyricSettingsLogic extends _$PlayerLyricSettingsLogic {
  @override
  PlayerLyricSettings build() {
    final AppSettingsStore store = ref.watch(appSettingsStoreProvider);
    try {
      final String rawValue = store.readString(
        HiveKeys.playerLyricSettings,
        defaultValue: '',
      );
      if (rawValue.isEmpty) {
        return const PlayerLyricSettings();
      }
      final Object? decoded = jsonDecode(rawValue);
      if (decoded is Map<String, dynamic>) {
        return PlayerLyricSettings.fromJson(decoded);
      }
    } on Object {
      return const PlayerLyricSettings();
    }
    return const PlayerLyricSettings();
  }

  Future<void> update(PlayerLyricSettings value) async {
    final PlayerLyricSettings next = value.sanitized();
    await ref
        .read(appSettingsStoreProvider)
        .writeString(HiveKeys.playerLyricSettings, jsonEncode(next.toJson()));
    if (ref.mounted) {
      state = next;
    }
  }

  Future<void> reset() => update(const PlayerLyricSettings());

  Future<void> setShowTranslation(bool value) =>
      update(state.copyWith(showTranslation: value));
}
