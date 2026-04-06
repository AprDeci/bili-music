import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final NotifierProvider<PlayerSettingsLogic, bool> playerSettingsLogicProvider =
    NotifierProvider<PlayerSettingsLogic, bool>(PlayerSettingsLogic.new);

class PlayerSettingsLogic extends Notifier<bool> {
  @override
  bool build() {
    return ref
        .read(appSettingsStoreProvider)
        .readBool(HiveKeys.playerAllowMixWithOthers, defaultValue: false);
  }

  Future<void> setAllowMixWithOthers(bool value) async {
    await ref
        .read(appSettingsStoreProvider)
        .writeBool(HiveKeys.playerAllowMixWithOthers, value);
    state = value;
  }
}
