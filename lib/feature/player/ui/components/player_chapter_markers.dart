import 'package:bilimusic/feature/player/domain/playback_chapter.dart';
import 'package:bilimusic/feature/player/domain/player_chapter_marker_style.dart';
import 'package:bilimusic/feature/player/logic/utils/player_ui_helpers.dart';
import 'package:flutter/material.dart';

class ChapterMarkers extends StatelessWidget {
  const ChapterMarkers({
    super.key,
    required this.chapters,
    required this.total,
    required this.style,
    required this.color,
  });

  final List<PlaybackChapter> chapters;
  final Duration? total;
  final PlayerChapterMarkerStyle style;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ChapterMarkerPainter(
        chapters: chapters,
        total: total,
        style: style,
        color: color,
      ),
    );
  }
}

class ChapterMarkerPainter extends CustomPainter {
  const ChapterMarkerPainter({
    required this.chapters,
    required this.total,
    required this.style,
    required this.color,
  });

  final List<PlaybackChapter> chapters;
  final Duration? total;
  final PlayerChapterMarkerStyle style;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final List<double> ratios = resolveChapterTickRatios(chapters, total);
    if (ratios.isEmpty || size.width <= 0 || size.height <= 0) {
      return;
    }

    const double edgeInset = 3;
    final double trackWidth = size.width - edgeInset * 2;
    if (trackWidth <= 0) {
      return;
    }

    final Paint paint = Paint()
      ..color = color
      ..isAntiAlias = true;
    final double centerY = size.height / 2;

    switch (style) {
      case PlayerChapterMarkerStyle.line:
        paint
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.round;
        final double top = size.height * 0.34;
        final double bottom = size.height * 0.66;
        for (final double ratio in ratios) {
          final double x = edgeInset + trackWidth * ratio;
          canvas.drawLine(Offset(x, top), Offset(x, bottom), paint);
        }
      case PlayerChapterMarkerStyle.dot:
        final double radius = (size.height * 0.05).clamp(1.6, 2.6);
        for (final double ratio in ratios) {
          final double x = edgeInset + trackWidth * ratio;
          canvas.drawCircle(Offset(x, centerY), radius, paint);
        }
    }
  }

  @override
  bool shouldRepaint(covariant ChapterMarkerPainter oldDelegate) {
    return oldDelegate.chapters != chapters ||
        oldDelegate.total != total ||
        oldDelegate.style != style ||
        oldDelegate.color != color;
  }
}
