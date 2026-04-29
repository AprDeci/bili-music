import 'dart:io';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/theme/theme_logic.dart';
import 'package:bilimusic/core/theme/theme_ui_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDirectory;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('theme_logic_test_');
    Hive.init(tempDirectory.path);
    await Hive.openBox<String>(HiveBoxNames.prefs);
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('reads persisted theme preferences', () async {
    final Box<String> prefsBox = Hive.box<String>(HiveBoxNames.prefs);
    await prefsBox.put(HiveKeys.themeMode, 'dark');
    await prefsBox.put(HiveKeys.lightThemeVariant, 'classicGreen');

    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final ThemeUiModel state = container.read(themeLogicProvider);

    expect(state.themeMode, ThemeMode.dark);
    expect(state.themeVariantId, 'classicGreen');
  });

  test('updates theme mode and variant', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final ThemeLogic notifier = container.read(themeLogicProvider.notifier);
    notifier.setThemeMode(ThemeMode.light);
    notifier.setThemeVariant('classicGreen');

    final ThemeUiModel state = container.read(themeLogicProvider);
    final Box<String> prefsBox = Hive.box<String>(HiveBoxNames.prefs);

    expect(state.themeMode, ThemeMode.light);
    expect(state.themeVariantId, 'classicGreen');
    expect(prefsBox.get(HiveKeys.themeMode), 'light');
    expect(prefsBox.get(HiveKeys.themeVariant), 'classicGreen');
  });
}
