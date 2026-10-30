import 'dart:async';

import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/favorites/data/bili_favorites_remote_repository.dart';
import 'package:bilimusic/feature/favorites/data/favorites_local_repository.dart';
import 'package:bilimusic/feature/favorites/data/favorites_remote_cache_repository.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/favorites/logic/remote_favorites_repositories.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_backfill_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime(2026);
  final FavoriteCollection collection = FavoriteCollection(
    id: 'remote:1',
    name: 'remote',
    source: FavoriteCollectionSource.remote,
    remoteId: '1',
    createdAt: now,
    updatedAt: now,
  );
  const PlayableItem item = PlayableItem(
    aid: 1,
    bvid: 'BV1',
    title: 'title',
    author: 'author',
    coverUrl: '',
    cid: 10,
    page: 1,
  );
  late _MemoryLocalRepository local;
  late _FakeRemoteRepository remote;
  late _MemoryRemoteCache cache;
  late ProviderContainer container;
  late FavoritesController controller;

  setUp(() {
    local = _MemoryLocalRepository(
      FavoritesState(
        collections: <FavoriteCollection>[
          FavoriteCollection.liked(now: now),
          FavoriteCollection(
            id: 'local',
            name: 'local',
            createdAt: now,
            updatedAt: now,
          ),
        ],
      ),
    );
    remote = _FakeRemoteRepository();
    cache = _MemoryRemoteCache(FavoritesState(collections: [collection]));
    container = ProviderContainer(
      overrides: [
        favoritesLocalRepositoryProvider.overrideWithValue(local),
        favoritesRemoteCacheRepositoryProvider.overrideWithValue(cache),
        biliFavoritesRemoteRepositoryProvider.overrideWithValue(remote),
        biliSessionControllerProvider.overrideWith(_Session.new),
        metadataBackfillControllerProvider.overrideWith(
          _NoopMetadataBackfill.new,
        ),
      ],
    );
    controller = container.read(favoritesControllerProvider.notifier);
  });

  tearDown(() => container.dispose());

  test(
    'sets local, liked, and remote kind without requiring a session',
    () async {
      (container.read(biliSessionControllerProvider.notifier) as _Session)
          .signOut();
      for (final String id in <String>['local', 'liked', collection.id]) {
        expect(
          await controller.setCollectionKind(
            collectionId: id,
            kind: CollectionKind.spoken,
          ),
          isTrue,
        );
        await controller.reload();
        expect(
          container
              .read(favoritesControllerProvider)
              .collections
              .firstWhere((value) => value.id == id)
              .kind,
          CollectionKind.spoken,
        );
      }
      expect(local.state.likedCollection.kind, CollectionKind.spoken);
      expect(cache.state.collections.single.kind, CollectionKind.spoken);
      expect(
        await controller.setCollectionKind(
          collectionId: 'missing',
          kind: CollectionKind.spoken,
        ),
        isFalse,
      );
    },
  );

  test(
    'spoken targets skip metadata on liked, single, batch, and remote adds',
    () async {
      for (final String id in <String>['local', 'liked', collection.id]) {
        await controller.setCollectionKind(
          collectionId: id,
          kind: CollectionKind.spoken,
        );
      }
      expect(await controller.toggleLiked(item), isTrue);
      expect(
        await controller.addToCollection(collectionId: 'local', item: item),
        isTrue,
      );
      expect(
        await controller.addItemsToCollection(
          collectionId: 'local',
          items: [item.copyWith(aid: 2, bvid: 'BV2', cid: 2)],
        ),
        1,
      );
      expect(
        await controller.addToCollection(
          collectionId: collection.id,
          item: item,
        ),
        isTrue,
      );
      final _NoopMetadataBackfill metadata =
          container.read(metadataBackfillControllerProvider.notifier)
              as _NoopMetadataBackfill;
      expect(metadata.enqueued, isEmpty);
    },
  );

  test(
    'metadata backfill follows target kind rather than source kind',
    () async {
      final PlayableItem spokenSource = item.copyWith(
        kind: CollectionKind.spoken,
        collectionId: 'source',
      );
      await controller.addToCollection(
        collectionId: 'local',
        item: spokenSource,
      );
      final _NoopMetadataBackfill metadata =
          container.read(metadataBackfillControllerProvider.notifier)
              as _NoopMetadataBackfill;
      expect(metadata.enqueued.single.kind, CollectionKind.music);
      expect(metadata.enqueued.single.collectionId, 'local');
    },
  );

  test(
    'single and batch adds skip a synced video with a different cid',
    () async {
      await cache.saveEntryToCollection(
        collectionId: collection.id,
        entry: FavoriteEntry.fromPlayableItem(
          item.copyWith(cid: null),
          now: now,
        ),
        addedAt: now,
      );
      await controller.reload();

      expect(
        controller.isInCollection(collectionId: collection.id, item: item),
        isTrue,
      );
      expect(
        await controller.addToCollection(
          collectionId: collection.id,
          item: item,
        ),
        isFalse,
      );
      expect(
        await controller.addItemsToCollection(
          collectionId: collection.id,
          items: [item],
        ),
        0,
      );
      expect(remote.addCalls, 0);
      expect(cache.saves, 1);
    },
  );

  test('concurrent and later adds of the same video only save once', () async {
    remote.pending = Completer<void>();
    final Future<bool> first = controller.addToCollection(
      collectionId: collection.id,
      item: item,
    );
    final PlayableItem otherPart = item.copyWith(cid: 20, page: 2);

    expect(
      await controller.addToCollection(
        collectionId: collection.id,
        item: otherPart,
      ),
      isFalse,
    );
    expect(remote.addCalls, 1);
    remote.pending!.complete();
    expect(await first, isTrue);
    expect(
      await controller.addToCollection(
        collectionId: collection.id,
        item: otherPart,
      ),
      isFalse,
    );
    expect(remote.addCalls, 1);
    expect(cache.saves, 1);
    expect(
      container
          .read(favoritesControllerProvider)
          .itemCountForCollection(collection.id),
      1,
    );
  });

  test('failed remote adds release the guard and can be retried', () async {
    remote.fail = true;
    await expectLater(
      controller.addToCollection(collectionId: collection.id, item: item),
      throwsStateError,
    );
    expect(cache.saves, 0);

    remote.fail = false;
    expect(
      await controller.addToCollection(collectionId: collection.id, item: item),
      isTrue,
    );
    expect(remote.addCalls, 2);
    expect(cache.saves, 1);
  });
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

  void signOut() => state = null;
}

class _MemoryLocalRepository implements FavoritesLocalRepository {
  _MemoryLocalRepository(this.state);

  FavoritesState state;

  @override
  FavoritesState loadState() => state;

  @override
  Future<void> saveCollection(FavoriteCollection collection) async {
    state = state.copyWith(
      collections: <FavoriteCollection>[
        for (final FavoriteCollection existing in state.collections)
          if (existing.id == collection.id) collection else existing,
      ],
    );
  }

  @override
  Future<void> saveEntry(FavoriteEntry entry) async {
    state = state.copyWith(
      entries: <FavoriteEntry>[
        ...state.entries.where((value) => value.itemId != entry.itemId),
        entry,
      ],
    );
  }

  @override
  Future<void> saveMembership(FavoriteMembership membership) async {
    state = state.copyWith(
      memberships: <FavoriteMembership>[
        ...state.memberships.where((value) => value.id != membership.id),
        membership,
      ],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MemoryRemoteCache implements FavoritesRemoteCacheRepository {
  _MemoryRemoteCache(this.state);

  FavoritesState state;
  int saves = 0;

  @override
  FavoritesState loadState() => state;

  @override
  Future<void> setCollectionKind({
    required String collectionId,
    required CollectionKind kind,
  }) async {
    state = state.copyWith(
      collections: <FavoriteCollection>[
        for (final FavoriteCollection collection in state.collections)
          if (collection.id == collectionId)
            collection.copyWith(kind: kind)
          else
            collection,
      ],
    );
  }

  @override
  Future<void> saveEntryToCollection({
    required String collectionId,
    required FavoriteEntry entry,
    required DateTime addedAt,
  }) async {
    saves++;
    state = state.copyWith(
      entries: [...state.entries, entry],
      memberships: [
        ...state.memberships,
        FavoriteMembership.create(
          collectionId: collectionId,
          itemId: entry.itemId,
          addedAt: addedAt,
        ),
      ],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRemoteRepository implements BiliFavoritesRemoteRepository {
  int addCalls = 0;
  bool fail = false;
  Completer<void>? pending;

  @override
  Future<void> addVideoToCollection({
    required BiliSession session,
    required String remoteId,
    required PlayableItem item,
  }) async {
    addCalls++;
    if (fail) {
      throw StateError('remote add failed');
    }
    await pending?.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoopMetadataBackfill extends MetadataBackfillController {
  final List<PlayableItem> enqueued = <PlayableItem>[];

  @override
  void enqueue(PlayableItem item) => enqueued.add(item);
}
