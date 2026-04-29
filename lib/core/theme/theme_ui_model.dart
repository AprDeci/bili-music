import 'package:flutter/material.dart';

import 'theme_catalog.dart';

final class ThemeUiModel {
  const ThemeUiModel({
    this.themeMode = ThemeMode.system,
    this.themeVariantId = defaultThemeVariantId,
  });

  final ThemeMode themeMode;
  final String themeVariantId;

  ThemeUiModel copyWith({ThemeMode? themeMode, String? themeVariantId}) {
    return ThemeUiModel(
      themeMode: themeMode ?? this.themeMode,
      themeVariantId: themeVariantId ?? this.themeVariantId,
    );
  }
}
