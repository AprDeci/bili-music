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
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (coverUrl.isNotEmpty)
                Image.network(
                  coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const PlayerArtworkFallback();
                  },
                )
              else
                const PlayerArtworkFallback(),
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
              const PlayerArtworkLiquidPattern(),
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

class PlayerArtworkLiquidPattern extends StatelessWidget {
  const PlayerArtworkLiquidPattern({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return CustomPaint(
      painter: PlayerLiquidArtworkPainter(
        darkColor: colorScheme.primary.withValues(alpha: 0.58),
        lightColor: colorScheme.primaryContainer.withValues(alpha: 0.68),
      ),
    );
  }
}

class PlayerLiquidArtworkPainter extends CustomPainter {
  PlayerLiquidArtworkPainter({
    required this.darkColor,
    required this.lightColor,
  });

  final Color darkColor;
  final Color lightColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint darkPaint = Paint()
      ..color = darkColor
      ..style = PaintingStyle.fill;

    final Paint lightPaint = Paint()
      ..color = lightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.11
      ..strokeCap = StrokeCap.round;

    final Path topWave = Path()
      ..moveTo(-size.width * 0.1, size.height * 0.2)
      ..cubicTo(
        size.width * 0.18,
        -size.height * 0.05,
        size.width * 0.52,
        size.height * 0.28,
        size.width * 0.92,
        size.height * 0.02,
      )
      ..cubicTo(
        size.width * 1.1,
        size.height * 0.16,
        size.width * 1.08,
        size.height * 0.44,
        size.width * 0.86,
        size.height * 0.5,
      )
      ..cubicTo(
        size.width * 0.56,
        size.height * 0.62,
        size.width * 0.24,
        size.height * 0.34,
        -size.width * 0.08,
        size.height * 0.48,
      )
      ..lineTo(-size.width * 0.12, -size.height * 0.08)
      ..close();

    final Path bottomWave = Path()
      ..moveTo(-size.width * 0.1, size.height * 0.82)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.56,
        size.width * 0.46,
        size.height * 1.04,
        size.width * 0.8,
        size.height * 0.78,
      )
      ..cubicTo(
        size.width * 0.98,
        size.height * 0.64,
        size.width * 1.06,
        size.height * 0.88,
        size.width * 1.08,
        size.height * 1.08,
      )
      ..lineTo(-size.width * 0.12, size.height * 1.08)
      ..close();

    canvas.drawPath(topWave, darkPaint);
    canvas.drawPath(bottomWave, darkPaint);

    final Path ribbon = Path()
      ..moveTo(-size.width * 0.02, size.height * 0.62)
      ..cubicTo(
        size.width * 0.16,
        size.height * 0.48,
        size.width * 0.42,
        size.height * 0.7,
        size.width * 0.58,
        size.height * 0.52,
      )
      ..cubicTo(
        size.width * 0.78,
        size.height * 0.28,
        size.width * 0.92,
        size.height * 0.38,
        size.width * 1.04,
        size.height * 0.22,
      );

    canvas.drawPath(ribbon, lightPaint);

    final Paint glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: <Color>[
              const Color(0xFFFFFFFF).withValues(alpha: 0.32),
              const Color(0x00FFFFFF),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.72, size.height * 0.56),
              radius: size.width * 0.34,
            ),
          );

    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.56),
      size.width * 0.34,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
