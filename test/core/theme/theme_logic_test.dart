import 'dart:io';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/theme/theme_logic.dart';
import 'package:bilimusic/core/theme/theme_ui_model.dart';
import 'package:bilimusic/core/layout/app_layout.dart';
import 'package:bilimusic/feature/setting/logic/appearance_setting_logic.dart';
import 'package:bilimusic/feature/setting/logic/car_ui_setting_logic.dart';
import 'package:bilimusic/feature/setting/ui/theme_settings_page.dart';
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

  testWidgets(
    'car mode hides standard appearance options without resetting them',
    (tester) async {
      tester.view.physicalSize = const Size(2000, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.runAsync(() async {
        container.read(themeLogicProvider.notifier).setThemeVariant('skyBlue');
        await container
            .read(appearanceSettingLogicProvider.notifier)
            .setUseGlassBar(true);
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) => AppLayoutScope(
              layout: ref.watch(carUiSettingLogicProvider)
                  ? AppLayout.car
                  : AppLayout.mobile,
              child: const MaterialApp(home: ThemeSettingsPage()),
            ),
          ),
        ),
      );
      expect(find.text('主题颜色'), findsOneWidget);
      expect(find.byType(RadioListTile<String>), findsNWidgets(6));
      expect(find.text('启用玻璃导航栏/播放栏'), findsOneWidget);
      await tester.runAsync(
        () => container
            .read(carUiSettingLogicProvider.notifier)
            .setEnabled(!container.read(carUiSettingLogicProvider)),
      );
      await tester.pumpAndSettle();
      expect(container.read(carUiSettingLogicProvider), isTrue);
      expect(find.text('主题颜色'), findsNothing);
      expect(find.byType(RadioListTile<String>), findsNothing);
      expect(find.text('启用玻璃导航栏/播放栏'), findsNothing);
      expect(find.text('主题模式'), findsOneWidget);
      expect(find.byType(RadioListTile<ThemeMode>), findsNWidgets(3));
      await tester.runAsync(
        () => container
            .read(carUiSettingLogicProvider.notifier)
            .setEnabled(!container.read(carUiSettingLogicProvider)),
      );
      await tester.pumpAndSettle();
      expect(find.text('主题颜色'), findsOneWidget);
      expect(find.byType(RadioListTile<String>), findsNWidgets(6));
      expect(find.text('启用玻璃导航栏/播放栏'), findsOneWidget);
      expect(container.read(themeLogicProvider).themeVariantId, 'skyBlue');
      expect(container.read(appearanceSettingLogicProvider), isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  test('uses frost tea white as default theme variant', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final ThemeUiModel state = container.read(themeLogicProvider);

    expect(state.themeVariantId, 'frostTeaWhite');
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
