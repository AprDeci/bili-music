import 'dart:convert';
import 'dart:io';

import 'package:bilimusic/core/cache/cache_util.dart';
import 'package:bilimusic/core/hive/hive_adapters.dart';
import 'package:bilimusic/feature/metadata/data/metadata_cache_repository.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/player/data/chapter_cache_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/playback_chapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory directory;
  late Box<String> box;
  late ChapterCacheRepository cache;
  const PlayableItem item = PlayableItem(
    aid: 1,
    bvid: 'BV1',
    title: '视频',
    author: 'UP',
    coverUrl: '',
  );
  const List<PlaybackChapter> chapters = <PlaybackChapter>[
    PlaybackChapter(start: Duration.zero, title: '第一首'),
    PlaybackChapter(start: Duration(minutes: 3), title: '第二首'),
  ];

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('chapter_cache_');
    Hive.init(directory.path);
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(MetadataAdapter());
    }
    box = await Hive.openBox<String>(chapterCacheBoxName);
    cache = ChapterCacheRepository(box);
    await Hive.openLazyBox<Metadata>(metadataCacheBoxName);
  });
  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test(
    'chapters take priority and missing or single chapters use the title',
    () async {
      expect(cache.isCompilation(item), isFalse);
      expect(cache.isCompilation(item.copyWith(title: '歌曲合集')), isTrue);
      expect(
        cache.isCompilation(item.copyWith(title: '歌曲合集', pageTitle: '单曲')),
        isFalse,
      );
      await cache.putChapters(item.contentId, chapters.take(1).toList());
      expect(box.isEmpty, isTrue);
      await cache.putChapters(item.contentId, chapters);
      expect(cache.isCompilation(item.copyWith(pageTitle: '单曲')), isTrue);
      expect(cache.isCompilation(item.copyWith(page: 2)), isFalse);
    },
  );

  test('metadata cache size and clearing include persisted chapters', () async {
    await cache.putChapters(item.contentId, chapters);
    expect(
      await CacheUtil.getMetadataCacheSizeBytes(),
      utf8.encode(box.get(item.contentId)!).length,
    );
    await CacheUtil.clearMetadataCache();
    expect(cache.getChapters(item.contentId), isEmpty);
    expect(await CacheUtil.getMetadataCacheSizeBytes(), 0);
  });
}
