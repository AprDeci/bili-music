// ignore_for_file: cast_nullable_to_non_nullable

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:flutter/material.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'theme_ui_model.dart';

part 'theme_logic.g.dart';

@riverpod
class ThemeLogic extends _$ThemeLogic {
  @override
  ThemeUiModel build() {
    final AppSettingsStore settingsStore = ref.watch(appSettingsStoreProvider);

    return ThemeUiModel(
      themeMode: _readThemeMode(
        settingsStore.readString(HiveKeys.themeMode, defaultValue: ''),
      ),
      lightThemeVariant: _readLightThemeVariant(
        settingsStore.readString(HiveKeys.lightThemeVariant, defaultValue: ''),
      ),
    );
  }

  void setThemeMode(ThemeMode mode) {
    ref
        .read(appSettingsStoreProvider)
        .writeString(HiveKeys.themeMode, _themeModeValue(mode));
    state = state.copyWith(themeMode: mode);
  }

  void setLightThemeVariant(LightThemeVariant variant) {
    ref
        .read(appSettingsStoreProvider)
        .writeString(
          HiveKeys.lightThemeVariant,
          _lightThemeVariantValue(variant),
        );
    state = state.copyWith(lightThemeVariant: variant);
  }

  void toggleTheme() {
    if (state.themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  ThemeMode _readThemeMode(String? rawValue) {
    switch (rawValue) {
      case 'dark':
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'light':
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'system':
      case 'ThemeMode.system':
        return ThemeMode.system;
      case null:
        return ThemeMode.light;
    }

    return ThemeMode.system;
  }

  LightThemeVariant _readLightThemeVariant(String? rawValue) {
    switch (rawValue) {
      case 'classicGreen':
        return LightThemeVariant.classicGreen;
      case 'skyBlue':
        return LightThemeVariant.skyBlue;
      case 'irisPurple':
        return LightThemeVariant.irisPurple;
      case 'blossomPink':
        return LightThemeVariant.blossomPink;
      case 'sunsetOrange':
        return LightThemeVariant.sunsetOrange;
      case null:
        return LightThemeVariant.classicGreen;
    }

    return LightThemeVariant.classicGreen;
  }

  String _themeModeValue(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
    }
  }

  String _lightThemeVariantValue(LightThemeVariant variant) {
    switch (variant) {
      case LightThemeVariant.classicGreen:
        return 'classicGreen';
      case LightThemeVariant.skyBlue:
        return 'skyBlue';
      case LightThemeVariant.irisPurple:
        return 'irisPurple';
      case LightThemeVariant.blossomPink:
        return 'blossomPink';
      case LightThemeVariant.sunsetOrange:
        return 'sunsetOrange';
    }
  }
}
