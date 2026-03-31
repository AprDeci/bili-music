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
        description: '默认',
        seedColor: Color(0xFF31C27C),
        scaffoldBackgroundColor: Color(0xFFF4F7FB),
        surfaceColor: Colors.white,
      ),
      LightThemeVariant.skyBlue: LightThemeDefinition(
        variant: LightThemeVariant.skyBlue,
        label: '海盐蓝',
        description: '更清爽通透的浅色蓝调',
        seedColor: Color(0xFF3B82F6),
        scaffoldBackgroundColor: Color(0xFFF3F7FE),
        surfaceColor: Color(0xFFFCFDFF),
      ),
      LightThemeVariant.irisPurple: LightThemeDefinition(
        variant: LightThemeVariant.irisPurple,
        label: '鸢尾紫',
        description: '柔和克制的浅色紫调',
        seedColor: Color(0xFF7C6CF2),
        scaffoldBackgroundColor: Color(0xFFF7F5FE),
        surfaceColor: Color(0xFFFFFCFF),
      ),
      LightThemeVariant.blossomPink: LightThemeDefinition(
        variant: LightThemeVariant.blossomPink,
        label: '花雾粉',
        description: '轻盈明快的浅色粉调',
        seedColor: Color(0xFFF1CADC),
        scaffoldBackgroundColor: Color(0xFFFFF5F9),
        surfaceColor: Color(0xFFFFFCFD),
      ),
      LightThemeVariant.sunsetOrange: LightThemeDefinition(
        variant: LightThemeVariant.sunsetOrange,
        label: '日落橙',
        description: '更有活力的暖色浅色主题',
        seedColor: Color(0xFFFF8A3D),
        scaffoldBackgroundColor: Color(0xFFFFF6F0),
        surfaceColor: Color(0xFFFFFCFA),
      ),
    };

LightThemeDefinition lightThemeDefinitionOf(LightThemeVariant variant) {
  return lightThemeCatalog[variant] ??
      lightThemeCatalog[LightThemeVariant.classicGreen]!;
}
