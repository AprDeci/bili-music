import 'dart:math';

import 'package:bilimusic/common/logger.dart';
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

int remoteFavoriteSyncBatchLimit(int itemCount) {
  return max(1, ((itemCount + 19) ~/ 20) + 2);
}

enum RemoteCollectionSyncResult { skipped, completed, incomplete }

@Riverpod(keepAlive: true)
class FavoritesController extends _$FavoritesController {
  static final AppLogger _logger = AppLogger('RemoteFavoriteSync');

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
  final Map<String, Future<RemoteCollectionSyncResult>> _collectionSyncs =
      <String, Future<RemoteCollectionSyncResult>>{};

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

  Future<RemoteCollectionSyncResult> syncRemoteCollectionIfStale(
    String collectionId,
  ) {
    final Future<RemoteCollectionSyncResult>? existing =
        _collectionSyncs[collectionId];
    final FavoriteCollection? collection = _collectionById(collectionId);
    final DateTime now = DateTime.now();
    _logger.d(
      'sync entry collectionId=$collectionId remoteId=${collection?.remoteId} '
      'foundCollection=${collection != null} lastSyncedAt=${collection?.lastSyncedAt} '
      'now=$now concurrentFuture=${existing != null}',
    );
    if (existing != null) {
      return existing;
    }
    final Future<RemoteCollectionSyncResult> sync =
        _syncRemoteCollectionIfStale(collectionId);
    _collectionSyncs[collectionId] = sync;
    sync.then<void>(
      (_) => _collectionSyncs.remove(collectionId),
      onError: (Object error, StackTrace stackTrace) {
        _collectionSyncs.remove(collectionId);
      },
    );
    return sync;
  }

  Future<RemoteCollectionSyncResult> _syncRemoteCollectionIfStale(
    String collectionId,
  ) async {
    final FavoriteCollection? collection = _collectionById(collectionId);
    final String? remoteId = collection?.remoteId;
    if (collection == null || !collection.isRemote || remoteId == null) {
      return RemoteCollectionSyncResult.skipped;
    }
    final DateTime? lastSyncedAt = collection.lastSyncedAt;
    final DateTime now = DateTime.now();
    final Duration? age = lastSyncedAt == null
        ? null
        : now.difference(lastSyncedAt);
    const Duration staleThreshold = Duration(minutes: 5);
    if (age != null && age <= staleThreshold) {
      _logger.d(
        'stale decision=skip collectionId=$collectionId age=$age '
        'threshold=$staleThreshold',
      );
      return RemoteCollectionSyncResult.skipped;
    }
    _logger.d(
      'stale decision=continue collectionId=$collectionId age=$age '
      'threshold=$staleThreshold',
    );

    try {
      final BiliSession session = _getSession();
      final List<FavoriteRemoteResource> manifest = await _remoteRepository
          .fetchCollectionItemManifest(session: session, remoteId: remoteId);
      final ({bool hasFullSnapshot, Set<String> ids}) snapshot = _remoteCache
          .loadWastedSnapshot(collectionId);
      final Set<String> wastedIds = snapshot.ids
        ..retainAll(
          manifest.map((FavoriteRemoteResource resource) => resource.stableId),
        );
      final List<FavoriteRemoteResource> effectiveManifest = manifest
          .where(
            (FavoriteRemoteResource resource) =>
                !wastedIds.contains(resource.stableId),
          )
          .toList(growable: false);
      final List<FavoriteRemoteResource> missing = _missingResources(
        collectionId,
        effectiveManifest,
      );
      if (!snapshot.hasFullSnapshot) {
        final Set<String> seen = await _scanCollectionPages(
          session: session,
          collection: collection,
          remoteId: remoteId,
          manifest: manifest,
        );
        state = _loadState();
        final Set<String> finalWasted =
            manifest
                .map((FavoriteRemoteResource resource) => resource.stableId)
                .toSet()
              ..removeAll(seen);
        await _remoteCache.saveWastedSnapshot(
          collectionId: collectionId,
          hasFullSnapshot: true,
          ids: finalWasted,
        );
        await _finishRemoteSync(collectionId, manifest, finalWasted);
        return RemoteCollectionSyncResult.completed;
      }
      if (missing.isNotEmpty) {
        int noProgressPages = 0;
        List<FavoriteRemoteResource> remaining = missing;
        for (int pageNumber = 1; ; pageNumber++) {
          final int before = remaining.length;
          final BiliFavoriteCollectionPage page = await _fetchAndCachePage(
            session: session,
            collection: collection,
            remoteId: remoteId,
            pageNumber: pageNumber,
            onlyResources: remaining,
          );
          state = _loadState();
          remaining = _missingResources(collectionId, remaining);
          noProgressPages = remaining.length == before
              ? noProgressPages + 1
              : 0;
          if (remaining.isEmpty || noProgressPages >= 2 || !page.hasMore) {
            wastedIds.addAll(
              remaining.map(
                (FavoriteRemoteResource resource) => resource.stableId,
              ),
            );
            break;
          }
          await _waitBetweenRemotePages();
        }
      }
      await _remoteCache.saveWastedSnapshot(
        collectionId: collectionId,
        hasFullSnapshot: true,
        ids: wastedIds,
      );
      await _finishRemoteSync(collectionId, manifest, wastedIds);
      return RemoteCollectionSyncResult.completed;
    } on Object catch (error, stackTrace) {
      _logger.w('Remote collection sync incomplete', error, stackTrace);
      return RemoteCollectionSyncResult.incomplete;
    }
  }

  Future<BiliFavoriteCollectionPage?> refreshRemoteCollectionItems({
    required String collectionId,
    int pageNumber = 1,
  }) {
    return _syncRemoteCollectionItemsPage(
      collectionId: collectionId,
      pageNumber: pageNumber,
    );
  }

  Future<BiliFavoriteCollectionPage?> loadMoreRemoteCollectionItems({
    required String collectionId,
    required int pageNumber,
  }) async {
    return _syncRemoteCollectionItemsPage(
      collectionId: collectionId,
      pageNumber: pageNumber,
    );
  }

  Future<BiliFavoriteCollectionPage?> _syncRemoteCollectionItemsPage({
    required String collectionId,
    required int pageNumber,
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
    _logger.d(
      'detail request after collectionId=$collectionId pageNumber=$pageNumber '
      'page.items.length=${page.items.length} hasMore=${page.hasMore} '
      'missingIdsRemaining=unknown',
    );
    final FavoriteCollection remoteCollection = page.collection.copyWith(
      isManagedByApp: true,
    );
    await _remoteCache.upsertCollectionItems(
      collection: remoteCollection,
      items: page.items,
    );
    state = _loadState();
    return page;
  }

  Future<BiliFavoriteCollectionPage> _fetchAndCachePage({
    required BiliSession session,
    required FavoriteCollection collection,
    required String remoteId,
    required int pageNumber,
    Iterable<FavoriteRemoteResource>? onlyResources,
  }) async {
    final BiliFavoriteCollectionPage page = await _remoteRepository
        .fetchCollectionPage(
          session: session,
          remoteId: remoteId,
          pageNumber: pageNumber,
        );
    final Iterable<FavoriteEntry> items = onlyResources == null
        ? page.items
        : page.items.where(
            (FavoriteEntry entry) => onlyResources.any(
              (FavoriteRemoteResource resource) =>
                  _resourceMatchesEntry(resource, entry),
            ),
          );
    await _remoteCache.upsertCollectionItems(
      collection: page.collection.copyWith(isManagedByApp: true),
      items: items,
    );
    return page;
  }

  Future<Set<String>> _scanCollectionPages({
    required BiliSession session,
    required FavoriteCollection collection,
    required String remoteId,
    required Iterable<FavoriteRemoteResource> manifest,
  }) async {
    final Set<String> seen = <String>{};
    for (int pageNumber = 1; ; pageNumber++) {
      final BiliFavoriteCollectionPage page = await _fetchAndCachePage(
        session: session,
        collection: collection,
        remoteId: remoteId,
        pageNumber: pageNumber,
      );
      for (final FavoriteRemoteResource resource in manifest) {
        if (page.items.any(
          (FavoriteEntry entry) => _resourceMatchesEntry(resource, entry),
        )) {
          seen.add(resource.stableId);
        }
      }
      if (!page.hasMore) {
        return seen;
      }
      await _waitBetweenRemotePages();
    }
  }

  Future<void> _waitBetweenRemotePages() {
    return Future<void>.delayed(
      Duration(milliseconds: 800 + _remoteImportRandom.nextInt(401)),
    );
  }

  Future<void> _finishRemoteSync(
    String collectionId,
    Iterable<FavoriteRemoteResource> manifest,
    Set<String> wastedIds,
  ) async {
    final List<FavoriteRemoteResource> effectiveManifest = manifest
        .where(
          (FavoriteRemoteResource resource) =>
              !wastedIds.contains(resource.stableId),
        )
        .toList(growable: false);
    await _remoteCache.reconcileCollection(
      collectionId: collectionId,
      supportedItemIds: _supportedItemIdsForReconcile(
        collectionId: collectionId,
        manifest: effectiveManifest,
      ),
    );
    state = _loadState();
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

  bool _resourceMatchesEntry(
    FavoriteRemoteResource resource,
    FavoriteEntry entry,
  ) {
    return (resource.aid > 0 && resource.aid == entry.aid) ||
        (resource.bvid.isNotEmpty && resource.bvid == entry.bvid);
  }

  List<FavoriteRemoteResource> _missingResources(
    String collectionId,
    Iterable<FavoriteRemoteResource> manifest,
  ) {
    final List<FavoriteEntry> localEntries = state.itemsForCollection(
      collectionId,
    );
    return manifest
        .where(
          (FavoriteRemoteResource resource) => !localEntries.any(
            (FavoriteEntry entry) => _resourceMatchesEntry(resource, entry),
          ),
        )
        .toList(growable: true);
  }

  Set<String> _supportedItemIdsForReconcile({
    required String collectionId,
    required Iterable<FavoriteRemoteResource> manifest,
  }) {
    final List<FavoriteRemoteResource> resources = manifest.toList(
      growable: false,
    );
    final Set<String> supported = <String>{
      for (final FavoriteRemoteResource resource in resources)
        resource.stableId,
      for (final FavoriteRemoteResource resource in resources)
        if (resource.aid > 0) 'aid:${resource.aid}',
      for (final FavoriteRemoteResource resource in resources)
        if (resource.bvid.isNotEmpty) resource.bvid,
    };
    for (final FavoriteEntry entry in state.itemsForCollection(collectionId)) {
      if (resources.any(
        (FavoriteRemoteResource resource) =>
            _resourceMatchesEntry(resource, entry),
      )) {
        supported.add(entry.itemId);
        if (entry.aid > 0) {
          supported.add('aid:${entry.aid}');
        }
        if (entry.bvid.isNotEmpty) {
          supported.add(entry.bvid);
        }
      }
    }
    return supported;
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
