import 'dart:async';

import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/metadata/data/metadata_cache_repository.dart';
import 'package:bilimusic/feature/metadata/data/metadata_resolver.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_backfill_controller.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_lookup_service.dart';
import 'package:bilimusic/feature/meting/data/meting_repository.dart';
import 'package:bilimusic/feature/meting/domain/meting_search_item.dart';
import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:bilimusic/feature/player/data/player_lyrics_cache_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_lyrics_cache_entry.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/lyrics/player_lyrics_controller.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _music = PlayableItem(
  aid: 1,
  bvid: 'BV1',
  cid: 10,
  title: 'Bilibili title',
  author: 'Bilibili author',
  coverUrl: 'https://example.com/bili.jpg',
);
const _searchItem = MetingSearchItem(
  id: 'song',
  title: 'Music title',
  author: 'Music artist',
  server: MetingServer.netease,
);
final _metadata = Metadata(
  stableId: _music.stableId,
  title: 'Music title',
  lyrics: '[00:00]Music lyric',
);

void main() {
  test('spoken skips metadata cache, lookup and every manual entry', () async {
    final fixture = _Fixture(_music.copyWith(kind: CollectionKind.spoken));
    final controller = fixture.controller;
    await fixture.flush();
    await controller.retryCurrent();
    await controller.searchManual('Music title');
    await controller.applyManualResult(_searchItem);
    await controller.adjustOffset(500);
    await controller.resetOffset();
    final state = fixture.container.read(metadataControllerProvider);
    expect(state.stableId, _music.stableId);
    expect(state.metadata, isNull);
    expect(state.isLoading, isFalse);
    expect(state.hasSearched, isFalse);
    expect(fixture.cache.reads, isEmpty);
    expect(fixture.cache.writes, isEmpty);
    expect(fixture.lookup.lookups, isEmpty);
    expect(fixture.lookup.manualItems, isEmpty);
    expect(fixture.meting.searches, 0);
  });

  test('legacy lyrics pathway cannot fetch or use cache for spoken', () async {
    final fixture = _Fixture(_music.copyWith(kind: CollectionKind.spoken));
    final controller = fixture.container.read(
      playerLyricsControllerProvider.notifier,
    );
    await controller.retryCurrent();
    await controller.searchManual('Music title');
    await controller.applyManualResult(_searchItem);
    await controller.adjustOffset(500);
    await controller.resetOffset();
    await fixture.flush();
    final state = fixture.container.read(playerLyricsControllerProvider);
    expect(state.stableId, _music.stableId);
    expect(state.rawLyrics, isNull);
    expect(state.isLoading, isFalse);
    expect(state.hasSearched, isFalse);
    expect(fixture.lyricsCache.reads, isEmpty);
    expect(fixture.meting.searches, 0);
  });

  test(
    'legacy lyrics discards a same-id cache result after switching modes',
    () async {
      final fixture = _Fixture(null);
      final pending = Completer<PlayerLyricsCacheEntry?>();
      fixture.lyricsCache.load = (_) => pending.future;
      fixture.container.read(playerLyricsControllerProvider);
      fixture.player.show(_music);
      await fixture.flush();
      expect(fixture.lyricsCache.reads, [_music]);
      fixture.player.show(_music.copyWith(kind: CollectionKind.spoken));
      pending.complete(
        PlayerLyricsCacheEntry(
          stableId: _music.stableId,
          rawLyrics: '[00:00]Music',
          lyricOffsetMs: 0,
          updatedAtEpochMs: 1,
        ),
      );
      await fixture.flush();
      final state = fixture.container.read(playerLyricsControllerProvider);
      expect(state.rawLyrics, isNull);
      expect(state.hasSearched, isFalse);
      expect(fixture.lyricsCache.reads, hasLength(1));
      expect(fixture.meting.searches, 0);
    },
  );

  test('same stable id mode switch rejects a pending cache hit', () async {
    final fixture = _Fixture(null);
    final pending = Completer<Metadata?>();
    fixture.cache.load = (_) => pending.future;
    fixture.controller;
    fixture.player.show(_music);
    await fixture.flush();
    expect(fixture.cache.reads, [_music]);
    fixture.player.show(_music.copyWith(kind: CollectionKind.spoken));
    pending.complete(_metadata);
    await fixture.flush();
    expect(fixture.container.read(metadataControllerProvider).metadata, isNull);
    expect(fixture.lookup.lookups, isEmpty);
    expect(fixture.cache.reads, hasLength(1));
  });

  for (final next in [
    _music.copyWith(kind: CollectionKind.spoken),
    _music.copyWith(collectionId: 'other-music-collection'),
  ]) {
    test(
      'same stable id context ${next.kind.name}/${next.collectionId} rejects lookup',
      () async {
        final fixture = _Fixture(null);
        final pending = Completer<MetadataLookupResult>();
        fixture.lookup.resolve = (_) => pending.future;
        fixture.controller;
        fixture.player.show(_music);
        await fixture.flush();
        expect(fixture.lookup.lookups, [_music]);
        fixture.player.show(next);
        fixture.lookup.resolve = (_) async => _result(null);
        pending.complete(_result(_metadata));
        await fixture.flush();
        expect(
          fixture.container
                  .read(metadataControllerProvider)
                  .metadata
                  ?.hasContent ??
              false,
          isFalse,
        );
        expect(fixture.cache.writes, isEmpty);
      },
    );
  }

  test(
    'music to spoken to music rejects first lookup and loads again',
    () async {
      final fixture = _Fixture(null);
      final old = Completer<MetadataLookupResult>();
      final fresh = Completer<MetadataLookupResult>();
      fixture.lookup.resolve = (_) => old.future;
      fixture.controller;
      fixture.player.show(_music);
      await fixture.flush();
      fixture.player.show(_music.copyWith(kind: CollectionKind.spoken));
      await fixture.flush();
      fixture.lookup.resolve = (_) => fresh.future;
      fixture.player.show(_music);
      await fixture.flush();
      expect(fixture.lookup.lookups, hasLength(2));
      old.complete(_result(_metadata));
      await fixture.flush();
      expect(
        fixture.container.read(metadataControllerProvider).metadata,
        isNull,
      );
      fresh.complete(_result(_metadata.copyWith(title: 'Fresh match')));
      await fixture.flush();
      expect(
        fixture.container.read(metadataControllerProvider).metadata?.title,
        'Fresh match',
      );
    },
  );

  test(
    'manual search completion cannot restore results after mode switch',
    () async {
      final fixture = _Fixture(null);
      fixture.controller;
      fixture.player.show(_music);
      await fixture.flush();
      final pending = Completer<List<MetingSearchItem>>();
      fixture.meting.response = pending.future;
      final search = fixture.controller.searchManual(
        'title',
        server: MetingServer.netease,
      );
      fixture.player.show(_music.copyWith(kind: CollectionKind.spoken));
      pending.complete([_searchItem]);
      await search;
      await fixture.flush();
      final state = fixture.container.read(metadataControllerProvider);
      expect(state.searchResults, isEmpty);
      expect(state.metadata, isNull);
      expect(state.isSearching, isFalse);
    },
  );

  test(
    'manual apply completion cannot restore music after mode switch',
    () async {
      final fixture = _Fixture(null);
      fixture.controller;
      fixture.player.show(_music);
      await fixture.flush();
      final pending = Completer<Metadata>();
      fixture.lookup.manual = (_) => pending.future;
      final apply = fixture.controller.applyManualResult(_searchItem);
      fixture.player.show(_music.copyWith(kind: CollectionKind.spoken));
      pending.complete(_metadata);
      await apply;
      await fixture.flush();
      expect(
        fixture.container.read(metadataControllerProvider).metadata,
        isNull,
      );
      expect(fixture.cache.writes, isEmpty);
    },
  );

  test(
    'backfill skips spoken before cache reads and only queues music',
    () async {
      final fixture = _Fixture(null);
      final controller = fixture.container.read(
        metadataBackfillControllerProvider.notifier,
      );
      final spoken = _music.copyWith(kind: CollectionKind.spoken);
      controller.enqueue(spoken);
      expect(await controller.backfillMissing([spoken]), 0);
      await fixture.flush();
      expect(fixture.cache.reads, isEmpty);
      expect(fixture.cache.contentReads, isEmpty);
      expect(fixture.lookup.lookups, isEmpty);
      expect(
        fixture.container.read(metadataBackfillControllerProvider).total,
        0,
      );
      expect(await controller.backfillMissing([spoken, _music]), 1);
      await fixture.flush();
      expect(fixture.lookup.lookups, [_music]);
      expect(fixture.cache.writes, [_music]);
      expect(
        fixture.container.read(metadataBackfillControllerProvider).processed,
        1,
      );
    },
  );
}

MetadataLookupResult _result(Metadata? value) => MetadataLookupResult(
  metadata: value ?? Metadata(stableId: _music.stableId),
  searchResults: const [],
);

class _Fixture {
  _Fixture(PlayableItem? item) : player = _Player(item) {
    container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(() => player),
        favoritesControllerProvider.overrideWith(_Favorites.new),
        metadataCacheRepositoryProvider.overrideWithValue(cache),
        playerLyricsCacheRepositoryProvider.overrideWithValue(lyricsCache),
        metadataLookupServiceProvider.overrideWithValue(lookup),
        metingRepositoryProvider.overrideWithValue(meting),
      ],
    );
    addTearDown(container.dispose);
  }

  final _Player player;
  final _Cache cache = _Cache();
  final _LyricsCache lyricsCache = _LyricsCache();
  final _Lookup lookup = _Lookup();
  final _Meting meting = _Meting();
  late final ProviderContainer container;
  MetadataController get controller =>
      container.read(metadataControllerProvider.notifier);
  Future<void> flush() async {
    await container.pump();
    await Future<void>.delayed(Duration.zero);
  }
}

class _Player extends PlayerController {
  _Player(this.initial);
  final PlayableItem? initial;
  @override
  PlayerState build() => PlayerState(currentItem: initial);
  void show(PlayableItem item) => state = state.copyWith(currentItem: item);
}

class _Favorites extends FavoritesController {
  @override
  FavoritesState build() => const FavoritesState();
}

class _Cache implements MetadataCacheRepository {
  final List<PlayableItem> reads = [];
  final List<String> contentReads = [];
  final List<PlayableItem> writes = [];
  Future<Metadata?> Function(PlayableItem) load = (_) async => null;
  @override
  Future<Metadata?> getCachedMetadata({required PlayableItem item}) {
    reads.add(item);
    return load(item);
  }

  @override
  Future<Metadata?> getCachedMetadataByContentId(String contentId) async {
    contentReads.add(contentId);
    return null;
  }

  @override
  Future<void> putCachedMetadata({
    required PlayableItem item,
    required Metadata metadata,
  }) async {
    writes.add(item);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _LyricsCache implements PlayerLyricsCacheRepository {
  final List<PlayableItem> reads = [];
  Future<PlayerLyricsCacheEntry?> Function(PlayableItem) load = (_) async =>
      null;
  @override
  Future<PlayerLyricsCacheEntry?> getCachedEntry({required PlayableItem item}) {
    reads.add(item);
    return load(item);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Lookup extends MetadataLookupService {
  _Lookup()
    : super(
        metingRepository: const MetingRepository(),
        resolveServer: (_) => MetingServer.netease,
      );
  final List<PlayableItem> lookups = [];
  final List<PlayableItem> manualItems = [];
  Future<MetadataLookupResult> Function(PlayableItem) resolve = (_) async =>
      _result(null);
  Future<Metadata> Function(PlayableItem) manual = (_) async => _metadata;
  @override
  Future<MetadataLookupResult> lookup({
    required PlayableItem item,
    required String title,
    bool Function()? isActive,
  }) {
    lookups.add(item);
    return resolve(item);
  }

  @override
  Future<Metadata> buildMetadataFromSearchItem({
    required PlayableItem item,
    required MetingSearchItem searchItem,
    bool Function()? isActive,
  }) {
    manualItems.add(item);
    return manual(item);
  }
}

class _Meting extends MetingRepository {
  int searches = 0;
  Future<List<MetingSearchItem>> response = Future.value(const []);
  @override
  Future<List<MetingSearchItem>> search({
    required String keyword,
    MetingServer server = MetingServer.netease,
  }) {
    searches++;
    return response;
  }
}
