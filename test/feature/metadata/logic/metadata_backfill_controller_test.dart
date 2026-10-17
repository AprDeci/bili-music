import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bilimusic/core/hive/hive_adapters.dart';
import 'package:bilimusic/feature/favorites/data/favorites_local_repository.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:bilimusic/feature/metadata/data/metadata_cache_repository.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_backfill_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_backfill_controller.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_lookup_service.dart';
import 'package:bilimusic/feature/meting/data/meting_repository.dart';
import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDirectory;
  late LazyBox<Metadata> metadataBox;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('backfill-test-');
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
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(MetaLyricsAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(MetadataAdapter());
    }
    await Hive.openBox<FavoriteCollection>(favoriteCollectionsBoxName);
    await Hive.openBox<FavoriteEntry>(favoriteEntriesBoxName);
    await Hive.openBox<FavoriteMembership>(favoriteMembershipsBoxName);
    metadataBox = await Hive.openLazyBox<Metadata>(metadataCacheBoxName);
  });

  tearDown(() async {
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('enqueue matches and caches metadata without a playing item', () async {
    final ProviderContainer container = _container(
      searchRequest: _hitSearchRequest,
      lyricRequest: _hitLyricRequest,
    );
    addTearDown(container.dispose);

    container
        .read(metadataBackfillControllerProvider.notifier)
        .enqueue(_item(bvid: 'BV1'));
    await _waitIdle(container);

    final MetadataBackfillState state = container.read(
      metadataBackfillControllerProvider,
    );
    expect(state.processed, 1);
    expect(state.matched, 1);

    final Metadata? cached = await metadataBox.get('metadata:bvid:BV1:page:1');
    expect(cached?.hasContent, isTrue);
    expect(cached?.artist, '周杰伦');
  });

  test('enqueue deduplicates the same content id', () async {
    final ProviderContainer container = _container(
      searchRequest: _missSearchRequest,
    );
    addTearDown(container.dispose);

    final PlayableItem item = _item(bvid: 'BV2');
    final MetadataBackfillController controller = container.read(
      metadataBackfillControllerProvider.notifier,
    );
    controller.enqueue(item);
    controller.enqueue(item);
    await _waitIdle(container);

    expect(container.read(metadataBackfillControllerProvider).total, 1);
    expect(container.read(metadataBackfillControllerProvider).processed, 1);
  });

  test('failed match is retryable through backfillMissing', () async {
    final ProviderContainer container = _container(
      searchRequest: _missSearchRequest,
    );
    addTearDown(container.dispose);

    final PlayableItem item = _item(bvid: 'BV3');
    container.read(metadataBackfillControllerProvider.notifier).enqueue(item);
    await _waitIdle(container);

    final Metadata? failed = await metadataBox.get('metadata:bvid:BV3:page:1');
    expect(failed?.hasContent, isFalse);

    final MetadataBackfillController controller = container.read(
      metadataBackfillControllerProvider.notifier,
    );
    final int requeued = await controller.backfillMissing(<PlayableItem>[item]);
    await _waitIdle(container);

    expect(requeued, 1);
    expect(container.read(metadataBackfillControllerProvider).processed, 1);
  });

  test('backfillMissing skips items that already have content', () async {
    await metadataBox.put(
      'metadata:bvid:BV4:page:1',
      const Metadata(stableId: 'bvid:BV4:cid:1', title: '已匹配'),
    );
    final ProviderContainer container = _container(
      searchRequest: _missSearchRequest,
    );
    addTearDown(container.dispose);

    final MetadataBackfillController controller = container.read(
      metadataBackfillControllerProvider.notifier,
    );
    final int queued = await controller.backfillMissing(<PlayableItem>[
      _item(bvid: 'BV4'),
      _item(bvid: 'BV5'),
    ]);
    await _waitIdle(container);

    expect(queued, 1);
    expect(container.read(metadataBackfillControllerProvider).processed, 1);
  });

  test('cancel then re-click resumes scanning remaining items', () async {
    final Map<String, int> searchCalls = <String, int>{};
    final ProviderContainer container = _container(
      searchRequest:
          ({
            required MetingServer server,
            required String keyword,
            required Map<String, dynamic> option,
          }) async {
            searchCalls.update(
              keyword,
              (int count) => count + 1,
              ifAbsent: () => 1,
            );
            return jsonEncode(<Map<String, dynamic>>[
              <String, dynamic>{
                'id': '1',
                'name': '晴天',
                'artist': <String>['周杰伦'],
                'lyric_id': '1',
              },
            ]);
          },
      lyricRequest: ({required MetingServer server, required String id}) async {
        return jsonEncode(<String, dynamic>{'lyric': '[00:00.000] 歌词'});
      },
    );
    addTearDown(container.dispose);

    final MetadataBackfillController controller = container.read(
      metadataBackfillControllerProvider.notifier,
    );
    final List<PlayableItem> items = <PlayableItem>[
      _item(bvid: 'BV10', title: '歌曲A'),
      _item(bvid: 'BV11', title: '歌曲B'),
      _item(bvid: 'BV12', title: '歌曲C'),
    ];

    unawaited(controller.backfillMissing(items));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    controller.cancel();
    await _waitIdle(container);

    expect(
      container.read(metadataBackfillControllerProvider).isRunning,
      isFalse,
    );

    final int requeued = await controller.backfillMissing(items);
    await _waitIdle(container);

    expect(requeued, greaterThan(0));
    expect(
      searchCalls.values.every((int count) => count == 1),
      isTrue,
      reason: '已匹配的条目不应被重复请求',
    );
    for (final PlayableItem item in items) {
      final Metadata? cached = await metadataBox.get(
        'metadata:${item.contentId}',
      );
      expect(cached?.hasContent, isTrue, reason: item.bvid);
    }
  });
}

ProviderContainer _container({
  required MetingSearchRequest searchRequest,
  MetingLyricRequest? lyricRequest,
}) {
  return ProviderContainer(
    overrides: [
      favoritesLocalRepositoryProvider.overrideWithValue(
        FavoritesLocalRepository(
          collectionsBox: Hive.box<FavoriteCollection>(
            favoriteCollectionsBoxName,
          ),
          entriesBox: Hive.box<FavoriteEntry>(favoriteEntriesBoxName),
          membershipsBox: Hive.box<FavoriteMembership>(
            favoriteMembershipsBoxName,
          ),
        ),
      ),
      metadataCacheRepositoryProvider.overrideWithValue(
        MetadataCacheRepository(Hive.lazyBox<Metadata>(metadataCacheBoxName)),
      ),
      metadataLookupServiceProvider.overrideWithValue(
        MetadataLookupService(
          metingRepository: MetingRepository(
            searchRequest: searchRequest,
            lyricRequest: lyricRequest ?? _missLyricRequest,
            pictureRequest: _stubPictureRequest,
          ),
          resolveServer: (_) => MetingServer.netease,
        ),
      ),
    ],
  );
}

Future<void> _waitIdle(ProviderContainer container) async {
  for (int i = 0; i < 100; i++) {
    if (!container.read(metadataBackfillControllerProvider).isRunning) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

PlayableItem _item({required String bvid, String? title}) {
  return PlayableItem(
    aid: 1,
    bvid: bvid,
    title: title ?? '视频标题',
    author: 'UP主',
    coverUrl: 'https://img.example.com/video.jpg',
    page: 1,
  );
}

Future<Object?> _hitSearchRequest({
  required MetingServer server,
  required String keyword,
  required Map<String, dynamic> option,
}) async {
  return jsonEncode(<Map<String, dynamic>>[
    <String, dynamic>{
      'id': '186016',
      'name': '晴天',
      'artist': <String>['周杰伦'],
      'lyric_id': '186016',
    },
  ]);
}

Future<Object?> _missSearchRequest({
  required MetingServer server,
  required String keyword,
  required Map<String, dynamic> option,
}) async {
  return jsonEncode(<Map<String, dynamic>>[]);
}

Future<Object?> _hitLyricRequest({
  required MetingServer server,
  required String id,
}) async {
  return jsonEncode(<String, dynamic>{'lyric': '[00:00.000] 歌词'});
}

Future<Object?> _missLyricRequest({
  required MetingServer server,
  required String id,
}) async {
  throw StateError('Unexpected lyric request');
}

Future<Object?> _stubPictureRequest({
  required MetingServer server,
  required String id,
  required int size,
}) async {
  return jsonEncode(<String, dynamic>{
    'url': 'https://img.example.com/cover.jpg',
  });
}
