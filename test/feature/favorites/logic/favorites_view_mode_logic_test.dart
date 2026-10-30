import 'dart:io';

import 'package:bilimusic/core/hive/hive_keys.dart';
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

  test('invalid collection preference falls back to video', () async {
    await prefs.put('${HiveKeys.favoritesListViewMode}.local:a', 'invalid');
    container.invalidate(first);
    expect(container.read(first), FavoriteListViewMode.video);
  });
}
