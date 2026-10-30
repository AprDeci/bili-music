import 'dart:io';

import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/core/hive/hive_adapters.dart';
import 'package:bilimusic/feature/player/data/player_queue_local_repository.dart';
import 'package:bilimusic/feature/player/domain/persisted_playback_queue.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDirectory;
  late Box<PersistedPlaybackQueue> box;
  late PlayerQueueLocalRepository repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('player-queue-test-');
    Hive.init(tempDirectory.path);
    if (!Hive.isAdapterRegistered(PersistedPlayableItemAdapter().typeId)) {
      Hive.registerAdapter(PersistedPlayableItemAdapter());
    }
    if (!Hive.isAdapterRegistered(PersistedPlaybackQueueAdapter().typeId)) {
      Hive.registerAdapter(PersistedPlaybackQueueAdapter());
    }
    if (!Hive.isAdapterRegistered(PlayerQueueModeAdapter().typeId)) {
      Hive.registerAdapter(PlayerQueueModeAdapter());
    }
    if (!Hive.isAdapterRegistered(CollectionKindAdapter().typeId)) {
      Hive.registerAdapter(CollectionKindAdapter());
    }
    box = await Hive.openBox<PersistedPlaybackQueue>(
      playerQueueSnapshotBoxName,
    );
    repository = PlayerQueueLocalRepository(box);
  });

  tearDown(() async {
    await Hive.close();
    final String resolvedPath = await tempDirectory.resolveSymbolicLinks();
    final String tempRoot = await Directory.systemTemp.resolveSymbolicLinks();
    expect(
      resolvedPath,
      startsWith('$tempRoot${Platform.pathSeparator}player-queue-test-'),
    );
    await tempDirectory.delete(recursive: true);
  });

  test('mixed queue context and defaults survive Hive reopen', () async {
    const List<PlayableItem> items = <PlayableItem>[
      PlayableItem(
        aid: 1,
        bvid: 'BVMUSIC',
        title: 'song',
        author: 'musician',
        coverUrl: '',
        kind: CollectionKind.music,
        collectionId: 'music-collection',
        cid: 101,
        page: 2,
        pageTitle: 'track two',
      ),
      PlayableItem(
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
      ),
      PlayableItem(
        aid: 3,
        bvid: 'BVDEFAULT',
        title: 'old item',
        author: 'tester',
        coverUrl: '',
      ),
    ];
    final PersistedPlaybackQueue snapshot = PersistedPlaybackQueue(
      queue: items.map(PersistedPlayableItem.fromPlayableItem).toList(),
      currentQueueIndex: 1,
      queueSourceLabel: 'mixed queue',
      resumePositionMs: 42000,
    );
    await repository.save(snapshot);
    await box.close();
    box = await Hive.openBox<PersistedPlaybackQueue>(
      playerQueueSnapshotBoxName,
    );
    repository = PlayerQueueLocalRepository(box);

    final PersistedPlaybackQueue restored = repository.load()!;
    expect(restored, snapshot);
    expect(restored.queue.map((item) => item.toPlayableItem()), items);
    expect(restored.queue.last.kind, CollectionKind.music);
    expect(restored.queue.last.collectionId, isNull);
    expect(restored.queue.last.page, isNull);
  });
}
