import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/playback_chapter.dart';
import 'package:bilimusic/feature/player/logic/chapters/playback_chapter_parser.dart';
import 'package:bilimusic/feature/player/logic/utils/player_ui_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const PlayableItem item = PlayableItem(
    aid: 1,
    bvid: 'BV1',
    cid: 10,
    page: 1,
    pageTitle: 'P1',
    title: '合集',
    author: 'UP',
    coverUrl: '',
  );

  List<PlaybackChapter> buildChapters(List<int> starts) {
    return PlaybackChapterParser.normalize(<PlaybackChapter>[
      for (int index = 0; index < starts.length; index += 1)
        PlaybackChapter(
          start: Duration(seconds: starts[index]),
          title: '歌曲 ${index + 1}',
        ),
    ]);
  }

  test('resolveChapterIndex maps position to chapter', () {
    final List<PlaybackChapter> chapters = buildChapters(<int>[0, 100, 200]);

    expect(resolveChapterIndex(chapters, Duration.zero), 0);
    expect(resolveChapterIndex(chapters, const Duration(seconds: 99)), 0);
    expect(resolveChapterIndex(chapters, const Duration(seconds: 100)), 1);
    expect(resolveChapterIndex(chapters, const Duration(seconds: 250)), 2);
    expect(
      resolveChapterIndex(const <PlaybackChapter>[], Duration.zero),
      isNull,
    );
  });

  test('formatJumpBadge prefers chapter index when chapters exist', () {
    final List<PlaybackChapter> chapters = buildChapters(<int>[0, 100, 200]);

    expect(
      formatJumpBadge(
        item: item,
        chapters: chapters,
        position: const Duration(seconds: 120),
      ),
      '2',
    );
    expect(
      formatJumpBadge(
        item: item,
        chapters: const <PlaybackChapter>[],
        position: Duration.zero,
      ),
      'P1',
    );
    expect(
      formatJumpBadge(item: null, chapters: chapters, position: Duration.zero),
      isNull,
    );
  });

  test('resolveChapterTickRatios maps starts onto the timeline', () {
    final List<PlaybackChapter> chapters = buildChapters(<int>[0, 100, 200]);
    final List<double> ratios = resolveChapterTickRatios(
      chapters,
      const Duration(seconds: 400),
    );

    expect(ratios.length, 3);
    expect(ratios[0], 0);
    expect(ratios[1], 0.25);
    expect(ratios[2], 0.5);
    expect(resolveChapterTickRatios(chapters, null), isEmpty);
    expect(
      resolveChapterTickRatios(
        chapters,
        const Duration(seconds: 400),
      ).every((double ratio) => ratio >= 0 && ratio <= 1),
      isTrue,
    );
  });

  test('resolveCurrentChapter requires at least two chapters', () {
    final List<PlaybackChapter> single = <PlaybackChapter>[
      const PlaybackChapter(start: Duration.zero, title: '只有一首'),
    ];
    expect(resolveCurrentChapter(single, const Duration(seconds: 10)), isNull);

    final List<PlaybackChapter> chapters = buildChapters(<int>[0, 100]);
    expect(
      resolveCurrentChapter(chapters, const Duration(seconds: 110))?.title,
      '歌曲 2',
    );
  });
}
