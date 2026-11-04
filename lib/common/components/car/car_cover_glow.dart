import 'package:bilimusic/feature/player/logic/display/player_cover_color_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CarCoverGlow extends ConsumerWidget {
  const CarCoverGlow({super.key, this.bottom = false});

  final bool bottom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color? coverColor = ref.watch(playerCoverColorControllerProvider);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final HSLColor hsl = HSLColor.fromColor(coverColor ?? Colors.transparent);
    final Color glow = coverColor == null
        ? Colors.transparent
        : hsl
              .withSaturation(hsl.saturation.clamp(0.0, 0.55))
              .withLightness(dark ? 0.55 : 0.70)
              .toColor()
              .withValues(alpha: dark ? 0.18 : 0.30);
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: bottom
                ? LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: const <double>[0, 0.18, 0.58],
                    colors: <Color>[
                      glow,
                      glow.withValues(alpha: glow.a * 0.65),
                      glow.withValues(alpha: 0),
                    ],
                  )
                : RadialGradient(
                    center: const Alignment(-1.0, 1.0),
                    radius: 1.1,
                    colors: <Color>[glow, glow.withValues(alpha: 0)],
                  ),
          ),
        ),
      ),
    );
  }
}
