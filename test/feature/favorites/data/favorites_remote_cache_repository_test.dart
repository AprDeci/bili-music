import 'dart:io';

import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/core/hive/hive_adapters.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/favorites/data/bili_favorites_remote_repository.dart';
import 'package:bilimusic/feature/favorites/data/favorites_local_repository.dart';
import 'package:bilimusic/feature/favorites/domain/bili_favorite_collection_page.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/favorites/logic/remote_favorites_repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final CollectionKindAdapter kindAdapter = CollectionKindAdapter();
    if (!Hive.isAdapterRegistered(kindAdapter.typeId)) {
      Hive.registerAdapter(kindAdapter);
    }
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

  test(
    'kind stays local across binding, summary refresh, and page refresh',
    () async {
      final FavoriteCollection remote = _collection('remote:1');
      await repository.bindCollection(remote);
      await repository.setCollectionKind(
        collectionId: remote.id,
        kind: CollectionKind.spoken,
      );
      await repository.upsertCollection(remote.copyWith(name: 'refreshed'));
      expect(collectionsBox.get(remote.id)!.kind, CollectionKind.spoken);
      await repository.upsertCollectionItems(
        collection: remote,
        items: <FavoriteEntry>[_entry('aid:1')],
      );
      expect(collectionsBox.get(remote.id)!.kind, CollectionKind.spoken);
      await repository.bindCollection(remote);
      expect(collectionsBox.get(remote.id)!.kind, CollectionKind.spoken);
      await collectionsBox.close();
      collectionsBox = await Hive.openBox<FavoriteCollection>('collections');
      expect(collectionsBox.get(remote.id)!.kind, CollectionKind.spoken);
    },
  );

  test('removing and binding again resets kind with the collection', () async {
    final FavoriteCollection remote = _collection('remote:1');
    await repository.bindCollection(remote);
    await repository.setCollectionKind(
      collectionId: remote.id,
      kind: CollectionKind.spoken,
    );
    await repository.deleteCollection(remote.id);
    expect(repository.loadState().collections, isEmpty);
    await repository.bindCollection(remote);
    expect(
      repository.loadState().collections.single.kind,
      CollectionKind.music,
    );
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

  test('page refresh preserves resolved part identity and metadata', () async {
    final FavoriteCollection collection = _collection('remote:1');
    final FavoriteEntry resolved = _entry('aid:1').copyWith(
      itemId: 'bvid:BV1:cid:10',
      bvid: 'BV1',
      cid: 10,
      page: 2,
      pageTitle: 'Part 2',
      durationText: '03:00',
    );
    await repository.saveEntryToCollection(
      collectionId: collection.id,
      entry: resolved,
      addedAt: resolved.createdAt,
    );
    await repository.upsertCollectionItems(
      collection: collection,
      items: <FavoriteEntry>[
        _entry('aid:1').copyWith(
          itemId: 'bvid:BV1',
          bvid: 'BV1',
          page: 1,
          title: 'Refreshed title',
          durationText: '10:00',
        ),
      ],
    );

    final FavoriteEntry stored = entriesBox.values.single;
    expect(stored.itemId, resolved.itemId);
    expect(stored.toPlayableItem().stableId, stored.itemId);
    expect(stored.cid, 10);
    expect(stored.page, 2);
    expect(stored.pageTitle, 'Part 2');
    expect(stored.durationText, '03:00');
    expect(stored.title, 'Refreshed title');
    expect(membershipsBox.values.single.itemId, stored.itemId);
    expect(await repository.normalizeItemIds(), 0);
  });

  for (final bool hasCid in <bool>[true, false]) {
    test('full sync retains existing cid key when hasCid=$hasCid', () async {
      final FavoriteCollection collection = _collection('remote:1');
      await repository.bindCollection(collection);
      final FavoriteEntry saved = _entry('aid:1').copyWith(
        itemId: 'bvid:BV1:cid:10',
        bvid: 'BV1',
        cid: hasCid ? 10 : null,
        page: 2,
      );
      await repository.saveEntryToCollection(
        collectionId: collection.id,
        entry: saved,
        addedAt: saved.createdAt,
      );
      final ProviderContainer container = ProviderContainer(
        overrides: [
          favoritesLocalRepositoryProvider.overrideWithValue(_EmptyLocal()),
          favoritesRemoteCacheRepositoryProvider.overrideWithValue(repository),
          biliFavoritesRemoteRepositoryProvider.overrideWithValue(
            _RemoteRepository(
              collection,
              saved.copyWith(itemId: 'bvid:BV1', cid: null, page: 1),
            ),
          ),
          biliSessionControllerProvider.overrideWith(_Session.new),
        ],
      );
      addTearDown(container.dispose);

      expect(
        await container
            .read(favoritesControllerProvider.notifier)
            .syncRemoteCollectionIfStale(collection.id, force: true),
        RemoteCollectionSyncResult.completed,
      );
      expect(
        container
            .read(favoritesControllerProvider)
            .itemsForCollection(collection.id)
            .single
            .itemId,
        saved.itemId,
      );
      expect(entriesBox.get(saved.itemId), isNotNull);
    });
  }

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

  test(
    'collection order stays based on createdAt after item refresh',
    () async {
      final DateTime olderCreatedAt = DateTime(2024);
      final DateTime newerCreatedAt = DateTime(2025);
      final FavoriteCollection older = _collection(
        'remote:older',
      ).copyWith(createdAt: olderCreatedAt, updatedAt: DateTime(2026));
      final FavoriteCollection newer = _collection(
        'remote:newer',
      ).copyWith(createdAt: newerCreatedAt, updatedAt: DateTime(2024));

      await repository.upsertCollection(older);
      await repository.upsertCollection(newer);

      expect(
        repository.loadState().collections.map(
          (FavoriteCollection value) => value.id,
        ),
        <String>['remote:newer', 'remote:older'],
      );

      await repository.upsertCollectionItems(
        collection: older.copyWith(updatedAt: DateTime(2027)),
        items: <FavoriteEntry>[_entry('aid:1')],
      );

      expect(
        repository.loadState().collections.map(
          (FavoriteCollection value) => value.id,
        ),
        <String>['remote:newer', 'remote:older'],
      );
    },
  );
}

class _EmptyLocal implements FavoritesLocalRepository {
  @override
  FavoritesState loadState() => const FavoritesState();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Session extends BiliSessionController {
  @override
  BiliSession? build() => const BiliSession(
    sessData: 'test',
    biliJct: 'test',
    dedeUserId: '1',
    refreshToken: '',
    cookie: '',
  );
}

class _RemoteRepository implements BiliFavoritesRemoteRepository {
  _RemoteRepository(this.collection, this.entry);

  final FavoriteCollection collection;
  final FavoriteEntry entry;

  @override
  Future<List<FavoriteRemoteResource>> fetchCollectionItemManifest({
    required BiliSession session,
    required String remoteId,
  }) async => <FavoriteRemoteResource>[
    FavoriteRemoteResource(stableId: 'bvid:BV1', aid: 1, bvid: 'BV1'),
  ];

  @override
  Future<BiliFavoriteCollectionPage> fetchCollectionPage({
    required BiliSession session,
    required String remoteId,
    int pageNumber = 1,
    int pageSize = 20,
  }) async => BiliFavoriteCollectionPage(
    collection: collection,
    items: <FavoriteEntry>[entry],
    hasMore: false,
    pageNumber: pageNumber,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
