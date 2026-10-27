import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_display_settings_logic.g.dart';

@riverpod
class PlayerDisplaySettingsLogic extends _$PlayerDisplaySettingsLogic {
  @override
  bool build() {
    return ref
        .read(appSettingsStoreProvider)
        .readBool(HiveKeys.playerUseMetadataCover, defaultValue: true);
  }

  Future<void> setPreferMetadata(bool value) async {
    await ref
        .read(appSettingsStoreProvider)
        .writeBool(HiveKeys.playerUseMetadataCover, value);
    if (ref.mounted) {
      state = value;
    }
  }
}
