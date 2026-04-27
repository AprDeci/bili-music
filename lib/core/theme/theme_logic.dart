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
      themeVariant: _readThemeVariant(
        settingsStore.readString(
          HiveKeys.themeVariant,
          defaultValue: settingsStore.readString(
            HiveKeys.lightThemeVariant,
            defaultValue: '',
          ),
        ),
      ),
    );
  }

  void setThemeMode(ThemeMode mode) {
    ref
        .read(appSettingsStoreProvider)
        .writeString(HiveKeys.themeMode, _themeModeValue(mode));
    state = state.copyWith(themeMode: mode);
  }

  void setThemeVariant(ThemeVariant variant) {
    ref
        .read(appSettingsStoreProvider)
        .writeString(HiveKeys.themeVariant, _themeVariantValue(variant));
    state = state.copyWith(themeVariant: variant);
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

  ThemeVariant _readThemeVariant(String? rawValue) {
    switch (rawValue) {
      case 'classicGreen':
        return ThemeVariant.classicGreen;
      case 'skyBlue':
        return ThemeVariant.skyBlue;
      case 'irisPurple':
        return ThemeVariant.irisPurple;
      case 'blossomPink':
        return ThemeVariant.blossomPink;
      case 'sunsetOrange':
        return ThemeVariant.sunsetOrange;
      case null:
        return ThemeVariant.classicGreen;
    }

    return ThemeVariant.classicGreen;
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

  String _themeVariantValue(ThemeVariant variant) {
    switch (variant) {
      case ThemeVariant.classicGreen:
        return 'classicGreen';
      case ThemeVariant.skyBlue:
        return 'skyBlue';
      case ThemeVariant.irisPurple:
        return 'irisPurple';
      case ThemeVariant.blossomPink:
        return 'blossomPink';
      case ThemeVariant.sunsetOrange:
        return 'sunsetOrange';
    }
  }
}
