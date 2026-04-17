import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

enum PlayerAudioQualityPreference { auto, hires, k192, k132 }

extension PlayerAudioQualityPreferenceX on PlayerAudioQualityPreference {
  String get storageValue => switch (this) {
    PlayerAudioQualityPreference.auto => 'auto',
    PlayerAudioQualityPreference.hires => 'hires',
    PlayerAudioQualityPreference.k192 => '192k',
    PlayerAudioQualityPreference.k132 => '132k',
  };

  String get title => switch (this) {
    PlayerAudioQualityPreference.auto => '自动',
    PlayerAudioQualityPreference.hires => 'Hi-Res',
    PlayerAudioQualityPreference.k192 => '192K',
    PlayerAudioQualityPreference.k132 => '132K',
  };

  String get description => switch (this) {
    PlayerAudioQualityPreference.auto => '优先播放当前可用最高码率',
    PlayerAudioQualityPreference.hires => '优先无损，未命中则回退到最高码率',
    PlayerAudioQualityPreference.k192 => '优先 192K，未命中则回退到最高码率',
    PlayerAudioQualityPreference.k132 => '优先 132K，未命中则回退到最高码率',
  };
}

PlayerAudioQualityPreference playerAudioQualityPreferenceFromStorage(
  String value,
) {
  return switch (value) {
    'hires' => PlayerAudioQualityPreference.hires,
    '192k' => PlayerAudioQualityPreference.k192,
    '132k' => PlayerAudioQualityPreference.k132,
    _ => PlayerAudioQualityPreference.auto,
  };
}

class PlayerAudioQualityPreferenceLogic
    extends StateNotifier<PlayerAudioQualityPreference> {
  PlayerAudioQualityPreferenceLogic(this._settingsStore)
    : super(
        playerAudioQualityPreferenceFromStorage(
          _settingsStore.readString(
            HiveKeys.playerAudioQualityPreference,
            defaultValue: PlayerAudioQualityPreference.auto.storageValue,
          ),
        ),
      );

  final AppSettingsStore _settingsStore;

  Future<void> setPreference(PlayerAudioQualityPreference value) async {
    state = value;
    await _settingsStore.writeString(
      HiveKeys.playerAudioQualityPreference,
      value.storageValue,
    );
  }
}

final StateNotifierProvider<
  PlayerAudioQualityPreferenceLogic,
  PlayerAudioQualityPreference
>
playerAudioQualityPreferenceLogicProvider =
    StateNotifierProvider<
      PlayerAudioQualityPreferenceLogic,
      PlayerAudioQualityPreference
    >((Ref ref) {
      return PlayerAudioQualityPreferenceLogic(
        ref.read(appSettingsStoreProvider),
      );
    });
