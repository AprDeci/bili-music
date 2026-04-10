import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bilimusic/feature/favorites/data/favorites_local_repository.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/setting/domain/favorites_import_preview.dart';
import 'package:bilimusic/feature/setting/domain/favorites_transfer_bundle.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorites_transfer_repository.g.dart';

@riverpod
FavoritesTransferRepository favoritesTransferRepository(Ref ref) {
  return FavoritesTransferRepository(
    favoritesRepository: ref.read(favoritesLocalRepositoryProvider),
  );
}

class FavoritesTransferRepository {
  FavoritesTransferRepository({required this._favoritesRepository});

  final FavoritesLocalRepository _favoritesRepository;

  Future<String> buildExportJson() async {
    final FavoritesState state = _favoritesRepository.loadState();
    final FavoritesTransferBundle bundle = _buildExportBundle(state);
    return const JsonEncoder.withIndent('  ').convert(bundle.toJson());
  }

  Future<void> saveExportToPath({
    required String json,
    required String path,
  }) async {
    final File file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(json, flush: true);
  }

  Future<FavoritesImportPreview> previewImport(Uint8List bytes) async {
    final FavoritesState importedState = _parseBytes(bytes);
    final FavoritesState localState = _favoritesRepository.loadState();
    final Set<String> localNames = localState.collections
        .where((FavoriteCollection collection) => !collection.isLikedCollection)
        .map(
          (FavoriteCollection collection) =>
              _normalizeCollectionName(collection.name),
        )
        .where((String name) => name.isNotEmpty)
        .toSet();

    final List<FavoritesImportCollectionPreview> collections = importedState
        .collections
        .map((FavoriteCollection collection) {
          final bool hasNameConflict =
              !collection.isLikedCollection &&
              localNames.contains(_normalizeCollectionName(collection.name));
          return FavoritesImportCollectionPreview(
            sourceCollectionId: collection.id,
            name: collection.name,
            isLikedCollection: collection.isLikedCollection,
            itemCount: importedState.itemCountForCollection(collection.id),
            hasNameConflict: hasNameConflict,
          );
        })
        .toList(growable: false);

    return FavoritesImportPreview(
      hasLikedCollection: importedState.hasCollection(
        FavoriteCollection.likedCollectionId,
      ),
      likedItemCount: importedState.itemCountForCollection(
        FavoriteCollection.likedCollectionId,
      ),
      customCollectionCount: importedState.collections
          .where(
            (FavoriteCollection collection) => !collection.isLikedCollection,
          )
          .length,
      totalEntryCount: importedState.entries.length,
      collections: collections,
      conflictingCollectionNames: collections
          .where(
            (FavoritesImportCollectionPreview collection) =>
                collection.hasNameConflict,
          )
          .map((FavoritesImportCollectionPreview collection) => collection.name)
          .toSet(),
    );
  }

  Future<void> importBytes({
    required Uint8List bytes,
    required bool importLikedCollection,
    required Set<String> selectedCollectionIds,
  }) async {
    final FavoritesState importedState = _parseBytes(bytes);
    final FavoritesState currentState = _favoritesRepository.loadState();
    final FavoritesState nextState = _applyImport(
      currentState: currentState,
      importedState: importedState,
      importLikedCollection: importLikedCollection,
      selectedCollectionIds: selectedCollectionIds,
    );
    await _favoritesRepository.replaceAll(nextState);
  }

  FavoritesTransferBundle _buildExportBundle(FavoritesState state) {
    final Set<String> exportedCollectionIds = state.collections
        .map((FavoriteCollection collection) => collection.id)
        .toSet();
    final List<FavoriteMembership> memberships =
        state.memberships
            .where(
              (FavoriteMembership membership) =>
                  exportedCollectionIds.contains(membership.collectionId),
            )
            .toList(growable: false)
          ..sort(
            (FavoriteMembership a, FavoriteMembership b) =>
                a.collectionId == b.collectionId
                ? b.addedAt.compareTo(a.addedAt)
                : a.collectionId.compareTo(b.collectionId),
          );
    final Set<String> referencedItemIds = memberships
        .map((FavoriteMembership membership) => membership.itemId)
        .toSet();
    final List<FavoriteEntry> entries =
        state.entries
            .where(
              (FavoriteEntry entry) => referencedItemIds.contains(entry.itemId),
            )
            .toList(growable: false)
          ..sort(
            (FavoriteEntry a, FavoriteEntry b) => a.itemId.compareTo(b.itemId),
          );
    final List<FavoriteCollection> collections =
        state.collections.toList(growable: false)
          ..sort((FavoriteCollection a, FavoriteCollection b) {
            if (a.isLikedCollection != b.isLikedCollection) {
              return a.isLikedCollection ? -1 : 1;
            }
            return a.createdAt.compareTo(b.createdAt);
          });

    return FavoritesTransferBundle(
      exportedAt: DateTime.now().toUtc(),
      collections: collections,
      entries: entries,
      memberships: memberships,
    );
  }

  FavoritesState _parseBytes(Uint8List bytes) {
    final String raw = utf8.decode(bytes, allowMalformed: false);
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FavoritesTransferException('导入文件格式不正确。');
    }

    final FavoritesTransferBundle bundle = FavoritesTransferBundle.fromJson(
      decoded,
    );
    if (bundle.schemaVersion != 1) {
      throw FavoritesTransferException('暂不支持版本 ${bundle.schemaVersion} 的导入文件。');
    }

    return _sanitizeImportedState(bundle);
  }

  FavoritesState _sanitizeImportedState(FavoritesTransferBundle bundle) {
    final Map<String, FavoriteCollection> collectionsById =
        <String, FavoriteCollection>{};
    for (final FavoriteCollection collection in bundle.collections) {
      final String name = collection.name.trim();
      if (collection.isLikedCollection) {
        collectionsById[FavoriteCollection.likedCollectionId] =
            FavoriteCollection(
              id: FavoriteCollection.likedCollectionId,
              name: '我喜欢',
              isSystem: true,
              createdAt: collection.createdAt,
              updatedAt: collection.updatedAt,
            );
        continue;
      }
      if (name.isEmpty) {
        continue;
      }
      collectionsById[collection.id] = collection.copyWith(
        name: name,
        isSystem: false,
      );
    }

    collectionsById.putIfAbsent(
      FavoriteCollection.likedCollectionId,
      FavoriteCollection.liked,
    );

    final Map<String, FavoriteEntry> entriesById = <String, FavoriteEntry>{};
    for (final FavoriteEntry entry in bundle.entries) {
      if (entry.itemId.trim().isEmpty) {
        continue;
      }
      final FavoriteEntry candidate = entry.copyWith(
        itemId: entry.itemId.trim(),
      );
      final FavoriteEntry? current = entriesById[candidate.itemId];
      entriesById[candidate.itemId] = _preferEntry(current, candidate);
    }

    final Map<String, FavoriteMembership> membershipsById =
        <String, FavoriteMembership>{};
    for (final FavoriteMembership membership in bundle.memberships) {
      String collectionId = membership.collectionId;
      if (collectionId == FavoriteCollection.likedCollectionId) {
        collectionId = FavoriteCollection.likedCollectionId;
      }
      if (!collectionsById.containsKey(collectionId)) {
        continue;
      }
      if (!entriesById.containsKey(membership.itemId)) {
        continue;
      }
      final FavoriteMembership normalized = FavoriteMembership(
        id: FavoriteMembership.membershipId(
          collectionId: collectionId,
          itemId: membership.itemId,
        ),
        collectionId: collectionId,
        itemId: membership.itemId,
        addedAt: membership.addedAt,
      );
      final FavoriteMembership? current = membershipsById[normalized.id];
      if (current == null || normalized.addedAt.isAfter(current.addedAt)) {
        membershipsById[normalized.id] = normalized;
      }
    }

    final Set<String> referencedItemIds = membershipsById.values
        .map((FavoriteMembership membership) => membership.itemId)
        .toSet();
    final List<FavoriteEntry> entries = entriesById.values
        .where(
          (FavoriteEntry entry) => referencedItemIds.contains(entry.itemId),
        )
        .toList(growable: false);

    return FavoritesState(
      collections: collectionsById.values.toList(growable: false),
      entries: entries,
      memberships: membershipsById.values.toList(growable: false),
    );
  }

  FavoritesState _applyImport({
    required FavoritesState currentState,
    required FavoritesState importedState,
    required bool importLikedCollection,
    required Set<String> selectedCollectionIds,
  }) {
    final _MutableFavorites mutable = _MutableFavorites.fromState(currentState);

    if (importLikedCollection) {
      _applyLikedImport(
        mutable: mutable,
        currentState: currentState,
        importedState: importedState,
      );
    }

    final Iterable<FavoriteCollection> importedCustomCollections = importedState
        .collections
        .where(
          (FavoriteCollection collection) =>
              !collection.isLikedCollection &&
              selectedCollectionIds.contains(collection.id),
        );

    for (final FavoriteCollection importedCollection
        in importedCustomCollections) {
      _createImportedCollection(
        mutable: mutable,
        importedState: importedState,
        importedCollection: importedCollection,
      );
    }

    return mutable.toState();
  }

  void _applyLikedImport({
    required _MutableFavorites mutable,
    required FavoritesState currentState,
    required FavoritesState importedState,
  }) {
    final DateTime now = DateTime.now();
    final List<FavoriteEntry> entries = importedState.itemsForCollection(
      FavoriteCollection.likedCollectionId,
    );
    for (final FavoriteEntry entry in entries) {
      mutable.upsertEntry(entry);
      mutable.upsertMembership(
        FavoriteMembership.create(
          collectionId: FavoriteCollection.likedCollectionId,
          itemId: entry.itemId,
          addedAt: _membershipAddedAt(
            importedState: importedState,
            collectionId: FavoriteCollection.likedCollectionId,
            itemId: entry.itemId,
          ),
        ),
      );
    }

    final FavoriteCollection currentLiked = currentState.likedCollection;
    mutable.collections[FavoriteCollection.likedCollectionId] = currentLiked
        .copyWith(updatedAt: now);
  }

  void _createImportedCollection({
    required _MutableFavorites mutable,
    required FavoritesState importedState,
    required FavoriteCollection importedCollection,
  }) {
    final String uniqueName = mutable.makeUniqueCollectionName(
      importedCollection.name,
    );
    final FavoriteCollection createdCollection = importedCollection.copyWith(
      id: _newCustomCollectionId(),
      name: uniqueName,
      isSystem: false,
    );
    mutable.collections[createdCollection.id] = createdCollection;

    for (final FavoriteEntry entry in importedState.itemsForCollection(
      importedCollection.id,
    )) {
      mutable.upsertEntry(entry);
      mutable.upsertMembership(
        FavoriteMembership.create(
          collectionId: createdCollection.id,
          itemId: entry.itemId,
          addedAt: _membershipAddedAt(
            importedState: importedState,
            collectionId: importedCollection.id,
            itemId: entry.itemId,
          ),
        ),
      );
    }
  }

  DateTime _membershipAddedAt({
    required FavoritesState importedState,
    required String collectionId,
    required String itemId,
  }) {
    for (final FavoriteMembership membership in importedState.memberships) {
      if (membership.collectionId == collectionId &&
          membership.itemId == itemId) {
        return membership.addedAt;
      }
    }
    return DateTime.now();
  }

  FavoriteEntry _preferEntry(FavoriteEntry? current, FavoriteEntry candidate) {
    if (current == null) {
      return candidate;
    }
    return candidate.updatedAt.isAfter(current.updatedAt) ? candidate : current;
  }

  String _normalizeCollectionName(String name) {
    return name.trim();
  }

  String _newCustomCollectionId() {
    return 'custom_${DateTime.now().microsecondsSinceEpoch}';
  }
}

class _MutableFavorites {
  _MutableFavorites({
    required this.collections,
    required this.entries,
    required this.memberships,
  });

  factory _MutableFavorites.fromState(FavoritesState state) {
    return _MutableFavorites(
      collections: <String, FavoriteCollection>{
        for (final FavoriteCollection collection in state.collections)
          collection.id: collection,
      },
      entries: <String, FavoriteEntry>{
        for (final FavoriteEntry entry in state.entries) entry.itemId: entry,
      },
      memberships: <String, FavoriteMembership>{
        for (final FavoriteMembership membership in state.memberships)
          membership.id: membership,
      },
    );
  }

  final Map<String, FavoriteCollection> collections;
  final Map<String, FavoriteEntry> entries;
  final Map<String, FavoriteMembership> memberships;

  void removeCollection(String collectionId) {
    collections.remove(collectionId);
    removeMembershipsForCollection(collectionId);
  }

  void removeMembershipsForCollection(String collectionId) {
    final List<String> membershipIds = memberships.values
        .where(
          (FavoriteMembership membership) =>
              membership.collectionId == collectionId,
        )
        .map((FavoriteMembership membership) => membership.id)
        .toList(growable: false);
    for (final String membershipId in membershipIds) {
      memberships.remove(membershipId);
    }
  }

  void upsertEntry(FavoriteEntry entry) {
    final FavoriteEntry? current = entries[entry.itemId];
    if (current == null || entry.updatedAt.isAfter(current.updatedAt)) {
      entries[entry.itemId] = entry;
    }
  }

  void upsertMembership(FavoriteMembership membership) {
    final FavoriteMembership? current = memberships[membership.id];
    if (current == null || membership.addedAt.isAfter(current.addedAt)) {
      memberships[membership.id] = membership;
    }
  }

  FavoriteCollection? findCustomCollectionByName(String normalizedName) {
    for (final FavoriteCollection collection in collections.values) {
      if (collection.isLikedCollection) {
        continue;
      }
      if (collection.name.trim() == normalizedName) {
        return collection;
      }
    }
    return null;
  }

  String makeUniqueCollectionName(String baseName) {
    final String trimmed = baseName.trim();
    if (findCustomCollectionByName(trimmed) == null) {
      return trimmed;
    }

    String candidate = '$trimmed（导入）';
    int index = 2;
    while (findCustomCollectionByName(candidate) != null) {
      candidate = '$trimmed（导入 $index）';
      index += 1;
    }
    return candidate;
  }

  FavoritesState toState() {
    final Set<String> referencedItemIds = memberships.values
        .map((FavoriteMembership membership) => membership.itemId)
        .toSet();
    final List<FavoriteCollection> nextCollections =
        collections.values.toList(growable: false)
          ..sort((FavoriteCollection a, FavoriteCollection b) {
            if (a.isLikedCollection != b.isLikedCollection) {
              return a.isLikedCollection ? -1 : 1;
            }
            return b.updatedAt.compareTo(a.updatedAt);
          });
    final List<FavoriteEntry> nextEntries = entries.values
        .where(
          (FavoriteEntry entry) => referencedItemIds.contains(entry.itemId),
        )
        .toList(growable: false);
    final List<FavoriteMembership> nextMemberships = memberships.values.toList(
      growable: false,
    );

    if (!collections.containsKey(FavoriteCollection.likedCollectionId)) {
      nextCollections.insert(0, FavoriteCollection.liked());
    }

    return FavoritesState(
      collections: nextCollections,
      entries: nextEntries,
      memberships: nextMemberships,
    );
  }
}

class FavoritesTransferException implements Exception {
  const FavoritesTransferException(this.message);

  final String message;

  @override
  String toString() => message;
}
