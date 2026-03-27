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
