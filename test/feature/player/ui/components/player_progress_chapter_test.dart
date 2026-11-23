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
    ValueChanged<double>? onChanged,
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
                onChanged: onChanged ?? (_) {},
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

  testWidgets('drag snaps visually, releases when moved away and seeks once', (
    WidgetTester tester,
  ) async {
    final List<double> seeks = <double>[];
    await pumpProgress(tester, chapters: chapters, onChanged: seeks.add);
    final Rect rect = tester.getRect(find.byType(Slider));
    Offset at(double ratio) =>
        Offset(rect.left + 3 + (rect.width - 6) * ratio, rect.center.dy);
    final TestGesture gesture = await tester.startGesture(at(0.5));
    await gesture.moveTo(at(0.405));
    await tester.pump();
    expect(tester.widget<Slider>(find.byType(Slider)).value, 0.4);
    expect(find.text('02:00'), findsOneWidget);
    expect(seeks, isEmpty);
    await gesture.moveTo(at(0.46));
    await tester.pump();
    expect(
      tester.widget<Slider>(find.byType(Slider)).value,
      closeTo(0.46, 0.001),
    );
    await gesture.moveTo(at(0.395));
    await tester.pump();
    expect(tester.widget<Slider>(find.byType(Slider)).value, 0.4);
    await gesture.up();
    await tester.pump();
    expect(seeks, <double>[0.4]);
    expect(tester.widget<Slider>(find.byType(Slider)).value, 0.4);
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);
  });

  testWidgets('progress without chapters keeps continuous seeking', (
    WidgetTester tester,
  ) async {
    final List<double> seeks = <double>[];
    await pumpProgress(
      tester,
      chapters: const <PlaybackChapter>[],
      onChanged: seeks.add,
    );
    final Slider slider = tester.widget(find.byType(Slider));
    slider.onChangeStart!(0.405);
    slider.onChanged!(0.405);
    slider.onChangeEnd!(0.405);
    await tester.pump();
    expect(seeks, <double>[0.405]);
    expect(tester.widget<Slider>(find.byType(Slider)).value, 0.405);
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('hides the chapter title when chapters are unavailable', (
    WidgetTester tester,
  ) async {
    await pumpProgress(tester, chapters: const <PlaybackChapter>[]);

    expect(find.text('晴天'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
