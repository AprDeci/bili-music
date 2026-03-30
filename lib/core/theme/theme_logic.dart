// ignore_for_file: cast_nullable_to_non_nullable

import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'theme_ui_model.dart';

part 'theme_logic.g.dart';

@riverpod
class ThemeLogic extends _$ThemeLogic {
  static const String _themeModeKey = 'themeMode';
  static const String _lightThemeVariantKey = 'lightThemeVariant';

  @override
  ThemeUiModel build() {
    final Box<String> prefsBox = Hive.box<String>('prefs');

    return ThemeUiModel(
      themeMode: _readThemeMode(prefsBox.get(_themeModeKey)),
      lightThemeVariant: _readLightThemeVariant(
        prefsBox.get(_lightThemeVariantKey),
      ),
    );
  }

  void setThemeMode(ThemeMode mode) {
    Hive.box<String>('prefs').put(_themeModeKey, _themeModeValue(mode));
    state = state.copyWith(themeMode: mode);
  }

  void setLightThemeVariant(LightThemeVariant variant) {
    Hive.box<String>(
      'prefs',
    ).put(_lightThemeVariantKey, _lightThemeVariantValue(variant));
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

    return 'system';
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

    return 'classicGreen';
  }
}
