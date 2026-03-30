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
      lightThemeVariant:
          $enumDecodeNullable(
            _$LightThemeVariantEnumMap,
            json['lightThemeVariant'],
          ) ??
          LightThemeVariant.classicGreen,
    );

Map<String, dynamic> _$ThemeUiModelToJson(
  _ThemeUiModel instance,
) => <String, dynamic>{
  'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
  'lightThemeVariant': _$LightThemeVariantEnumMap[instance.lightThemeVariant]!,
};

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _$LightThemeVariantEnumMap = {
  LightThemeVariant.classicGreen: 'classicGreen',
  LightThemeVariant.skyBlue: 'skyBlue',
  LightThemeVariant.irisPurple: 'irisPurple',
  LightThemeVariant.blossomPink: 'blossomPink',
  LightThemeVariant.sunsetOrange: 'sunsetOrange',
};
