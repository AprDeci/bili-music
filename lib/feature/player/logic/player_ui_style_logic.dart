import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/player/domain/player_ui_style.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_ui_style_logic.g.dart';

@Riverpod(keepAlive: true)
class PlayerUiStyleLogic extends _$PlayerUiStyleLogic {
  @override
  PlayerUiStyle build() {
    final AppSettingsStore settingsStore = ref.read(appSettingsStoreProvider);
    return playerUiStyleFromStorage(
      settingsStore.readString(
        HiveKeys.playerUiStyle,
        defaultValue: PlayerUiStyle.classic.storageValue,
      ),
    );
  }

  Future<void> setStyle(PlayerUiStyle value) async {
    state = value;
    await ref
        .read(appSettingsStoreProvider)
        .writeString(HiveKeys.playerUiStyle, value.storageValue);
  }
}
