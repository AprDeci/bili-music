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
    );

Map<String, dynamic> _$ThemeUiModelToJson(_ThemeUiModel instance) =>
    <String, dynamic>{'themeMode': _$ThemeModeEnumMap[instance.themeMode]!};

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};
