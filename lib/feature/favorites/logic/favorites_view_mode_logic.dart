import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorites_view_mode_logic.g.dart';

enum FavoriteListViewMode {
  video,
  metadata;

  static FavoriteListViewMode fromStorage(String value) {
    return FavoriteListViewMode.values.firstWhere(
      (FavoriteListViewMode mode) => mode.name == value,
      orElse: () => FavoriteListViewMode.video,
    );
  }
}

@riverpod
class FavoritesViewModeLogic extends _$FavoritesViewModeLogic {
  @override
  FavoriteListViewMode build() {
    return FavoriteListViewMode.fromStorage(
      ref
          .read(appSettingsStoreProvider)
          .readString(
            HiveKeys.favoritesListViewMode,
            defaultValue: FavoriteListViewMode.video.name,
          ),
    );
  }

  Future<void> setViewMode(FavoriteListViewMode mode) async {
    if (mode == state) {
      return;
    }
    state = mode;
    await ref
        .read(appSettingsStoreProvider)
        .writeString(HiveKeys.favoritesListViewMode, mode.name);
  }

  Future<void> toggle() {
    return setViewMode(
      state == FavoriteListViewMode.video
          ? FavoriteListViewMode.metadata
          : FavoriteListViewMode.video,
    );
  }
}
