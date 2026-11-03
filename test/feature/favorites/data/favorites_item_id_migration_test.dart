import 'dart:io';

import 'package:bilimusic/core/hive/hive_adapters.dart';
import 'package:bilimusic/feature/favorites/data/favorites_item_id_migration.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

const String _entriesBoxName = 'migration_test_entries';
const String _membershipsBoxName = 'migration_test_memberships';

void main() {
  late Directory tempDirectory;
  late Box<FavoriteEntry> entriesBox;
  late Box<FavoriteMembership> membershipsBox;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'favorites-migration-test-',
    );
    Hive.init(tempDirectory.path);
    final FavoriteEntryAdapter entryAdapter = FavoriteEntryAdapter();
    if (!Hive.isAdapterRegistered(entryAdapter.typeId)) {
      Hive.registerAdapter(entryAdapter);
    }
    final FavoriteMembershipAdapter membershipAdapter =
        FavoriteMembershipAdapter();
    if (!Hive.isAdapterRegistered(membershipAdapter.typeId)) {
      Hive.registerAdapter(membershipAdapter);
    }
    entriesBox = await Hive.openBox<FavoriteEntry>(_entriesBoxName);
    membershipsBox = await Hive.openBox<FavoriteMembership>(
      _membershipsBoxName,
    );
  });

  tearDown(() async {
    await entriesBox.close();
    await membershipsBox.close();
    await Hive.deleteBoxFromDisk(_entriesBoxName);
    await Hive.deleteBoxFromDisk(_membershipsBoxName);
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('裸 bvid 迁移为规范 id 并改写成员关系', () async {
    await entriesBox.put('BV1', _entry(itemId: 'BV1', bvid: 'BV1'));
    await membershipsBox.put(
      'liked::BV1',
      _membership(collectionId: 'liked', itemId: 'BV1'),
    );

    final int changed = await migrateFavoriteItemIds(
      entriesBox: entriesBox,
      membershipsBox: membershipsBox,
    );

    expect(changed, 2);
    expect(entriesBox.keys, <String>['bvid:BV1']);
    expect(entriesBox.get('bvid:BV1')?.itemId, 'bvid:BV1');
    expect(membershipsBox.keys, <String>['liked::bvid:BV1']);
    expect(membershipsBox.get('liked::bvid:BV1')?.itemId, 'bvid:BV1');
  });

  test('带 bvid 的 aid 形式迁移为 bvid 形式', () async {
    await entriesBox.put(
      'aid:42',
      _entry(itemId: 'aid:42', aid: 42, bvid: 'BV2'),
    );
    await membershipsBox.put(
      'custom:1::aid:42',
      _membership(collectionId: 'custom:1', itemId: 'aid:42'),
    );

    await migrateFavoriteItemIds(
      entriesBox: entriesBox,
      membershipsBox: membershipsBox,
    );

    expect(entriesBox.keys, <String>['bvid:BV2']);
    expect(membershipsBox.keys, <String>['custom:1::bvid:BV2']);
  });

  test('合并规范化后同 id 的重复条目与重复成员关系', () async {
    await entriesBox.put(
      'BV3',
      _entry(itemId: 'BV3', bvid: 'BV3', pageTitle: '分P'),
    );
    await entriesBox.put('bvid:BV3', _entry(itemId: 'bvid:BV3', bvid: 'BV3'));
    await entriesBox.put(
      'bvid:BV3:cid:99',
      _entry(itemId: 'bvid:BV3:cid:99', bvid: 'BV3', cid: 99),
    );
    await membershipsBox.put(
      'liked::BV3',
      _membership(
        collectionId: 'liked',
        itemId: 'BV3',
        addedAt: DateTime(2026, 1, 2),
      ),
    );
    await membershipsBox.put(
      'liked::bvid:BV3',
      _membership(
        collectionId: 'liked',
        itemId: 'bvid:BV3',
        addedAt: DateTime(2026, 1, 1),
      ),
    );
    await membershipsBox.put(
      'liked::bvid:BV3:cid:99',
      _membership(collectionId: 'liked', itemId: 'bvid:BV3:cid:99'),
    );

    await migrateFavoriteItemIds(
      entriesBox: entriesBox,
      membershipsBox: membershipsBox,
    );

    expect(entriesBox.keys.toSet(), <String>{'bvid:BV3', 'bvid:BV3:cid:99'});
    expect(entriesBox.get('bvid:BV3')?.pageTitle, '分P');
    expect(membershipsBox.keys.toSet(), <String>{
      'liked::bvid:BV3',
      'liked::bvid:BV3:cid:99',
    });
    expect(
      membershipsBox.get('liked::bvid:BV3')?.addedAt,
      DateTime(2026, 1, 1),
    );
  });

  test('已规范的数据不做任何改写', () async {
    await entriesBox.put(
      'bvid:BV4:cid:7',
      _entry(itemId: 'bvid:BV4:cid:7', bvid: 'BV4', cid: 7),
    );
    await membershipsBox.put(
      'liked::bvid:BV4:cid:7',
      _membership(collectionId: 'liked', itemId: 'bvid:BV4:cid:7'),
    );

    final int changed = await migrateFavoriteItemIds(
      entriesBox: entriesBox,
      membershipsBox: membershipsBox,
    );

    expect(changed, 0);
    expect(entriesBox.keys, <String>['bvid:BV4:cid:7']);
  });

  test('引用未知条目的成员关系保持原样', () async {
    await membershipsBox.put(
      'liked::aid:404',
      _membership(collectionId: 'liked', itemId: 'aid:404'),
    );

    final int changed = await migrateFavoriteItemIds(
      entriesBox: entriesBox,
      membershipsBox: membershipsBox,
    );

    expect(changed, 0);
    expect(membershipsBox.keys, <String>['liked::aid:404']);
  });
}

FavoriteEntry _entry({
  required String itemId,
  String bvid = '',
  int aid = 0,
  int? cid,
  String? pageTitle,
}) {
  return FavoriteEntry(
    itemId: itemId,
    aid: aid,
    bvid: bvid,
    title: 'Title',
    author: 'Author',
    coverUrl: '',
    cid: cid,
    page: 1,
    pageTitle: pageTitle,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 3),
  );
}

FavoriteMembership _membership({
  required String collectionId,
  required String itemId,
  DateTime? addedAt,
}) {
  return FavoriteMembership.create(
    collectionId: collectionId,
    itemId: itemId,
    addedAt: addedAt ?? DateTime(2026, 1, 1),
  );
}
