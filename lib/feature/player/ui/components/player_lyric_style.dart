import 'package:bilimusic/feature/player/domain/player_lyric_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/flutter_lyric.dart';

LyricPreset buildPlayerLyricPreset({
  required ThemeData theme,
  required PlayerLyricSettings settings,
  Color? activeColor,
  bool reduceMotion = false,
}) {
  final ColorScheme colors = activeColor == null
      ? theme.colorScheme
      : ColorScheme.fromSeed(
          seedColor: activeColor,
          brightness: theme.brightness,
        );
  final Color highlightColor = switch (settings.colorMode) {
    PlayerLyricColorMode.cover => colors.primary,
    PlayerLyricColorMode.theme => theme.colorScheme.primary,
    PlayerLyricColorMode.custom => Color(settings.customColor),
  };
  final PlayerLyricMotion motion = reduceMotion
      ? PlayerLyricMotion.off
      : settings.motion;
  const LyricPreset base = LyricPresets.appleMusic;
  return base.copyWith(
    textStyle: base.textStyle.copyWith(
      fontSize: 30 * settings.fontScale,
      color: colors.onSurface.withValues(alpha: settings.textOpacity),
    ),
    activeTextStyle: TextStyle(
      fontSize: settings.activeFontSize,
      fontWeight: settings.activeFontWeight == 700
          ? null
          : FontWeight.values[settings.activeFontWeight ~/ 100 - 1],
      color:
          settings.activeTextColor == null && settings.activeTextOpacity == null
          ? null
          : (settings.activeTextColor == null
                    ? theme.colorScheme.onSurface
                    : Color(settings.activeTextColor!))
                .withValues(
                  alpha: settings.activeTextOpacity ?? settings.textOpacity,
                ),
    ),
    translationTextStyle: base.translationTextStyle.copyWith(
      fontSize: settings.translationFontSize ?? 16 * settings.fontScale,
      color: colors.onSurface.withValues(alpha: 0.7),
    ),
    activeTranslationTextStyle: base.activeTranslationTextStyle.copyWith(
      fontSize: settings.activeTranslationFontSize,
      color: highlightColor,
    ),
    textAlign: switch (settings.alignment) {
      PlayerLyricAlignment.start => TextAlign.start,
      PlayerLyricAlignment.center => TextAlign.center,
      PlayerLyricAlignment.end => TextAlign.end,
    },
    contentAlignment: switch (settings.contentAlignment ?? settings.alignment) {
      PlayerLyricAlignment.start => LyricContentAlignment.start,
      PlayerLyricAlignment.center => LyricContentAlignment.center,
      PlayerLyricAlignment.end => LyricContentAlignment.end,
    },
    displayMode: switch (settings.displayMode) {
      PlayerLyricDisplayMode.scrollable => LyricDisplayMode.scrollable,
      PlayerLyricDisplayMode.activeLine => LyricDisplayMode.activeLine,
    },
    layoutMode: switch (settings.layoutMode) {
      PlayerLyricLayoutMode.fixed => LyricLayoutMode.fixed,
      PlayerLyricLayoutMode.dualStyle => LyricLayoutMode.dualStyle,
    },
    padding: EdgeInsets.symmetric(horizontal: settings.horizontalPadding),
    lineSpacing: settings.lineSpacing,
    translationSpacing: settings.translationSpacing,
    activeAnchor: _buildAnchor(
      settings.activeAnchorUnit,
      settings.activeAnchorPosition,
      settings.activeAnchorTarget,
    ),
    selectionAnchor: _buildAnchor(
      settings.selectionAnchorUnit,
      settings.selectionAnchorPosition,
      settings.selectionAnchorTarget,
    ),
    selectedTextColor: colors.onSurface,
    selectedTranslationTextColor: colors.onSurface,
    highlight: LyricHighlight.solid(
      highlightColor,
      tailFadeWidth: base.highlight.tailFadeWidth,
    ),
    countdown: motion == PlayerLyricMotion.off
        ? const LyricCountdown.none()
        : base.countdown.copyWith(
            color: highlightColor,
            breathDuration: motion == PlayerLyricMotion.reduced
                ? Duration.zero
                : base.countdown.breathDuration,
          ),
    scrollAnimation: switch (motion) {
      PlayerLyricMotion.full => base.scrollAnimation,
      PlayerLyricMotion.reduced => const LyricScrollAnimation.fixed(
        duration: Duration(milliseconds: 240),
      ),
      PlayerLyricMotion.off => const LyricScrollAnimation.none(),
    },
    lineTransition: motion == PlayerLyricMotion.full
        ? base.lineTransition
        : const LyricLineTransition.none(),
    lineMotion: motion == PlayerLyricMotion.full
        ? base.lineMotion
        : const LyricLineMotion(),
    wordEffects: switch (motion) {
      PlayerLyricMotion.full => base.wordEffects,
      PlayerLyricMotion.reduced => const LyricWordEffects(simulateTiming: true),
      PlayerLyricMotion.off => const LyricWordEffects(),
    },
    distanceBlur: motion == PlayerLyricMotion.full
        ? base.distanceBlur
        : const LyricDistanceBlur(),
  );
}

LyricAnchor _buildAnchor(
  PlayerLyricAnchorUnit unit,
  double position,
  PlayerLyricAnchorTarget target,
) {
  final LyricAnchorTarget lyricTarget = switch (target) {
    PlayerLyricAnchorTarget.mainText => LyricAnchorTarget.mainText,
    PlayerLyricAnchorTarget.translationText =>
      LyricAnchorTarget.translationText,
    PlayerLyricAnchorTarget.lineCenter => LyricAnchorTarget.lineCenter,
  };
  return switch (unit) {
    PlayerLyricAnchorUnit.fraction => LyricAnchor.fraction(
      position,
      target: lyricTarget,
    ),
    PlayerLyricAnchorUnit.pixels => LyricAnchor.pixels(
      position,
      target: lyricTarget,
    ),
  };
}
