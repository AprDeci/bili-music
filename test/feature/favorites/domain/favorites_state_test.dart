import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('collection membership', () {
    final DateTime now = DateTime(2026);
    const PlayableItem item = PlayableItem(
      aid: 1,
      bvid: 'BV1',
      title: 'title',
      author: 'author',
      coverUrl: '',
      cid: 20,
      page: 2,
    );
    final FavoriteEntry entry = FavoriteEntry.fromPlayableItem(
      item.copyWith(cid: null, page: 1),
      now: now,
    );
    final FavoritesState state = FavoritesState(
      collections: <FavoriteCollection>[
        FavoriteCollection(
          id: 'remote:1',
          name: 'remote',
          source: FavoriteCollectionSource.remote,
          remoteId: '1',
          createdAt: now,
          updatedAt: now,
        ),
        FavoriteCollection(
          id: 'local',
          name: 'local',
          createdAt: now,
          updatedAt: now,
        ),
      ],
      entries: <FavoriteEntry>[entry],
      memberships: <FavoriteMembership>[
        for (final String collectionId in <String>['remote:1', 'local'])
          FavoriteMembership.create(
            collectionId: collectionId,
            itemId: entry.itemId,
          ),
      ],
    );

    test('remote membership ignores cid and page', () {
      expect(
        state.containsItemInCollection(collectionId: 'remote:1', item: item),
        isTrue,
      );
    });

    test('remote membership falls back to aid or bvid', () {
      for (final PlayableItem candidate in <PlayableItem>[
        item.copyWith(bvid: ''),
        item.copyWith(aid: 0),
      ]) {
        expect(
          state.containsItemInCollection(
            collectionId: 'remote:1',
            item: candidate,
          ),
          isTrue,
        );
      }
    });

    test('remote membership rejects other videos and missing identities', () {
      for (final PlayableItem candidate in <PlayableItem>[
        item.copyWith(aid: 2, bvid: 'BV2'),
        item.copyWith(aid: 0, bvid: ''),
      ]) {
        expect(
          state.containsItemInCollection(
            collectionId: 'remote:1',
            item: candidate,
          ),
          isFalse,
        );
      }
    });

    test('local membership still uses the exact item identity', () {
      expect(
        state.containsItemInCollection(collectionId: 'local', item: item),
        isFalse,
      );
      expect(
        state.containsItemInCollection(
          collectionId: 'local',
          item: entry.toPlayableItem(),
        ),
        isTrue,
      );
    });

    test('membership is isolated by collection', () {
      expect(
        state.containsItemInCollection(collectionId: 'remote:2', item: item),
        isFalse,
      );
    });
  });

  test('matches a cid-less single-P item to a favorited entry', () {
    final DateTime now = DateTime(2024);
    final FavoriteEntry entry = FavoriteEntry(
      itemId: 'bvid:BV1:cid:10',
      aid: 1,
      bvid: 'BV1',
      title: 'title',
      author: 'author',
      coverUrl: '',
      cid: 10,
      createdAt: now,
      updatedAt: now,
    );
    final FavoritesState state = FavoritesState(
      collections: <FavoriteCollection>[
        FavoriteCollection(
          id: 'collection',
          name: 'collection',
          createdAt: now,
          updatedAt: now,
        ),
      ],
      entries: <FavoriteEntry>[entry],
      memberships: <FavoriteMembership>[
        FavoriteMembership.create(
          collectionId: 'collection',
          itemId: entry.itemId,
        ),
      ],
    );

    expect(
      state.collectionsForItem(
        PlayableItem(
          aid: 1,
          bvid: 'BV1',
          title: 'title',
          author: 'author',
          coverUrl: '',
          page: null,
        ),
      ),
      hasLength(1),
    );
  });

  test('keeps different pages separate', () {
    final DateTime now = DateTime(2024);
    final FavoriteEntry entry = FavoriteEntry(
      itemId: 'bvid:BV1:cid:10',
      aid: 1,
      bvid: 'BV1',
      title: 'title',
      author: 'author',
      coverUrl: '',
      page: 2,
      createdAt: now,
      updatedAt: now,
    );
    final FavoritesState state = FavoritesState(
      collections: <FavoriteCollection>[
        FavoriteCollection(
          id: 'collection',
          name: 'collection',
          createdAt: now,
          updatedAt: now,
        ),
      ],
      entries: <FavoriteEntry>[entry],
      memberships: <FavoriteMembership>[
        FavoriteMembership.create(
          collectionId: 'collection',
          itemId: entry.itemId,
        ),
      ],
    );

    expect(
      state.collectionsForItem(
        PlayableItem(
          aid: 1,
          bvid: 'BV1',
          title: 'title',
          author: 'author',
          coverUrl: '',
          page: 1,
        ),
      ),
      isEmpty,
    );
  });
}
