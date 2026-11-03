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
  return base.copyWith(
    colorScheme: colors,
    scaffoldBackgroundColor: colors.surfaceContainerLow,
    textTheme: base.textTheme.apply(
      bodyColor: colors.onSurface,
      displayColor: colors.onSurface,
    ),
    iconTheme: base.iconTheme.copyWith(color: colors.onSurface),
    appBarTheme: base.appBarTheme.copyWith(foregroundColor: colors.onSurface),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
    ),
    sliderTheme: base.sliderTheme.copyWith(
      activeTrackColor: colors.onSurfaceVariant,
      inactiveTrackColor: colors.surfaceContainerHighest,
      thumbColor: colors.onSurfaceVariant,
    ),
  );
}
