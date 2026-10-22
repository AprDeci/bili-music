import 'dart:io';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/player/domain/player_ui_style.dart';
import 'package:bilimusic/feature/player/logic/player_ui_style_logic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDirectory;
  late Box<String> prefsBox;
  late ProviderContainer container;

  ProviderContainer buildContainer() => ProviderContainer(
    overrides: [
      appSettingsStoreProvider.overrideWithValue(AppSettingsStore(prefsBox)),
    ],
  );

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'player_ui_style_logic_test_',
    );
    Hive.init(tempDirectory.path);
    prefsBox = await Hive.openBox<String>(HiveBoxNames.prefs);
    container = buildContainer();
  });

  tearDown(() async {
    container.dispose();
    await prefsBox.close();
    await Hive.deleteBoxFromDisk(HiveBoxNames.prefs);
    await Hive.close();
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('defaults to classic when nothing is stored', () {
    expect(container.read(playerUiStyleLogicProvider), PlayerUiStyle.classic);
  });

  test('reads a valid stored apple music style', () async {
    await prefsBox.put(HiveKeys.playerUiStyle, 'appleMusic');
    final ProviderContainer freshContainer = buildContainer();
    addTearDown(freshContainer.dispose);

    expect(
      freshContainer.read(playerUiStyleLogicProvider),
      PlayerUiStyle.appleMusic,
    );
  });

  test('falls back to classic for unknown stored value', () async {
    await prefsBox.put(HiveKeys.playerUiStyle, 'unknown-style');
    final ProviderContainer freshContainer = buildContainer();
    addTearDown(freshContainer.dispose);

    expect(
      freshContainer.read(playerUiStyleLogicProvider),
      PlayerUiStyle.classic,
    );
  });

  test('persists changes and restores after container rebuild', () async {
    await container
        .read(playerUiStyleLogicProvider.notifier)
        .setStyle(PlayerUiStyle.appleMusic);

    expect(
      container.read(playerUiStyleLogicProvider),
      PlayerUiStyle.appleMusic,
    );
    expect(prefsBox.get(HiveKeys.playerUiStyle), 'appleMusic');

    final ProviderContainer rebuiltContainer = buildContainer();
    addTearDown(rebuiltContainer.dispose);
    expect(
      rebuiltContainer.read(playerUiStyleLogicProvider),
      PlayerUiStyle.appleMusic,
    );
  });
}
