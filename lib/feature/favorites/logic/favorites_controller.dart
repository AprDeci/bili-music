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

  bool isLiked(PlayableItem item) {
    return state.isLiked(item);
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
}
