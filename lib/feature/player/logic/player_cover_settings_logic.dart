import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_cover_settings_logic.g.dart';

@riverpod
class PlayerCoverSettingsLogic extends _$PlayerCoverSettingsLogic {
  @override
  bool build() {
    return ref
        .read(appSettingsStoreProvider)
        .readBool(HiveKeys.playerUseMetadataCover, defaultValue: true);
  }

  Future<void> setUseMetadataCover(bool value) async {
    state = value;
    await ref
        .read(appSettingsStoreProvider)
        .writeBool(HiveKeys.playerUseMetadataCover, value);
  }
}
