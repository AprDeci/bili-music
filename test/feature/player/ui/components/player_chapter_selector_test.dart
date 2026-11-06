import 'package:bilimusic/feature/player/domain/playback_chapter.dart';
import 'package:bilimusic/feature/player/logic/chapters/playback_chapter_parser.dart';
import 'package:bilimusic/feature/player/ui/components/player_chapter_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final List<PlaybackChapter> chapters =
      PlaybackChapterParser.normalize(<PlaybackChapter>[
        const PlaybackChapter(start: Duration.zero, title: '夜曲'),
        const PlaybackChapter(start: Duration(seconds: 100), title: '晴天'),
        const PlaybackChapter(start: Duration(seconds: 200), title: '稻香'),
      ]);

  testWidgets('shows timeline rows and seeks to the tapped chapter', (
    WidgetTester tester,
  ) async {
    Duration? seeked;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) => TextButton(
              onPressed: () => showPlayerChapterSelector(
                context: context,
                chapters: chapters,
                position: const Duration(seconds: 70),
                isPlaying: false,
                onSeek: (Duration value) => seeked = value,
              ),
              child: const Text('打开时间轴'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开时间轴'));
    await tester.pumpAndSettle();

    expect(find.text('时间轴'), findsOneWidget);
    expect(find.byTooltip('下载本视频'), findsNothing);
    expect(find.text('3 首'), findsOneWidget);
    expect(find.text('夜曲'), findsOneWidget);
    expect(find.text('01:40'), findsOneWidget);
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('chapter-selector-0')))
          .height,
      56,
    );

    await tester.tap(find.text('晴天'));
    await tester.pumpAndSettle();

    expect(seeked, const Duration(seconds: 100));
    expect(find.text('时间轴'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('highlights the chapter under the given position', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) => TextButton(
              onPressed: () => showPlayerChapterSelector(
                context: context,
                chapters: chapters,
                position: const Duration(seconds: 150),
                isPlaying: false,
                onSeek: (_) {},
              ),
              child: const Text('打开时间轴'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开时间轴'));
    await tester.pumpAndSettle();

    final ColorScheme colorScheme = Theme.of(
      tester.element(find.text('晴天')),
    ).colorScheme;
    expect(
      tester.widget<Text>(find.text('晴天')).style?.color,
      colorScheme.primary,
    );
    expect(
      tester.widget<Text>(find.text('夜曲')).style?.color,
      colorScheme.onSurface,
    );
    expect(
      tester.widget<Text>(find.text('稻香')).style?.color,
      colorScheme.onSurface,
    );
  });
}
