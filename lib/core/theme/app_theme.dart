
import 'package:bilimusic/core/theme/dark_theme_catalog.dart';
import 'package:bilimusic/core/theme/light_theme_catalog.dart';
import 'package:bilimusic/core/theme/theme_ui_model.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';

final class AppTheme {
  const AppTheme._();

  static ThemeData lightTheme(ThemeVariant variant) {
    final LightThemeDefinition definition = lightThemeDefinitionOf(variant);
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: definition.seedColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      // fontFamily: _getFontFamily(),
      textTheme: TextTheme().useSystemChineseFont(Brightness.light),
      colorScheme: colorScheme,
      scaffoldBackgroundColor: definition.scaffoldBackgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: definition.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: definition.surfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

  static ThemeData darkTheme(ThemeVariant variant) {
    final DarkThemeDefinition definition = darkThemeDefinitionOf(variant);
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: definition.seedColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      // fontFamily: _getFontFamily(),
      textTheme: TextTheme().useSystemChineseFont(Brightness.dark),
      colorScheme: colorScheme,
      scaffoldBackgroundColor: definition.scaffoldBackgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: definition.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: definition.surfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

}
