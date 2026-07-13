import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_settings_logic.g.dart';

@riverpod
class PlayerSettingsLogic extends _$PlayerSettingsLogic {
  @override
  bool build() {
    return ref
        .read(appSettingsStoreProvider)
        .readBool(HiveKeys.playerAllowMixWithOthers, defaultValue: false);
  }

  Future<void> setAllowMixWithOthers(bool value) async {
    state = value;
    await ref
        .read(appSettingsStoreProvider)
        .writeBool(HiveKeys.playerAllowMixWithOthers, value);
  }
}

@riverpod
class PlayerAutoEnqueueAllPartsLogic extends _$PlayerAutoEnqueueAllPartsLogic {
  @override
  bool build() {
    return ref
        .read(appSettingsStoreProvider)
        .readBool(HiveKeys.playerAutoEnqueueAllParts, defaultValue: false);
  }

  Future<void> setAutoEnqueueAllParts(bool value) async {
    state = value;
    await ref
        .read(appSettingsStoreProvider)
        .writeBool(HiveKeys.playerAutoEnqueueAllParts, value);
  }
}
