import 'dart:io';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/feature/player/logic/player_settings_logic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDirectory;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'player_settings_logic_test_',
    );
    Hive.init(tempDirectory.path);
    await Hive.openBox<String>(HiveBoxNames.prefs);
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('defaults allow mix with others to false', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(playerSettingsLogicProvider), isFalse);
  });

  test('persists allow mix with others changes', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(playerSettingsLogicProvider.notifier)
        .setAllowMixWithOthers(true);

    expect(container.read(playerSettingsLogicProvider), isTrue);
    expect(
      Hive.box<String>(
        HiveBoxNames.prefs,
      ).get(HiveKeys.playerAllowMixWithOthers),
      'true',
    );
  });
}
