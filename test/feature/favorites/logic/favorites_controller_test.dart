import 'dart:async';

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
  late _FakeRemoteRepository remote;
  late _MemoryRemoteCache cache;
  late ProviderContainer container;
  late FavoritesController controller;

  setUp(() {
    remote = _FakeRemoteRepository();
    cache = _MemoryRemoteCache(FavoritesState(collections: [collection]));
    container = ProviderContainer(
      overrides: [
        favoritesLocalRepositoryProvider.overrideWithValue(
          _EmptyLocalRepository(),
        ),
        favoritesRemoteCacheRepositoryProvider.overrideWithValue(cache),
        biliFavoritesRemoteRepositoryProvider.overrideWithValue(remote),
        biliSessionControllerProvider.overrideWithValue(
          const BiliSession(
            sessData: 'test',
            biliJct: 'test',
            dedeUserId: '1',
            refreshToken: '',
            cookie: '',
          ),
        ),
        metadataBackfillControllerProvider.overrideWith(
          _NoopMetadataBackfill.new,
        ),
      ],
    );
    controller = container.read(favoritesControllerProvider.notifier);
  });

  tearDown(() => container.dispose());

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

class _EmptyLocalRepository implements FavoritesLocalRepository {
  @override
  FavoritesState loadState() => const FavoritesState();

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
  @override
  void enqueue(PlayableItem item) {}
}
