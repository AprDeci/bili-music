import 'dart:io';

import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/core/hive/hive_adapters.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/recent/data/recent_playback_local_repository.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDirectory;
  late Box<RecentPlaybackEntry> box;
  late RecentPlaybackLocalRepository repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'recent-playback-test-',
    );
    Hive.init(tempDirectory.path);
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(RecentPlaybackEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(CollectionKindAdapter().typeId)) {
      Hive.registerAdapter(CollectionKindAdapter());
    }
    box = await Hive.openBox<RecentPlaybackEntry>(recentPlaybackBoxName);
    repository = RecentPlaybackLocalRepository(box);
  });

  tearDown(() async {
    await Hive.close();
    final String resolvedPath = await tempDirectory.resolveSymbolicLinks();
    final String tempRoot = await Directory.systemTemp.resolveSymbolicLinks();
    expect(
      resolvedPath,
      startsWith('$tempRoot${Platform.pathSeparator}recent-playback-test-'),
    );
    await tempDirectory.delete(recursive: true);
  });

  test('saveEntry keeps latest first and deduplicates by stable id', () async {
    await repository.saveEntry(
      _entry(aid: 1, cid: 101, title: 'first', playedAt: 1),
    );
    await repository.saveEntry(
      _entry(aid: 2, cid: 201, title: 'second', playedAt: 2),
    );

    final List<RecentPlaybackEntry> result = await repository.saveEntry(
      _entry(aid: 1, cid: 101, title: 'first updated', playedAt: 3),
    );

    expect(result, hasLength(2));
    expect(result.first.title, 'first updated');
    expect(result.first.stableId, 'aid:1:cid:101');
    expect(result.last.stableId, 'aid:2:cid:201');
  });

  test('playable context and defaults survive Hive reopen', () async {
    const PlayableItem spoken = PlayableItem(
      aid: 2,
      bvid: 'BVSPOKEN',
      title: 'book',
      author: 'reader',
      coverUrl: '',
      kind: CollectionKind.spoken,
      collectionId: 'spoken-collection',
      cid: 202,
      page: 3,
      pageTitle: 'chapter three',
    );
    const RecentPlaybackEntry legacy = RecentPlaybackEntry(
      aid: 1,
      bvid: '',
      title: 'old item',
      author: 'tester',
      coverUrl: '',
      playedAtEpochMs: 1,
    );
    await repository.saveEntry(legacy);
    final RecentPlaybackEntry entry = RecentPlaybackEntry.fromPlayableItem(
      spoken,
      playedAtEpochMs: 2,
    );
    await repository.saveEntry(entry);
    await box.close();
    box = await Hive.openBox<RecentPlaybackEntry>(recentPlaybackBoxName);
    repository = RecentPlaybackLocalRepository(box);

    final List<RecentPlaybackEntry> restored = repository.load();
    expect(restored, <RecentPlaybackEntry>[entry, legacy]);
    expect(restored.first.toPlayableItem(), spoken);
    final PlayableItem oldItem = restored.last.toPlayableItem();
    expect(oldItem.kind, CollectionKind.music);
    expect(oldItem.collectionId, isNull);
    expect(oldItem.page, isNull);
  });

  test('saveEntry truncates to maxEntries items', () async {
    const int overflow = 2;
    final int count = RecentPlaybackLocalRepository.maxEntries + overflow;

    for (int index = 0; index < count; index++) {
      await repository.saveEntry(
        _entry(
          aid: index + 1,
          cid: 1000 + index,
          title: 'item $index',
          playedAt: index + 1,
        ),
      );
    }

    final List<RecentPlaybackEntry> result = repository.load();

    expect(result, hasLength(RecentPlaybackLocalRepository.maxEntries));
    expect(result.first.title, 'item ${count - 1}');
    expect(
      result.last.title,
      'item ${count - RecentPlaybackLocalRepository.maxEntries}',
    );
  });
}

RecentPlaybackEntry _entry({
  required int aid,
  required int cid,
  required String title,
  required int playedAt,
}) {
  return RecentPlaybackEntry(
    aid: aid,
    bvid: '',
    title: title,
    author: 'tester',
    coverUrl: 'https://example.com/$aid.jpg',
    cid: cid,
    playedAtEpochMs: playedAt,
  );
}
