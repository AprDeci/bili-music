import 'dart:convert';

import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:hive_ce/hive.dart';

const String remoteFavoriteCollectionsBoxName = 'remote_favorite_collections';
const String remoteFavoriteEntriesBoxName = 'remote_favorite_entries';
const String remoteFavoriteMembershipsBoxName = 'remote_favorite_memberships';

class FavoritesRemoteCacheRepository {
  static final AppLogger _logger = AppLogger('RemoteFavoriteSync');

  FavoritesRemoteCacheRepository({
    required this.collectionsBox,
    required this.entriesBox,
    required this.membershipsBox,
    this.wastedResourceIdsBox,
  });

  final Box<FavoriteCollection> collectionsBox;
  final Box<FavoriteEntry> entriesBox;
  final Box<FavoriteMembership> membershipsBox;
  final Box<String>? wastedResourceIdsBox;

  ({bool hasFullSnapshot, Set<String> ids}) loadWastedSnapshot(
    String collectionId,
  ) {
    final String? encoded = wastedResourceIdsBox?.get(collectionId);
    if (encoded == null || encoded.isEmpty) {
      return (hasFullSnapshot: false, ids: <String>{});
    }
    try {
      final dynamic decoded = jsonDecode(encoded);
      if (decoded is Map<String, dynamic>) {
        return (
          hasFullSnapshot: decoded['hasFullSnapshot'] == true,
          ids: (decoded['ids'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<String>()
              .toSet(),
        );
      }
    } on Object {
      // Keep malformed old records recoverable as an empty snapshot.
    }
    return (hasFullSnapshot: false, ids: <String>{});
  }

  Set<String> loadWastedIds(String collectionId) {
    return loadWastedSnapshot(collectionId).ids;
  }

  Future<void> addWastedIds(String collectionId, Iterable<String> ids) async {
    final ({bool hasFullSnapshot, Set<String> ids}) snapshot =
        loadWastedSnapshot(collectionId);
    await saveWastedSnapshot(
      collectionId: collectionId,
      hasFullSnapshot: snapshot.hasFullSnapshot,
      ids: snapshot.ids..addAll(ids),
    );
  }

  Future<void> saveWastedSnapshot({
    required String collectionId,
    required bool hasFullSnapshot,
    required Iterable<String> ids,
  }) async {
    await wastedResourceIdsBox?.put(
      collectionId,
      jsonEncode(<String, dynamic>{
        'hasFullSnapshot': hasFullSnapshot,
        'ids': ids.toSet().toList(),
      }),
    );
  }

  FavoritesState loadState() {
    final List<FavoriteCollection> collections =
        collectionsBox.values
            .where((FavoriteCollection collection) => collection.isManagedByApp)
            .toList()
          ..sort(
            (FavoriteCollection a, FavoriteCollection b) =>
                b.updatedAt.compareTo(a.updatedAt),
          );
    return FavoritesState(
      collections: collections,
      entries: entriesBox.values.toList(growable: false),
      memberships: membershipsBox.values.toList(growable: false),
    );
  }

  Future<void> bindCollection(FavoriteCollection collection) {
    return collectionsBox.put(
      collection.id,
      collection.copyWith(
        source: FavoriteCollectionSource.remote,
        isManagedByApp: true,
        lastSyncedAt: collection.lastSyncedAt,
      ),
    );
  }

  Future<void> upsertCollection(FavoriteCollection collection) async {
    final FavoriteCollection? existing = collectionsBox.get(collection.id);
    await collectionsBox.put(
      collection.id,
      collection.copyWith(
        source: FavoriteCollectionSource.remote,
        isManagedByApp: existing?.isManagedByApp ?? collection.isManagedByApp,
        lastSyncedAt: existing?.lastSyncedAt,
      ),
    );
  }

  Future<void> upsertCollectionItems({
    required FavoriteCollection collection,
    required Iterable<FavoriteEntry> items,
    bool preserveExistingAddedAt = true,
  }) async {
    final List<FavoriteEntry> itemList = items.toList(growable: false);
    _logger.d(
      'upsertCollectionItems collectionId=${collection.id} items=${itemList.length}',
    );
    final FavoriteCollection? existing = collectionsBox.get(collection.id);
    await collectionsBox.put(
      collection.id,
      collection.copyWith(
        source: FavoriteCollectionSource.remote,
        isManagedByApp: existing?.isManagedByApp ?? collection.isManagedByApp,
        itemCount: collection.itemCount,
        lastSyncedAt: existing?.lastSyncedAt,
      ),
    );

    final Map<String, FavoriteEntry> entryMap = <String, FavoriteEntry>{};
    final Map<String, FavoriteMembership> membershipMap =
        <String, FavoriteMembership>{};
    for (final FavoriteEntry entry in itemList) {
      FavoriteMembership? existingMembership;
      for (final FavoriteMembership membership in membershipsBox.values) {
        if (membership.collectionId != collection.id) {
          continue;
        }
        final FavoriteEntry? existingEntry = entriesBox.get(membership.itemId);
        if (existingEntry != null &&
            ((entry.aid > 0 && entry.aid == existingEntry.aid) ||
                (entry.bvid.isNotEmpty && entry.bvid == existingEntry.bvid))) {
          existingMembership = membership;
          break;
        }
      }
      final String itemId = existingMembership?.itemId ?? entry.itemId;
      final FavoriteEntry storedEntry = entry.itemId == itemId
          ? entry
          : entry.copyWith(itemId: itemId);
      entryMap[itemId] = storedEntry;
      final FavoriteMembership membership = FavoriteMembership.create(
        collectionId: collection.id,
        itemId: itemId,
        addedAt: preserveExistingAddedAt && existingMembership != null
            ? existingMembership.addedAt
            : entry.createdAt,
      );
      membershipMap[membership.id] = membership;
    }
    await Future.wait(<Future<void>>[
      entriesBox.putAll(entryMap),
      membershipsBox.putAll(membershipMap),
    ]);
  }

  // 同步收藏项到本地缓存。
  Future<void> reconcileCollection({
    required String collectionId,
    required Set<String> supportedItemIds,
  }) async {
    final List<String> staleMembershipIds = membershipsBox.values
        .where(
          (FavoriteMembership membership) =>
              membership.collectionId == collectionId &&
              !supportedItemIds.contains(membership.itemId),
        )
        .map((FavoriteMembership membership) => membership.id)
        .toList(growable: false);
    if (staleMembershipIds.isNotEmpty) {
      await membershipsBox.deleteAll(staleMembershipIds);
    }
    await pruneOrphanEntries();
    final FavoriteCollection? collection = collectionsBox.get(collectionId);
    final DateTime syncedAt = DateTime.now();
    if (collection != null) {
      await collectionsBox.put(
        collectionId,
        collection.copyWith(lastSyncedAt: syncedAt),
      );
    }
    _logger.d(
      'reconcile collectionId=$collectionId deletedMemberships=${staleMembershipIds.length} '
      'savedLastSyncedAt=${collection != null ? syncedAt : null}',
    );
  }

  Future<void> saveEntryToCollection({
    required String collectionId,
    required FavoriteEntry entry,
    required DateTime addedAt,
  }) async {
    await entriesBox.put(entry.itemId, entry);
    final FavoriteMembership membership = FavoriteMembership.create(
      collectionId: collectionId,
      itemId: entry.itemId,
      addedAt: addedAt,
    );
    await membershipsBox.put(membership.id, membership);
    final FavoriteCollection? collection = collectionsBox.get(collectionId);
    if (collection != null) {
      await collectionsBox.put(
        collectionId,
        collection.copyWith(
          itemCount: collection.itemCount + 1,
          updatedAt: addedAt,
        ),
      );
    }
  }

  Future<void> removeEntryFromCollection({
    required String collectionId,
    required String itemId,
  }) async {
    await membershipsBox.delete(
      FavoriteMembership.membershipId(
        collectionId: collectionId,
        itemId: itemId,
      ),
    );
    final FavoriteCollection? collection = collectionsBox.get(collectionId);
    if (collection != null) {
      await collectionsBox.put(
        collectionId,
        collection.copyWith(
          itemCount: collection.itemCount > 0 ? collection.itemCount - 1 : 0,
          updatedAt: DateTime.now(),
        ),
      );
    }
    await pruneOrphanEntries();
  }

  Future<void> deleteCollection(String collectionId) async {
    await collectionsBox.delete(collectionId);
    final List<String> membershipIds = membershipsBox.values
        .where(
          (FavoriteMembership membership) =>
              membership.collectionId == collectionId,
        )
        .map((FavoriteMembership membership) => membership.id)
        .toList(growable: false);
    if (membershipIds.isNotEmpty) {
      await membershipsBox.deleteAll(membershipIds);
    }
    await pruneOrphanEntries();
    await wastedResourceIdsBox?.delete(collectionId);
  }

  Future<void> pruneOrphanEntries() async {
    final Set<String> referencedIds = membershipsBox.values
        .map((FavoriteMembership membership) => membership.itemId)
        .toSet();
    final List<String> orphanIds = entriesBox.keys
        .whereType<String>()
        .where((String itemId) => !referencedIds.contains(itemId))
        .toList(growable: false);
    if (orphanIds.isNotEmpty) {
      await entriesBox.deleteAll(orphanIds);
    }
  }
}
