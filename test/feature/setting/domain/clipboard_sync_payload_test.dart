import 'dart:convert';

import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/setting/domain/clipboard_sync_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('encodes and decodes ultra compact BM3 favorites payload', () {
    final DateTime now = DateTime.fromMillisecondsSinceEpoch(1710000000000);
    final FavoritesState favoritesState = FavoritesState(
      collections: <FavoriteCollection>[
        FavoriteCollection.liked(now: now),
        FavoriteCollection(
          id: 'custom_1',
          name: '歌单',
          createdAt: now,
          updatedAt: now,
        ),
      ],
      entries: <FavoriteEntry>[_entry('bvid:BV1:cid:11', now)],
      memberships: <FavoriteMembership>[
        FavoriteMembership.create(
          collectionId: FavoriteCollection.likedCollectionId,
          itemId: 'bvid:BV1:cid:11',
          addedAt: now,
        ),
      ],
    );
    final ClipboardSyncPayload payload = ClipboardSyncPayload(
      userId: '123',
      updatedAtEpochMs: now.millisecondsSinceEpoch,
      favoritesState: favoritesState,
      settings: const <String, String>{'player.blacklist_entries': '[]'},
    );

    final String encoded = payload.toJsonString();
    final ClipboardSyncPayload decoded = ClipboardSyncPayload.fromJsonString(
      encoded,
    );

    expect(encoded, startsWith('BM3\n'));
    expect(encoded, contains('L:1#11'));
    expect(encoded, isNot(contains('投稿')));
    expect(encoded, isNot(contains('作者')));
    expect(encoded, isNot(contains('cover')));
    expect(encoded, isNot(contains('player.blacklist_entries')));
    expect(decoded.userId, isEmpty);
    expect(decoded.favoritesState.collections, hasLength(1));
    expect(decoded.favoritesState.entries.single.itemId, 'bvid:BV1:cid:11');
    expect(decoded.favoritesState.entries.single.pageTitle, isNull);
    expect(decoded.settings, isEmpty);
  });

  test('escapes playlist names in BM3 payload', () {
    final DateTime now = DateTime.fromMillisecondsSinceEpoch(1710000000000);
    final FavoritesState favoritesState = FavoritesState(
      collections: <FavoriteCollection>[
        FavoriteCollection(
          id: 'custom_1',
          name: '歌单,一=换\n行',
          createdAt: now,
          updatedAt: now,
        ),
      ],
      entries: <FavoriteEntry>[_entry('aid:123:cid:456', now)],
      memberships: <FavoriteMembership>[
        FavoriteMembership.create(
          collectionId: 'custom_1',
          itemId: 'aid:123:cid:456',
          addedAt: now,
        ),
      ],
    );

    final ClipboardSyncPayload decoded = ClipboardSyncPayload.fromJsonString(
      ClipboardSyncPayload(
        userId: '123',
        updatedAtEpochMs: now.millisecondsSinceEpoch,
        favoritesState: favoritesState,
        settings: const <String, String>{},
      ).toJsonString(),
    );

    expect(
      decoded.favoritesState.collections
          .where(
            (FavoriteCollection collection) => !collection.isLikedCollection,
          )
          .single
          .name,
      '歌单,一=换\n行',
    );
    expect(decoded.favoritesState.entries.single.itemId, 'aid:123:cid:456');
    expect(
      ClipboardSyncPayload(
        userId: '123',
        updatedAtEpochMs: now.millisecondsSinceEpoch,
        favoritesState: favoritesState,
        settings: const <String, String>{},
      ).toJsonString(),
      contains('a123#456'),
    );
  });

  test('decodes legacy json payload', () {
    final DateTime now = DateTime.fromMillisecondsSinceEpoch(1710000000000);
    final String legacyPayload = jsonEncode(<String, dynamic>{
      'v': 1,
      'u': '123',
      't': now.millisecondsSinceEpoch,
      'c': <List<dynamic>>[
        <dynamic>[
          FavoriteCollection.likedCollectionId,
          '我喜欢',
          'local',
          1,
          null,
          null,
          0,
          0,
          null,
          now.millisecondsSinceEpoch,
          now.millisecondsSinceEpoch,
        ],
      ],
      'e': <List<dynamic>>[_entryToLegacyRow(_entry('bvid:BV1:cid:11', now))],
      'm': <List<dynamic>>[
        <dynamic>[
          'liked::bvid:BV1:cid:11',
          FavoriteCollection.likedCollectionId,
          'bvid:BV1:cid:11',
          now.millisecondsSinceEpoch,
        ],
      ],
      's': <String, String>{'player.blacklist_entries': '[]'},
    });

    final ClipboardSyncPayload decoded = ClipboardSyncPayload.fromJsonString(
      legacyPayload,
    );

    expect(decoded.userId, '123');
    expect(decoded.favoritesState.entries.single.pageTitle, '分段名');
    expect(decoded.favoritesState.memberships.single.addedAt, now);
    expect(decoded.settings['player.blacklist_entries'], '[]');
  });

  test('decodes previous BM3 refs with BV and av prefixes', () {
    final ClipboardSyncPayload decoded = ClipboardSyncPayload.fromJsonString(
      'BM3\nL:BV1#11,av123#456',
    );

    expect(
      decoded.favoritesState.entries.map((FavoriteEntry entry) => entry.itemId),
      containsAll(<String>['bvid:BV1:cid:11', 'aid:123:cid:456']),
    );
  });

  test('groups repeated BV ids and merges same-name playlists', () {
    final DateTime now = DateTime.fromMillisecondsSinceEpoch(1710000000000);
    final FavoritesState favoritesState = FavoritesState(
      collections: <FavoriteCollection>[
        FavoriteCollection(
          id: 'custom_1',
          name: 'music',
          createdAt: now,
          updatedAt: now,
        ),
        FavoriteCollection(
          id: 'custom_2',
          name: 'music',
          createdAt: now,
          updatedAt: now,
        ),
      ],
      entries: <FavoriteEntry>[
        _entry('bvid:BV1az4ceJEhk:cid:101', now),
        _entry('bvid:BV1az4ceJEhk:cid:102', now),
        _entry('bvid:BV1az4ceJEhk:cid:103', now),
      ],
      memberships: <FavoriteMembership>[
        FavoriteMembership.create(
          collectionId: 'custom_1',
          itemId: 'bvid:BV1az4ceJEhk:cid:101',
          addedAt: now,
        ),
        FavoriteMembership.create(
          collectionId: 'custom_1',
          itemId: 'bvid:BV1az4ceJEhk:cid:102',
          addedAt: now,
        ),
        FavoriteMembership.create(
          collectionId: 'custom_2',
          itemId: 'bvid:BV1az4ceJEhk:cid:103',
          addedAt: now,
        ),
      ],
    );

    final String encoded = ClipboardSyncPayload(
      userId: '123',
      updatedAtEpochMs: now.millisecondsSinceEpoch,
      favoritesState: favoritesState,
      settings: const <String, String>{},
    ).toJsonString();
    final ClipboardSyncPayload decoded = ClipboardSyncPayload.fromJsonString(
      encoded,
    );

    expect(_occurrences(encoded, 'P:music='), 1);
    expect(encoded, contains('P:music=1az4ceJEhk#101.102.103'));
    expect(_occurrences(encoded, '1az4ceJEhk'), 1);
    expect(
      decoded.favoritesState.entries.map((FavoriteEntry entry) => entry.itemId),
      containsAll(<String>[
        'bvid:BV1az4ceJEhk:cid:101',
        'bvid:BV1az4ceJEhk:cid:102',
        'bvid:BV1az4ceJEhk:cid:103',
      ]),
    );
  });

  test('merge keeps local duplicate entries and imports remote-only items', () {
    final DateTime now = DateTime.fromMillisecondsSinceEpoch(1710000000000);
    final FavoriteEntry localEntry = _entry(
      'bvid:BV1:cid:11',
      now,
    ).copyWith(title: 'local');
    final FavoriteEntry remoteDuplicate = _entry(
      'bvid:BV1:cid:11',
      now,
    ).copyWith(title: 'remote');
    final FavoriteEntry remoteOnly = _entry('bvid:BV2:cid:22', now);

    final FavoritesState merged = mergeClipboardFavorites(
      localState: FavoritesState(
        collections: <FavoriteCollection>[FavoriteCollection.liked(now: now)],
        entries: <FavoriteEntry>[localEntry],
        memberships: <FavoriteMembership>[
          FavoriteMembership.create(
            collectionId: FavoriteCollection.likedCollectionId,
            itemId: localEntry.itemId,
            addedAt: now,
          ),
        ],
      ),
      remoteState: FavoritesState(
        collections: <FavoriteCollection>[FavoriteCollection.liked(now: now)],
        entries: <FavoriteEntry>[remoteDuplicate, remoteOnly],
        memberships: <FavoriteMembership>[
          FavoriteMembership.create(
            collectionId: FavoriteCollection.likedCollectionId,
            itemId: remoteDuplicate.itemId,
            addedAt: now,
          ),
          FavoriteMembership.create(
            collectionId: FavoriteCollection.likedCollectionId,
            itemId: remoteOnly.itemId,
            addedAt: now,
          ),
        ],
      ),
    );

    expect(merged.entries, hasLength(2));
    expect(
      merged.entries
          .firstWhere(
            (FavoriteEntry entry) => entry.itemId == localEntry.itemId,
          )
          .title,
      'local',
    );
    expect(merged.memberships, hasLength(2));
  });

  test('rejects unsupported payload versions', () {
    expect(
      () => ClipboardSyncPayload.fromJsonString(
        jsonEncode(<String, dynamic>{'v': 999}),
      ),
      throwsFormatException,
    );
  });
}

FavoriteEntry _entry(String itemId, DateTime now) {
  return FavoriteEntry(
    itemId: itemId,
    aid: 1,
    bvid: 'BV1',
    title: '投稿',
    author: '作者',
    coverUrl: 'cover',
    ownerMid: 100,
    cid: 11,
    page: 1,
    pageTitle: '分段名',
    durationText: '03:00',
    createdAt: now,
    updatedAt: now,
  );
}

List<dynamic> _entryToLegacyRow(FavoriteEntry entry) {
  return <dynamic>[
    entry.itemId,
    entry.aid,
    entry.bvid,
    entry.title,
    entry.author,
    entry.coverUrl,
    entry.ownerMid,
    entry.cid,
    entry.page,
    entry.pageTitle,
    entry.durationText,
    entry.createdAt.millisecondsSinceEpoch,
    entry.updatedAt.millisecondsSinceEpoch,
  ];
}

int _occurrences(String value, String pattern) {
  return RegExp(RegExp.escape(pattern)).allMatches(value).length;
}
