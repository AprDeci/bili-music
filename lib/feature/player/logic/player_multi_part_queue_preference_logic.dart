import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/player/domain/multi_part_queue_preference.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_multi_part_queue_preference_logic.g.dart';

@Riverpod(keepAlive: true)
class PlayerMultiPartQueuePreferenceLogic
    extends _$PlayerMultiPartQueuePreferenceLogic {
  @override
  MultiPartQueuePreference build() {
    final AppSettingsStore settingsStore = ref.read(appSettingsStoreProvider);
    return multiPartQueuePreferenceFromStorage(
      settingsStore.readString(
        HiveKeys.playerMultiPartQueuePreference,
        defaultValue: MultiPartQueuePreference.currentPart.storageValue,
      ),
    );
  }

  Future<void> setPreference(MultiPartQueuePreference value) async {
    state = value;
    await ref
        .read(appSettingsStoreProvider)
        .writeString(
          HiveKeys.playerMultiPartQueuePreference,
          value.storageValue,
        );
  }
}

@Riverpod(keepAlive: true)
class PlayerMultiPartTipShownLogic extends _$PlayerMultiPartTipShownLogic {
  @override
  bool build() {
    return ref
        .read(appSettingsStoreProvider)
        .readBool(HiveKeys.playerMultiPartTipShown, defaultValue: false);
  }

  Future<void> setShown(bool value) async {
    state = value;
    await ref
        .read(appSettingsStoreProvider)
        .writeBool(HiveKeys.playerMultiPartTipShown, value);
  }
}
