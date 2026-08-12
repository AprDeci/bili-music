import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
