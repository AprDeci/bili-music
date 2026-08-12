import 'dart:io';

import 'package:bilimusic/core/hive/hive_adapters.dart';
import 'package:bilimusic/feature/metadata/data/metadata_cache_repository.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDirectory;
  late LazyBox<Metadata> box;
  late MetadataCacheRepository repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'metadata-cache-test-',
    );
    Hive.init(tempDirectory.path);
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(MetadataAdapter());
    }
    box = await Hive.openLazyBox<Metadata>(metadataCacheBoxName);
    repository = MetadataCacheRepository(box);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk(metadataCacheBoxName);
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('cache key uses shared content identity', () {
    final PlayableItem withCid = _item(cid: 10, page: null);
    final PlayableItem withoutCid = _item(cid: null, page: 1);

    expect(repository.buildCacheKey(item: withCid), 'metadata:bvid:BV1:page:1');
    expect(
      repository.buildCacheKey(item: withCid),
      repository.buildCacheKey(item: withoutCid),
    );
  });

  test('reads metadata after cid is lost and normalizes stable id', () async {
    final PlayableItem withCid = _item(cid: 10, page: null);
    final PlayableItem withoutCid = _item(cid: null, page: 1);
    await repository.putCachedMetadata(
      item: withCid,
      metadata: Metadata(stableId: withCid.stableId, title: 'Cached title'),
    );

    final Metadata? cached = await repository.getCachedMetadata(
      item: withoutCid,
    );

    expect(cached?.title, 'Cached title');
    expect(cached?.stableId, withoutCid.stableId);
  });
}

PlayableItem _item({required int? cid, required int? page}) {
  return PlayableItem(
    aid: 1,
    bvid: 'BV1',
    title: 'title',
    author: 'author',
    coverUrl: '',
    cid: cid,
    page: page,
  );
}
