import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/core/theme/components/no_transition_builder.dart';
import 'package:bilimusic/core/theme/desktop_chinese_font.dart';
import 'package:bilimusic/core/theme/theme_catalog.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.grey.shade200,
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.grey.shade200,
          disabledForegroundColor: Colors.black38,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
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
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {TargetPlatform.windows: NoTransitionBuilder()},
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
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF20242C),
          foregroundColor: const Color(0xFFF1F3F4),
          disabledBackgroundColor: const Color(0xFF20242C),
          disabledForegroundColor: Colors.white38,
        ),
      ),
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

  static TextTheme _textTheme(Brightness brightness) {
    final TextTheme textTheme = TextTheme().useSystemChineseFont(brightness);

    if (PlatformUtil.isDesktop) {
      return textTheme.apply(fontFamily: DesktopChineseFont.fontFamily);
    }

    return textTheme;
  }
}
