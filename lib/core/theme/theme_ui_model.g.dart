// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_ui_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ThemeUiModel _$ThemeUiModelFromJson(Map<String, dynamic> json) =>
    _ThemeUiModel(
      themeMode:
          $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode']) ??
          ThemeMode.system,
      themeVariant:
          $enumDecodeNullable(_$ThemeVariantEnumMap, json['themeVariant']) ??
          ThemeVariant.classicGreen,
    );

Map<String, dynamic> _$ThemeUiModelToJson(_ThemeUiModel instance) =>
    <String, dynamic>{
      'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
      'themeVariant': _$ThemeVariantEnumMap[instance.themeVariant]!,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _$ThemeVariantEnumMap = {
  ThemeVariant.classicGreen: 'classicGreen',
  ThemeVariant.skyBlue: 'skyBlue',
  ThemeVariant.irisPurple: 'irisPurple',
  ThemeVariant.blossomPink: 'blossomPink',
  ThemeVariant.sunsetOrange: 'sunsetOrange',
};
