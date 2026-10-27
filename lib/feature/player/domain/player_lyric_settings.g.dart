// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_lyric_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlayerLyricSettings _$PlayerLyricSettingsFromJson(Map<String, dynamic> json) =>
    _PlayerLyricSettings(
      fontScale: json['fontScale'] == null
          ? 1.0
          : _fontScaleFromJson(json['fontScale']),
      activeFontSize: _activeFontSizeFromJson(json['activeFontSize']),
      activeFontWeight: json['activeFontWeight'] == null
          ? 700
          : _activeFontWeightFromJson(json['activeFontWeight']),
      textOpacity: json['textOpacity'] == null
          ? 0.6
          : _textOpacityFromJson(json['textOpacity']),
      activeTextOpacity: _activeTextOpacityFromJson(json['activeTextOpacity']),
      activeTextColor: _nullableColorFromJson(json['activeTextColor']),
      translationFontSize: _translationFontSizeFromJson(
        json['translationFontSize'],
      ),
      activeTranslationFontSize: _activeTranslationFontSizeFromJson(
        json['activeTranslationFontSize'],
      ),
      translationSpacing: json['translationSpacing'] == null
          ? 8.0
          : _translationSpacingFromJson(json['translationSpacing']),
      lineSpacing: json['lineSpacing'] == null
          ? 24.0
          : _lineSpacingFromJson(json['lineSpacing']),
      alignment:
          $enumDecodeNullable(
            _$PlayerLyricAlignmentEnumMap,
            json['alignment'],
            unknownValue: PlayerLyricAlignment.start,
          ) ??
          PlayerLyricAlignment.start,
      contentAlignment: $enumDecodeNullable(
        _$PlayerLyricAlignmentEnumMap,
        json['contentAlignment'],
        unknownValue: JsonKey.nullForUndefinedEnumValue,
      ),
      displayMode:
          $enumDecodeNullable(
            _$PlayerLyricDisplayModeEnumMap,
            json['displayMode'],
            unknownValue: PlayerLyricDisplayMode.scrollable,
          ) ??
          PlayerLyricDisplayMode.scrollable,
      layoutMode:
          $enumDecodeNullable(
            _$PlayerLyricLayoutModeEnumMap,
            json['layoutMode'],
            unknownValue: PlayerLyricLayoutMode.fixed,
          ) ??
          PlayerLyricLayoutMode.fixed,
      horizontalPadding: json['horizontalPadding'] == null
          ? 24.0
          : _horizontalPaddingFromJson(json['horizontalPadding']),
      activeAnchorUnit:
          $enumDecodeNullable(
            _$PlayerLyricAnchorUnitEnumMap,
            json['activeAnchorUnit'],
            unknownValue: PlayerLyricAnchorUnit.fraction,
          ) ??
          PlayerLyricAnchorUnit.fraction,
      activeAnchorPosition: json['activeAnchorPosition'] == null
          ? 0.38
          : _anchorPositionFromJson(json['activeAnchorPosition']),
      activeAnchorTarget:
          $enumDecodeNullable(
            _$PlayerLyricAnchorTargetEnumMap,
            json['activeAnchorTarget'],
            unknownValue: PlayerLyricAnchorTarget.mainText,
          ) ??
          PlayerLyricAnchorTarget.mainText,
      selectionAnchorUnit:
          $enumDecodeNullable(
            _$PlayerLyricAnchorUnitEnumMap,
            json['selectionAnchorUnit'],
            unknownValue: PlayerLyricAnchorUnit.fraction,
          ) ??
          PlayerLyricAnchorUnit.fraction,
      selectionAnchorPosition: json['selectionAnchorPosition'] == null
          ? 0.38
          : _anchorPositionFromJson(json['selectionAnchorPosition']),
      selectionAnchorTarget:
          $enumDecodeNullable(
            _$PlayerLyricAnchorTargetEnumMap,
            json['selectionAnchorTarget'],
            unknownValue: PlayerLyricAnchorTarget.mainText,
          ) ??
          PlayerLyricAnchorTarget.mainText,
      showTranslation: json['showTranslation'] == null
          ? true
          : _showTranslationFromJson(json['showTranslation']),
      colorMode:
          $enumDecodeNullable(
            _$PlayerLyricColorModeEnumMap,
            json['colorMode'],
            unknownValue: PlayerLyricColorMode.cover,
          ) ??
          PlayerLyricColorMode.cover,
      customColor: json['customColor'] == null
          ? 0xffe91e63
          : _customColorFromJson(json['customColor']),
      motion:
          $enumDecodeNullable(
            _$PlayerLyricMotionEnumMap,
            json['motion'],
            unknownValue: PlayerLyricMotion.full,
          ) ??
          PlayerLyricMotion.full,
    );

Map<String, dynamic> _$PlayerLyricSettingsToJson(
  _PlayerLyricSettings instance,
) => <String, dynamic>{
  'fontScale': instance.fontScale,
  'activeFontSize': instance.activeFontSize,
  'activeFontWeight': instance.activeFontWeight,
  'textOpacity': instance.textOpacity,
  'activeTextOpacity': instance.activeTextOpacity,
  'activeTextColor': instance.activeTextColor,
  'translationFontSize': instance.translationFontSize,
  'activeTranslationFontSize': instance.activeTranslationFontSize,
  'translationSpacing': instance.translationSpacing,
  'lineSpacing': instance.lineSpacing,
  'alignment': _$PlayerLyricAlignmentEnumMap[instance.alignment]!,
  'contentAlignment': _$PlayerLyricAlignmentEnumMap[instance.contentAlignment],
  'displayMode': _$PlayerLyricDisplayModeEnumMap[instance.displayMode]!,
  'layoutMode': _$PlayerLyricLayoutModeEnumMap[instance.layoutMode]!,
  'horizontalPadding': instance.horizontalPadding,
  'activeAnchorUnit':
      _$PlayerLyricAnchorUnitEnumMap[instance.activeAnchorUnit]!,
  'activeAnchorPosition': instance.activeAnchorPosition,
  'activeAnchorTarget':
      _$PlayerLyricAnchorTargetEnumMap[instance.activeAnchorTarget]!,
  'selectionAnchorUnit':
      _$PlayerLyricAnchorUnitEnumMap[instance.selectionAnchorUnit]!,
  'selectionAnchorPosition': instance.selectionAnchorPosition,
  'selectionAnchorTarget':
      _$PlayerLyricAnchorTargetEnumMap[instance.selectionAnchorTarget]!,
  'showTranslation': instance.showTranslation,
  'colorMode': _$PlayerLyricColorModeEnumMap[instance.colorMode]!,
  'customColor': instance.customColor,
  'motion': _$PlayerLyricMotionEnumMap[instance.motion]!,
};

const _$PlayerLyricAlignmentEnumMap = {
  PlayerLyricAlignment.start: 'start',
  PlayerLyricAlignment.center: 'center',
  PlayerLyricAlignment.end: 'end',
};

const _$PlayerLyricDisplayModeEnumMap = {
  PlayerLyricDisplayMode.scrollable: 'scrollable',
  PlayerLyricDisplayMode.activeLine: 'activeLine',
};

const _$PlayerLyricLayoutModeEnumMap = {
  PlayerLyricLayoutMode.fixed: 'fixed',
  PlayerLyricLayoutMode.dualStyle: 'dualStyle',
};

const _$PlayerLyricAnchorUnitEnumMap = {
  PlayerLyricAnchorUnit.fraction: 'fraction',
  PlayerLyricAnchorUnit.pixels: 'pixels',
};

const _$PlayerLyricAnchorTargetEnumMap = {
  PlayerLyricAnchorTarget.mainText: 'mainText',
  PlayerLyricAnchorTarget.translationText: 'translationText',
  PlayerLyricAnchorTarget.lineCenter: 'lineCenter',
};

const _$PlayerLyricColorModeEnumMap = {
  PlayerLyricColorMode.cover: 'cover',
  PlayerLyricColorMode.theme: 'theme',
  PlayerLyricColorMode.custom: 'custom',
};

const _$PlayerLyricMotionEnumMap = {
  PlayerLyricMotion.full: 'full',
  PlayerLyricMotion.reduced: 'reduced',
  PlayerLyricMotion.off: 'off',
};
