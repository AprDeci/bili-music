import 'dart:io';

import 'package:bilimusic/core/hive/hive_adapters.dart';
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
    box = await Hive.openBox<RecentPlaybackEntry>(recentPlaybackBoxName);
    repository = RecentPlaybackLocalRepository(box);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk(recentPlaybackBoxName);
    await Hive.close();
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

  test('saveEntry truncates to recent 10 items', () async {
    for (int index = 0; index < 12; index++) {
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

    expect(result, hasLength(10));
    expect(result.first.title, 'item 11');
    expect(result.last.title, 'item 2');
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
