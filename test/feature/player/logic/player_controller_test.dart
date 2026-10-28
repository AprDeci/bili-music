import 'dart:async';

import 'package:bilimusic/feature/player/data/audio_cache_repository.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/data/player_queue_local_repository.dart';
import 'package:bilimusic/feature/player/domain/persisted_playback_queue.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/media_session/app_audio_handler.dart';
import 'package:bilimusic/feature/player/logic/playback/player_audio_engine.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
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
