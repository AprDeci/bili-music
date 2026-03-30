import 'dart:io';

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
    await Hive.openBox<String>('prefs');
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('reads persisted theme preferences', () async {
    final Box<String> prefsBox = Hive.box<String>('prefs');
    await prefsBox.put('themeMode', 'dark');
    await prefsBox.put('lightThemeVariant', 'classicGreen');

    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final ThemeUiModel state = container.read(themeLogicProvider);

    expect(state.themeMode, ThemeMode.dark);
    expect(state.lightThemeVariant, LightThemeVariant.classicGreen);
  });

  test('updates theme mode and light variant', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final ThemeLogic notifier = container.read(themeLogicProvider.notifier);
    notifier.setThemeMode(ThemeMode.light);
    notifier.setLightThemeVariant(LightThemeVariant.classicGreen);

    final ThemeUiModel state = container.read(themeLogicProvider);
    final Box<String> prefsBox = Hive.box<String>('prefs');

    expect(state.themeMode, ThemeMode.light);
    expect(state.lightThemeVariant, LightThemeVariant.classicGreen);
    expect(prefsBox.get('themeMode'), 'light');
    expect(prefsBox.get('lightThemeVariant'), 'classicGreen');
  });
}
