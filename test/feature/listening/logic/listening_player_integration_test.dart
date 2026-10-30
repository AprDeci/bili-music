import 'dart:async';
import 'dart:io';

import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/listening/data/bili_history_remote_repository.dart';
import 'package:bilimusic/feature/listening/data/listening_progress_local_repository.dart';
import 'package:bilimusic/feature/listening/domain/listening_progress.dart';
import 'package:bilimusic/feature/listening/logic/listening_progress_controller.dart';
import 'package:bilimusic/feature/player/data/audio_cache_repository.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/data/player_queue_local_repository.dart';
import 'package:bilimusic/feature/player/domain/persisted_playback_queue.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/media_session/app_audio_handler.dart';
import 'package:bilimusic/feature/player/logic/playback/player_audio_engine.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

const PlayableItem _chapter = PlayableItem(
  aid: 1,
  bvid: 'BVbook',
  cid: 101,
  page: 1,
  title: 'Book',
  pageTitle: 'Chapter one',
  author: 'Narrator',
  coverUrl: '',
  kind: CollectionKind.spoken,
  collectionId: 'book',
);
final PlayableItem _nextChapter = _chapter.copyWith(
  cid: 102,
  page: 2,
  pageTitle: 'Chapter two',
);
const Duration _duration = Duration(minutes: 10);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final bool pauseDuringOpen in [false, true]) {
    test(
      'engine completion saves before automatic advance, paused open: $pauseDuringOpen',
      () async {
        final Directory directory = await Directory.systemTemp.createTemp(
          'listening-player-integration-',
        );
        addTearDown(() async {
          final String path = directory.resolveSymbolicLinksSync();
          expect(
            path,
            startsWith(Directory.systemTemp.resolveSymbolicLinksSync()),
          );
          expect(
            directory.path.split('/').last,
            startsWith('listening-player-integration-'),
          );
          await directory.delete(recursive: true);
        });
        Hive.init(directory.path);
        final Box<String> box = await Hive.openBox<String>(
          listeningProgressBoxName,
        );
        addTearDown(box.close);
        final ListeningProgressLocalRepository local =
            ListeningProgressLocalRepository(box);
        final ListeningProgress nextProgress = ListeningProgress(
          accountId: 'guest',
          aid: _nextChapter.aid,
          bvid: _nextChapter.bvid,
          cid: _nextChapter.cid!,
          page: _nextChapter.page!,
          collectionId: _nextChapter.collectionId,
          positionMs: 8000,
          durationMs: _duration.inMilliseconds,
          updatedAtMs: 1,
        );
        await local.save(nextProgress);
        ListeningProgress? read(PlayableItem item) => local.readChapter(
          accountId: 'guest',
          aid: item.aid,
          bvid: item.bvid,
          cid: item.cid!,
        );

        const MethodChannel connectivity = MethodChannel(
          'dev.fluttercommunity.plus/connectivity',
        );
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              connectivity,
              (_) async => <String>['none'],
            );
        addTearDown(
          () => TestDefaultBinaryMessengerBinding
              .instance
              .defaultBinaryMessenger
              .setMockMethodCallHandler(connectivity, null),
        );
        final _AudioEngine engine = _AudioEngine(
          blockFirstOpen: pauseDuringOpen,
        );
        final ProviderContainer container = ProviderContainer(
          overrides: [
            playerControllerProvider.overrideWith(
              () => PlayerController(audioEngine: engine),
            ),
            appAudioHandlerProvider.overrideWithValue(AppAudioHandler()),
            appSettingsStoreProvider.overrideWithValue(AppSettingsStore(box)),
            biliSessionControllerProvider.overrideWith(_GuestSession.new),
            listeningProgressLocalRepositoryProvider.overrideWithValue(local),
            biliHistoryRemoteRepositoryProvider.overrideWithValue(
              _UnusedHistoryRepository(),
            ),
            biliPlayerRepositoryProvider.overrideWithValue(
              _UnusedPlayerRepository(),
            ),
            playerAudioCacheRepositoryProvider.overrideWithValue(
              _CachedChapters(File('${directory.path}/fake.audio')),
            ),
            playerQueueLocalRepositoryProvider.overrideWithValue(
              _MemoryQueueRepository(),
            ),
            recentPlaybackControllerProvider.overrideWith(
              _NoRecentPlayback.new,
            ),
          ],
        );
        addTearDown(container.dispose);
        final PlayerController player = container.read(
          playerControllerProvider.notifier,
        );
        addTearDown(player.shutdown);
        final loading = player.setQueue(<PlayableItem>[_chapter, _nextChapter]);
        if (pauseDuringOpen) {
          await engine.openStarted.future;
          await player.pause();
          engine.firstOpen.complete();
          await loading;
          await container.pump();
          expect(container.read(playerControllerProvider).isReady, isFalse);
          expect(container.read(playerControllerProvider).audioStream, isNull);
          expect(engine.playing, isFalse);
          await player.play();
        } else {
          await loading;
        }
        await container.pump();
        final ListeningProgressController listening = container.read(
          listeningProgressControllerProvider.notifier,
        );
        expect(container.read(playerControllerProvider).isPlaying, isTrue);
        expect(engine.openedPositions, <Duration>[
          if (pauseDuringOpen) Duration.zero,
          Duration.zero,
        ]);
        engine.emitPosition(const Duration(minutes: 9, seconds: 50));
        await Future<void>.delayed(Duration.zero);
        await listening.flush();
        expect(read(_chapter)!.completed, isFalse);

        final Completer<void> advanced = Completer<void>();
        final ProviderSubscription<PlayerState> subscription = container.listen(
          playerControllerProvider,
          (_, PlayerState next) {
            if (next.currentItem?.cid == _nextChapter.cid &&
                next.isPlaying &&
                !next.isLoading &&
                !advanced.isCompleted) {
              advanced.complete();
            }
          },
        );
        addTearDown(subscription.close);

        engine.complete();
        await advanced.future.timeout(const Duration(seconds: 2));
        await Future<void>.delayed(Duration.zero);
        await listening.flush();

        final ListeningProgress completed = read(_chapter)!;
        expect(completed.completed, isTrue);
        expect(completed.positionMs, _duration.inMilliseconds);
        expect(completed.durationMs, _duration.inMilliseconds);
        expect(completed.page, 1);
        expect(completed.collectionId, 'book');
        expect(completed.pendingSync, isFalse);
        expect(
          container.read(playerControllerProvider).currentItem,
          _nextChapter,
        );
        expect(engine.openedPositions, <Duration>[
          if (pauseDuringOpen) Duration.zero,
          Duration.zero,
          const Duration(seconds: 8),
        ]);
        final ListeningProgress resumed = read(_nextChapter)!;
        expect(resumed.completed, isFalse);
        expect(resumed.positionMs, nextProgress.positionMs);
        expect(resumed.page, 2);

        engine.emitPosition(const Duration(seconds: 16));
        await Future<void>.delayed(Duration.zero);
        await player.stop();
        await listening.flush();

        expect(read(_chapter), completed);
        expect(read(_nextChapter)!.completed, isFalse);
        expect(read(_nextChapter)!.positionMs, 16000);
        expect(local.load('guest'), hasLength(2));
      },
    );
  }
}

class _GuestSession extends BiliSessionController {
  @override
  BiliSession? build() => null;
}

class _UnusedHistoryRepository implements BiliHistoryRemoteRepository {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedPlayerRepository implements BiliPlayerRepository {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CachedChapters implements PlayerAudioCacheRepository {
  _CachedChapters(this.file);

  final File file;

  @override
  Future<CachedAudio?> lookupCachedAudio({
    required PlayableItem item,
    required PlayerAudioQualityPreference preference,
    int? preferredQualityId,
    bool allowQualityFallback = true,
  }) async => CachedAudio(
    file: file,
    metadata: AudioCacheMetadata(
      cacheKey: item.stableId,
      bvid: item.bvid,
      aid: item.aid,
      cid: item.cid!,
      page: item.page,
      qualityId: 30280,
      qualityLabel: '192K',
      bandwidth: 192000,
      durationMs: _duration.inMilliseconds,
      pageTitle: item.pageTitle,
      byteLength: 1,
      sha256Hash: '',
      completedAt: 0,
    ),
  );

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MemoryQueueRepository implements PlayerQueueLocalRepository {
  @override
  Future<void> save(PersistedPlaybackQueue snapshot) async {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoRecentPlayback extends RecentPlaybackController {
  @override
  List<RecentPlaybackEntry> build() => const <RecentPlaybackEntry>[];

  @override
  Future<void> recordItem(PlayableItem item) async {}
}

class _AudioEngine implements PlayerAudioEngine {
  _AudioEngine({this.blockFirstOpen = false});
  final bool blockFirstOpen;
  final Completer<void> openStarted = Completer<void>();
  final Completer<void> firstOpen = Completer<void>();
  final StreamController<Duration> _positions =
      StreamController<Duration>.broadcast();
  final StreamController<PlayerEngineState> _states =
      StreamController<PlayerEngineState>.broadcast();
  final List<Duration> openedPositions = <Duration>[];

  @override
  bool playing = false;
  @override
  Duration position = Duration.zero;
  @override
  double volume = 1;
  @override
  PlayerEngineProcessingState processingState =
      PlayerEngineProcessingState.idle;

  @override
  Stream<Duration> get positionStream => _positions.stream;
  @override
  Stream<Duration> get bufferedPositionStream => const Stream<Duration>.empty();
  @override
  Stream<Duration?> get durationStream => const Stream<Duration?>.empty();
  @override
  Stream<double> get volumeStream => const Stream<double>.empty();
  @override
  Stream<PlayerEngineException> get errorStream =>
      const Stream<PlayerEngineException>.empty();
  @override
  Stream<PlayerEngineState> get playerStateStream => _states.stream;

  void emitPosition(Duration value) {
    position = value;
    _positions.add(value);
  }

  void _emitState() => _states.add(
    PlayerEngineState(playing: playing, processingState: processingState),
  );

  void complete() {
    playing = false;
    processingState = PlayerEngineProcessingState.completed;
    _emitState();
  }

  @override
  Future<Duration?> setFileSource({
    required String filePath,
    Duration? initialPosition,
  }) async {
    position = initialPosition ?? Duration.zero;
    openedPositions.add(position);
    if (blockFirstOpen && openedPositions.length == 1) {
      openStarted.complete();
      await firstOpen.future;
    }
    processingState = PlayerEngineProcessingState.ready;
    _emitState();
    return _duration;
  }

  @override
  Future<void> seek(Duration value) async {
    openedPositions[openedPositions.length - 1] = value;
    emitPosition(value);
  }

  @override
  Future<void> play() async {
    playing = true;
    _emitState();
  }

  @override
  Future<void> pause() async {
    playing = false;
    _emitState();
  }

  @override
  Future<void> stop() async {
    playing = false;
    position = Duration.zero;
    processingState = PlayerEngineProcessingState.idle;
    _positions.add(Duration.zero);
    _emitState();
  }

  @override
  Future<void> setVolume(double value) async => volume = value;

  @override
  Future<void> dispose() async {
    await _positions.close();
    await _states.close();
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
