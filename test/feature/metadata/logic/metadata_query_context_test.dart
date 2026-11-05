import 'package:bilimusic/feature/metadata/logic/metadata_query_context.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/playback_chapter.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:flutter_test/flutter_test.dart';

const PlayableItem _item = PlayableItem(
  aid: 1,
  bvid: 'BV1',
  cid: 10,
  page: 1,
  title: '一小时合集',
  author: 'UP',
  coverUrl: '',
);

const List<PlaybackChapter> _chapters = <PlaybackChapter>[
  PlaybackChapter(start: Duration.zero, title: '夜曲'),
  PlaybackChapter(start: Duration(minutes: 2), title: '晴天'),
];

void main() {
  test('prefers the chapter containing the current position', () {
    final MetadataQueryContext context = MetadataQueryContext.fromState(
      item: _item,
      state: const PlayerState(
        currentItem: _item,
        position: Duration(minutes: 3),
        chapters: _chapters,
      ),
    );

    expect(context.defaultKeyword, '晴天');
    expect(context.titles, <String>['晴天']);
    expect(context.chapterStartMs, 120000);
    expect(context.hasChapter, isTrue);
    expect(context.lyricBaseOffsetMs, -120000);
  });

  test('falls back to the video title when there are no chapters', () {
    final MetadataQueryContext context = MetadataQueryContext.fromState(
      item: _item,
      state: const PlayerState(currentItem: _item),
    );

    expect(context.titles, <String>['一小时合集']);
    expect(context.hasChapter, isFalse);
    expect(context.lyricBaseOffsetMs, 0);
  });

  test('uses the page title for multi part videos', () {
    final PlayableItem part = _item.copyWith(pageTitle: '第一首');
    final MetadataQueryContext context = MetadataQueryContext.fromState(
      item: part,
      state: PlayerState(
        currentItem: part,
        availableParts: <PlayableItem>[part, part.copyWith(cid: 11, page: 2)],
      ),
    );

    expect(context.titles, <String>['第一首', '一小时合集']);
    expect(context.chapterStartMs, isNull);
  });

  test('ignores position changes inside the same chapter', () {
    final MetadataQueryContext first = MetadataQueryContext.fromState(
      item: _item,
      state: const PlayerState(
        currentItem: _item,
        position: Duration(seconds: 10),
        chapters: _chapters,
      ),
    );
    final MetadataQueryContext later = MetadataQueryContext.fromState(
      item: _item,
      state: const PlayerState(
        currentItem: _item,
        position: Duration(seconds: 90),
        chapters: _chapters,
      ),
    );

    expect(first.matches(later), isTrue);

    final MetadataQueryContext nextChapter = MetadataQueryContext.fromState(
      item: _item,
      state: const PlayerState(
        currentItem: _item,
        position: Duration(minutes: 4),
        chapters: _chapters,
      ),
    );
    expect(first.matches(nextChapter), isFalse);
  });

  test('blank chapter titles fall back to the video title', () {
    final MetadataQueryContext context = MetadataQueryContext.fromState(
      item: _item,
      state: const PlayerState(
        currentItem: _item,
        chapters: <PlaybackChapter>[
          PlaybackChapter(start: Duration.zero, title: '  '),
          PlaybackChapter(start: Duration(minutes: 2), title: '晴天'),
        ],
      ),
    );

    expect(context.hasChapter, isFalse);
    expect(context.titles, <String>['一小时合集']);
  });
}
