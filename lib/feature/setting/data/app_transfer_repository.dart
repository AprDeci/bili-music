import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/favorites/data/favorites_local_repository.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/setting/domain/app_transfer_bundle.dart';
import 'package:bilimusic/feature/setting/domain/app_import_preview.dart';
import 'package:bilimusic/feature/setting/domain/favorites_transfer_bundle.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_transfer_repository.g.dart';

@riverpod
AppTransferRepository appTransferRepository(Ref ref) {
  return AppTransferRepository(
    favoritesRepository: ref.read(favoritesLocalRepositoryProvider),
    settingsStore: ref.read(appSettingsStoreProvider),
  );
}

class AppTransferRepository {
  AppTransferRepository({
    required FavoritesLocalRepository favoritesRepository,
    required AppSettingsStore settingsStore,
  }) : _favoritesRepository = favoritesRepository,
       _settingsStore = settingsStore;

  final FavoritesLocalRepository _favoritesRepository;
  final AppSettingsStore _settingsStore;

  static const List<_TransferSettingKey> _settingKeys = <_TransferSettingKey>[
    _TransferSettingKey(key: HiveKeys.themeMode, defaultValue: ''),
    _TransferSettingKey(key: HiveKeys.themeVariant, defaultValue: ''),
    _TransferSettingKey(key: HiveKeys.lightThemeVariant, defaultValue: ''),
    _TransferSettingKey(
      key: HiveKeys.appearanceUseGlassBar,
      defaultValue: 'true',
    ),
    _TransferSettingKey(
      key: HiveKeys.playerAllowMixWithOthers,
      defaultValue: 'false',
    ),
    _TransferSettingKey(
      key: HiveKeys.playerAudioQualityPreference,
      defaultValue: 'auto',
    ),
    _TransferSettingKey(key: HiveKeys.metingBaseUrl, defaultValue: ''),
  ];

  Future<String> buildExportJson() async {
    final FavoritesState state = _favoritesRepository.loadState();
    final AppTransferBundle bundle = AppTransferBundle(
      exportedAt: DateTime.now().toUtc(),
      favorites: _buildExportBundle(state),
      settings: _readExportedSettings(),
    );
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

  Future<AppImportPreview> previewImport(Uint8List bytes) async {
    final _ParsedTransfer parsed = _parseBytes(bytes);
    final FavoritesState importedState = parsed.favoritesState;
    final FavoritesState localState = _favoritesRepository.loadState();
    final Set<String> localNames = localState.collections
        .where((FavoriteCollection collection) => !collection.isLikedCollection)
        .map(
          (FavoriteCollection collection) =>
              _normalizeCollectionName(collection.name),
        )
        .where((String name) => name.isNotEmpty)
        .toSet();

    final List<AppImportCollectionPreview> collections = importedState
        .collections
        .map((FavoriteCollection collection) {
          final bool hasNameConflict =
              !collection.isLikedCollection &&
              localNames.contains(_normalizeCollectionName(collection.name));
          return AppImportCollectionPreview(
            sourceCollectionId: collection.id,
            name: collection.name,
            isLikedCollection: collection.isLikedCollection,
            itemCount: importedState.itemCountForCollection(collection.id),
            hasNameConflict: hasNameConflict,
          );
        })
        .toList(growable: false);

    return AppImportPreview(
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
      hasSettings: parsed.settings.isNotEmpty,
      collections: collections,
      conflictingCollectionNames: collections
          .where(
            (AppImportCollectionPreview collection) =>
                collection.hasNameConflict,
          )
          .map((AppImportCollectionPreview collection) => collection.name)
          .toSet(),
    );
  }

  Future<void> importBytes({
    required Uint8List bytes,
    required bool importLikedCollection,
    required Set<String> selectedCollectionIds,
    required bool importSettings,
  }) async {
    final _ParsedTransfer parsed = _parseBytes(bytes);
    final FavoritesState importedState = parsed.favoritesState;
    final FavoritesState currentState = _favoritesRepository.loadState();
    final FavoritesState nextState = _applyImport(
      currentState: currentState,
      importedState: importedState,
      importLikedCollection: importLikedCollection,
      selectedCollectionIds: selectedCollectionIds,
    );
    await _favoritesRepository.replaceAll(nextState);
    if (importSettings && parsed.settings.isNotEmpty) {
      await _applyImportedSettings(parsed.settings);
    }
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

  _ParsedTransfer _parseBytes(Uint8List bytes) {
    final String raw = utf8.decode(bytes, allowMalformed: false);
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const AppTransferException('导入文件格式不正确。');
    }

    if (decoded.containsKey('favorites')) {
      final AppTransferBundle bundle = AppTransferBundle.fromJson(decoded);
      if (bundle.schemaVersion != 2) {
        throw AppTransferException('暂不支持版本 ${bundle.schemaVersion} 的导入文件。');
      }

      return _ParsedTransfer(
        favoritesState: _sanitizeImportedState(bundle.favorites),
        settings: _sanitizeImportedSettings(bundle.settings),
      );
    }

    final FavoritesTransferBundle bundle = FavoritesTransferBundle.fromJson(
      decoded,
    );
    if (bundle.schemaVersion != 1) {
      throw AppTransferException('暂不支持版本 ${bundle.schemaVersion} 的导入文件。');
    }

    return _ParsedTransfer(
      favoritesState: _sanitizeImportedState(bundle),
      settings: const <String, String>{},
    );
  }

  Map<String, String> _readExportedSettings() {
    return <String, String>{
      for (final _TransferSettingKey item in _settingKeys)
        item.key: _settingsStore.readString(
          item.key,
          defaultValue: item.defaultValue,
        ),
    };
  }

  Map<String, String> _sanitizeImportedSettings(Map<String, String> settings) {
    final Set<String> allowedKeys = _settingKeys
        .map((_TransferSettingKey item) => item.key)
        .toSet();
    return <String, String>{
      for (final MapEntry<String, String> entry in settings.entries)
        if (allowedKeys.contains(entry.key)) entry.key: entry.value,
    };
  }

  Future<void> _applyImportedSettings(Map<String, String> settings) async {
    await Future.wait(<Future<void>>[
      for (final MapEntry<String, String> entry in settings.entries)
        _settingsStore.writeString(entry.key, entry.value),
    ]);
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

class _TransferSettingKey {
  const _TransferSettingKey({required this.key, required this.defaultValue});

  final String key;
  final String defaultValue;
}

class _ParsedTransfer {
  const _ParsedTransfer({required this.favoritesState, required this.settings});

  final FavoritesState favoritesState;
  final Map<String, String> settings;
}

class AppTransferException implements Exception {
  const AppTransferException(this.message);

  final String message;

  @override
  String toString() => message;
}
