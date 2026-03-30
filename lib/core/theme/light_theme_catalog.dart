import 'package:bilimusic/core/theme/theme_ui_model.dart';
import 'package:flutter/material.dart';

class LightThemeDefinition {
  const LightThemeDefinition({
    required this.variant,
    required this.label,
    required this.description,
    required this.seedColor,
    required this.scaffoldBackgroundColor,
    required this.surfaceColor,
  });

  final LightThemeVariant variant;
  final String label;
  final String description;
  final Color seedColor;
  final Color scaffoldBackgroundColor;
  final Color surfaceColor;
}

const Map<LightThemeVariant, LightThemeDefinition> lightThemeCatalog =
    <LightThemeVariant, LightThemeDefinition>{
      LightThemeVariant.classicGreen: LightThemeDefinition(
        variant: LightThemeVariant.classicGreen,
        label: '经典绿',
        description: '沿用当前应用的默认浅色主题',
        seedColor: Color(0xFF31C27C),
        scaffoldBackgroundColor: Color(0xFFF4F7FB),
        surfaceColor: Colors.white,
      ),
      LightThemeVariant.classicRed: LightThemeDefinition(
        variant: LightThemeVariant.classicRed,
        label: '经典红',
        description: '沿用当前应用的默认浅色主题',
        seedColor: Color(0xFFD42E2E),
        scaffoldBackgroundColor: Color(0xFFF4F7FB),
        surfaceColor: Colors.white,
      ),
    };

LightThemeDefinition lightThemeDefinitionOf(LightThemeVariant variant) {
  return lightThemeCatalog[variant] ??
      lightThemeCatalog[LightThemeVariant.classicGreen]!;
}
