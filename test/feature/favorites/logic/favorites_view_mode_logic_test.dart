import 'dart:io';

import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_view_mode_logic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory directory;
  late Box<String> prefs;
  late ProviderContainer container;

  final first = favoritesViewModeLogicProvider('local:a');
  final second = favoritesViewModeLogicProvider('remote:1');

  ProviderContainer createContainer() => ProviderContainer(
    overrides: [
      appSettingsStoreProvider.overrideWithValue(AppSettingsStore(prefs)),
      favoritesControllerProvider.overrideWith(_Favorites.new),
    ],
  );

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('favorites-view-mode-');
    Hive.init(directory.path);
    prefs = await Hive.openBox<String>(HiveBoxNames.prefs);
    container = createContainer();
    container.listen(first, (_, _) {});
    container.listen(second, (_, _) {});
  });

  tearDown(() async {
    container.dispose();
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('defaults to video and only changes the selected collection', () async {
    expect(container.read(first), FavoriteListViewMode.video);
    expect(container.read(second), FavoriteListViewMode.video);

    await container.read(first.notifier).toggle();
    expect(container.read(first), FavoriteListViewMode.metadata);
    expect(container.read(second), FavoriteListViewMode.video);
    expect(prefs.get(HiveKeys.favoritesListViewMode), isNull);

    await container.read(second.notifier).toggle();
    await container.read(first.notifier).toggle();
    expect(container.read(first), FavoriteListViewMode.video);
    expect(container.read(second), FavoriteListViewMode.metadata);
  });

  test(
    'preserves the old global preference as an independent default',
    () async {
      await prefs.put(HiveKeys.favoritesListViewMode, 'metadata');
      container.invalidate(first);
      container.invalidate(second);
      expect(container.read(first), FavoriteListViewMode.metadata);
      expect(container.read(second), FavoriteListViewMode.metadata);

      await container.read(first.notifier).toggle();
      expect(container.read(first), FavoriteListViewMode.video);
      expect(container.read(second), FavoriteListViewMode.metadata);
      expect(prefs.get(HiveKeys.favoritesListViewMode), 'metadata');
    },
  );

  test('restores different collection modes after reopening storage', () async {
    await container.read(first.notifier).toggle();
    container.dispose();
    await prefs.close();
    prefs = await Hive.openBox<String>(HiveBoxNames.prefs);
    container = createContainer();

    expect(container.read(first), FavoriteListViewMode.metadata);
    expect(container.read(second), FavoriteListViewMode.video);
  });

  test(
    'effective mode follows kind without overwriting either preference',
    () async {
      final firstEffective = effectiveFavoritesViewModeProvider('local:a');
      final secondEffective = effectiveFavoritesViewModeProvider('remote:1');
      container.listen(firstEffective, (_, _) {});
      container.listen(secondEffective, (_, _) {});
      await container
          .read(first.notifier)
          .setViewMode(FavoriteListViewMode.metadata);
      expect(container.read(firstEffective), FavoriteListViewMode.metadata);
      expect(container.read(secondEffective), FavoriteListViewMode.video);

      final favorites =
          container.read(favoritesControllerProvider.notifier) as _Favorites;
      favorites.setKind(CollectionKind.spoken);
      expect(container.read(firstEffective), FavoriteListViewMode.video);
      expect(container.read(first), FavoriteListViewMode.metadata);
      expect(
        prefs.get('${HiveKeys.favoritesListViewMode}.local:a'),
        'metadata',
      );
      expect(container.read(secondEffective), FavoriteListViewMode.video);

      favorites.setKind(CollectionKind.music);
      expect(container.read(firstEffective), FavoriteListViewMode.metadata);
      expect(container.read(secondEffective), FavoriteListViewMode.video);
    },
  );

  test('invalid collection preference falls back to video', () async {
    await prefs.put('${HiveKeys.favoritesListViewMode}.local:a', 'invalid');
    container.invalidate(first);
    expect(container.read(first), FavoriteListViewMode.video);
  });
}

class _Favorites extends FavoritesController {
  @override
  FavoritesState build() => FavoritesState(
    collections: [
      FavoriteCollection(
        id: 'local:a',
        name: 'a',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
      FavoriteCollection(
        id: 'remote:1',
        name: 'remote',
        source: FavoriteCollectionSource.remote,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    ],
  );

  void setKind(CollectionKind kind) {
    state = state.copyWith(
      collections: [
        for (final collection in state.collections)
          if (collection.id == 'local:a')
            collection.copyWith(kind: kind)
          else
            collection,
      ],
    );
  }
}
