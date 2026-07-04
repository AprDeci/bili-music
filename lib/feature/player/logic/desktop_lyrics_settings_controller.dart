import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/player/domain/desktop_lyrics_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final NotifierProvider<DesktopLyricsSettingsController, DesktopLyricsSettings>
desktopLyricsSettingsControllerProvider =
    NotifierProvider<DesktopLyricsSettingsController, DesktopLyricsSettings>(
      DesktopLyricsSettingsController.new,
    );

class DesktopLyricsSettingsController extends Notifier<DesktopLyricsSettings> {
  @override
  DesktopLyricsSettings build() {
    final AppSettingsStore settingsStore = ref.read(appSettingsStoreProvider);
    return DesktopLyricsSettings(
      enabled: settingsStore.readBool(
        HiveKeys.playerDesktopLyricsEnabled,
        defaultValue: false,
      ),
      alwaysOnTop: settingsStore.readBool(
        HiveKeys.playerDesktopLyricsAlwaysOnTop,
        defaultValue: true,
      ),
      opacity: DesktopLyricsSettings.clampOpacity(
        settingsStore.readDouble(
          HiveKeys.playerDesktopLyricsOpacity,
          defaultValue: 0.86,
        ),
      ),
    );
  }

  Future<void> setEnabled(bool value) async {
    state = state.copyWith(enabled: value);
    await ref
        .read(appSettingsStoreProvider)
        .writeBool(HiveKeys.playerDesktopLyricsEnabled, value);
  }

  Future<void> setAlwaysOnTop(bool value) async {
    state = state.copyWith(alwaysOnTop: value);
    await ref
        .read(appSettingsStoreProvider)
        .writeBool(HiveKeys.playerDesktopLyricsAlwaysOnTop, value);
  }

  Future<void> setOpacity(double value) async {
    final double nextValue = DesktopLyricsSettings.clampOpacity(value);
    state = state.copyWith(opacity: nextValue);
    await ref
        .read(appSettingsStoreProvider)
        .writeDouble(HiveKeys.playerDesktopLyricsOpacity, nextValue);
  }
}
