import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/player/domain/player_lyric_font_preference.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_lyric_font_preference_logic.g.dart';

@Riverpod(keepAlive: true)
class PlayerLyricFontPreferenceLogic extends _$PlayerLyricFontPreferenceLogic {
  @override
  PlayerLyricFontPreference build() {
    final AppSettingsStore settingsStore = ref.read(appSettingsStoreProvider);
    return playerLyricFontPreferenceFromStorage(
      settingsStore.readString(
        HiveKeys.playerLyricFontPreference,
        defaultValue: PlayerLyricFontPreference.appDefault.storageValue,
      ),
    );
  }

  Future<void> setPreference(PlayerLyricFontPreference value) async {
    state = value;
    await ref
        .read(appSettingsStoreProvider)
        .writeString(HiveKeys.playerLyricFontPreference, value.storageValue);
  }
}
