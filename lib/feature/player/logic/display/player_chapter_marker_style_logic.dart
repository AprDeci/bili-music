import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/player/domain/player_chapter_marker_style.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_chapter_marker_style_logic.g.dart';

@riverpod
class PlayerChapterMarkerStyleLogic extends _$PlayerChapterMarkerStyleLogic {
  AppSettingsStore? get _settingsStore {
    try {
      return ref.read(appSettingsStoreProvider);
    } on Object {
      return null;
    }
  }

  @override
  PlayerChapterMarkerStyle build() {
    final AppSettingsStore? store = _settingsStore;
    if (store == null) {
      return PlayerChapterMarkerStyle.line;
    }
    return PlayerChapterMarkerStyle.fromStorage(
      store.readString(HiveKeys.playerChapterMarkerStyle, defaultValue: ''),
    );
  }

  Future<void> setStyle(PlayerChapterMarkerStyle style) async {
    state = style;
    final AppSettingsStore? store = _settingsStore;
    if (store == null) {
      return;
    }
    await store.writeString(HiveKeys.playerChapterMarkerStyle, style.name);
  }
}
