import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/player/domain/player_lyric_font_size_preference.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_lyric_font_size_preference_logic.g.dart';

@Riverpod(keepAlive: true)
class PlayerLyricFontSizePreferenceLogic
    extends _$PlayerLyricFontSizePreferenceLogic {
  @override
  PlayerLyricFontSizePreference build() {
    final AppSettingsStore settingsStore = ref.read(appSettingsStoreProvider);
    return playerLyricFontSizePreferenceFromStorage(
      settingsStore.readString(
        HiveKeys.playerLyricFontSizePreference,
        defaultValue: PlayerLyricFontSizePreference.normal.storageValue,
      ),
    );
  }

  Future<void> setPreference(PlayerLyricFontSizePreference value) async {
    state = value;
    await ref
        .read(appSettingsStoreProvider)
        .writeString(
          HiveKeys.playerLyricFontSizePreference,
          value.storageValue,
        );
  }
}
