import 'package:bilimusic/common/components/cachedImage.dart';
import 'package:flutter/material.dart';

class PlayerArtworkFrame extends StatelessWidget {
  const PlayerArtworkFrame({super.key, required this.coverUrl});

  final String coverUrl;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.16),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              CommonCachedImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
                placeholder: const PlayerArtworkFallback(),
                errorWidget: const PlayerArtworkFallback(),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      colorScheme.primary.withValues(alpha: 0.78),
                      const Color(0x00000000),
                      colorScheme.primaryContainer.withValues(alpha: 0.44),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const <double>[0, 0.55, 1],
                  ),
                ),
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
