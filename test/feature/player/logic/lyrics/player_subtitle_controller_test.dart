import 'dart:async';

import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/player/data/bili_subtitle_repository.dart';
import 'package:bilimusic/feature/player/domain/bili_subtitle.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/domain/player_subtitle_state.dart';
import 'package:bilimusic/feature/player/logic/lyrics/player_subtitle_controller.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _item = PlayableItem(
  aid: 1,
  bvid: 'BV1',
  cid: 10,
  title: 'Song',
  author: 'Artist',
  coverUrl: '',
);
const _session = BiliSession(
  sessData: 'test-session',
  biliJct: 'test-csrf',
  dedeUserId: '1',
  refreshToken: '',
  cookie: '',
);
const _tracks = <BiliSubtitleTrack>[
  BiliSubtitleTrack(
    id: 'zh',
    language: 'zh-CN',
    label: '中文',
    url: 'https://example.com/zh',
  ),
  BiliSubtitleTrack(
    id: 'en',
    language: 'en',
    label: 'English',
    url: 'https://example.com/en',
  ),
];
const _lines = <BiliSubtitleLine>[
  BiliSubtitleLine(startMs: 1250, endMs: 2500, text: 'Subtitle'),
];

void main() {
  test(
    'defaults to Meting and discovers tracks without fetching their content',
    () async {
      final fixture = _Fixture();
      final initial = fixture.value;
      expect(initial.stableId, _item.stableId);
      expect(initial.isDiscovering, isTrue);
      expect(initial.usesSubtitles, isFalse);
      expect(initial.selectedTrackId, isNull);
      expect(initial.lines, isEmpty);
      expect(initial.offsetMs, 0);
      await fixture.discover();
      expect(fixture.value.tracks, _tracks);
      expect(fixture.value.isDiscovering, isFalse);
      expect(fixture.repository.discoveredItems, [_item]);
      expect(fixture.repository.loadedTracks, isEmpty);

      expect(await fixture.controller.selectTrack('unknown'), isFalse);
      expect(fixture.repository.loadedTracks, isEmpty);
      expect(await fixture.controller.selectTrack('zh'), isTrue);
      expect(fixture.repository.loadedTracks, ['zh']);
      expect(fixture.value.selectedTrackId, 'zh');
      expect(fixture.value.lines, _lines);
      expect(fixture.value.usesSubtitles, isTrue);
    },
  );

  test(
    'missing item, invalid cid, and logged-out sessions never request tracks',
    () async {
      for (final item in <PlayableItem?>[
        null,
        _item.copyWith(cid: null),
        _item.copyWith(cid: 0),
        _item.copyWith(cid: -1),
      ]) {
        final fixture = _Fixture(item: item);
        await fixture.discover();
        expect(fixture.value.isDiscovering, isFalse);
        expect(fixture.repository.discoveredItems, isEmpty);
        expect(fixture.repository.loadedTracks, isEmpty);
      }
      for (final session in <BiliSession?>[null, _session.clearAuth()]) {
        final fixture = _Fixture(session: session);
        await fixture.discover();
        expect(fixture.value.isDiscovering, isFalse);
        expect(fixture.repository.discoveredItems, isEmpty);
      }
    },
  );

  test('discovery failure keeps Meting and exposes an error', () async {
    final fixture = _Fixture();
    fixture.repository.discover = (_) async => throw StateError('unavailable');
    await fixture.discover();
    expect(fixture.value.usesSubtitles, isFalse);
    expect(fixture.value.tracks, isEmpty);
    expect(fixture.value.isDiscovering, isFalse);
    expect(fixture.value.errorMessage, isNotEmpty);
  });

  test('failed or empty downloads preserve the current source', () async {
    final fixture = _Fixture();
    await fixture.discover();
    fixture.repository.load = (_) async => throw StateError('unavailable');
    expect(await fixture.controller.selectTrack('zh'), isFalse);
    expect(fixture.value.selectedTrackId, isNull);
    expect(fixture.value.usesSubtitles, isFalse);
    expect(fixture.value.pendingTrackId, isNull);
    expect(fixture.value.errorMessage, isNotEmpty);

    fixture.repository.load = (_) async => _lines;
    expect(await fixture.controller.selectTrack('zh'), isTrue);
    fixture.controller.adjustOffset(200);
    fixture.repository.load = (_) async => const [];
    expect(await fixture.controller.selectTrack('en'), isFalse);
    expect(fixture.value.selectedTrackId, 'zh');
    expect(fixture.value.lines, _lines);
    expect(fixture.value.offsetMs, 200);
    expect(fixture.value.errorMessage, isNotEmpty);
    expect(fixture.value.pendingTrackId, isNull);
  });

  test(
    'repeated selection uses cached lines and track offsets remain isolated',
    () async {
      final fixture = _Fixture();
      await fixture.discover();
      fixture.controller.adjustOffset(100);
      expect(fixture.value.offsetMs, 0);
      await fixture.controller.selectTrack('zh');
      fixture.controller.adjustOffset(200);
      await fixture.controller.selectTrack('zh');
      expect(fixture.repository.loadedTracks, ['zh']);
      expect(fixture.value.offsetMs, 200);
      await fixture.controller.selectTrack('en');
      expect(fixture.value.offsetMs, 0);
      fixture.controller.adjustOffset(-100);
      await fixture.controller.selectTrack('zh');
      expect(fixture.value.offsetMs, 200);
      fixture.controller.useMeting();
      expect(fixture.value.selectedTrackId, isNull);
      expect(fixture.value.lines, isEmpty);
      expect(fixture.value.offsetMs, 0);
      await fixture.controller.selectTrack('en');
      expect(fixture.value.offsetMs, -100);
      expect(fixture.repository.loadedTracks, ['zh', 'en']);
    },
  );

  test('returning to Meting invalidates an in-flight selection', () async {
    final fixture = _Fixture();
    await fixture.discover();
    final pending = Completer<List<BiliSubtitleLine>>();
    fixture.repository.load = (_) => pending.future;
    final result = fixture.controller.selectTrack('zh');
    expect(fixture.value.pendingTrackId, 'zh');
    fixture.controller.useMeting();
    pending.complete(_lines);
    expect(await result, isFalse);
    expect(fixture.value.selectedTrackId, isNull);
    expect(fixture.value.pendingTrackId, isNull);
    expect(fixture.value.lines, isEmpty);
    expect(fixture.value.errorMessage, isNull);
  });

  test(
    'a newer selection cannot be overwritten by an older download',
    () async {
      final fixture = _Fixture();
      await fixture.discover();
      final pending = Completer<List<BiliSubtitleLine>>();
      fixture.repository.load = (track) =>
          track.id == 'zh' ? pending.future : Future.value(_lines);
      final oldSelection = fixture.controller.selectTrack('zh');
      expect(await fixture.controller.selectTrack('en'), isTrue);
      pending.complete(_lines);
      expect(await oldSelection, isFalse);
      expect(fixture.value.selectedTrackId, 'en');
    },
  );

  test(
    'switching songs invalidates old downloads and clears track offsets/cache',
    () async {
      final fixture = _Fixture();
      await fixture.discover();
      await fixture.controller.selectTrack('en');
      fixture.controller.adjustOffset(300);
      final pending = Completer<List<BiliSubtitleLine>>();
      fixture.repository.load = (_) => pending.future;
      final oldSelection = fixture.controller.selectTrack('zh');
      final next = _item.copyWith(cid: 20);
      fixture.player.setItem(next);
      await fixture.discover();
      expect(fixture.value.stableId, next.stableId);
      expect(fixture.value.selectedTrackId, isNull);
      expect(fixture.value.lines, isEmpty);
      pending.complete(_lines);
      expect(await oldSelection, isFalse);
      expect(fixture.value.selectedTrackId, isNull);
      fixture.repository.load = (_) async => _lines;
      await fixture.controller.selectTrack('en');
      expect(fixture.value.offsetMs, 0);
      expect(
        fixture.repository.loadedTracks.where((id) => id == 'en').length,
        2,
      );
    },
  );

  test(
    'a previous song discovery cannot replace the current track list',
    () async {
      final fixture = _Fixture();
      final pending = Completer<List<BiliSubtitleTrack>>();
      fixture.repository.discover = (item) =>
          item.cid == 10 ? pending.future : Future.value([_tracks.last]);
      await fixture.discover();
      fixture.player.setItem(_item.copyWith(cid: 20));
      await fixture.discover();
      expect(fixture.value.tracks, [_tracks.last]);
      pending.complete([_tracks.first]);
      await fixture.discover();
      expect(fixture.value.tracks, [_tracks.last]);
    },
  );

  test(
    'login changes clear old tracks, selections and cached content',
    () async {
      final fixture = _Fixture();
      await fixture.discover();
      await fixture.controller.selectTrack('zh');
      fixture.controller.adjustOffset(400);
      fixture.session.setValue(null);
      await fixture.discover();
      expect(fixture.value.tracks, isEmpty);
      expect(fixture.value.selectedTrackId, isNull);
      expect(fixture.value.lines, isEmpty);
      expect(fixture.value.offsetMs, 0);
      expect(fixture.repository.discoveredItems, hasLength(1));
      fixture.session.setValue(_session.copyWith(dedeUserId: '2'));
      await fixture.discover();
      expect(fixture.value.tracks, _tracks);
      await fixture.controller.selectTrack('zh');
      expect(fixture.value.offsetMs, 0);
      expect(fixture.repository.loadedTracks, ['zh', 'zh']);
    },
  );

  for (final nextSession in <BiliSession?>[
    _session.copyWith(dedeUserId: '2'),
    null,
  ]) {
    for (final fails in [false, true]) {
      test(
        '${nextSession == null ? 'logout' : 'account change'} rejects old discovery ${fails ? 'errors' : 'tracks'} before provider flush',
        () async {
          final fixture = _Fixture();
          final oldDiscovery = Completer<List<BiliSubtitleTrack>>();
          final newDiscovery = Completer<List<BiliSubtitleTrack>>();
          fixture.repository.discover = (_) => oldDiscovery.future;
          await fixture.discover();
          expect(fixture.repository.discoveredItems, [_item]);
          expect(fixture.value.isDiscovering, isTrue);
          fixture.repository.discover = (_) => newDiscovery.future;
          fixture.session.setValue(nextSession);
          if (fails) {
            oldDiscovery.completeError(StateError('old account failure'));
          } else {
            oldDiscovery.complete([_tracks.first]);
          }
          await Future<void>.delayed(Duration.zero);
          expect(fixture.value.tracks, isEmpty);
          expect(fixture.value.errorMessage, isNull);
          expect(fixture.value.selectedTrackId, isNull);
          expect(fixture.value.isDiscovering, nextSession != null);
          expect(
            fixture.repository.discoveredItems,
            hasLength(nextSession == null ? 1 : 2),
          );
          if (nextSession != null) {
            newDiscovery.complete([_tracks.last]);
            await fixture.discover();
            expect(fixture.value.tracks, [_tracks.last]);
            expect(fixture.value.isDiscovering, isFalse);
          }
        },
      );
    }
  }

  test(
    '403 refreshes the expired track URL once and caches the download',
    () async {
      final fixture = _Fixture();
      await fixture.discover();
      final refreshed = _tracks.first.copyWith(
        url: 'https://example.com/zh?renewed=1',
      );
      final urls = <String>[];
      fixture.repository.discover = (_) async => [refreshed, _tracks.last];
      fixture.repository.load = (track) async {
        urls.add(track.url);
        if (track.url == _tracks.first.url) {
          final request = RequestOptions(path: track.url);
          throw DioException.badResponse(
            statusCode: 403,
            requestOptions: request,
            response: Response(requestOptions: request, statusCode: 403),
          );
        }
        return _lines;
      };
      expect(await fixture.controller.selectTrack('zh'), isTrue);
      expect(urls, [_tracks.first.url, refreshed.url]);
      expect(fixture.repository.discoveredItems, [_item, _item]);
      expect(fixture.value.tracks.first, refreshed);
      expect(fixture.value.lines, _lines);
      expect(fixture.value.errorMessage, isNull);
      expect(await fixture.controller.selectTrack('zh'), isTrue);
      expect(urls, hasLength(2));
      expect(fixture.repository.discoveredItems, hasLength(2));
    },
  );

  test(
    'a second 403 fails without another metadata refresh or source change',
    () async {
      final fixture = _Fixture();
      await fixture.discover();
      expect(await fixture.controller.selectTrack('en'), isTrue);
      fixture.controller.adjustOffset(200);
      final refreshed = _tracks.first.copyWith(
        url: 'https://example.com/zh?renewed=1',
      );
      fixture.repository.discover = (_) async => [refreshed, _tracks.last];
      final urls = <String>[];
      fixture.repository.load = (track) async {
        urls.add(track.url);
        final request = RequestOptions(path: track.url);
        throw DioException.badResponse(
          statusCode: 403,
          requestOptions: request,
          response: Response(requestOptions: request, statusCode: 403),
        );
      };
      expect(await fixture.controller.selectTrack('zh'), isFalse);
      expect(urls, [_tracks.first.url, refreshed.url]);
      expect(fixture.repository.discoveredItems, [_item, _item]);
      expect(fixture.value.selectedTrackId, 'en');
      expect(fixture.value.lines, _lines);
      expect(fixture.value.offsetMs, 200);
      expect(fixture.value.pendingTrackId, isNull);
      expect(fixture.value.errorMessage, isNotEmpty);
    },
  );

  test('account changes invalidate an in-flight discovery', () async {
    final fixture = _Fixture();
    final pending = Completer<List<BiliSubtitleTrack>>();
    fixture.repository.discover = (_) => pending.future;
    await fixture.discover();
    fixture.session.setValue(_session.copyWith(dedeUserId: '2'));
    fixture.repository.discover = (_) async => [_tracks.last];
    await fixture.discover();
    pending.complete([_tracks.first]);
    await fixture.discover();
    expect(fixture.value.tracks, [_tracks.last]);
    expect(fixture.value.selectedTrackId, isNull);
  });
}

class _Fixture {
  _Fixture({PlayableItem? item = _item, BiliSession? session = _session})
    : player = _PlayerController(item),
      session = _SessionController(session) {
    container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(() => player),
        biliSessionControllerProvider.overrideWith(() => this.session),
        biliSubtitleRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    container.read(playerSubtitleControllerProvider);
  }

  final _PlayerController player;
  final _SessionController session;
  final _SubtitleRepository repository = _SubtitleRepository();
  late final ProviderContainer container;
  PlayerSubtitleState get value =>
      container.read(playerSubtitleControllerProvider);
  PlayerSubtitleController get controller =>
      container.read(playerSubtitleControllerProvider.notifier);
  Future<void> discover() async {
    await container.pump();
    container.read(playerSubtitleControllerProvider);
    await Future<void>.delayed(Duration.zero);
  }
}

class _PlayerController extends PlayerController {
  _PlayerController(this.item);
  final PlayableItem? item;
  @override
  PlayerState build() => PlayerState(currentItem: item);
  void setItem(PlayableItem item) => state = state.copyWith(currentItem: item);
}

class _SessionController extends BiliSessionController {
  _SessionController(this.initial);
  final BiliSession? initial;
  @override
  BiliSession? build() => initial;
  void setValue(BiliSession? value) => state = value;
}

class _SubtitleRepository implements BiliSubtitleRepository {
  final List<PlayableItem> discoveredItems = [];
  final List<String> loadedTracks = [];
  Future<List<BiliSubtitleTrack>> Function(PlayableItem) discover = (_) async =>
      _tracks;
  Future<List<BiliSubtitleLine>> Function(BiliSubtitleTrack) load = (_) async =>
      _lines;

  @override
  Future<List<BiliSubtitleTrack>> fetchTracks(PlayableItem item) {
    discoveredItems.add(item);
    return discover(item);
  }

  @override
  Future<List<BiliSubtitleLine>> fetchLines(BiliSubtitleTrack track) {
    loadedTracks.add(track.id);
    return load(track);
  }
}
