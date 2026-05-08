import 'package:flutter/material.dart';

Color neutralColorForBrightness(
  Brightness brightness, {
  double lightAlpha = 0.86,
  double darkAlpha = 0.88,
}) {
  return switch (brightness) {
    Brightness.light => Colors.black.withValues(alpha: lightAlpha),
    Brightness.dark => Colors.white.withValues(alpha: darkAlpha),
  };
}

Color neutralColorOf(
  BuildContext context, {
  double lightAlpha = 0.86,
  double darkAlpha = 0.88,
}) {
  return neutralColorForBrightness(
    Theme.of(context).brightness,
    lightAlpha: lightAlpha,
    darkAlpha: darkAlpha,
  );
}
