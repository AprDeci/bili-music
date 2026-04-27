import 'package:bilimusic/core/theme/theme_ui_model.dart';
import 'package:flutter/material.dart';

class DarkThemeDefinition {
  const DarkThemeDefinition({
    required this.variant,
    required this.label,
    required this.description,
    required this.seedColor,
    required this.scaffoldBackgroundColor,
    required this.surfaceColor,
  });

  final ThemeVariant variant;
  final String label;
  final String description;
  final Color seedColor;
  final Color scaffoldBackgroundColor;
  final Color surfaceColor;
}

const Map<ThemeVariant, DarkThemeDefinition> darkThemeCatalog =
    <ThemeVariant, DarkThemeDefinition>{
      ThemeVariant.classicGreen: DarkThemeDefinition(
        variant: ThemeVariant.classicGreen,
        label: '经典绿',
        description: '默认',
        seedColor: Color(0xFF31C27C),
        scaffoldBackgroundColor: Color(0xFF09120F),
        surfaceColor: Color(0xFF13211D),
      ),
      ThemeVariant.skyBlue: DarkThemeDefinition(
        variant: ThemeVariant.skyBlue,
        label: '海盐蓝',
        description: '更清爽通透的深色蓝调',
        seedColor: Color(0xFF60A5FA),
        scaffoldBackgroundColor: Color(0xFF08111F),
        surfaceColor: Color(0xFF101D33),
      ),
      ThemeVariant.irisPurple: DarkThemeDefinition(
        variant: ThemeVariant.irisPurple,
        label: '鸢尾紫',
        description: '柔和克制的深色紫调',
        seedColor: Color(0xFFA99BFF),
        scaffoldBackgroundColor: Color(0xFF120D1E),
        surfaceColor: Color(0xFF211932),
      ),
      ThemeVariant.blossomPink: DarkThemeDefinition(
        variant: ThemeVariant.blossomPink,
        label: '花雾粉',
        description: '轻盈明快的深色粉调',
        seedColor: Color(0xFFF6B4D0),
        scaffoldBackgroundColor: Color(0xFF1D0E16),
        surfaceColor: Color(0xFF2E1924),
      ),
      ThemeVariant.sunsetOrange: DarkThemeDefinition(
        variant: ThemeVariant.sunsetOrange,
        label: '日落橙',
        description: '更有活力的暖色深色主题',
        seedColor: Color(0xFFFF9F5A),
        scaffoldBackgroundColor: Color(0xFF1E1008),
        surfaceColor: Color(0xFF2F1B10),
      ),
    };

DarkThemeDefinition darkThemeDefinitionOf(ThemeVariant variant) {
  return darkThemeCatalog[variant] ??
      darkThemeCatalog[ThemeVariant.classicGreen]!;
}
