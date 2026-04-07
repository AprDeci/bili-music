import 'package:color_palette_plus/color_palette_plus.dart';
import 'package:flutter/material.dart';

class ColorUtil {
  ColorUtil._();

  /// 生成完整的 Material Swatch（50~900）
  static MaterialColor getSwatch(Color baseColor) {
    return ColorPalette.generateSwatch(baseColor);
  }

  /// 获取某个具体 shade
  static Color getShade(Color baseColor, int shadeValue) {
    return ColorPalette.getShade(baseColor, shadeValue);
  }

  /// 获取全部 shades Map
  static Map<int, Color> getAllShades(Color baseColor) {
    return ColorPalette.getAllShades(baseColor);
  }

  /// 单色调调色板
  static List<Color> getMonochromatic(Color baseColor, {int steps = 8}) {
    return ColorPalettes.monochromatic(baseColor, steps: steps);
  }

  /// 类似色调色板
  /// angle 建议 25~40，数值越大颜色差异越明显
  static List<Color> getAnalogous(
    Color baseColor, {
    int steps = 5,
    double angle = 30,
  }) {
    return ColorPalettes.analogous(baseColor, steps: steps, angle: angle);
  }

  /// 互补色（返回两个颜色，适合强调色 + 背景）
  static List<Color> getComplementary(Color baseColor) {
    return ColorPalettes.complementary(baseColor);
  }

  /// 快捷方法（你在播放界面最常用）
  static Color getPrimary(Color baseColor) => getShade(baseColor, 500); // 主色
  static Color getLight(Color baseColor) => getShade(baseColor, 100); // 浅色
  static Color getDark(Color baseColor) => getShade(baseColor, 900); // 深色
  static Color getProgressColor(Color baseColor) =>
      getAnalogous(baseColor, steps: 5)[2]; // 类似色中的醒目颜色，适合进度条
}
