import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorites_local_repository.g.dart';

const String favoriteCollectionsBoxName = 'favorite_collections';
const String favoriteEntriesBoxName = 'favorite_entries';
const String favoriteMembershipsBoxName = 'favorite_memberships';

@riverpod
FavoritesLocalRepository favoritesLocalRepository(Ref ref) {
  return FavoritesLocalRepository(
    collectionsBox: Hive.box<FavoriteCollection>(favoriteCollectionsBoxName),
    entriesBox: Hive.box<FavoriteEntry>(favoriteEntriesBoxName),
    membershipsBox: Hive.box<FavoriteMembership>(favoriteMembershipsBoxName),
  );
}

class FavoritesLocalRepository {
  FavoritesLocalRepository({
    required this._collectionsBox,
    required this._entriesBox,
    required this._membershipsBox,
  });

  final Box<FavoriteCollection> _collectionsBox;
  final Box<FavoriteEntry> _entriesBox;
  final Box<FavoriteMembership> _membershipsBox;

  Future<FavoritesState> initialize() async {
    if (!_collectionsBox.containsKey(FavoriteCollection.likedCollectionId)) {
      final FavoriteCollection liked = FavoriteCollection.liked();
      await _collectionsBox.put(liked.id, liked);
    }
    return loadState();
  }

  FavoritesState loadState() {
    final List<FavoriteCollection> collections = _collectionsBox.values.toList()
      ..sort((FavoriteCollection a, FavoriteCollection b) {
        if (a.isLikedCollection != b.isLikedCollection) {
          return a.isLikedCollection ? -1 : 1;
        }
        return b.updatedAt.compareTo(a.updatedAt);
      });

    final List<FavoriteEntry> entries = _entriesBox.values.toList();
    final List<FavoriteMembership> memberships = _membershipsBox.values
        .toList();

    return FavoritesState(
      collections: collections,
      entries: entries,
      memberships: memberships,
    );
  }

  Future<void> saveCollection(FavoriteCollection collection) {
    return _collectionsBox.put(collection.id, collection);
  }

  Future<void> saveEntry(FavoriteEntry entry) {
    return _entriesBox.put(entry.itemId, entry);
  }

  Future<void> saveMembership(FavoriteMembership membership) {
    return _membershipsBox.put(membership.id, membership);
  }

  Future<void> saveAll({
    required Iterable<FavoriteCollection> collections,
    required Iterable<FavoriteEntry> entries,
    required Iterable<FavoriteMembership> memberships,
  }) {
    final Map<String, FavoriteCollection> collectionMap =
        <String, FavoriteCollection>{
          for (final FavoriteCollection collection in collections)
            collection.id: collection,
        };
    final Map<String, FavoriteEntry> entryMap = <String, FavoriteEntry>{
      for (final FavoriteEntry entry in entries) entry.itemId: entry,
    };
    final Map<String, FavoriteMembership> membershipMap =
        <String, FavoriteMembership>{
          for (final FavoriteMembership membership in memberships)
            membership.id: membership,
        };

    return Future.wait(<Future<void>>[
      _collectionsBox.putAll(collectionMap),
      _entriesBox.putAll(entryMap),
      _membershipsBox.putAll(membershipMap),
    ]);
  }

  Future<void> replaceAll(FavoritesState nextState) async {
    await Future.wait(<Future<void>>[
      _collectionsBox.clear(),
      _entriesBox.clear(),
      _membershipsBox.clear(),
    ]);
    await saveAll(
      collections: nextState.collections,
      entries: nextState.entries,
      memberships: nextState.memberships,
    );
    if (!_collectionsBox.containsKey(FavoriteCollection.likedCollectionId)) {
      await _collectionsBox.put(
        FavoriteCollection.likedCollectionId,
        FavoriteCollection.liked(),
      );
    }
  }

  Future<void> deleteMembership(String membershipId) {
    return _membershipsBox.delete(membershipId);
  }

  Future<void> deleteCollection(String collectionId) async {
    await _collectionsBox.delete(collectionId);
    final List<String> membershipIds = _membershipsBox.values
        .where(
          (FavoriteMembership membership) =>
              membership.collectionId == collectionId,
        )
        .map((FavoriteMembership membership) => membership.id)
        .toList(growable: false);
    if (membershipIds.isNotEmpty) {
      await _membershipsBox.deleteAll(membershipIds);
    }
    await pruneOrphanEntries();
  }

  Future<void> pruneOrphanEntries() async {
    final Set<String> referencedIds = _membershipsBox.values
        .map((FavoriteMembership membership) => membership.itemId)
        .toSet();
    final List<String> orphanIds = _entriesBox.keys
        .whereType<String>()
        .where((String itemId) => !referencedIds.contains(itemId))
        .toList(growable: false);

    if (orphanIds.isNotEmpty) {
      await _entriesBox.deleteAll(orphanIds);
    }
  }
}
