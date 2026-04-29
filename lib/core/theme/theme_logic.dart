// ignore_for_file: cast_nullable_to_non_nullable

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:flutter/material.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'theme_catalog.dart';
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
      themeVariantId: _readThemeVariantId(
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

  void setThemeVariant(String variantId) {
    final String normalizedVariantId = _readThemeVariantId(variantId);
    ref
        .read(appSettingsStoreProvider)
        .writeString(HiveKeys.themeVariant, normalizedVariantId);
    state = state.copyWith(themeVariantId: normalizedVariantId);
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

  String _readThemeVariantId(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) {
      return defaultThemeVariantId;
    }

    if (isKnownThemeVariantId(rawValue)) {
      return rawValue;
    }

    return defaultThemeVariantId;
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
}
