import 'package:bilimusic/feature/player/domain/playback_chapter.dart';
import 'package:bilimusic/feature/player/ui/components/player_chapter_markers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const List<PlaybackChapter> chapters = <PlaybackChapter>[
    PlaybackChapter(start: Duration.zero, title: 'A'),
    PlaybackChapter(start: Duration(seconds: 30), title: 'B'),
    PlaybackChapter(start: Duration(seconds: 60), title: 'C'),
  ];
  const ChapterMarkerPainter painter = ChapterMarkerPainter(
    chapters: chapters,
    total: Duration(seconds: 120),
    color: Colors.black,
  );

  for (final double height in <double>[24, 48]) {
    test('paints only small dots at chapter starts at height $height', () {
      void paint(Canvas canvas) => painter.paint(canvas, Size(200, height));

      expect(
        paint,
        paints
          ..circle(x: 3, y: height / 2, radius: 1.2, color: Colors.black)
          ..circle(x: 51.5, y: height / 2, radius: 1.2)
          ..circle(x: 100, y: height / 2, radius: 1.2),
      );
      expect(paint, paintsExactlyCountTimes(#drawCircle, 3));
      expect(paint, paintsExactlyCountTimes(#drawLine, 0));
    });
  }

  test('paints nothing without chapters', () {
    const ChapterMarkerPainter emptyPainter = ChapterMarkerPainter(
      chapters: <PlaybackChapter>[],
      total: Duration(seconds: 120),
      color: Colors.black,
    );
    expect(
      (Canvas canvas) => emptyPainter.paint(canvas, const Size(200, 48)),
      paintsNothing,
    );
  });

  test('paints nothing without duration or usable space', () {
    const ChapterMarkerPainter unknownDuration = ChapterMarkerPainter(
      chapters: chapters,
      total: null,
      color: Colors.black,
    );
    expect(
      (Canvas canvas) => unknownDuration.paint(canvas, const Size(200, 48)),
      paintsNothing,
    );
    for (final Size size in <Size>[Size.zero, const Size(6, 48)]) {
      expect((Canvas canvas) => painter.paint(canvas, size), paintsNothing);
    }
  });
}
