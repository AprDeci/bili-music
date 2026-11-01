import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
FavoriteListViewMode effectiveFavoritesViewMode(Ref ref, String collectionId) {
  final bool isSpoken = ref.watch(
    favoritesControllerProvider.select(
      (state) => state.collections.any(
        (collection) => collection.id == collectionId && collection.isSpoken,
      ),
    ),
  );
  return isSpoken
      ? FavoriteListViewMode.video
      : ref.watch(favoritesViewModeLogicProvider(collectionId));
}

@riverpod
class FavoritesViewModeLogic extends _$FavoritesViewModeLogic {
  @override
  FavoriteListViewMode build(String collectionId) {
    final AppSettingsStore settings = ref.read(appSettingsStoreProvider);
    return FavoriteListViewMode.fromStorage(
      settings.readString(
        '${HiveKeys.favoritesListViewMode}.$collectionId',
        defaultValue: settings.readString(
          HiveKeys.favoritesListViewMode,
          defaultValue: FavoriteListViewMode.video.name,
        ),
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
        .writeString(
          '${HiveKeys.favoritesListViewMode}.$collectionId',
          mode.name,
        );
  }

  Future<void> toggle() {
    return setViewMode(
      state == FavoriteListViewMode.video
          ? FavoriteListViewMode.metadata
          : FavoriteListViewMode.video,
    );
  }
}
