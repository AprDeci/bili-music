import 'package:bilimusic/core/theme/desktop_chinese_font.dart';
import 'package:bilimusic/core/theme/theme_catalog.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';

final class AppTheme {
  const AppTheme._();

  static ThemeData lightTheme(String variantId) {
    final ThemeDefinition definition = themeDefinitionOf(variantId);
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: definition.seedColor,
      brightness: Brightness.light,
    ).copyWith(primary: definition.primaryColor);

    return ThemeData(
      useMaterial3: true,
      textTheme: _textTheme(Brightness.light),
      colorScheme: colorScheme,
      scaffoldBackgroundColor: definition.lightScaffoldBackgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: definition.lightSurfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: definition.lightSurfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

  static ThemeData darkTheme(String variantId) {
    final ThemeDefinition definition = themeDefinitionOf(variantId);
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: definition.seedColor,
      brightness: Brightness.dark,
    ).copyWith(primary: definition.primaryColor);

    return ThemeData(
      useMaterial3: true,
      textTheme: _textTheme(Brightness.dark),
      colorScheme: colorScheme,
      scaffoldBackgroundColor: definition.darkScaffoldBackgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: definition.darkSurfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: definition.darkSurfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

  static const List<String> _fontFamilyFallback = <String>[
    DesktopChineseFont.fontFamily,
    'Noto Sans CJK SC',
    'Noto Sans SC',
    'Source Han Sans SC',
    'WenQuanYi Micro Hei',
    'Microsoft YaHei',
    'sans-serif',
  ];

  static TextTheme _textTheme(Brightness brightness) {
    return TextTheme()
        .useSystemChineseFont(brightness)
        .apply(fontFamilyFallback: _fontFamilyFallback);
  }
}
