import 'package:bilimusic/core/theme/app_theme.dart';
import 'package:bilimusic/core/theme/theme_catalog.dart';
import 'package:flutter/material.dart';

ThemeData carLightTheme() {
  final ThemeData base = AppTheme.lightTheme(defaultThemeVariantId);
  final ColorScheme colors = base.colorScheme.copyWith(
    primary: const Color(0xFF00854A),
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFF0F2F3),
    onPrimaryContainer: const Color(0xFF17191B),
    secondary: const Color(0xFF555A60),
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFE5E8EB),
    onSecondaryContainer: const Color(0xFF17191B),
    tertiary: const Color(0xFF555A60),
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFFE5E8EB),
    onTertiaryContainer: const Color(0xFF17191B),
    surface: Colors.white,
    onSurface: const Color(0xFF17191B),
    onSurfaceVariant: const Color(0xFF555A60),
    surfaceDim: const Color(0xFFE2E5E8),
    surfaceBright: Colors.white,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: const Color(0xFFEDEFF1),
    surfaceContainer: const Color(0xFFE8EBED),
    surfaceContainerHigh: const Color(0xFFE2E5E8),
    surfaceContainerHighest: const Color(0xFFDDE1E5),
    surfaceTint: Colors.transparent,
    outline: const Color(0xFF757B81),
    outlineVariant: const Color(0xFFDDE1E5),
  );
  return _carTheme(base, colors);
}

ThemeData carDarkTheme() {
  final ThemeData base = AppTheme.darkTheme(defaultThemeVariantId);
  final ColorScheme colors = base.colorScheme.copyWith(
    primary: const Color(0xFF4DD99A),
    onPrimary: const Color(0xFF002112),
    primaryContainer: const Color(0xFF2B4037),
    onPrimaryContainer: const Color(0xFFF1F3F4),
    secondary: const Color(0xFFB8BDC3),
    onSecondary: const Color(0xFF17191B),
    secondaryContainer: const Color(0xFF2C313A),
    onSecondaryContainer: const Color(0xFFF1F3F4),
    tertiary: const Color(0xFFB8BDC3),
    onTertiary: const Color(0xFF17191B),
    tertiaryContainer: const Color(0xFF2C313A),
    onTertiaryContainer: const Color(0xFFF1F3F4),
    surface: const Color(0xFF20242C),
    onSurface: const Color(0xFFF1F3F4),
    onSurfaceVariant: const Color(0xFFB8BDC3),
    surfaceDim: const Color(0xFF0C0F13),
    surfaceBright: const Color(0xFF3B424C),
    surfaceContainerLowest: const Color(0xFF0C0F13),
    surfaceContainerLow: const Color(0xFF101318),
    surfaceContainer: const Color(0xFF252A32),
    surfaceContainerHigh: const Color(0xFF2D333D),
    surfaceContainerHighest: const Color(0xFF363C45),
    surfaceTint: Colors.transparent,
    outline: const Color(0xFF8A9096),
    outlineVariant: const Color(0xFF3D4349),
  );
  return _carTheme(base, colors).copyWith(
    cardTheme: base.cardTheme.copyWith(color: colors.surface),
    bottomSheetTheme: base.bottomSheetTheme.copyWith(
      backgroundColor: colors.surface,
    ),
  );
}

ThemeData _carTheme(ThemeData base, ColorScheme colors) {
  return base.copyWith(
    colorScheme: colors,
    scaffoldBackgroundColor: colors.surfaceContainerLow,
    textTheme: base.textTheme.apply(
      bodyColor: colors.onSurface,
      displayColor: colors.onSurface,
    ),
    iconTheme: base.iconTheme.copyWith(color: colors.onSurface),
    appBarTheme: base.appBarTheme.copyWith(foregroundColor: colors.onSurface),
    sliderTheme: base.sliderTheme.copyWith(
      activeTrackColor: colors.onSurfaceVariant,
      inactiveTrackColor: colors.surfaceContainerHighest,
      thumbColor: colors.onSurfaceVariant,
    ),
  );
}
