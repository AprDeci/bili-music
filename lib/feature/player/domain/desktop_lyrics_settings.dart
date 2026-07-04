class DesktopLyricsSettings {
  const DesktopLyricsSettings({
    required this.enabled,
    required this.alwaysOnTop,
    required this.opacity,
  });

  static const double minOpacity = 0.2;
  static const double maxOpacity = 1.0;

  final bool enabled;
  final bool alwaysOnTop;
  final double opacity;

  DesktopLyricsSettings copyWith({
    bool? enabled,
    bool? alwaysOnTop,
    double? opacity,
  }) {
    return DesktopLyricsSettings(
      enabled: enabled ?? this.enabled,
      alwaysOnTop: alwaysOnTop ?? this.alwaysOnTop,
      opacity: opacity ?? this.opacity,
    );
  }

  static double clampOpacity(double value) {
    return value.clamp(minOpacity, maxOpacity).toDouble();
  }
}
