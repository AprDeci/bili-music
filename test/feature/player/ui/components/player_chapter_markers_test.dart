import 'package:bilimusic/feature/player/domain/playback_chapter.dart';
import 'package:bilimusic/feature/player/domain/player_chapter_marker_style.dart';
import 'package:bilimusic/feature/player/ui/components/player_chapter_markers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const List<PlaybackChapter> chapters = <PlaybackChapter>[
    PlaybackChapter(start: Duration.zero, title: 'A'),
    PlaybackChapter(start: Duration(seconds: 30), title: 'B'),
    PlaybackChapter(start: Duration(seconds: 60), title: 'C'),
  ];

  Future<void> pumpMarkers(
    WidgetTester tester,
    PlayerChapterMarkerStyle style,
  ) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 24,
              child: ChapterMarkers(
                chapters: chapters,
                total: const Duration(seconds: 120),
                style: style,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  ChapterMarkerPainter painterOf(WidgetTester tester) {
    final CustomPaint paint = tester.widget<CustomPaint>(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is CustomPaint && widget.painter is ChapterMarkerPainter,
      ),
    );
    return paint.painter! as ChapterMarkerPainter;
  }

  for (final PlayerChapterMarkerStyle style
      in PlayerChapterMarkerStyle.values) {
    testWidgets('paints ${style.name} markers without errors', (
      WidgetTester tester,
    ) async {
      await pumpMarkers(tester, style);

      expect(painterOf(tester).style, style);
      expect(painterOf(tester).chapters.length, 3);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('renders nothing when the video has no chapters', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 24,
            child: ChapterMarkers(
              chapters: <PlaybackChapter>[],
              total: Duration(seconds: 120),
              style: PlayerChapterMarkerStyle.dot,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
