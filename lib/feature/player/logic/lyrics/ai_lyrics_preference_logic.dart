import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_lyrics_preference_logic.g.dart';

@Riverpod(keepAlive: true)
class AiLyricsPreferenceLogic extends _$AiLyricsPreferenceLogic {
  AppSettingsStore? get _store {
    try {
      return ref.read(appSettingsStoreProvider);
    } on Object {
      return null;
    }
  }

  @override
  bool build() {
    final AppSettingsStore? store = _store;
    if (store == null) {
      return true;
    }
    return store.readBool(HiveKeys.playerPreferAiLyrics, defaultValue: true);
  }

  Future<void> setEnabled(bool value) async {
    if (state == value) {
      return;
    }
    state = value;
    final AppSettingsStore? store = _store;
    if (store == null) {
      return;
    }
    await store.writeBool(HiveKeys.playerPreferAiLyrics, value);
  }
}
