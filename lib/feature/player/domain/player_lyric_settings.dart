import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_lyric_settings.freezed.dart';
part 'player_lyric_settings.g.dart';

enum PlayerLyricAlignment { start, center, end }

enum PlayerLyricColorMode { cover, theme, custom }

enum PlayerLyricMotion { full, reduced, off }

enum PlayerLyricDisplayMode { scrollable, activeLine }

enum PlayerLyricLayoutMode { fixed, dualStyle }

enum PlayerLyricAnchorUnit { fraction, pixels }

enum PlayerLyricAnchorTarget { mainText, translationText, lineCenter }

@freezed
abstract class PlayerLyricSettings with _$PlayerLyricSettings {
  const factory PlayerLyricSettings({
    @JsonKey(fromJson: _fontScaleFromJson) @Default(1.0) double fontScale,
    @JsonKey(fromJson: _activeFontSizeFromJson) double? activeFontSize,
    @JsonKey(fromJson: _activeFontWeightFromJson)
    @Default(700)
    int activeFontWeight,
    @JsonKey(fromJson: _textOpacityFromJson) @Default(0.6) double textOpacity,
    @JsonKey(fromJson: _activeTextOpacityFromJson) double? activeTextOpacity,
    @JsonKey(fromJson: _nullableColorFromJson) int? activeTextColor,
    @JsonKey(fromJson: _translationFontSizeFromJson)
    double? translationFontSize,
    @JsonKey(fromJson: _activeTranslationFontSizeFromJson)
    double? activeTranslationFontSize,
    @JsonKey(fromJson: _translationSpacingFromJson)
    @Default(8.0)
    double translationSpacing,
    @JsonKey(fromJson: _lineSpacingFromJson) @Default(24.0) double lineSpacing,
    @JsonKey(unknownEnumValue: PlayerLyricAlignment.start)
    @Default(PlayerLyricAlignment.start)
    PlayerLyricAlignment alignment,
    @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
    PlayerLyricAlignment? contentAlignment,
    @JsonKey(unknownEnumValue: PlayerLyricDisplayMode.scrollable)
    @Default(PlayerLyricDisplayMode.scrollable)
    PlayerLyricDisplayMode displayMode,
    @JsonKey(unknownEnumValue: PlayerLyricLayoutMode.fixed)
    @Default(PlayerLyricLayoutMode.fixed)
    PlayerLyricLayoutMode layoutMode,
    @JsonKey(fromJson: _horizontalPaddingFromJson)
    @Default(24.0)
    double horizontalPadding,
    @JsonKey(unknownEnumValue: PlayerLyricAnchorUnit.fraction)
    @Default(PlayerLyricAnchorUnit.fraction)
    PlayerLyricAnchorUnit activeAnchorUnit,
    @JsonKey(fromJson: _anchorPositionFromJson)
    @Default(0.38)
    double activeAnchorPosition,
    @JsonKey(unknownEnumValue: PlayerLyricAnchorTarget.mainText)
    @Default(PlayerLyricAnchorTarget.mainText)
    PlayerLyricAnchorTarget activeAnchorTarget,
    @JsonKey(unknownEnumValue: PlayerLyricAnchorUnit.fraction)
    @Default(PlayerLyricAnchorUnit.fraction)
    PlayerLyricAnchorUnit selectionAnchorUnit,
    @JsonKey(fromJson: _anchorPositionFromJson)
    @Default(0.38)
    double selectionAnchorPosition,
    @JsonKey(unknownEnumValue: PlayerLyricAnchorTarget.mainText)
    @Default(PlayerLyricAnchorTarget.mainText)
    PlayerLyricAnchorTarget selectionAnchorTarget,
    @JsonKey(fromJson: _showTranslationFromJson)
    @Default(true)
    bool showTranslation,
    @JsonKey(unknownEnumValue: PlayerLyricColorMode.cover)
    @Default(PlayerLyricColorMode.cover)
    PlayerLyricColorMode colorMode,
    @JsonKey(fromJson: _customColorFromJson)
    @Default(0xffe91e63)
    int customColor,
    @JsonKey(unknownEnumValue: PlayerLyricMotion.full)
    @Default(PlayerLyricMotion.full)
    PlayerLyricMotion motion,
  }) = _PlayerLyricSettings;

  const PlayerLyricSettings._();

  factory PlayerLyricSettings.fromJson(Map<String, dynamic> json) =>
      _$PlayerLyricSettingsFromJson(json).sanitized();

  PlayerLyricSettings sanitized() => copyWith(
    fontScale: _fontScaleFromJson(fontScale),
    activeFontSize: _activeFontSizeFromJson(activeFontSize),
    activeFontWeight: _activeFontWeightFromJson(activeFontWeight),
    textOpacity: _textOpacityFromJson(textOpacity),
    activeTextOpacity: _activeTextOpacityFromJson(activeTextOpacity),
    activeTextColor: _nullableColorFromJson(activeTextColor),
    translationFontSize: _translationFontSizeFromJson(translationFontSize),
    activeTranslationFontSize: _activeTranslationFontSizeFromJson(
      activeTranslationFontSize,
    ),
    translationSpacing: _translationSpacingFromJson(translationSpacing),
    lineSpacing: _lineSpacingFromJson(lineSpacing),
    horizontalPadding: _horizontalPaddingFromJson(horizontalPadding),
    activeAnchorPosition: _anchorPositionFromJson(activeAnchorPosition).clamp(
      0.0,
      activeAnchorUnit == PlayerLyricAnchorUnit.fraction ? 1.0 : 600.0,
    ),
    selectionAnchorPosition: _anchorPositionFromJson(selectionAnchorPosition)
        .clamp(
          0.0,
          selectionAnchorUnit == PlayerLyricAnchorUnit.fraction ? 1.0 : 600.0,
        ),
    customColor: _customColorFromJson(customColor),
  );
}

double _fontScaleFromJson(Object? value) =>
    _boundedDouble(value, fallback: 1.0, min: 10 / 30, max: 1.6);

double? _activeFontSizeFromJson(Object? value) =>
    _nullableBoundedDouble(value, min: 10, max: 60);

int _activeFontWeightFromJson(Object? value) =>
    value is int && const <int>[400, 500, 600, 700, 800].contains(value)
    ? value
    : 700;

double _textOpacityFromJson(Object? value) =>
    _boundedDouble(value, fallback: 0.6, min: 0, max: 1);

double? _activeTextOpacityFromJson(Object? value) =>
    _nullableBoundedDouble(value, min: 0, max: 1);

double? _translationFontSizeFromJson(Object? value) =>
    _nullableBoundedDouble(value, min: 8, max: 32);

double? _activeTranslationFontSizeFromJson(Object? value) =>
    _nullableBoundedDouble(value, min: 8, max: 36);

double _translationSpacingFromJson(Object? value) =>
    _boundedDouble(value, fallback: 8.0, min: 0, max: 32);

double _lineSpacingFromJson(Object? value) =>
    _boundedDouble(value, fallback: 24.0, min: 0, max: 80);

double _horizontalPaddingFromJson(Object? value) =>
    _boundedDouble(value, fallback: 24.0, min: 0, max: 80);

double _anchorPositionFromJson(Object? value) =>
    _boundedDouble(value, fallback: 0.38, min: 0, max: 600);

double? _nullableBoundedDouble(
  Object? value, {
  required double min,
  required double max,
}) => value is num && value.isFinite ? value.toDouble().clamp(min, max) : null;

double _boundedDouble(
  Object? value, {
  required double fallback,
  required double min,
  required double max,
}) => _nullableBoundedDouble(value, min: min, max: max) ?? fallback;

bool _showTranslationFromJson(Object? value) => value is bool ? value : true;

int? _nullableColorFromJson(Object? value) =>
    value is int && value >= 0 && value <= 0xffffffff ? value : null;

int _customColorFromJson(Object? value) =>
    _nullableColorFromJson(value) ?? 0xffe91e63;
