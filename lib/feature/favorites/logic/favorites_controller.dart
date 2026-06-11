import 'dart:math';

import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/favorites/data/bili_favorites_remote_repository.dart';
import 'package:bilimusic/feature/favorites/data/favorites_local_repository.dart';
import 'package:bilimusic/feature/favorites/data/favorites_remote_cache_repository.dart';
import 'package:bilimusic/feature/favorites/domain/bili_favorite_collection_page.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/remote_favorites_repositories.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorites_controller.g.dart';

@Riverpod(keepAlive: true)
class FavoritesController extends _$FavoritesController {
  late final FavoritesLocalRepository _repository = ref.read(
    favoritesLocalRepositoryProvider,
  );
  late final FavoritesRemoteCacheRepository _remoteCache = ref.read(
    favoritesRemoteCacheRepositoryProvider,
  );
  late final BiliFavoritesRemoteRepository _remoteRepository = ref.read(
    biliFavoritesRemoteRepositoryProvider,
  );
  final Random _remoteImportRandom = Random();

  @override
  FavoritesState build() {
    return _loadState();
  }

  Future<void> initialize() async {
    final FavoritesState nextState = await _repository.initialize();
    state = _mergeStates(
      localState: nextState,
      remoteState: _remoteCache.loadState(),
    );
  }

  Future<void> reload() async {
    state = _loadState();
  }

  Future<void> refreshRemoteCollections() async {
    final BiliSession session = _getSession();
    final List<FavoriteCollection> remoteCollections = await _remoteRepository
        .fetchCreatedCollections(session: session);
    final Set<String> managedIds = state.collections
        .where((FavoriteCollection collection) => collection.isRemote)
        .map((FavoriteCollection collection) => collection.id)
        .toSet();
    final Set<String> remoteIds = remoteCollections
        .map((FavoriteCollection collection) => collection.id)
        .toSet();

    for (final FavoriteCollection collection in remoteCollections) {
      if (managedIds.contains(collection.id)) {
        await _remoteCache.upsertCollection(collection);
      }
    }
    for (final String collectionId in managedIds.difference(remoteIds)) {
      await _remoteCache.deleteCollection(collectionId);
    }
    state = _loadState();
  }

  Future<List<FavoriteCollection>> fetchImportableRemoteCollections() async {
    final BiliSession session = _getSession();
    final List<FavoriteCollection> remoteCollections = await _remoteRepository
        .fetchCreatedCollections(session: session);
    final Set<String> managedIds = state.collections
        .where((FavoriteCollection collection) => collection.isRemote)
        .map((FavoriteCollection collection) => collection.id)
        .toSet();
    final List<FavoriteCollection> importableCollections =
        remoteCollections
            .where(
              (FavoriteCollection collection) =>
                  !managedIds.contains(collection.id),
            )
            .toList(growable: false)
          ..sort(
            (FavoriteCollection a, FavoriteCollection b) =>
                b.updatedAt.compareTo(a.updatedAt),
          );
    return importableCollections;
  }

  Future<void> bindRemoteCollection(FavoriteCollection collection) async {
    if (!collection.isRemote) {
      return;
    }
    await _remoteCache.bindCollection(collection);
    state = _loadState();
  }

  Future<bool> removeRemoteCollection(String collectionId) async {
    final FavoriteCollection? targetCollection = _collectionById(collectionId);
    if (targetCollection == null || !targetCollection.isRemote) {
      return false;
    }

    await _remoteCache.deleteCollection(collectionId);
    state = _loadState();
    return true;
  }

  Future<BiliFavoriteCollectionPage?> refreshRemoteCollectionItems({
    required String collectionId,
    int pageNumber = 1,
  }) async {
    return _syncRemoteCollectionItemsPage(
      collectionId: collectionId,
      pageNumber: pageNumber,
      replaceExistingItems: true,
    );
  }

  Future<BiliFavoriteCollectionPage?> loadMoreRemoteCollectionItems({
    required String collectionId,
    required int pageNumber,
  }) async {
    return _syncRemoteCollectionItemsPage(
      collectionId: collectionId,
      pageNumber: pageNumber,
      replaceExistingItems: false,
    );
  }

  Future<BiliFavoriteCollectionPage?> _syncRemoteCollectionItemsPage({
    required String collectionId,
    required int pageNumber,
    required bool replaceExistingItems,
  }) async {
    final FavoriteCollection? collection = _collectionById(collectionId);
    final String? remoteId = collection?.remoteId;
    if (collection == null || !collection.isRemote || remoteId == null) {
      return null;
    }
    final BiliSession session = _getSession();
    final BiliFavoriteCollectionPage page = await _remoteRepository
        .fetchCollectionPage(
          session: session,
          remoteId: remoteId,
          pageNumber: pageNumber,
        );
    final FavoriteCollection remoteCollection = page.collection.copyWith(
      isManagedByApp: true,
    );
    if (replaceExistingItems) {
      await _remoteCache.replaceCollectionItems(
        collection: remoteCollection,
        items: page.items,
      );
    } else {
      await _remoteCache.appendCollectionItems(
        collection: remoteCollection,
        items: page.items,
      );
    }
    state = _loadState();
    return page;
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
      state = _loadState();
      return false;
    }

    await _upsertEntry(item: item, now: now);
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
    state = _loadState();
    return true;
  }

  Future<bool> addToCollection({
    required String collectionId,
    required PlayableItem item,
  }) async {
    if (!state.hasCollection(collectionId)) {
      return false;
    }

    final FavoriteCollection? collection = _collectionById(collectionId);
    if (collection?.isRemote ?? false) {
      return _addToRemoteCollection(collection: collection!, item: item);
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
    state = _loadState();
    return true;
  }

  Future<bool> removeFromCollection({
    required String collectionId,
    required String itemId,
  }) async {
    final FavoriteCollection? collection = _collectionById(collectionId);
    if (collection?.isRemote ?? false) {
      return _removeFromRemoteCollection(
        collection: collection!,
        itemId: itemId,
      );
    }

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
    state = _loadState();
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

  bool isLikedVideoPage({
    required int aid,
    required String bvid,
    required int page,
  }) {
    return state.isLikedVideoPage(aid: aid, bvid: bvid, page: page);
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

  Future<FavoriteCollection?> createCollection(String name) async {
    final String trimmedName = name.trim();
    if (trimmedName.isEmpty || _hasDuplicateCustomCollectionName(trimmedName)) {
      return null;
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
    state = _loadState();
    return collection;
  }

  Future<FavoriteCollection?> createRemoteCollection(String name) async {
    final String trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return null;
    }

    final FavoriteCollection collection = await _remoteRepository
        .createCollection(session: _getSession(), name: trimmedName);
    await _remoteCache.bindCollection(collection);
    state = _loadState();
    return collection.copyWith(isManagedByApp: true);
  }

  Future<int> addItemsToCollection({
    required String collectionId,
    required Iterable<PlayableItem> items,
  }) async {
    final FavoriteCollection? collection = _collectionById(collectionId);
    if (collection == null) {
      return 0;
    }

    if (collection.isRemote) {
      return _addItemsToRemoteCollection(collection: collection, items: items);
    }

    final DateTime now = DateTime.now();
    final Map<String, PlayableItem> uniqueItems = <String, PlayableItem>{};
    for (final PlayableItem item in items) {
      uniqueItems[item.stableId] = item;
    }

    int addedCount = 0;
    for (final PlayableItem item in uniqueItems.values) {
      final String itemId = item.stableId;
      await _upsertEntry(item: item, now: now);
      if (!state.isItemInCollection(
        collectionId: collectionId,
        itemId: itemId,
      )) {
        await _repository.saveMembership(
          FavoriteMembership.create(
            collectionId: collectionId,
            itemId: itemId,
            addedAt: now,
          ),
        );
        addedCount++;
      }
    }

    await _touchCollection(collectionId: collectionId, updatedAt: now);
    state = _loadState();
    return addedCount;
  }

  Future<int> _addItemsToRemoteCollection({
    required FavoriteCollection collection,
    required Iterable<PlayableItem> items,
  }) async {
    final Map<String, PlayableItem> uniqueItems = <String, PlayableItem>{};
    for (final PlayableItem item in items) {
      uniqueItems[item.stableId] = item;
    }

    int addedCount = 0;
    for (final PlayableItem item in uniqueItems.values) {
      if (state.isItemInCollection(
        collectionId: collection.id,
        itemId: item.stableId,
      )) {
        continue;
      }
      await Future<void>.delayed(
        Duration(milliseconds: 1000 + _remoteImportRandom.nextInt(201)),
      );
      final bool added = await _addToRemoteCollection(
        collection: collection,
        item: item,
      );
      if (added) {
        addedCount++;
      }
    }
    return addedCount;
  }

  Future<bool> renameCollection({
    required String collectionId,
    required String name,
  }) async {
    final String trimmedName = name.trim();
    if (trimmedName.isEmpty ||
        collectionId == FavoriteCollection.likedCollectionId) {
      return false;
    }

    FavoriteCollection? targetCollection = _collectionById(collectionId);

    if (targetCollection == null || targetCollection.isSystem) {
      return false;
    }

    if (targetCollection.isRemote) {
      final String? remoteId = targetCollection.remoteId;
      if (remoteId == null) {
        return false;
      }
      final FavoriteCollection renamed = await _remoteRepository
          .renameCollection(
            session: _getSession(),
            remoteId: remoteId,
            name: trimmedName,
          );
      await _remoteCache.upsertCollection(
        renamed.copyWith(isManagedByApp: true),
      );
      state = _loadState();
      return true;
    }

    if (_hasDuplicateCustomCollectionName(
      trimmedName,
      excludeId: collectionId,
    )) {
      return false;
    }

    await _repository.saveCollection(
      targetCollection.copyWith(name: trimmedName, updatedAt: DateTime.now()),
    );
    state = _loadState();
    return true;
  }

  Future<bool> deleteCollection(String collectionId) async {
    if (collectionId == FavoriteCollection.likedCollectionId) {
      return false;
    }

    FavoriteCollection? targetCollection = _collectionById(collectionId);

    if (targetCollection == null || targetCollection.isSystem) {
      return false;
    }

    if (targetCollection.isRemote) {
      final String? remoteId = targetCollection.remoteId;
      if (remoteId == null) {
        return false;
      }
      await _remoteRepository.deleteCollection(
        session: _getSession(),
        remoteId: remoteId,
      );
      await _remoteCache.deleteCollection(collectionId);
      state = _loadState();
      return true;
    }

    await _repository.deleteCollection(collectionId);
    state = _loadState();
    return true;
  }

  Future<void> _upsertEntry({
    required PlayableItem item,
    required DateTime now,
  }) async {
    final String itemId = item.stableId;

    final FavoriteEntry? existingEntry = _entryByItemId(itemId);

    await _repository.saveEntry(
      existingEntry?.copyWith(
            aid: item.aid,
            bvid: item.bvid,
            title: item.title,
            author: item.author,
            coverUrl: item.coverUrl,
            ownerMid: item.ownerMid,
            cid: item.cid,
            page: item.page,
            pageTitle: item.pageTitle,
            durationText: item.durationText,
            updatedAt: now,
          ) ??
          FavoriteEntry.fromPlayableItem(item, now: now),
    );
  }

  Future<bool> _addToRemoteCollection({
    required FavoriteCollection collection,
    required PlayableItem item,
  }) async {
    final String? remoteId = collection.remoteId;
    if (remoteId == null) {
      return false;
    }

    await _remoteRepository.addVideoToCollection(
      session: _getSession(),
      remoteId: remoteId,
      item: item,
    );
    final DateTime now = DateTime.now();
    await _remoteCache.saveEntryToCollection(
      collectionId: collection.id,
      entry: FavoriteEntry.fromPlayableItem(item, now: now),
      addedAt: now,
    );
    state = _loadState();
    return true;
  }

  Future<bool> _removeFromRemoteCollection({
    required FavoriteCollection collection,
    required String itemId,
  }) async {
    final String? remoteId = collection.remoteId;
    if (remoteId == null) {
      return false;
    }
    final FavoriteEntry? entry = _entryByItemId(itemId);
    if (entry == null) {
      return false;
    }

    await _remoteRepository.removeVideoFromCollection(
      session: _getSession(),
      remoteId: remoteId,
      aid: entry.aid,
    );
    await _remoteCache.removeEntryFromCollection(
      collectionId: collection.id,
      itemId: itemId,
    );
    state = _loadState();
    return true;
  }

  FavoriteCollection? _collectionById(String collectionId) {
    for (final FavoriteCollection collection in state.collections) {
      if (collection.id == collectionId) {
        return collection;
      }
    }
    return null;
  }

  FavoriteEntry? _entryByItemId(String itemId) {
    for (final FavoriteEntry entry in state.entries) {
      if (entry.itemId == itemId) {
        return entry;
      }
    }
    return null;
  }

  BiliSession _getSession() {
    final BiliSession? session = ref.read(biliSessionControllerProvider);
    if (session == null || !session.isLoggedIn) {
      throw const BiliFavoritesException('Bilibili session is required.');
    }
    return session;
  }

  FavoritesState _loadState() {
    return _mergeStates(
      localState: _repository.loadState(),
      remoteState: _remoteCache.loadState(),
    );
  }

  FavoritesState _mergeStates({
    required FavoritesState localState,
    required FavoritesState remoteState,
  }) {
    final Map<String, FavoriteEntry> entries = <String, FavoriteEntry>{
      for (final FavoriteEntry entry in localState.entries) entry.itemId: entry,
      for (final FavoriteEntry entry in remoteState.entries)
        entry.itemId: entry,
    };
    return FavoritesState(
      collections: <FavoriteCollection>[
        ...remoteState.collections,
        ...localState.collections,
      ],
      entries: entries.values.toList(growable: false),
      memberships: <FavoriteMembership>[
        ...remoteState.memberships,
        ...localState.memberships,
      ],
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

  bool _hasDuplicateCustomCollectionName(String name, {String? excludeId}) {
    final String normalizedName = name.trim();
    for (final FavoriteCollection collection in state.collections) {
      if (collection.isSystem || collection.id == excludeId) {
        continue;
      }
      if (collection.name.trim() == normalizedName) {
        return true;
      }
    }
    return false;
  }
}
