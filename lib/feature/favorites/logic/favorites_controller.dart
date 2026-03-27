import 'package:bilimusic/feature/favorites/data/favorites_local_repository.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorites_controller.g.dart';

@riverpod
class FavoritesController extends _$FavoritesController {
  late final FavoritesLocalRepository _repository = ref.read(
    favoritesLocalRepositoryProvider,
  );

  @override
  FavoritesState build() {
    Future<void>.microtask(_bootstrap);
    return _repository.loadState();
  }

  Future<void> _bootstrap() async {
    final FavoritesState nextState = await _repository.initialize();
    state = nextState;
  }

  Future<bool> toggleLiked(PlayableItem item) async {
    final String itemId = item.stableId;
    final String membershipId = FavoriteMembership.membershipId(
      collectionId: FavoriteCollection.likedCollectionId,
      itemId: itemId,
    );
    final DateTime now = DateTime.now();
    final bool isAlreadyLiked = state.likedItemIds.contains(itemId);

    if (isAlreadyLiked) {
      await _repository.deleteMembership(membershipId);
      await _repository.saveCollection(
        state.likedCollection.copyWith(updatedAt: now),
      );
      await _repository.pruneOrphanEntries();
      state = _repository.loadState();
      return false;
    }

    FavoriteEntry? existingEntry;
    for (final FavoriteEntry entry in state.entries) {
      if (entry.itemId == itemId) {
        existingEntry = entry;
        break;
      }
    }

    await _repository.saveEntry(
      existingEntry?.copyWith(
            aid: item.aid,
            bvid: item.bvid,
            title: item.title,
            author: item.author,
            coverUrl: item.coverUrl,
            durationText: item.durationText,
            updatedAt: now,
          ) ??
          FavoriteEntry.fromPlayableItem(item, now: now),
    );
    await _repository.saveMembership(
      FavoriteMembership.create(
        collectionId: FavoriteCollection.likedCollectionId,
        itemId: itemId,
        addedAt: now,
      ),
    );
    await _repository.saveCollection(
      state.likedCollection.copyWith(updatedAt: now),
    );
    state = _repository.loadState();
    return true;
  }

  Future<bool> addToCollection({
    required String collectionId,
    required PlayableItem item,
  }) async {
    if (!state.hasCollection(collectionId)) {
      return false;
    }

    final String itemId = item.stableId;
    final DateTime now = DateTime.now();

    await _upsertEntry(item: item, now: now);

    if (!state.isItemInCollection(collectionId: collectionId, itemId: itemId)) {
      await _repository.saveMembership(
        FavoriteMembership.create(
          collectionId: collectionId,
          itemId: itemId,
          addedAt: now,
        ),
      );
    }

    await _touchCollection(collectionId: collectionId, updatedAt: now);
    state = _repository.loadState();
    return true;
  }

  Future<bool> removeFromCollection({
    required String collectionId,
    required String itemId,
  }) async {
    if (!state.hasCollection(collectionId)) {
      return false;
    }

    if (!state.isItemInCollection(collectionId: collectionId, itemId: itemId)) {
      return false;
    }

    final DateTime now = DateTime.now();
    await _repository.deleteMembership(
      FavoriteMembership.membershipId(
        collectionId: collectionId,
        itemId: itemId,
      ),
    );
    await _touchCollection(collectionId: collectionId, updatedAt: now);
    await _repository.pruneOrphanEntries();
    state = _repository.loadState();
    return true;
  }

  Future<Map<String, bool>> addToCollections({
    required Iterable<String> collectionIds,
    required PlayableItem item,
  }) async {
    final Map<String, bool> result = <String, bool>{};
    for (final String collectionId in collectionIds) {
      result[collectionId] = await addToCollection(
        collectionId: collectionId,
        item: item,
      );
    }
    return result;
  }

  bool isLiked(PlayableItem item) {
    return state.isLiked(item);
  }

  bool isInCollection({
    required String collectionId,
    required PlayableItem item,
  }) {
    return state.containsItemInCollection(
      collectionId: collectionId,
      item: item,
    );
  }

  List<FavoriteCollection> collectionsForItem(PlayableItem item) {
    return state.collectionsForItem(item);
  }

  Future<void> createCollection(String name) async {
    final String trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return;
    }

    final DateTime now = DateTime.now();
    final FavoriteCollection collection = FavoriteCollection(
      id: 'custom_${now.microsecondsSinceEpoch}',
      name: trimmedName,
      isSystem: false,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.saveCollection(collection);
    state = _repository.loadState();
  }

  Future<bool> deleteCollection(String collectionId) async {
    if (collectionId == FavoriteCollection.likedCollectionId) {
      return false;
    }

    FavoriteCollection? targetCollection;
    for (final FavoriteCollection collection in state.collections) {
      if (collection.id == collectionId) {
        targetCollection = collection;
        break;
      }
    }

    if (targetCollection == null || targetCollection.isSystem) {
      return false;
    }

    await _repository.deleteCollection(collectionId);
    state = _repository.loadState();
    return true;
  }

  Future<void> _upsertEntry({
    required PlayableItem item,
    required DateTime now,
  }) async {
    final String itemId = item.stableId;

    FavoriteEntry? existingEntry;
    for (final FavoriteEntry entry in state.entries) {
      if (entry.itemId == itemId) {
        existingEntry = entry;
        break;
      }
    }

    await _repository.saveEntry(
      existingEntry?.copyWith(
            aid: item.aid,
            bvid: item.bvid,
            title: item.title,
            author: item.author,
            coverUrl: item.coverUrl,
            durationText: item.durationText,
            updatedAt: now,
          ) ??
          FavoriteEntry.fromPlayableItem(item, now: now),
    );
  }

  Future<void> _touchCollection({
    required String collectionId,
    required DateTime updatedAt,
  }) async {
    for (final FavoriteCollection collection in state.collections) {
      if (collection.id == collectionId) {
        await _repository.saveCollection(
          collection.copyWith(updatedAt: updatedAt),
        );
        break;
      }
    }
  }
}
