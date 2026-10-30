import 'dart:async';
import 'dart:io';

import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/listening/domain/listening_state.dart';
import 'package:bilimusic/feature/listening/logic/listening_progress_controller.dart';
import 'package:bilimusic/feature/player/data/audio_cache_repository.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/data/player_queue_local_repository.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/persisted_playback_queue.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/media_session/app_audio_handler.dart';
import 'package:bilimusic/feature/player/logic/playback/player_audio_engine.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const PlayableItem _first = PlayableItem(
  aid: 1,
  bvid: 'BV1',
  title: 'First',
  author: 'Author',
  coverUrl: '',
);
const PlayableItem _second = PlayableItem(
  aid: 2,
  bvid: 'BV2',
  title: 'Second',
  author: 'Author',
  coverUrl: '',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final Map<String, Future<void> Function(PlayerController)> switches =
      <String, Future<void> Function(PlayerController)>{
        'next track': (PlayerController player) => player.skipToNext(),
        'queue selection': (PlayerController player) =>
            player.skipToQueueIndex(1),
        'new queue': (PlayerController player) =>
            player.setQueue(<PlayableItem>[_second]),
        'replace current item': (PlayerController player) =>
            player.replaceCurrentQueueItem(_second),
        'remove current item': (PlayerController player) =>
            player.removeQueueItemAt(0),
      };

  for (final MapEntry<String, Future<void> Function(PlayerController)> entry
      in switches.entries) {
    test('${entry.key} stops old audio before resolving new audio', () async {
      final _BlockingStopEngine engine = _BlockingStopEngine();
      final ProviderContainer container = ProviderContainer(
        overrides: [
          playerControllerProvider.overrideWith(
            () => _PlayingController(engine),
          ),
          appAudioHandlerProvider.overrideWithValue(AppAudioHandler()),
          biliPlayerRepositoryProvider.overrideWithValue(_UnusedRepository()),
          playerAudioCacheRepositoryProvider.overrideWithValue(_UnusedCache()),
          playerQueueLocalRepositoryProvider.overrideWithValue(
            _MemoryQueueRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);
      final PlayerController player = container.read(
        playerControllerProvider.notifier,
      );

      final Future<void> switching = entry.value(player);

      expect(engine.stopCalls, 1);
      expect(engine.playing, isFalse);
      expect(container.read(playerControllerProvider).isLoading, isTrue);
      expect(container.read(playerControllerProvider).currentItem, _second);
      expect(engine.sourceCalls, 0);

      await player.stop();
      engine.firstStop.complete();
      await switching;

      expect(engine.playing, isFalse);
      expect(engine.sourceCalls, 0);
    });
  }

  test('current play starts after session activation', () async {
    final _SessionBarrier session = _SessionBarrier();
    final _PlaybackEngine engine = _PlaybackEngine();
    final ProviderContainer container = _playbackContainer(engine);
    addTearDown(container.dispose);
    final PlayerController player = container.read(
      playerControllerProvider.notifier,
    );
    final Future<void> playing = player.play();
    await session.configuring.future;
    expect(engine.playCalls, 0);
    session.release.complete();
    await playing;

    expect(engine.playCalls, 1);
    expect(engine.playing, isTrue);
    await player.shutdown();
  });

  for (final String cancellation in <String>['stop', 'pause', 'new source']) {
    test('$cancellation cancels play waiting for session activation', () async {
      final _SessionBarrier session = _SessionBarrier();
      final _PlaybackEngine engine = _PlaybackEngine();
      final ProviderContainer container = _playbackContainer(engine);
      addTearDown(container.dispose);
      final PlayerController player = container.read(
        playerControllerProvider.notifier,
      );
      final Future<void> playing = player.play();
      await session.configuring.future;

      switch (cancellation) {
        case 'stop':
          await player.stop();
        case 'pause':
          await player.pause();
        case 'new source':
          final Future<void> replacing = player.setQueue(<PlayableItem>[
            _second,
          ], autoplay: false);
          session.release.complete();
          await replacing;
      }
      if (!session.release.isCompleted) session.release.complete();
      await playing;
      await player.shutdown();

      expect(engine.playCalls, 0);
      expect(engine.playing, isFalse);
    });
  }

  for (final String cancellation in <String>['stop', 'pause', 'new source']) {
    test('$cancellation cancels an awaited source cache lookup', () async {
      _SessionBarrier(block: false);
      final _PlaybackEngine engine = _PlaybackEngine();
      final _SourceLookupCache cache = _SourceLookupCache();
      final ProviderContainer container = _playbackContainer(
        engine,
        cache: cache,
      );
      addTearDown(container.dispose);
      final PlayerController player = container.read(
        playerControllerProvider.notifier,
      );
      final Future<void> loading = player.setQueue(<PlayableItem>[
        _first,
      ], autoplay: false);
      await cache.sourceLookupStarted.future;
      switch (cancellation) {
        case 'stop':
          await player.stop();
        case 'pause':
          await player.pause();
        case 'new source':
          await player.setQueue(<PlayableItem>[_second], autoplay: false);
      }
      final PlayerState latest = container.read(playerControllerProvider);
      final List<String> sources = List<String>.of(engine.sources);
      cache.firstSourceLookup.complete(File('stale.audio'));
      await loading;

      expect(engine.sources, sources);
      expect(engine.sources, isNot(contains('stale.audio')));
      expect(container.read(playerControllerProvider), latest);
      await player.shutdown();
    });
  }

  test('superseding a spoken load invalidates its history request', () async {
    _SessionBarrier(block: false);
    final _PlaybackEngine engine = _PlaybackEngine();
    final _PendingResume listening = _PendingResume();
    final ProviderContainer container = _playbackContainer(
      engine,
      listening: listening,
    );
    addTearDown(container.dispose);
    final PlayerController player = container.read(
      playerControllerProvider.notifier,
    );
    final Future<void> loading = player.setQueue(<PlayableItem>[
      _first.copyWith(kind: CollectionKind.spoken, cid: 1),
    ], autoplay: false);
    await listening.requestStarted.future;
    expect(listening.isCurrent, isNotNull);
    expect(listening.isCurrent!(), isTrue);

    await player.setQueue(<PlayableItem>[_second], autoplay: false);
    expect(listening.isCurrent!(), isFalse);
    final List<String> latestSources = List<String>.of(engine.sources);
    listening.position.complete(const Duration(seconds: 10));
    await loading;

    expect(engine.sources, latestSources);
    expect(container.read(playerControllerProvider).currentItem, _second);
    await player.shutdown();
  });
}

class _PendingResume extends ListeningProgressController {
  final Completer<void> requestStarted = Completer<void>();
  final Completer<Duration> position = Completer<Duration>();
  bool Function()? isCurrent;

  @override
  ListeningState build() => const ListeningState();

  @override
  Future<Duration> resumePosition(
    PlayableItem item, {
    Duration fallback = Duration.zero,
    bool Function()? isCurrent,
  }) {
    this.isCurrent = isCurrent;
    requestStarted.complete();
    return position.future;
  }

  @override
  void begin(PlayableItem item, Duration position, Duration? duration) {}

  @override
  Future<void> suspend() async {}

  @override
  Future<void> flush() async {}
}

class _SessionBarrier {
  _SessionBarrier({bool block = true}) {
    const MethodChannel channel = MethodChannel('com.ryanheise.audio_session');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          if (call.method == 'setConfiguration') {
            if (!configuring.isCompleted) configuring.complete();
            await release.future;
          }
          return null;
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
    if (!block) release.complete();
  }

  final Completer<void> configuring = Completer<void>();
  final Completer<void> release = Completer<void>();
}

ProviderContainer _playbackContainer(
  _PlaybackEngine engine, {
  _SourceLookupCache? cache,
  _PendingResume? listening,
}) {
  const MethodChannel channel = MethodChannel(
    'dev.fluttercommunity.plus/connectivity',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (_) async => <String>['wifi']);
  addTearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
  return ProviderContainer(
    overrides: [
      playerControllerProvider.overrideWith(() => _PlayingController(engine)),
      if (listening != null)
        listeningProgressControllerProvider.overrideWith(() => listening),
      appAudioHandlerProvider.overrideWithValue(AppAudioHandler()),
      appSettingsStoreProvider.overrideWithValue(_DefaultSettings()),
      biliSessionControllerProvider.overrideWith(_GuestSession.new),
      biliPlayerRepositoryProvider.overrideWithValue(_ResolvedRepository()),
      playerAudioCacheRepositoryProvider.overrideWithValue(
        cache ?? _SourceLookupCache(block: false),
      ),
      playerQueueLocalRepositoryProvider.overrideWithValue(
        _MemoryQueueRepository(),
      ),
    ],
  );
}

class _GuestSession extends BiliSessionController {
  @override
  BiliSession? build() => null;
}

class _DefaultSettings implements AppSettingsStore {
  @override
  bool readBool(String key, {required bool defaultValue}) => defaultValue;

  @override
  String readString(String key, {required String defaultValue}) => defaultValue;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ResolvedRepository implements BiliPlayerRepository {
  @override
  Future<PlayerLoadResult> resolveAudioStream(
    PlayableItem item, {
    required BiliSession? session,
    required PlayerAudioQualityPreference qualityPreference,
    int? preferredQualityId,
  }) async => PlayerLoadResult(
    item: item,
    availableParts: <PlayableItem>[item],
    audioStream: AudioStreamInfo(
      streamUrl: 'https://audio/${item.bvid}',
      backupUrls: const <String>[],
      headers: const <String, String>{},
      cid: item.aid,
      duration: const Duration(minutes: 1),
      bandwidth: 132000,
      availableQualities: const <AudioQualityOption>[],
    ),
  );

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SourceLookupCache implements PlayerAudioCacheRepository {
  _SourceLookupCache({this.block = true});

  final bool block;
  final Completer<void> sourceLookupStarted = Completer<void>();
  final Completer<File?> firstSourceLookup = Completer<File?>();
  int firstLookups = 0;

  @override
  Future<CachedAudio?> lookupCachedAudio({
    required PlayableItem item,
    required PlayerAudioQualityPreference preference,
    int? preferredQualityId,
    bool allowQualityFallback = true,
  }) async => null;

  @override
  Future<File?> getCachedFile({
    required PlayableItem item,
    required AudioStreamInfo audioStream,
  }) {
    if (block && item == _first && ++firstLookups == 2) {
      sourceLookupStarted.complete();
      return firstSourceLookup.future;
    }
    return Future<File?>.value();
  }

  @override
  Future<File> cacheAudio({
    required PlayableItem item,
    required AudioStreamInfo audioStream,
  }) async => File('cached.audio');

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PlaybackEngine implements PlayerAudioEngine {
  final List<String> sources = <String>[];
  int playCalls = 0;

  @override
  bool playing = false;

  @override
  Future<void> play() async {
    playCalls++;
    playing = true;
  }

  @override
  Future<void> pause() async => playing = false;

  @override
  Future<void> stop() async => playing = false;

  @override
  Future<void> dispose() async {}

  @override
  Future<Duration?> setRemoteSource({
    required Uri uri,
    Map<String, String>? headers,
    Duration? initialPosition,
  }) async {
    sources.add(uri.toString());
    return const Duration(minutes: 1);
  }

  @override
  Future<Duration?> setFileSource({
    required String filePath,
    Duration? initialPosition,
  }) async {
    sources.add(filePath);
    return const Duration(minutes: 1);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PlayingController extends PlayerController {
  _PlayingController(PlayerAudioEngine engine) : super(audioEngine: engine);

  @override
  PlayerState build() => const PlayerState(
    currentItem: _first,
    queue: <PlayableItem>[_first, _second],
    currentQueueIndex: 0,
    isPlaying: true,
    isReady: true,
  );
}

class _UnusedRepository implements BiliPlayerRepository {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedCache implements PlayerAudioCacheRepository {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MemoryQueueRepository implements PlayerQueueLocalRepository {
  @override
  Future<void> save(PersistedPlaybackQueue snapshot) async {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _BlockingStopEngine implements PlayerAudioEngine {
  final Completer<void> firstStop = Completer<void>();
  int stopCalls = 0;
  int sourceCalls = 0;

  @override
  bool playing = true;

  @override
  Future<void> stop() {
    stopCalls++;
    playing = false;
    return stopCalls == 1 ? firstStop.future : Future<void>.value();
  }

  @override
  Future<Duration?> setRemoteSource({
    required Uri uri,
    Map<String, String>? headers,
    Duration? initialPosition,
  }) async {
    sourceCalls++;
    return null;
  }

  @override
  Future<Duration?> setFileSource({
    required String filePath,
    Duration? initialPosition,
  }) async {
    sourceCalls++;
    return null;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
