import 'package:bilimusic/common/components/cached_image.dart';
import 'package:flutter/material.dart';

double playerArtworkSize(Size screenSize) {
  final double height = screenSize.longestSide;
  return height < 600
      ? (height * 0.27).clamp(150.0, 190.0)
      : (height * 0.31).clamp(190.0, 320.0);
}

class PlayerArtworkFrame extends StatelessWidget {
  const PlayerArtworkFrame({
    super.key,
    required this.coverUrl,
    this.borderRadius = 8,
    this.fallback = const PlayerArtworkFallback(),
  });

  final String coverUrl;
  final double borderRadius;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              CommonCachedImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
                placeholder: fallback,
                errorWidget: fallback,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayerArtworkFallback extends StatelessWidget {
  const PlayerArtworkFallback({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[colorScheme.primary, colorScheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.music_note_rounded, size: 84, color: Colors.white),
      ),
    );
  }
}
