import 'dart:io';

import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/logic/favorite_entry_metadata.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorite_metadata_tile.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/player/data/chapter_cache_repository.dart';
import 'package:bilimusic/feature/player/domain/playback_chapter.dart';
import 'package:bilimusic/feature/statistics/data/statistics_local_repository.dart';
import 'package:bilimusic/feature/statistics/logic/statistics_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

late Box<Map> _box;

void main() {
  setUpAll(() {
    Hive.init(Directory.systemTemp.path);
  });

  setUp(() async {
    _box = await Hive.openBox<Map>('favorite_metadata_tile_test');
    await _box.clear();
    await Hive.openBox<String>(chapterCacheBoxName);
    await Hive.box<String>(chapterCacheBoxName).clear();
  });

  tearDown(() async {
    await _box.close();
    await Hive.box<String>(chapterCacheBoxName).close();
  });

  testWidgets('renders metadata title and artist without lyric tag', (
    WidgetTester tester,
  ) async {
    await _pumpTile(
      tester,
      metadata: const Metadata(
        stableId: 'bvid:BV1:cid:1',
        title: '晴天',
        artist: '周杰伦',
        lyrics: '[00:00.000] 歌词',
      ),
    );

    expect(find.text('晴天'), findsOneWidget);
    expect(find.text('周杰伦'), findsOneWidget);
    expect(find.text('词'), findsNothing);
    expect(find.text('未解析'), findsNothing);
  });

  testWidgets('falls back to entry fields and marks unresolved', (
    WidgetTester tester,
  ) async {
    await _pumpTile(tester, metadata: null);

    expect(find.text('视频标题'), findsOneWidget);
    expect(find.text('UP主'), findsOneWidget);
    expect(find.text('未解析'), findsOneWidget);
  });

  testWidgets('compilation ignores an old single-song match', (
    WidgetTester tester,
  ) async {
    await _pumpTile(
      tester,
      title: '周杰伦歌曲合集',
      metadata: const Metadata(
        stableId: 'bvid:BV1:cid:1',
        title: '晴天',
        artist: '周杰伦',
        albumArtUrl: 'https://img.example.com/wrong.jpg',
      ),
    );

    expect(find.text('周杰伦歌曲合集'), findsOneWidget);
    expect(find.text('UP主'), findsOneWidget);
    expect(find.text('晴天'), findsNothing);
    expect(find.text('未解析'), findsNothing);
    expect(
      tester.widget<CommonCachedImage>(find.byType(CommonCachedImage)).imageUrl,
      'https://img.example.com/video.jpg',
    );
  });

  testWidgets(
    'new cached chapters replace an old match without title keywords',
    (WidgetTester tester) async {
      await _pumpTile(
        tester,
        metadata: const Metadata(
          stableId: 'bvid:BV1:cid:1',
          title: '晴天',
          artist: '周杰伦',
          albumArtUrl: 'https://img.example.com/wrong.jpg',
        ),
      );
      expect(find.text('晴天'), findsOneWidget);
      await tester.runAsync(() async {
        await ChapterCacheRepository(
          Hive.box<String>(chapterCacheBoxName),
        ).putChapters('bvid:BV1:page:1', const <PlaybackChapter>[
          PlaybackChapter(start: Duration.zero, title: '第一首'),
          PlaybackChapter(start: Duration(minutes: 3), title: '第二首'),
        ]);
      });
      await tester.pumpAndSettle();
      expect(find.text('视频标题'), findsOneWidget);
      expect(find.text('UP主'), findsOneWidget);
      expect(find.text('晴天'), findsNothing);
      expect(find.text('未解析'), findsNothing);
      expect(
        tester
            .widget<CommonCachedImage>(find.byType(CommonCachedImage))
            .imageUrl,
        'https://img.example.com/video.jpg',
      );
    },
  );

  testWidgets('play and more callbacks fire', (WidgetTester tester) async {
    int playCount = 0;
    int moreCount = 0;
    await _pumpTile(
      tester,
      metadata: null,
      onPlay: () => playCount++,
      onMore: () => moreCount++,
    );

    await tester.tap(find.byTooltip('播放'));
    await tester.tap(find.byTooltip('更多'));
    await tester.pump();

    expect(playCount, 1);
    expect(moreCount, 1);
  });
}

Future<void> _pumpTile(
  WidgetTester tester, {
  required Metadata? metadata,
  String title = '视频标题',
  VoidCallback? onPlay,
  VoidCallback? onMore,
}) async {
  final FavoriteEntry entry = FavoriteEntry(
    itemId: 'bvid:BV1:cid:1',
    aid: 1,
    bvid: 'BV1',
    title: title,
    author: 'UP主',
    coverUrl: 'https://img.example.com/video.jpg',
    page: 1,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        favoriteEntryMetadataProvider(
          entry.contentId,
        ).overrideWith((ref) async => metadata),
        statisticsTrackerProvider.overrideWithValue(
          StatisticsTracker(
            const Stream.empty(),
            StatisticsLocalRepository(_box),
          ),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: FavoriteMetadataTile(
            entry: entry,
            selected: false,
            onTap: () {},
            onLongPress: () {},
            onPlay: onPlay ?? () {},
            onMore: onMore ?? () {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
