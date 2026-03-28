import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorites_state.freezed.dart';

@freezed
abstract class FavoritesState with _$FavoritesState {
  const FavoritesState._();

  const factory FavoritesState({
    @Default(<FavoriteCollection>[]) List<FavoriteCollection> collections,
    @Default(<FavoriteEntry>[]) List<FavoriteEntry> entries,
    @Default(<FavoriteMembership>[]) List<FavoriteMembership> memberships,
  }) = _FavoritesState;

  FavoriteCollection get likedCollection {
    return collections.firstWhere(
      (FavoriteCollection collection) => collection.isLikedCollection,
      orElse: FavoriteCollection.liked,
    );
  }

  Set<String> get likedItemIds {
    return memberships
        .where(
          (FavoriteMembership membership) =>
              membership.collectionId == FavoriteCollection.likedCollectionId,
        )
        .map((FavoriteMembership membership) => membership.itemId)
        .toSet();
  }

  bool isLiked(PlayableItem item) {
    return likedItemIds.contains(item.stableId);
  }

  bool isLikedVideoPage({
    required int aid,
    required String bvid,
    required int page,
  }) {
    if (aid <= 0 && bvid.isEmpty) {
      return false;
    }

    final Set<String> likedIds = likedItemIds;
    for (final FavoriteEntry entry in entries) {
      if (!likedIds.contains(entry.itemId)) {
        continue;
      }
      final bool sameVideo = bvid.isNotEmpty
          ? entry.bvid == bvid
          : entry.aid == aid;
      if (!sameVideo) {
        continue;
      }
      if (entry.page == page) {
        return true;
      }
    }
    return false;
  }

  bool hasCollection(String collectionId) {
    return collections.any(
      (FavoriteCollection collection) => collection.id == collectionId,
    );
  }

  bool isItemInCollection({
    required String collectionId,
    required String itemId,
  }) {
    return memberships.any(
      (FavoriteMembership membership) =>
          membership.collectionId == collectionId &&
          membership.itemId == itemId,
    );
  }

  bool containsItemInCollection({
    required String collectionId,
    required PlayableItem item,
  }) {
    return isItemInCollection(
      collectionId: collectionId,
      itemId: item.stableId,
    );
  }

  List<FavoriteCollection> collectionsForItem(PlayableItem item) {
    final Set<String> collectionIds = memberships
        .where(
          (FavoriteMembership membership) => membership.itemId == item.stableId,
        )
        .map((FavoriteMembership membership) => membership.collectionId)
        .toSet();

    return collections
        .where(
          (FavoriteCollection collection) =>
              collectionIds.contains(collection.id),
        )
        .toList(growable: false);
  }

  int itemCountForCollection(String collectionId) {
    return memberships.where((FavoriteMembership membership) {
      return membership.collectionId == collectionId;
    }).length;
  }

  List<FavoriteEntry> itemsForCollection(String collectionId) {
    final Map<String, FavoriteEntry> entryMap = <String, FavoriteEntry>{
      for (final FavoriteEntry entry in entries) entry.itemId: entry,
    };
    final List<FavoriteMembership> sortedMemberships =
        memberships
            .where(
              (FavoriteMembership membership) =>
                  membership.collectionId == collectionId,
            )
            .toList()
          ..sort(
            (FavoriteMembership a, FavoriteMembership b) =>
                b.addedAt.compareTo(a.addedAt),
          );

    return sortedMemberships
        .map((FavoriteMembership membership) => entryMap[membership.itemId])
        .whereType<FavoriteEntry>()
        .toList(growable: false);
  }
}
