import 'package:adaptive_palette/adaptive_palette.dart';
import 'package:bilimusic/core/cache/cache_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

enum PlayerBackdropVariant { mobile, desktop }

class PlayerDynamicBackdrop extends StatefulWidget {
  const PlayerDynamicBackdrop({
    super.key,
    required this.coverUrl,
    this.variant = PlayerBackdropVariant.mobile,
  });

  final String? coverUrl;
  final PlayerBackdropVariant variant;

  @override
  State<PlayerDynamicBackdrop> createState() => _PlayerDynamicBackdropState();
}

class _PlayerDynamicBackdropState extends State<PlayerDynamicBackdrop> {
  static const Duration _extractDelay = Duration(milliseconds: 520);
  static const Duration _colorTransitionDuration = Duration(milliseconds: 1000);
  static const int _paletteCacheExtent = 96;
  static const int _maxColorCacheEntries = 160;
  static final Map<String, Color> _colorCache = <String, Color>{};

  String? _loadedUrl;
  Color? _baseColor;
  int _loadGeneration = 0;
  Brightness? _scheduledBrightness;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Brightness brightness = Theme.of(context).brightness;
    if (_scheduledBrightness != brightness) {
      _scheduledBrightness = brightness;
      _scheduleColorLoad(brightness);
    }
  }

  @override
  void didUpdateWidget(covariant PlayerDynamicBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coverUrl?.trim() != widget.coverUrl?.trim()) {
      _scheduleColorLoad(_scheduledBrightness ?? Theme.of(context).brightness);
    }
  }

  void _scheduleColorLoad(Brightness brightness) {
    final int generation = ++_loadGeneration;
    final String resolvedUrl = widget.coverUrl?.trim() ?? '';
    _loadedUrl = resolvedUrl;

    final Color? cachedColor = _colorCache[resolvedUrl];
    if (cachedColor != null) {
      _setBaseColor(cachedColor);
      return;
    }

    if (resolvedUrl.isEmpty) {
      _setBaseColor(null);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(_extractDelay);
      if (!mounted || generation != _loadGeneration) {
        return;
      }
      await _loadColor(resolvedUrl, generation, brightness);
    });
  }

  Future<void> _loadColor(
    String resolvedUrl,
    int generation,
    Brightness brightness,
  ) async {
    final Color? cachedColor = _colorCache[resolvedUrl];
    if (cachedColor != null) {
      _setBaseColor(cachedColor);
      return;
    }

    try {
      // final ColorScheme imageColorScheme = await ColorScheme.fromImageProvider(
      //   provider: CachedNetworkImageProvider(
      //     resolvedUrl,
      //     cacheManager: CacheUtil.imageCacheManager,
      //   ),
      //   brightness: brightness,
      // );
      final imageColorScheme = await FluidPaletteExtractor.extractColors(
        CachedNetworkImageProvider(
          resolvedUrl,
          cacheManager: CacheUtil.imageCacheManager,
          maxWidth: _paletteCacheExtent,
          maxHeight: _paletteCacheExtent,
        ),
        count: 5, // 1–10, default 5
      );
      final Color extractedColor = imageColorScheme[0];
      _rememberColor(resolvedUrl, extractedColor);
      if (!mounted ||
          generation != _loadGeneration ||
          _loadedUrl != resolvedUrl) {
        return;
      }
      _setBaseColor(extractedColor);
    } on Object {
      if (!mounted ||
          generation != _loadGeneration ||
          _loadedUrl != resolvedUrl) {
        return;
      }
      _setBaseColor(null);
    }
  }

  void _setBaseColor(Color? color) {
    if (!mounted || _baseColor == color) {
      return;
    }
    setState(() {
      _baseColor = color;
    });
  }

  void _rememberColor(String url, Color color) {
    _colorCache[url] = color;
    if (_colorCache.length <= _maxColorCacheEntries) {
      return;
    }

    _colorCache.remove(_colorCache.keys.first);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color baseColor = _baseColor ?? colorScheme.primary;
    final _BackdropColors colors = _BackdropColors.from(
      baseColor: baseColor,
      colorScheme: colorScheme,
      brightness: theme.brightness,
    );

    return IgnorePointer(
      child: RepaintBoundary(
        child: TweenAnimationBuilder<_BackdropColors>(
          tween: _BackdropColorsTween(end: colors),
          duration: _colorTransitionDuration,
          curve: Curves.easeOutCubic,
          builder:
              (
                BuildContext context,
                _BackdropColors animatedColors,
                Widget? child,
              ) {
                return _BackdropLayer(
                  colors: animatedColors,
                  colorScheme: colorScheme,
                  variant: widget.variant,
                );
              },
        ),
      ),
    );
  }
}

class _BackdropColorsTween extends Tween<_BackdropColors> {
  _BackdropColorsTween({required _BackdropColors end}) : super(end: end);

  @override
  _BackdropColors lerp(double t) {
    final _BackdropColors? beginColors = begin;
    final _BackdropColors? endColors = end;

    if (beginColors == null || endColors == null) {
      return endColors ?? beginColors!;
    }

    return _BackdropColors.lerp(beginColors, endColors, t);
  }
}

class _BackdropLayer extends StatelessWidget {
  const _BackdropLayer({
    required this.colors,
    required this.colorScheme,
    required this.variant,
  });

  final _BackdropColors colors;
  final ColorScheme colorScheme;
  final PlayerBackdropVariant variant;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[colors.top, colors.center, colors.bottom],
          stops: const <double>[0, 0.58, 1],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _BackdropGlow(
            alignment: variant == PlayerBackdropVariant.desktop
                ? const Alignment(-0.42, -0.08)
                : const Alignment(-0.34, -0.28),
            color: colors.glow,
            widthFactor: variant == PlayerBackdropVariant.desktop ? 0.52 : 0.64,
            heightFactor: variant == PlayerBackdropVariant.desktop
                ? 0.72
                : 0.42,
            opacity: variant == PlayerBackdropVariant.desktop ? 0.24 : 0.20,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  colorScheme.surface.withValues(alpha: 0.06),
                  colorScheme.surface.withValues(alpha: 0.34),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackdropGlow extends StatelessWidget {
  const _BackdropGlow({
    required this.alignment,
    required this.color,
    required this.widthFactor,
    required this.heightFactor,
    required this.opacity,
  });

  final Alignment alignment;
  final Color color;
  final double widthFactor;
  final double heightFactor;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Align(
          alignment: alignment,
          child: Container(
            width: constraints.maxWidth * widthFactor,
            height: constraints.maxHeight * heightFactor,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: <Color>[
                  color.withValues(alpha: opacity),
                  color.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BackdropColors {
  const _BackdropColors({
    required this.top,
    required this.center,
    required this.bottom,
    required this.glow,
    required this.accent,
  });

  final Color top;
  final Color center;
  final Color bottom;
  final Color glow;
  final Color accent;

  @override
  int get hashCode => Object.hash(top, center, bottom, glow, accent);

  @override
  bool operator ==(Object other) {
    return other is _BackdropColors &&
        other.top == top &&
        other.center == center &&
        other.bottom == bottom &&
        other.glow == glow &&
        other.accent == accent;
  }

  static _BackdropColors lerp(_BackdropColors a, _BackdropColors b, double t) {
    return _BackdropColors(
      top: Color.lerp(a.top, b.top, t) ?? b.top,
      center: Color.lerp(a.center, b.center, t) ?? b.center,
      bottom: Color.lerp(a.bottom, b.bottom, t) ?? b.bottom,
      glow: Color.lerp(a.glow, b.glow, t) ?? b.glow,
      accent: Color.lerp(a.accent, b.accent, t) ?? b.accent,
    );
  }

  factory _BackdropColors.from({
    required Color baseColor,
    required ColorScheme colorScheme,
    required Brightness brightness,
  }) {
    final bool isDark = brightness == Brightness.dark;
    final HSLColor hsl = HSLColor.fromColor(baseColor);
    final Color top = _blend(
      hsl
          .withSaturation(
            _clampSaturation(hsl.saturation, isDark ? 0.32 : 0.34),
          )
          .withLightness(isDark ? 0.13 : 0.90)
          .toColor(),
      colorScheme.surface,
      isDark ? 0.14 : 0.10,
    );
    final Color center = _blend(
      hsl
          .withSaturation(
            _clampSaturation(hsl.saturation, isDark ? 0.28 : 0.30),
          )
          .withLightness(isDark ? 0.16 : 0.88)
          .toColor(),
      colorScheme.surface,
      isDark ? 0.20 : 0.18,
    );
    final Color bottom = _blend(
      hsl
          .withSaturation(
            _clampSaturation(hsl.saturation, isDark ? 0.18 : 0.18),
          )
          .withLightness(isDark ? 0.11 : 0.94)
          .toColor(),
      colorScheme.surface,
      isDark ? 0.32 : 0.42,
    );
    final Color glow = hsl
        .withSaturation(_clampSaturation(hsl.saturation, isDark ? 0.45 : 0.42))
        .withLightness(isDark ? 0.28 : 0.78)
        .toColor();
    final Color accent = hsl
        .withSaturation(_clampSaturation(hsl.saturation, isDark ? 0.58 : 0.54))
        .withLightness(isDark ? 0.54 : 0.64)
        .toColor();

    return _BackdropColors(
      top: top,
      center: center,
      bottom: bottom,
      glow: glow,
      accent: accent,
    );
  }

  static double _clampSaturation(double value, double target) {
    return value.clamp(0.18, target).toDouble();
  }

  static Color _blend(Color color, Color surface, double surfaceOpacity) {
    return Color.lerp(color, surface, surfaceOpacity) ?? color;
  }
}
