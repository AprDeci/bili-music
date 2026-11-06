import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'car_ui_setting_logic.g.dart';

@Riverpod(keepAlive: true)
class CarUiSettingLogic extends _$CarUiSettingLogic {
  @override
  bool build() => ref
      .read(appSettingsStoreProvider)
      .readBool(HiveKeys.carUiEnabled, defaultValue: false);

  Future<void> setEnabled(bool value) async {
    await ref
        .read(appSettingsStoreProvider)
        .writeBool(HiveKeys.carUiEnabled, value);
    if (ref.mounted) {
      state = value;
    }
  }
}
