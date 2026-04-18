import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_audio_quality_preference_logic.g.dart';

@Riverpod(keepAlive: true)
class PlayerAudioQualityPreferenceLogic
    extends _$PlayerAudioQualityPreferenceLogic {
  @override
  PlayerAudioQualityPreference build() {
    final AppSettingsStore settingsStore = ref.read(appSettingsStoreProvider);
    return playerAudioQualityPreferenceFromStorage(
      settingsStore.readString(
        HiveKeys.playerAudioQualityPreference,
        defaultValue: PlayerAudioQualityPreference.auto.storageValue,
      ),
    );
  }

  Future<void> setPreference(PlayerAudioQualityPreference value) async {
    state = value;
    await ref
        .read(appSettingsStoreProvider)
        .writeString(HiveKeys.playerAudioQualityPreference, value.storageValue);
  }
}
