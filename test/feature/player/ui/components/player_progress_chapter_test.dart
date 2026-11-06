import 'package:bilimusic/feature/player/domain/playback_chapter.dart';
import 'package:bilimusic/feature/player/logic/chapters/playback_chapter_parser.dart';
import 'package:bilimusic/feature/player/ui/components/player_controls.dart';
import 'package:bilimusic/feature/player/ui/components/player_chapter_markers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final List<PlaybackChapter> chapters =
      PlaybackChapterParser.normalize(<PlaybackChapter>[
        const PlaybackChapter(start: Duration.zero, title: '夜曲'),
        const PlaybackChapter(start: Duration(minutes: 2), title: '晴天'),
      ]);

  Future<void> pumpProgress(
    WidgetTester tester, {
    required List<PlaybackChapter> chapters,
    Duration position = const Duration(minutes: 2, seconds: 30),
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: PlayerProgressSection(
                position: position,
                duration: const Duration(minutes: 5),
                isReady: true,
                chapters: chapters,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('keeps time labels and markers without the chapter title', (
    WidgetTester tester,
  ) async {
    await pumpProgress(tester, chapters: chapters);

    expect(find.text('晴天'), findsNothing);
    expect(find.text('夜曲'), findsNothing);
    expect(find.byType(ChapterMarkers), findsOneWidget);
    expect(find.text('02:30'), findsOneWidget);
    expect(find.text('05:00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hides the chapter title when chapters are unavailable', (
    WidgetTester tester,
  ) async {
    await pumpProgress(tester, chapters: const <PlaybackChapter>[]);

    expect(find.text('晴天'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
