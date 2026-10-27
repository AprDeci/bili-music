import 'dart:convert';
import 'dart:io';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/player/domain/player_lyric_settings.dart';
import 'package:bilimusic/feature/player/logic/lyrics/player_lyric_settings_logic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDirectory;
  late Box<String> prefsBox;
  late ProviderContainer container;

  ProviderContainer createContainer() => ProviderContainer(
    overrides: [
      appSettingsStoreProvider.overrideWithValue(AppSettingsStore(prefsBox)),
    ],
  );

  PlayerLyricSettings readSettings() =>
      container.read(playerLyricSettingsLogicProvider);

  PlayerLyricSettingsLogic readLogic() =>
      container.read(playerLyricSettingsLogicProvider.notifier);

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'lyric-settings-test-',
    );
    Hive.init(tempDirectory.path);
    prefsBox = await Hive.openBox<String>(HiveBoxNames.prefs);
    container = createContainer();
  });

  tearDown(() async {
    container.dispose();
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('uses all appearance defaults without writing preferences', () {
    final PlayerLyricSettings settings = readSettings();

    expect(settings.fontScale, 1.0);
    expect(settings.lineSpacing, 24.0);
    expect(settings.alignment, PlayerLyricAlignment.start);
    expect(settings.showTranslation, isTrue);
    expect(settings.colorMode, PlayerLyricColorMode.cover);
    expect(settings.customColor, 0xffe91e63);
    expect(settings.motion, PlayerLyricMotion.full);
    expect(settings.activeFontSize, isNull);
    expect(settings.activeFontWeight, 700);
    expect(settings.textOpacity, 0.6);
    expect(settings.activeTextOpacity, isNull);
    expect(settings.activeTextColor, isNull);
    expect(settings.translationFontSize, isNull);
    expect(settings.activeTranslationFontSize, isNull);
    expect(settings.translationSpacing, 8);
    expect(settings.contentAlignment, isNull);
    expect(settings.displayMode, PlayerLyricDisplayMode.scrollable);
    expect(settings.layoutMode, PlayerLyricLayoutMode.fixed);
    expect(settings.horizontalPadding, 24);
    expect(settings.activeAnchorUnit, PlayerLyricAnchorUnit.fraction);
    expect(settings.activeAnchorPosition, 0.38);
    expect(settings.activeAnchorTarget, PlayerLyricAnchorTarget.mainText);
    expect(settings.selectionAnchorUnit, PlayerLyricAnchorUnit.fraction);
    expect(settings.selectionAnchorPosition, 0.38);
    expect(settings.selectionAnchorTarget, PlayerLyricAnchorTarget.mainText);
    expect(prefsBox.get(HiveKeys.playerLyricSettings), isNull);
    expect(PlayerLyricSettings.fromJson(settings.toJson()), settings);
  });

  test(
    'persists every setting across container disposal and recreation',
    () async {
      const PlayerLyricSettings value = PlayerLyricSettings(
        fontScale: 1.3,
        lineSpacing: 36.0,
        alignment: PlayerLyricAlignment.end,
        showTranslation: false,
        colorMode: PlayerLyricColorMode.custom,
        customColor: 0xff123456,
        motion: PlayerLyricMotion.off,
        activeFontSize: 42,
        activeFontWeight: 800,
        textOpacity: 0.4,
        activeTextOpacity: 0.9,
        activeTextColor: 0xffabcdef,
        translationFontSize: 18,
        activeTranslationFontSize: 22,
        translationSpacing: 12,
        contentAlignment: PlayerLyricAlignment.center,
        displayMode: PlayerLyricDisplayMode.activeLine,
        layoutMode: PlayerLyricLayoutMode.dualStyle,
        horizontalPadding: 36,
        activeAnchorUnit: PlayerLyricAnchorUnit.pixels,
        activeAnchorPosition: 180,
        activeAnchorTarget: PlayerLyricAnchorTarget.translationText,
        selectionAnchorUnit: PlayerLyricAnchorUnit.fraction,
        selectionAnchorPosition: 0.7,
        selectionAnchorTarget: PlayerLyricAnchorTarget.lineCenter,
      );
      await readLogic().update(value);
      expect(readSettings(), value);
      expect(
        jsonDecode(prefsBox.get(HiveKeys.playerLyricSettings)!),
        value.toJson(),
      );

      container.dispose();
      container = createContainer();
      expect(readSettings(), value);
    },
  );

  test('serializes every enum value by name', () {
    for (int index = 0; index < 3; index++) {
      final PlayerLyricSettings value = PlayerLyricSettings(
        alignment: PlayerLyricAlignment.values[index],
        colorMode: PlayerLyricColorMode.values[index],
        motion: PlayerLyricMotion.values[index],
      );
      final Map<String, dynamic> json = value.toJson();

      expect(json['alignment'], value.alignment.name);
      expect(json['colorMode'], value.colorMode.name);
      expect(json['motion'], value.motion.name);
      expect(PlayerLyricSettings.fromJson(json), value);
    }
  });

  for (final String raw in <String>[
    '',
    '{broken',
    'null',
    '[]',
    '42',
    '"settings"',
    '{"fontScale":NaN}',
    '{"fontScale":1e999,"lineSpacing":-1e999}',
  ]) {
    test(
      'falls back safely for corrupt or non-object preferences: $raw',
      () async {
        await prefsBox.put(HiveKeys.playerLyricSettings, raw);

        expect(readSettings(), const PlayerLyricSettings());
        expect(prefsBox.get(HiveKeys.playerLyricSettings), raw);
      },
    );
  }

  test('defaults invalid field types and enums independently', () async {
    await prefsBox.put(
      HiveKeys.playerLyricSettings,
      jsonEncode(<String, Object?>{
        'fontScale': '1.4',
        'lineSpacing': <int>[24],
        'alignment': 'unknown',
        'showTranslation': 'false',
        'colorMode': 1,
        'customColor': '0xff123456',
        'motion': <String, Object?>{},
        'activeFontSize': '42',
        'activeFontWeight': 700.0,
        'textOpacity': false,
        'activeTextOpacity': <int>[1],
        'activeTextColor': '0xffabcdef',
        'translationFontSize': <String, Object?>{},
        'activeTranslationFontSize': true,
        'translationSpacing': '8',
        'contentAlignment': 'unknown',
        'displayMode': 1,
        'layoutMode': false,
        'horizontalPadding': <int>[24],
        'activeAnchorUnit': 'unknown',
        'activeAnchorPosition': '0.5',
        'activeAnchorTarget': 2,
        'selectionAnchorUnit': <String, Object?>{},
        'selectionAnchorPosition': false,
        'selectionAnchorTarget': 'unknown',
      }),
    );
    expect(readSettings(), const PlayerLyricSettings());

    await prefsBox.put(
      HiveKeys.playerLyricSettings,
      '{"fontScale":1.2,"alignment":"invalid","showTranslation":false}',
    );
    container.invalidate(playerLyricSettingsLogicProvider);
    expect(
      readSettings(),
      const PlayerLyricSettings(fontScale: 1.2, showTranslation: false),
    );
  });

  test('clamps persisted finite ranges and rejects invalid colors', () async {
    await prefsBox.put(
      HiveKeys.playerLyricSettings,
      '{"fontScale":-100,"lineSpacing":100,"customColor":-1}',
    );
    expect(
      readSettings(),
      const PlayerLyricSettings(fontScale: 10 / 30, lineSpacing: 80.0),
    );

    await prefsBox.put(
      HiveKeys.playerLyricSettings,
      '{"fontScale":100,"lineSpacing":-100,"customColor":4294967296}',
    );
    container.invalidate(playerLyricSettingsLogicProvider);
    expect(
      readSettings(),
      const PlayerLyricSettings(fontScale: 1.6, lineSpacing: 0.0),
    );
  });

  test('sanitizes updates before writing JSON or changing state', () async {
    for (final double value in <double>[
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      await readLogic().update(
        PlayerLyricSettings(
          fontScale: value,
          lineSpacing: value,
          activeFontSize: value,
          textOpacity: value,
          activeTextOpacity: value,
          translationFontSize: value,
          activeTranslationFontSize: value,
          translationSpacing: value,
          horizontalPadding: value,
          activeAnchorPosition: value,
          selectionAnchorPosition: value,
          activeFontWeight: 900,
          activeTextColor: -1,
          customColor: -1,
        ),
      );
      expect(readSettings(), const PlayerLyricSettings());
      expect(
        PlayerLyricSettings.fromJson(
          jsonDecode(prefsBox.get(HiveKeys.playerLyricSettings)!)
              as Map<String, dynamic>,
        ),
        const PlayerLyricSettings(),
      );
    }

    await readLogic().update(
      const PlayerLyricSettings(fontScale: 2.0, lineSpacing: 0.0),
    );
    expect(
      readSettings(),
      const PlayerLyricSettings(fontScale: 1.6, lineSpacing: 0.0),
    );
  });

  test(
    'translation updates preserve appearance and reset persists defaults',
    () async {
      const PlayerLyricSettings value = PlayerLyricSettings(
        fontScale: 1.4,
        alignment: PlayerLyricAlignment.center,
        colorMode: PlayerLyricColorMode.theme,
        motion: PlayerLyricMotion.reduced,
      );
      await readLogic().update(value);
      await readLogic().setShowTranslation(false);
      expect(readSettings(), value.copyWith(showTranslation: false));

      await readLogic().reset();
      expect(readSettings(), const PlayerLyricSettings());
      container.dispose();
      container = createContainer();
      expect(readSettings(), const PlayerLyricSettings());
    },
  );

  test('old JSON keeps nullable typography and alignment inheritance', () {
    final PlayerLyricSettings settings =
        PlayerLyricSettings.fromJson(<String, dynamic>{
          'fontScale': 1.4,
          'lineSpacing': 36,
          'alignment': 'end',
          'showTranslation': false,
          'colorMode': 'theme',
          'customColor': 0xff123456,
          'motion': 'reduced',
        });
    expect(
      settings,
      const PlayerLyricSettings(
        fontScale: 1.4,
        lineSpacing: 36,
        alignment: PlayerLyricAlignment.end,
        showTranslation: false,
        colorMode: PlayerLyricColorMode.theme,
        customColor: 0xff123456,
        motion: PlayerLyricMotion.reduced,
      ),
    );
    expect(settings.activeFontSize, isNull);
    expect(settings.activeTextOpacity, isNull);
    expect(settings.activeTextColor, isNull);
    expect(settings.translationFontSize, isNull);
    expect(settings.activeTranslationFontSize, isNull);
    expect(settings.contentAlignment, isNull);
  });

  test('round trips each new enum by name and nullable overrides', () {
    final Map<String, Iterable<Enum>> enums = <String, Iterable<Enum>>{
      'contentAlignment': PlayerLyricAlignment.values,
      'displayMode': PlayerLyricDisplayMode.values,
      'layoutMode': PlayerLyricLayoutMode.values,
      'activeAnchorUnit': PlayerLyricAnchorUnit.values,
      'selectionAnchorUnit': PlayerLyricAnchorUnit.values,
      'activeAnchorTarget': PlayerLyricAnchorTarget.values,
      'selectionAnchorTarget': PlayerLyricAnchorTarget.values,
    };
    for (final MapEntry<String, Iterable<Enum>> entry in enums.entries) {
      for (final Enum value in entry.value) {
        final PlayerLyricSettings settings = PlayerLyricSettings.fromJson(
          <String, dynamic>{entry.key: value.name},
        );
        expect(settings.toJson()[entry.key], value.name);
        expect(PlayerLyricSettings.fromJson(settings.toJson()), settings);
      }
    }
    final PlayerLyricSettings cleared =
        const PlayerLyricSettings(
          activeFontSize: 40,
          activeTextOpacity: 0.8,
          activeTextColor: 0xff123456,
          translationFontSize: 20,
          activeTranslationFontSize: 24,
          contentAlignment: PlayerLyricAlignment.center,
        ).copyWith(
          activeFontSize: null,
          activeTextOpacity: null,
          activeTextColor: null,
          translationFontSize: null,
          activeTranslationFontSize: null,
          contentAlignment: null,
        );
    expect(cleared, const PlayerLyricSettings());
    expect(PlayerLyricSettings.fromJson(cleared.toJson()), cleared);
  });

  test('JSON rejects every nonfinite numeric field independently', () {
    for (final double invalid in <double>[
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      expect(
        PlayerLyricSettings.fromJson(<String, dynamic>{
          'fontScale': invalid,
          'activeFontSize': invalid,
          'activeFontWeight': invalid,
          'textOpacity': invalid,
          'activeTextOpacity': invalid,
          'activeTextColor': invalid,
          'translationFontSize': invalid,
          'activeTranslationFontSize': invalid,
          'translationSpacing': invalid,
          'lineSpacing': invalid,
          'horizontalPadding': invalid,
          'activeAnchorPosition': invalid,
          'selectionAnchorPosition': invalid,
          'customColor': invalid,
        }),
        const PlayerLyricSettings(),
      );
    }
  });

  test('clamps typography and layout at JSON and update boundaries', () async {
    final Map<String, dynamic> low = <String, dynamic>{
      'fontScale': -1,
      'activeFontSize': -1,
      'textOpacity': -1,
      'activeTextOpacity': -1,
      'translationFontSize': -1,
      'activeTranslationFontSize': -1,
      'translationSpacing': -1,
      'lineSpacing': -1,
      'horizontalPadding': -1,
      'activeAnchorPosition': -1,
      'selectionAnchorPosition': -1,
    };
    final Map<String, dynamic> high = <String, dynamic>{
      for (final String field in low.keys) field: 1000,
    };
    const PlayerLyricSettings expectedLow = PlayerLyricSettings(
      fontScale: 10 / 30,
      activeFontSize: 10,
      textOpacity: 0,
      activeTextOpacity: 0,
      translationFontSize: 8,
      activeTranslationFontSize: 8,
      translationSpacing: 0,
      lineSpacing: 0,
      horizontalPadding: 0,
      activeAnchorPosition: 0,
      selectionAnchorPosition: 0,
    );
    const PlayerLyricSettings expectedHigh = PlayerLyricSettings(
      fontScale: 1.6,
      activeFontSize: 60,
      textOpacity: 1,
      activeTextOpacity: 1,
      translationFontSize: 32,
      activeTranslationFontSize: 36,
      translationSpacing: 32,
      lineSpacing: 80,
      horizontalPadding: 80,
      activeAnchorPosition: 1,
      selectionAnchorPosition: 1,
    );
    expect(PlayerLyricSettings.fromJson(low), expectedLow);
    expect(PlayerLyricSettings.fromJson(high), expectedHigh);
    for (final (double value, PlayerLyricSettings expected)
        in <(double, PlayerLyricSettings)>[
          (-1, expectedLow),
          (1000, expectedHigh),
        ]) {
      await readLogic().update(
        PlayerLyricSettings(
          fontScale: value,
          activeFontSize: value,
          textOpacity: value,
          activeTextOpacity: value,
          translationFontSize: value,
          activeTranslationFontSize: value,
          translationSpacing: value,
          lineSpacing: value,
          horizontalPadding: value,
          activeAnchorPosition: value,
          selectionAnchorPosition: value,
        ),
      );
      expect(readSettings(), expected);
    }
  });

  test(
    'anchor units clamp independently on read and when units change',
    () async {
      expect(
        PlayerLyricSettings.fromJson(<String, dynamic>{
          'activeAnchorUnit': 'pixels',
          'activeAnchorPosition': 900,
          'selectionAnchorPosition': 900,
        }),
        const PlayerLyricSettings(
          activeAnchorUnit: PlayerLyricAnchorUnit.pixels,
          activeAnchorPosition: 600,
          selectionAnchorPosition: 1,
        ),
      );
      final PlayerLyricSettings settings =
          PlayerLyricSettings.fromJson(<String, dynamic>{
            'activeAnchorPosition': 120,
            'selectionAnchorUnit': 'pixels',
            'selectionAnchorPosition': 120,
          });
      expect(settings.activeAnchorPosition, 1);
      expect(settings.selectionAnchorPosition, 120);
      await readLogic().update(
        settings.copyWith(
          activeAnchorUnit: PlayerLyricAnchorUnit.pixels,
          activeAnchorPosition: 900,
          selectionAnchorUnit: PlayerLyricAnchorUnit.fraction,
        ),
      );
      expect(readSettings().activeAnchorPosition, 600);
      expect(readSettings().selectionAnchorPosition, 1);
    },
  );

  test('validates uint32 colors and discrete font weights', () async {
    for (final int color in <int>[0, 0xffffffff]) {
      final PlayerLyricSettings settings = PlayerLyricSettings.fromJson(
        <String, dynamic>{'activeTextColor': color, 'customColor': color},
      );
      expect(settings.activeTextColor, color);
      expect(settings.customColor, color);
      await readLogic().update(settings);
      expect(readSettings(), settings);
    }
    for (final Object? color in <Object?>[
      -1,
      0x100000000,
      0xffffffff.toDouble(),
      '4294967295',
      false,
    ]) {
      expect(
        PlayerLyricSettings.fromJson(<String, dynamic>{
          'activeTextColor': color,
          'customColor': color,
        }),
        const PlayerLyricSettings(),
      );
    }
    for (final int color in <int>[-1, 0x100000000]) {
      await readLogic().update(
        PlayerLyricSettings(activeTextColor: color, customColor: color),
      );
      expect(readSettings(), const PlayerLyricSettings());
    }
    for (final int weight in <int>[400, 500, 600, 700, 800]) {
      final PlayerLyricSettings settings = PlayerLyricSettings.fromJson(
        <String, dynamic>{'activeFontWeight': weight},
      );
      expect(settings.activeFontWeight, weight);
      await readLogic().update(settings);
      expect(readSettings(), settings);
    }
    for (final Object? weight in <Object?>[100, 900, 650, 700.0, '700', null]) {
      expect(
        PlayerLyricSettings.fromJson(<String, dynamic>{
          'activeFontWeight': weight,
        }).activeFontWeight,
        700,
      );
    }
  });

  test('failed updates and resets preserve the previous state', () async {
    const PlayerLyricSettings value = PlayerLyricSettings(fontScale: 1.4);
    final PlayerLyricSettingsLogic logic = readLogic();
    await logic.update(value);
    await prefsBox.close();

    await expectLater(
      logic.update(value.copyWith(showTranslation: false)),
      throwsA(isA<HiveError>()),
    );
    expect(readSettings(), value);
    await expectLater(logic.reset(), throwsA(isA<HiveError>()));
    expect(readSettings(), value);
  });
}
