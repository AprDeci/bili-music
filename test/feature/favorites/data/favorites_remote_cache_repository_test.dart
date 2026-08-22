import 'dart:io';

import 'package:bilimusic/core/hive/hive_adapters.dart';
import 'package:bilimusic/feature/favorites/data/favorites_remote_cache_repository.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDirectory;
  late Box<FavoriteCollection> collectionsBox;
  late Box<FavoriteEntry> entriesBox;
  late Box<FavoriteMembership> membershipsBox;
  late Box<String> wastedResourceIdsBox;
  late FavoritesRemoteCacheRepository repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('remote-favorites-');
    Hive.init(tempDirectory.path);
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(FavoriteCollectionAdapter());
    }
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(FavoriteCollectionSourceAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(FavoriteEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(FavoriteMembershipAdapter());
    }
    collectionsBox = await Hive.openBox<FavoriteCollection>('collections');
    entriesBox = await Hive.openBox<FavoriteEntry>('entries');
    membershipsBox = await Hive.openBox<FavoriteMembership>('memberships');
    wastedResourceIdsBox = await Hive.openBox<String>('wasted');
    repository = FavoritesRemoteCacheRepository(
      collectionsBox: collectionsBox,
      entriesBox: entriesBox,
      membershipsBox: membershipsBox,
      wastedResourceIdsBox: wastedResourceIdsBox,
    );
  });

  tearDown(() async {
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('upserting a first page retains older memberships', () async {
    final FavoriteCollection collection = _collection('remote:1');
    await repository.upsertCollectionItems(
      collection: collection,
      items: <FavoriteEntry>[_entry('aid:1'), _entry('aid:2')],
    );

    await repository.upsertCollectionItems(
      collection: collection,
      items: <FavoriteEntry>[_entry('aid:1')],
    );

    expect(
      membershipsBox.values.map((FavoriteMembership value) => value.itemId),
      containsAll(<String>['aid:1', 'aid:2']),
    );
  });

  test(
    'reconcile only removes stale current memberships and prunes orphans',
    () async {
      final FavoriteCollection first = _collection('remote:1');
      final FavoriteCollection second = _collection('remote:2');
      await repository.upsertCollectionItems(
        collection: first,
        items: <FavoriteEntry>[_entry('aid:1'), _entry('aid:2')],
      );
      await repository.upsertCollectionItems(
        collection: second,
        items: <FavoriteEntry>[_entry('aid:2')],
      );

      await repository.reconcileCollection(
        collectionId: first.id,
        supportedItemIds: <String>{'aid:1'},
      );

      expect(
        membershipsBox.get(
          FavoriteMembership.membershipId(
            collectionId: first.id,
            itemId: 'aid:2',
          ),
        ),
        isNull,
      );
      expect(
        membershipsBox.get(
          FavoriteMembership.membershipId(
            collectionId: second.id,
            itemId: 'aid:2',
          ),
        ),
        isNotNull,
      );
      expect(entriesBox.get('aid:2'), isNotNull);

      await repository.reconcileCollection(
        collectionId: second.id,
        supportedItemIds: <String>{},
      );

      expect(entriesBox.get('aid:2'), isNull);
    },
  );

  test(
    'wasted IDs are isolated by collection and deleted with collection',
    () async {
      await repository.addWastedIds('remote:1', <String>{'aid:1', 'bvid:1'});
      await repository.addWastedIds('remote:2', <String>{'aid:2'});

      expect(repository.loadWastedIds('remote:1'), <String>{'aid:1', 'bvid:1'});
      expect(repository.loadWastedIds('remote:2'), <String>{'aid:2'});

      await repository.deleteCollection('remote:1');
      expect(repository.loadWastedIds('remote:1'), isEmpty);
      expect(repository.loadWastedIds('remote:2'), <String>{'aid:2'});
    },
  );

  test('wasted snapshots persist full state', () async {
    await repository.saveWastedSnapshot(
      collectionId: 'remote:1',
      hasFullSnapshot: true,
      ids: <String>{'aid:2'},
    );
    expect(repository.loadWastedSnapshot('remote:1').hasFullSnapshot, isTrue);
    expect(repository.loadWastedIds('remote:1'), <String>{'aid:2'});
  });

  test('upsert preserves an existing membership timestamp', () async {
    final FavoriteCollection collection = _collection('remote:1');
    final DateTime original = DateTime(2020);
    await repository.upsertCollectionItems(
      collection: collection,
      items: <FavoriteEntry>[_entry('aid:1').copyWith(createdAt: original)],
    );
    final DateTime refreshed = DateTime(2026);
    await repository.upsertCollectionItems(
      collection: collection,
      items: <FavoriteEntry>[_entry('aid:1').copyWith(createdAt: refreshed)],
    );

    expect(membershipsBox.values.single.addedAt, original);
  });
}

FavoriteCollection _collection(String id) {
  final DateTime now = DateTime(2026);
  return FavoriteCollection(
    id: id,
    name: id,
    source: FavoriteCollectionSource.remote,
    remoteId: id.substring('remote:'.length),
    isManagedByApp: true,
    createdAt: now,
    updatedAt: now,
  );
}

FavoriteEntry _entry(String itemId) {
  final DateTime now = DateTime(2026);
  return FavoriteEntry(
    itemId: itemId,
    aid: int.parse(itemId.substring('aid:'.length)),
    bvid: '',
    title: itemId,
    author: '',
    coverUrl: '',
    createdAt: now,
    updatedAt: now,
  );
}
