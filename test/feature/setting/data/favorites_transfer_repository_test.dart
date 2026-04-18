import 'dart:convert';
import 'dart:io';

import 'package:bilimusic/core/hive/hive_adapters.dart';
import 'package:bilimusic/feature/favorites/data/favorites_local_repository.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/setting/data/favorites_transfer_repository.dart';
import 'package:bilimusic/feature/setting/domain/favorites_transfer_bundle.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDirectory;
  late Box<FavoriteCollection> collectionsBox;
  late Box<FavoriteEntry> entriesBox;
  late Box<FavoriteMembership> membershipsBox;
  late FavoritesLocalRepository favoritesRepository;
  late FavoritesTransferRepository transferRepository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'favorites-transfer-test-',
    );
    Hive.init(tempDirectory.path);
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(FavoriteCollectionAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(FavoriteEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(FavoriteMembershipAdapter());
    }

    collectionsBox = await Hive.openBox<FavoriteCollection>(
      favoriteCollectionsBoxName,
    );
    entriesBox = await Hive.openBox<FavoriteEntry>(favoriteEntriesBoxName);
    membershipsBox = await Hive.openBox<FavoriteMembership>(
      favoriteMembershipsBoxName,
    );
    favoritesRepository = FavoritesLocalRepository(
      collectionsBox: collectionsBox,
      entriesBox: entriesBox,
      membershipsBox: membershipsBox,
    );
    transferRepository = FavoritesTransferRepository(
      favoritesRepository: favoritesRepository,
    );
    await favoritesRepository.initialize();
  });

  tearDown(() async {
    await collectionsBox.close();
    await entriesBox.close();
    await membershipsBox.close();
    await Hive.deleteBoxFromDisk(favoriteCollectionsBoxName);
    await Hive.deleteBoxFromDisk(favoriteEntriesBoxName);
    await Hive.deleteBoxFromDisk(favoriteMembershipsBoxName);
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('buildExportJson exports only referenced entries', () async {
    final DateTime now = DateTime(2026, 4, 9, 12);
    final FavoriteCollection custom = FavoriteCollection(
      id: 'custom_1',
      name: '夜间循环',
      isSystem: false,
      createdAt: now,
      updatedAt: now,
    );
    final FavoriteEntry likedEntry = _entry(
      itemId: 'aid:1',
      title: 'liked',
      updatedAt: now,
    );
    final FavoriteEntry customEntry = _entry(
      itemId: 'aid:2',
      title: 'custom',
      updatedAt: now.add(const Duration(minutes: 1)),
    );
    final FavoriteEntry orphanEntry = _entry(
      itemId: 'aid:404',
      title: 'orphan',
      updatedAt: now.add(const Duration(minutes: 2)),
    );

    await favoritesRepository.saveAll(
      collections: <FavoriteCollection>[
        FavoriteCollection.liked(now: now),
        custom,
      ],
      entries: <FavoriteEntry>[likedEntry, customEntry, orphanEntry],
      memberships: <FavoriteMembership>[
        FavoriteMembership.create(
          collectionId: FavoriteCollection.likedCollectionId,
          itemId: likedEntry.itemId,
          addedAt: now,
        ),
        FavoriteMembership.create(
          collectionId: custom.id,
          itemId: customEntry.itemId,
          addedAt: now,
        ),
      ],
    );

    final String exported = await transferRepository.buildExportJson();
    final FavoritesTransferBundle bundle = FavoritesTransferBundle.fromJson(
      jsonDecode(exported) as Map<String, dynamic>,
    );

    expect(
      bundle.collections.map((FavoriteCollection item) => item.id),
      containsAll(<String>['liked', 'custom_1']),
    );
    expect(
      bundle.entries.map((FavoriteEntry item) => item.itemId),
      containsAll(<String>['aid:1', 'aid:2']),
    );
    expect(
      bundle.entries.map((FavoriteEntry item) => item.itemId),
      isNot(contains('aid:404')),
    );
  });

  test(
    'importBytes merges liked items and creates copy for same-name playlist',
    () async {
      final DateTime now = DateTime(2026, 4, 9, 18);
      final FavoriteCollection localCustom = FavoriteCollection(
        id: 'custom_local',
        name: '夜间循环',
        isSystem: false,
        createdAt: now,
        updatedAt: now,
      );
      final FavoriteEntry localLiked = _entry(
        itemId: 'aid:10',
        title: 'local liked',
        updatedAt: now,
      );
      final FavoriteEntry localCustomEntry = _entry(
        itemId: 'aid:11',
        title: 'local custom',
        updatedAt: now,
      );

      await favoritesRepository.replaceAll(
        FavoritesState(
          collections: <FavoriteCollection>[
            FavoriteCollection.liked(now: now),
            localCustom,
          ],
          entries: <FavoriteEntry>[localLiked, localCustomEntry],
          memberships: <FavoriteMembership>[
            FavoriteMembership.create(
              collectionId: FavoriteCollection.likedCollectionId,
              itemId: localLiked.itemId,
              addedAt: now,
            ),
            FavoriteMembership.create(
              collectionId: localCustom.id,
              itemId: localCustomEntry.itemId,
              addedAt: now,
            ),
          ],
        ),
      );

      final FavoriteCollection importedCustom = FavoriteCollection(
        id: 'custom_imported',
        name: '夜间循环',
        isSystem: false,
        createdAt: now.add(const Duration(days: 1)),
        updatedAt: now.add(const Duration(days: 1)),
      );
      final FavoriteEntry importedLiked = _entry(
        itemId: 'aid:20',
        title: 'imported liked',
        updatedAt: now.add(const Duration(days: 1)),
      );
      final FavoriteEntry importedCustomEntry = _entry(
        itemId: 'aid:21',
        title: 'imported custom',
        updatedAt: now.add(const Duration(days: 1, minutes: 1)),
      );
      final FavoritesTransferBundle bundle = FavoritesTransferBundle(
        exportedAt: now.toUtc(),
        collections: <FavoriteCollection>[
          FavoriteCollection.liked(now: now.add(const Duration(days: 1))),
          importedCustom,
        ],
        entries: <FavoriteEntry>[importedLiked, importedCustomEntry],
        memberships: <FavoriteMembership>[
          FavoriteMembership.create(
            collectionId: FavoriteCollection.likedCollectionId,
            itemId: importedLiked.itemId,
            addedAt: now.add(const Duration(days: 1)),
          ),
          FavoriteMembership.create(
            collectionId: importedCustom.id,
            itemId: importedCustomEntry.itemId,
            addedAt: now.add(const Duration(days: 1)),
          ),
        ],
      );

      await transferRepository.importBytes(
        bytes: utf8.encode(jsonEncode(bundle.toJson())),
        importLikedCollection: true,
        selectedCollectionIds: <String>{importedCustom.id},
      );

      final FavoritesState result = favoritesRepository.loadState();

      expect(
        result.itemCountForCollection(FavoriteCollection.likedCollectionId),
        2,
      );
      expect(
        result
            .itemsForCollection(FavoriteCollection.likedCollectionId)
            .map((FavoriteEntry item) => item.itemId),
        containsAll(<String>['aid:10', 'aid:20']),
      );

      final List<FavoriteCollection> customCollections = result.collections
          .where(
            (FavoriteCollection collection) => !collection.isLikedCollection,
          )
          .toList(growable: false);
      expect(customCollections, hasLength(2));
      expect(
        customCollections.map((FavoriteCollection item) => item.name),
        containsAll(<String>['夜间循环', '夜间循环（导入）']),
      );

      final FavoriteCollection importedCopy = customCollections.firstWhere(
        (FavoriteCollection collection) => collection.name == '夜间循环（导入）',
      );
      expect(
        result
            .itemsForCollection(importedCopy.id)
            .map((FavoriteEntry item) => item.itemId),
        <String>['aid:21'],
      );
    },
  );
}

FavoriteEntry _entry({
  required String itemId,
  required String title,
  required DateTime updatedAt,
}) {
  return FavoriteEntry(
    itemId: itemId,
    aid: int.tryParse(itemId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
    bvid: '',
    title: title,
    author: 'tester',
    coverUrl: 'https://example.com/$itemId.jpg',
    createdAt: updatedAt,
    updatedAt: updatedAt,
  );
}
