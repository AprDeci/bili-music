import 'package:bilimusic/feature/player/domain/player_lyric_settings.dart';
import 'package:bilimusic/feature/player/ui/components/player_lyric_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/flutter_lyric.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final Brightness brightness in Brightness.values) {
    test('theme and custom highlights retain readable text in $brightness', () {
      final ThemeData theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: brightness,
        ),
      );
      for (final PlayerLyricColorMode mode in PlayerLyricColorMode.values) {
        final LyricPreset preset = buildPlayerLyricPreset(
          theme: theme,
          activeColor: Colors.orange,
          settings: PlayerLyricSettings(
            colorMode: mode,
            customColor: 0xff123456,
          ),
        );
        expect(
          preset.textStyle.color!.computeLuminance(),
          brightness == Brightness.light ? lessThan(0.1) : greaterThan(0.6),
        );
        final Color expected = switch (mode) {
          PlayerLyricColorMode.cover => ColorScheme.fromSeed(
            seedColor: Colors.orange,
            brightness: brightness,
          ).primary,
          PlayerLyricColorMode.theme => theme.colorScheme.primary,
          PlayerLyricColorMode.custom => const Color(0xff123456),
        };
        expect(preset.highlight.color, expected);
        expect(preset.activeTranslationTextStyle.color, expected);
        expect(preset.countdown.color, expected);
      }
    });
  }

  test('off and system reduced motion disable all decorative animation', () {
    for (final bool systemOverride in <bool>[false, true]) {
      final LyricPreset preset = buildPlayerLyricPreset(
        theme: ThemeData(),
        settings: PlayerLyricSettings(
          motion: systemOverride
              ? PlayerLyricMotion.full
              : PlayerLyricMotion.off,
        ),
        reduceMotion: systemOverride,
      );
      expect(preset.scrollAnimation.resolve(200).duration, Duration.zero);
      expect(preset.lineTransition.enabled, isFalse);
      expect(preset.lineMotion.maxLag, 0);
      expect(preset.lineMotion.waveAmplitude, 0);
      expect(preset.wordEffects.enabled, isFalse);
      expect(preset.distanceBlur.maxSigma, 0);
      expect(preset.countdown.enabled, isFalse);
    }
  });

  test('default typography inherits and preserves the current preset', () {
    final ThemeData theme = ThemeData();
    final LyricPreset preset = buildPlayerLyricPreset(
      theme: theme,
      settings: const PlayerLyricSettings(),
    );
    const LyricPreset base = LyricPresets.appleMusic;
    expect(preset.textStyle.fontSize, 30);
    expect(preset.textStyle.fontWeight, FontWeight.w700);
    expect(
      preset.textStyle.color,
      theme.colorScheme.onSurface.withValues(alpha: 0.6),
    );
    expect(preset.activeTextStyle, const TextStyle());
    expect(preset.translationTextStyle.fontSize, 16);
    expect(
      preset.translationTextStyle.color,
      theme.colorScheme.onSurface.withValues(alpha: 0.7),
    );
    expect(preset.activeTranslationTextStyle.fontSize, isNull);
    expect(preset.activeTranslationTextStyle.color, preset.highlight.color);
    expect(preset.translationInheritsTextStyle, isFalse);
    expect(preset.displayMode, base.displayMode);
    expect(preset.layoutMode, base.layoutMode);
    expect(preset.padding, base.padding);
    expect(preset.lineSpacing, base.lineSpacing);
    expect(preset.translationSpacing, base.translationSpacing);
    expect(preset.activeAnchor, base.activeAnchor);
    expect(preset.selectionAnchor, base.selectionAnchor);
    expect(preset.scrollAnimation, base.scrollAnimation);
    expect(preset.lineTransition, base.lineTransition);
    expect(preset.lineMotion, base.lineMotion);
    expect(preset.wordEffects, base.wordEffects);
    expect(preset.distanceBlur, base.distanceBlur);
    expect(preset.edgeFade, base.edgeFade);
    expect(preset.highlight.tailFadeWidth, base.highlight.tailFadeWidth);
  });

  test('legacy scale and alignment continue to drive inherited styles', () {
    final LyricPreset preset = buildPlayerLyricPreset(
      theme: ThemeData(),
      settings: PlayerLyricSettings.fromJson(<String, dynamic>{
        'fontScale': 1.4,
        'alignment': 'end',
      }),
    );
    expect(preset.textStyle.fontSize, 42);
    expect(preset.textStyle.merge(preset.activeTextStyle).fontSize, 42);
    expect(preset.translationTextStyle.fontSize, 16 * 1.4);
    expect(
      preset.translationTextStyle
          .merge(preset.activeTranslationTextStyle)
          .fontSize,
      16 * 1.4,
    );
    expect(preset.activeTextStyle, const TextStyle());
    expect(preset.textAlign, TextAlign.end);
    expect(preset.contentAlignment, LyricContentAlignment.end);
  });

  test('maps explicit typography while keeping translated highlight color', () {
    final ThemeData theme = ThemeData();
    final LyricPreset preset = buildPlayerLyricPreset(
      theme: theme,
      settings: const PlayerLyricSettings(
        fontScale: 1.2,
        activeFontSize: 44,
        activeFontWeight: 500,
        textOpacity: 0.25,
        activeTextOpacity: 0.85,
        activeTextColor: 0xff123456,
        translationFontSize: 20,
        activeTranslationFontSize: 26,
        translationSpacing: 15,
        lineSpacing: 60,
        horizontalPadding: 45,
        colorMode: PlayerLyricColorMode.custom,
        customColor: 0xffabcdef,
      ),
    );
    expect(preset.textStyle.fontSize, 36);
    expect(
      preset.textStyle.color,
      theme.colorScheme.onSurface.withValues(alpha: 0.25),
    );
    expect(preset.activeTextStyle.fontSize, 44);
    expect(preset.activeTextStyle.fontWeight, FontWeight.w500);
    expect(
      preset.activeTextStyle.color,
      const Color(0xff123456).withValues(alpha: 0.85),
    );
    expect(preset.translationTextStyle.fontSize, 20);
    expect(preset.activeTranslationTextStyle.fontSize, 26);
    expect(preset.activeTranslationTextStyle.color, const Color(0xffabcdef));
    expect(preset.translationSpacing, 15);
    expect(preset.lineSpacing, 60);
    expect(preset.padding, const EdgeInsets.symmetric(horizontal: 45));
  });

  test('active color and opacity override independently', () {
    final ThemeData theme = ThemeData();
    for (final PlayerLyricSettings settings in <PlayerLyricSettings>[
      const PlayerLyricSettings(textOpacity: 0.2, activeTextColor: 0xff123456),
      const PlayerLyricSettings(textOpacity: 0.2, activeTextOpacity: 0.9),
      const PlayerLyricSettings(textOpacity: 0.2, activeTextOpacity: 0),
    ]) {
      final LyricPreset preset = buildPlayerLyricPreset(
        theme: theme,
        settings: settings,
      );
      final Color expected = settings.activeTextColor == null
          ? theme.colorScheme.onSurface
          : Color(settings.activeTextColor!);
      expect(
        preset.activeTextStyle.color,
        expected.withValues(
          alpha: settings.activeTextOpacity ?? settings.textOpacity,
        ),
      );
      expect(preset.highlight.color, theme.colorScheme.primary);
      expect(
        preset.activeTranslationTextStyle.color,
        theme.colorScheme.primary,
      );
    }
    final LyricPreset inherited = buildPlayerLyricPreset(
      theme: theme,
      settings: const PlayerLyricSettings(textOpacity: 0.2),
    );
    expect(inherited.activeTextStyle.color, isNull);
    expect(
      inherited.textStyle.merge(inherited.activeTextStyle).color,
      theme.colorScheme.onSurface.withValues(alpha: 0.2),
    );
  });

  test(
    'maps all active weights without freezing default style inheritance',
    () {
      for (final int weight in <int>[400, 500, 600, 700, 800]) {
        final LyricPreset preset = buildPlayerLyricPreset(
          theme: ThemeData(),
          settings: PlayerLyricSettings(activeFontWeight: weight),
        );
        expect(
          preset.textStyle.merge(preset.activeTextStyle).fontWeight,
          FontWeight.values[weight ~/ 100 - 1],
        );
        if (weight == 700) {
          expect(preset.activeTextStyle, const TextStyle());
        }
      }
    },
  );

  test(
    'explicit sizes stop inheriting and unset active sizes keep inheriting',
    () {
      for (final double scale in <double>[10 / 30, 1, 1.6]) {
        final LyricPreset preset = buildPlayerLyricPreset(
          theme: ThemeData(),
          settings: PlayerLyricSettings(
            fontScale: scale,
            translationFontSize: 22,
          ),
        );
        expect(preset.textStyle.fontSize, 30 * scale);
        expect(
          preset.textStyle.merge(preset.activeTextStyle).fontSize,
          30 * scale,
        );
        expect(preset.translationTextStyle.fontSize, 22);
        expect(
          preset.translationTextStyle
              .merge(preset.activeTranslationTextStyle)
              .fontSize,
          22,
        );
      }
    },
  );

  test('text and content alignment are independent when explicitly set', () {
    for (final PlayerLyricAlignment text in PlayerLyricAlignment.values) {
      for (final PlayerLyricAlignment content in PlayerLyricAlignment.values) {
        final LyricPreset preset = buildPlayerLyricPreset(
          theme: ThemeData(),
          settings: PlayerLyricSettings(
            alignment: text,
            contentAlignment: content,
          ),
        );
        expect(preset.textAlign, switch (text) {
          PlayerLyricAlignment.start => TextAlign.start,
          PlayerLyricAlignment.center => TextAlign.center,
          PlayerLyricAlignment.end => TextAlign.end,
        });
        expect(preset.contentAlignment, switch (content) {
          PlayerLyricAlignment.start => LyricContentAlignment.start,
          PlayerLyricAlignment.center => LyricContentAlignment.center,
          PlayerLyricAlignment.end => LyricContentAlignment.end,
        });
      }
    }
  });

  test('maps each display and layout mode independently', () {
    for (final PlayerLyricDisplayMode display
        in PlayerLyricDisplayMode.values) {
      for (final PlayerLyricLayoutMode layout in PlayerLyricLayoutMode.values) {
        final LyricPreset preset = buildPlayerLyricPreset(
          theme: ThemeData(),
          settings: PlayerLyricSettings(
            displayMode: display,
            layoutMode: layout,
          ),
        );
        expect(preset.displayMode, switch (display) {
          PlayerLyricDisplayMode.scrollable => LyricDisplayMode.scrollable,
          PlayerLyricDisplayMode.activeLine => LyricDisplayMode.activeLine,
        });
        expect(preset.layoutMode, switch (layout) {
          PlayerLyricLayoutMode.fixed => LyricLayoutMode.fixed,
          PlayerLyricLayoutMode.dualStyle => LyricLayoutMode.dualStyle,
        });
      }
    }
  });

  test(
    'active and selection anchors map independently for each unit/target',
    () {
      for (final PlayerLyricAnchorUnit unit in PlayerLyricAnchorUnit.values) {
        for (final PlayerLyricAnchorTarget target
            in PlayerLyricAnchorTarget.values) {
          final LyricPreset preset = buildPlayerLyricPreset(
            theme: ThemeData(),
            settings: PlayerLyricSettings(
              activeAnchorUnit: unit,
              activeAnchorPosition: unit == PlayerLyricAnchorUnit.fraction
                  ? 0.2
                  : 120,
              activeAnchorTarget: target,
              selectionAnchorUnit: unit == PlayerLyricAnchorUnit.fraction
                  ? PlayerLyricAnchorUnit.pixels
                  : PlayerLyricAnchorUnit.fraction,
              selectionAnchorPosition: unit == PlayerLyricAnchorUnit.fraction
                  ? 240
                  : 0.8,
              selectionAnchorTarget: PlayerLyricAnchorTarget.lineCenter,
            ),
          );
          expect(
            preset.activeAnchor.isFraction,
            unit == PlayerLyricAnchorUnit.fraction,
          );
          expect(
            preset.activeAnchor.resolve(1000),
            unit == PlayerLyricAnchorUnit.fraction ? 200 : 120,
          );
          expect(preset.activeAnchor.target, switch (target) {
            PlayerLyricAnchorTarget.mainText => LyricAnchorTarget.mainText,
            PlayerLyricAnchorTarget.translationText =>
              LyricAnchorTarget.translationText,
            PlayerLyricAnchorTarget.lineCenter => LyricAnchorTarget.lineCenter,
          });
          expect(
            preset.selectionAnchor.isFraction,
            unit != PlayerLyricAnchorUnit.fraction,
          );
          expect(
            preset.selectionAnchor.resolve(1000),
            unit == PlayerLyricAnchorUnit.fraction ? 240 : 800,
          );
          expect(preset.selectionAnchor.target, LyricAnchorTarget.lineCenter);
        }
      }
    },
  );

  test(
    'reduced motion preserves typography and only keeps smooth scrolling',
    () {
      final LyricPreset preset = buildPlayerLyricPreset(
        theme: ThemeData(),
        settings: const PlayerLyricSettings(
          activeFontSize: 50,
          motion: PlayerLyricMotion.reduced,
        ),
      );
      expect(preset.activeTextStyle.fontSize, 50);
      expect(
        preset.scrollAnimation.resolve(200).duration,
        const Duration(milliseconds: 240),
      );
      expect(preset.lineTransition.enabled, isFalse);
      expect(preset.lineMotion.maxLag, 0);
      expect(preset.wordEffects.lift, 0);
      expect(preset.wordEffects.floatAmplitude, 0);
      expect(preset.wordEffects.simulateTiming, isTrue);
      expect(preset.distanceBlur.maxSigma, 0);
      expect(preset.countdown.enabled, isTrue);
      expect(preset.countdown.breathDuration, Duration.zero);
    },
  );

  test('right alignment changes text and content together', () {
    final LyricPreset preset = buildPlayerLyricPreset(
      theme: ThemeData(),
      settings: const PlayerLyricSettings(alignment: PlayerLyricAlignment.end),
    );
    expect(preset.textAlign, TextAlign.end);
    expect(preset.contentAlignment, LyricContentAlignment.end);
  });
}
