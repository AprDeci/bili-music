import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'appearance_setting_logic.g.dart';

@riverpod
class AppearanceSettingLogic extends _$AppearanceSettingLogic {
  @override
  bool build() {
    return ref
        .read(appSettingsStoreProvider)
        .readBool(HiveKeys.appearanceUseGlassBar, defaultValue: false);
  }

  Future<void> setUseGlassBar(bool value) async {
    state = value;
    await ref
        .read(appSettingsStoreProvider)
        .writeBool(HiveKeys.appearanceUseGlassBar, value);
  }
}
