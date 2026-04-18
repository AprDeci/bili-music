import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/player/data/audio_cache_repository.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/data/player_queue_local_repository.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/persisted_playback_queue.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/app_audio_handler.dart';
import 'package:bilimusic/feature/player/logic/controller/player_playback_loader.dart';
import 'package:bilimusic/feature/player/logic/controller/player_queue_manager.dart';
import 'package:bilimusic/feature/player/logic/player_audio_engine.dart';
import 'package:bilimusic/feature/player/logic/player_audio_quality_preference_logic.dart';
import 'package:bilimusic/feature/player/logic/player_audio_session_coordinator.dart';
import 'package:bilimusic/feature/player/logic/player_media_item_mapper.dart';
import 'package:bilimusic/feature/player/logic/player_settings_logic.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' as audio;

final NotifierProvider<PlayerController, PlayerState> playerControllerProvider =
    NotifierProvider<PlayerController, PlayerState>(PlayerController.new);

class PlayerController extends Notifier<PlayerState>
    implements PlayerCommandTarget {
  final AppLogger _logger = AppLogger('PlayerController');

  late final PlayerQueueLocalRepository _queueRepository = ref.read(
    playerQueueLocalRepositoryProvider,
  );
  late final AppAudioHandler _audioHandler = ref.read(appAudioHandlerProvider);
  late final PlayerAudioEngine _audioEngine = PlayerAudioEngine();
  late final PlayerPlaybackLoader _playbackLoader = PlayerPlaybackLoader(
    repository: ref.read(biliPlayerRepositoryProvider),
    audioCacheRepository: ref.read(playerAudioCacheRepositoryProvider),
    audioEngine: _audioEngine,
    readSession: () => ref.read(biliSessionControllerProvider),
    readQualityPreference: () =>
        ref.read(playerAudioQualityPreferenceLogicProvider),
    logEvent: _logPlayerEvent,
  );
  late final PlayerQueueManager _queueManager = PlayerQueueManager();
  late final PlayerAudioSessionCoordinator _audioSessionCoordinator =
      PlayerAudioSessionCoordinator(
        audioEngine: _audioEngine,
        readAllowMixWithOthers: () => ref.read(playerSettingsLogicProvider),
        readHasQueue: () => state.hasQueue,
        readIsPlaying: () => state.isPlaying,
        readIsReady: () => state.isReady,
        readIsLoading: () => state.isLoading,
        readHasError: () => state.hasError,
        play: play,
        pause: pause,
      );

  final Map<String, int?> _qualityOverrides = <String, int?>{};
  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];

  bool _isBound = false;
  bool _isDisposed = false;
  bool _isAdvancingQueue = false;
  int _operationGeneration = 0;

  @override
  PlayerState build() {
    if (!_isBound) {
      _bindPlayerStreams();
      _audioHandler.attachTarget(this);
      unawaited(_audioSessionCoordinator.bind());
      _isBound = true;
    }

    ref.onDispose(() {
      unawaited(_dispose());
    });

    return const PlayerState();
  }

  Future<void> _dispose() async {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    _audioHandler.detachTarget(this);
    await _audioSessionCoordinator.dispose();

    for (final StreamSubscription<dynamic> subscription in _subscriptions) {
      await subscription.cancel();
    }

    try {
      await _audioEngine.dispose();
    } on Object {
      // Ignore engine dispose failures.
    }
  }

  Future<void> loadFromItem(PlayableItem item, {bool autoplay = true}) {
    return setQueue(
      <PlayableItem>[item],
      startIndex: 0,
      sourceLabel: state.queueSourceLabel,
      autoplay: autoplay,
    );
  }

  @override
  Future<void> play() async {
    if (!state.hasQueue) {
      return;
    }

    final int? queueIndex = state.currentQueueIndex;
    if (queueIndex == null) {
      await _loadQueueIndex(0, autoplay: true, initialPosition: state.position);
      return;
    }

    if (!state.isReady && !state.isLoading) {
      await _loadQueueIndex(
        queueIndex,
        autoplay: true,
        initialPosition: state.position,
      );
      return;
    }

    await _audioEngine.play();
  }

  @override
  Future<void> pause() async {
    await _audioEngine.pause();
    await _persistQueueSnapshot();
  }

  Future<void> togglePlayback() async {
    if (state.isPlaying) {
      await pause();
      return;
    }
    await play();
  }

  Future<void> setAudioQualityPreference(
    PlayerAudioQualityPreference preference,
  ) async {
    final PlayerAudioQualityPreference currentPreference = ref.read(
      playerAudioQualityPreferenceLogicProvider,
    );
    if (currentPreference == preference) {
      return;
    }

    await ref
        .read(playerAudioQualityPreferenceLogicProvider.notifier)
        .setPreference(preference);

    if (!state.hasActiveQueueIndex || state.currentItem == null) {
      return;
    }

    _qualityOverrides.remove(state.currentItem!.stableId);

    _playbackLoader.clearResolvedEntryCache(
      item: state.currentItem!,
      preference: currentPreference,
    );
    _playbackLoader.clearResolvedEntryCache(
      item: state.currentItem!,
      preference: preference,
    );

    final int queueIndex = state.currentQueueIndex!;
    final bool wasPlaying = state.isPlaying;
    final Duration position = state.position;
    await _loadQueueIndex(
      queueIndex,
      autoplay: wasPlaying,
      initialPosition: position,
    );
    if (!wasPlaying && state.isReady) {
      await _audioEngine.pause();
      state = state.copyWith(isPlaying: false, isBuffering: false);
      _publishMediaSession();
      await _persistQueueSnapshot();
    }
  }

  Future<void> switchCurrentAudioQuality(int? qualityId) async {
    final PlayableItem? currentItem = state.currentItem;
    if (!state.hasActiveQueueIndex || currentItem == null) {
      return;
    }

    final int? currentQualityId = state.audioStream?.qualityId;
    if (currentQualityId == qualityId) {
      return;
    }

    final PlayerAudioQualityPreference qualityPreference = ref.read(
      playerAudioQualityPreferenceLogicProvider,
    );
    _playbackLoader.clearResolvedEntryCache(
      item: currentItem,
      preference: qualityPreference,
      preferredQualityId: qualityId,
    );
    _qualityOverrides[currentItem.stableId] = qualityId;

    final int queueIndex = state.currentQueueIndex!;
    final bool wasPlaying = state.isPlaying;
    final Duration position = state.position;
    await _loadQueueIndex(
      queueIndex,
      autoplay: wasPlaying,
      initialPosition: position,
    );
    if (!wasPlaying && state.isReady) {
      await _audioEngine.pause();
      state = state.copyWith(isPlaying: false, isBuffering: false);
      _publishMediaSession();
      await _persistQueueSnapshot();
    }
  }

  @override
  Future<void> seek(Duration position) {
    return _audioEngine.seek(position);
  }

  Future<void> seekBy(Duration offset) async {
    final Duration effectiveDuration = state.duration ?? Duration.zero;
    final Duration nextPosition = _audioEngine.position + offset;
    final Duration clamped = nextPosition < Duration.zero
        ? Duration.zero
        : effectiveDuration > Duration.zero && nextPosition > effectiveDuration
        ? effectiveDuration
        : nextPosition;
    await seek(clamped);
  }

  @override
  Future<void> stop() async {
    final int generation = _nextGeneration();
    await _audioEngine.stop();
    if (!_isCurrentGeneration(generation)) {
      return;
    }

    state = state.copyWith(
      isPlaying: false,
      isBuffering: false,
      isReady: false,
      position: Duration.zero,
      bufferedPosition: Duration.zero,
    );
    _publishMediaSession();
    await _persistQueueSnapshot();
  }

  Future<void> setQueue(
    List<PlayableItem> items, {
    int startIndex = 0,
    String? sourceLabel,
    bool autoplay = true,
  }) async {
    if (items.isEmpty) {
      return;
    }

    final int generation = _nextGeneration();
    final int resolvedIndex = startIndex.clamp(0, items.length - 1);
    final List<PlayableItem> queue = List<PlayableItem>.unmodifiable(items);
    _qualityOverrides.clear();
    _queueManager.resetForQueue(currentIndex: resolvedIndex);
    state = state.copyWith(
      queue: queue,
      currentQueueIndex: resolvedIndex,
      currentItem: queue[resolvedIndex],
      queueSourceLabel: sourceLabel,
      availableParts: const <PlayableItem>[],
      audioStream: null,
      duration: null,
      position: Duration.zero,
      bufferedPosition: Duration.zero,
      isReady: false,
      isPlaying: false,
      isBuffering: false,
      statusHint: null,
      errorMessage: null,
    );
    _publishMediaSession();
    await _loadQueueIndex(
      resolvedIndex,
      autoplay: autoplay,
      initialPosition: Duration.zero,
      generation: generation,
    );
  }

  Future<void> replaceCurrentQueueItem(
    PlayableItem item, {
    bool autoplay = true,
  }) async {
    if (!state.hasActiveQueueIndex) {
      await setQueue(
        <PlayableItem>[item],
        startIndex: 0,
        sourceLabel: state.queueSourceLabel,
        autoplay: autoplay,
      );
      return;
    }

    final int currentIndex = state.currentQueueIndex!;
    final int generation = _nextGeneration();
    final List<PlayableItem> nextQueue = List<PlayableItem>.of(state.queue);
    final PlayableItem previousItem = nextQueue[currentIndex];
    _qualityOverrides.remove(previousItem.stableId);
    nextQueue[currentIndex] = item;
    _playbackLoader.removeResolvedEntryCachesForItem(previousItem);
    state = state.copyWith(
      queue: List<PlayableItem>.unmodifiable(nextQueue),
      currentQueueIndex: currentIndex,
      currentItem: item,
      availableParts: const <PlayableItem>[],
      audioStream: null,
      duration: null,
      position: Duration.zero,
      bufferedPosition: Duration.zero,
      isReady: false,
      isPlaying: false,
      isBuffering: false,
      statusHint: null,
      errorMessage: null,
    );
    _publishMediaSession();
    await _loadQueueIndex(
      currentIndex,
      autoplay: autoplay,
      initialPosition: Duration.zero,
      generation: generation,
    );
  }

  Future<void> enqueue(List<PlayableItem> items) async {
    if (items.isEmpty) {
      return;
    }

    final List<PlayableItem> queue = List<PlayableItem>.unmodifiable(
      <PlayableItem>[...state.queue, ...items],
    );

    if (!state.hasActiveQueueIndex) {
      await setQueue(
        queue,
        startIndex: 0,
        sourceLabel: state.queueSourceLabel,
        autoplay: false,
      );
      return;
    }

    state = state.copyWith(queue: queue);
    _publishMediaSession();
    await _persistQueueSnapshot();
  }

  Future<void> playNext(PlayableItem item) async {
    if (!state.hasActiveQueueIndex) {
      await setQueue(<PlayableItem>[item]);
      return;
    }

    final int insertIndex = state.currentQueueIndex! + 1;
    final List<PlayableItem> nextQueue = List<PlayableItem>.of(state.queue)
      ..insert(insertIndex, item);
    state = state.copyWith(queue: List<PlayableItem>.unmodifiable(nextQueue));
    _publishMediaSession();
    await _persistQueueSnapshot();
  }

  Future<void> removeQueueItemAt(int index) async {
    if (index < 0 || index >= state.queue.length) {
      return;
    }

    final PlayableItem removedItem = state.queue[index];
    _qualityOverrides.remove(removedItem.stableId);
    final QueueRemovalResult removal = _queueManager.removeAt(
      queue: state.queue,
      currentIndex: state.currentQueueIndex,
      removedIndex: index,
    );
    final List<PlayableItem> nextQueue = removal.queue;
    _playbackLoader.removeResolvedEntryCachesForItem(removedItem);

    if (nextQueue.isEmpty) {
      await clearQueue();
      return;
    }

    final int generation = _nextGeneration();
    final int? previousCurrentIndex = state.currentQueueIndex;
    final int? nextCurrentIndex = removal.nextCurrentIndex;
    state = state.copyWith(
      queue: List<PlayableItem>.unmodifiable(nextQueue),
      currentQueueIndex: nextCurrentIndex,
      currentItem: nextCurrentIndex == null
          ? null
          : nextQueue[nextCurrentIndex],
      availableParts: removal.removedCurrentItem
          ? const <PlayableItem>[]
          : state.availableParts,
      audioStream: removal.removedCurrentItem ? null : state.audioStream,
      duration: removal.removedCurrentItem ? null : state.duration,
      position: removal.removedCurrentItem ? Duration.zero : state.position,
      bufferedPosition: removal.removedCurrentItem
          ? Duration.zero
          : state.bufferedPosition,
      isReady: removal.removedCurrentItem ? false : state.isReady,
      isPlaying: removal.removedCurrentItem ? false : state.isPlaying,
      isBuffering: false,
      statusHint: removal.removedCurrentItem ? null : state.statusHint,
      errorMessage: null,
    );
    _publishMediaSession();

    if (nextCurrentIndex == null) {
      await _persistQueueSnapshot();
      return;
    }

    if (removal.removedCurrentItem && previousCurrentIndex != null) {
      await _loadQueueIndex(
        nextCurrentIndex,
        autoplay: state.isPlaying,
        initialPosition: Duration.zero,
        generation: generation,
      );
      return;
    }

    await _persistQueueSnapshot();
  }

  Future<void> clearQueue() async {
    _nextGeneration();
    _queueManager.resetForQueue(currentIndex: null);
    _qualityOverrides.clear();
    await _audioEngine.stop();
    state = state.copyWith(
      queue: const <PlayableItem>[],
      currentQueueIndex: null,
      currentItem: null,
      availableParts: const <PlayableItem>[],
      audioStream: null,
      queueSourceLabel: null,
      isLoading: false,
      isReady: false,
      isPlaying: false,
      isBuffering: false,
      position: Duration.zero,
      bufferedPosition: Duration.zero,
      duration: null,
      statusHint: null,
      errorMessage: null,
    );
    _audioHandler.clearSession();
    await _queueRepository.clear();
  }

  @override
  Future<void> skipToPrevious() async {
    if (state.position > const Duration(seconds: 3)) {
      await seek(Duration.zero);
      return;
    }

    final int? targetIndex = _queueManager.resolvePreviousIndex(
      queue: state.queue,
      currentIndex: state.currentQueueIndex,
      mode: state.queueMode,
    );
    if (targetIndex == null) {
      await seek(Duration.zero);
      return;
    }

    await skipToQueueIndex(targetIndex);
  }

  @override
  Future<void> skipToNext() async {
    if (_isAdvancingQueue) {
      return;
    }

    _isAdvancingQueue = true;
    try {
      final int? targetIndex = _queueManager.resolveNextIndex(
        queue: state.queue,
        currentIndex: state.currentQueueIndex,
        mode: state.queueMode,
      );
      if (targetIndex == null) {
        state = state.copyWith(isPlaying: false, isBuffering: false);
        _publishMediaSession();
        return;
      }
      await skipToQueueIndex(targetIndex);
    } finally {
      _isAdvancingQueue = false;
    }
  }

  Future<void> skipToQueueIndex(int index, {bool autoplay = true}) async {
    if (index < 0 || index >= state.queue.length) {
      return;
    }

    final int generation = _nextGeneration();
    state = state.copyWith(
      currentQueueIndex: index,
      currentItem: state.queue[index],
      availableParts: const <PlayableItem>[],
      audioStream: null,
      duration: null,
      position: Duration.zero,
      bufferedPosition: Duration.zero,
      isReady: false,
      isPlaying: false,
      isBuffering: false,
      statusHint: null,
      errorMessage: null,
    );
    _publishMediaSession();
    await _loadQueueIndex(
      index,
      autoplay: autoplay,
      initialPosition: Duration.zero,
      generation: generation,
    );
  }

  void toggleQueueMode() {
    final PlayerQueueMode nextMode = switch (state.queueMode) {
      PlayerQueueMode.sequence => PlayerQueueMode.singleRepeat,
      PlayerQueueMode.singleRepeat => PlayerQueueMode.shuffle,
      PlayerQueueMode.shuffle => PlayerQueueMode.sequence,
    };
    _queueManager.resetForMode(
      mode: nextMode,
      currentIndex: state.currentQueueIndex,
    );
    state = state.copyWith(queueMode: nextMode);
    _publishMediaSession();
    unawaited(_persistQueueSnapshot());
  }

  Future<void> restoreFromPersistence() async {
    final PersistedPlaybackQueue? snapshot = _queueRepository.load();
    if (snapshot == null) {
      return;
    }

    final int? restoredIndex = snapshot.sanitizedCurrentQueueIndex;
    final List<PlayableItem> restoredQueue = snapshot.queue
        .map((PersistedPlayableItem item) => item.toPlayableItem())
        .toList(growable: false);
    if (restoredQueue.isEmpty || restoredIndex == null) {
      await _queueRepository.clear();
      return;
    }

    final int generation = _nextGeneration();
    _queueManager.resetForMode(
      mode: snapshot.queueMode,
      currentIndex: restoredIndex,
    );
    state = state.copyWith(
      queue: List<PlayableItem>.unmodifiable(restoredQueue),
      currentQueueIndex: restoredIndex,
      currentItem: restoredQueue[restoredIndex],
      queueMode: snapshot.queueMode,
      queueSourceLabel: snapshot.queueSourceLabel,
      availableParts: const <PlayableItem>[],
      audioStream: null,
      duration: null,
      position: Duration.zero,
      bufferedPosition: Duration.zero,
      isLoading: false,
      isReady: false,
      isPlaying: false,
      isBuffering: false,
      statusHint: null,
      errorMessage: null,
    );
    _publishMediaSession();

    final bool restored = await _loadQueueIndex(
      restoredIndex,
      autoplay: false,
      initialPosition: Duration(milliseconds: snapshot.resumePositionMs),
      generation: generation,
      persistAfterLoad: false,
    );
    if (!restored || !_isCurrentGeneration(generation)) {
      return;
    }

    await pause();
    if (!_isCurrentGeneration(generation)) {
      return;
    }

    state = state.copyWith(isPlaying: false, isBuffering: false);
    _publishMediaSession();
    await _persistQueueSnapshot();
  }

  Future<bool> _loadQueueIndex(
    int queueIndex, {
    required bool autoplay,
    required Duration initialPosition,
    int? generation,
    bool persistAfterLoad = true,
  }) async {
    if (queueIndex < 0 || queueIndex >= state.queue.length) {
      return false;
    }

    final int effectiveGeneration = generation ?? _nextGeneration();
    final PlayableItem targetItem = state.queue[queueIndex];
    _logPlayerEvent(
      'loadQueueIndex:start',
      details: <String, Object?>{
        'generation': effectiveGeneration,
        'queueIndex': queueIndex,
        'autoplay': autoplay,
        'stableId': targetItem.stableId,
        'title': targetItem.title,
        'positionMs': initialPosition.inMilliseconds,
      },
    );

    state = state.copyWith(
      currentQueueIndex: queueIndex,
      currentItem: targetItem,
      isLoading: true,
      isReady: false,
      isPlaying: false,
      isBuffering: false,
      statusHint: PlayerStatusHint.resolvingAudio,
      availableParts: const <PlayableItem>[],
      audioStream: null,
      duration: null,
      position: Duration.zero,
      bufferedPosition: Duration.zero,
      errorMessage: null,
    );
    _publishMediaSession();

    try {
      final ResolvedQueueEntry entry = await _playbackLoader.resolveQueueEntry(
        targetItem,
        preferredQualityId: _qualityOverrides[targetItem.stableId],
      );
      if (!_isCurrentGeneration(effectiveGeneration)) {
        return false;
      }

      final Duration? loadedDuration = await _playbackLoader.setSourceForEntry(
        entry: entry,
        queueSourceLabel: state.queueSourceLabel,
        initialPosition: initialPosition,
        onStatusHint: (PlayerStatusHint hint) {
          state = state.copyWith(statusHint: hint);
        },
      );
      if (!_isCurrentGeneration(effectiveGeneration)) {
        return false;
      }

      _applyResolvedCurrentEntry(
        queueIndex: queueIndex,
        entry: entry,
        durationOverride: loadedDuration,
      );
      _queueManager.recordVisit(mode: state.queueMode, index: queueIndex);
      if (autoplay) {
        unawaited(
          ref
              .read(recentPlaybackControllerProvider.notifier)
              .recordItem(entry.item),
        );
      }
      _publishMediaSession();

      if (autoplay) {
        await _audioEngine.play();
      } else {
        await _audioEngine.pause();
      }
      if (!_isCurrentGeneration(effectiveGeneration)) {
        return false;
      }

      unawaited(_playbackLoader.cacheEntryInBackground(entry));

      if (persistAfterLoad) {
        await _persistQueueSnapshot();
      }
      _publishMediaSession();
      return true;
    } on Object catch (error) {
      if (!_isCurrentGeneration(effectiveGeneration)) {
        return false;
      }

      state = state.copyWith(
        isLoading: false,
        isReady: false,
        isPlaying: false,
        isBuffering: false,
        statusHint: PlayerStatusHint.error,
        availableParts: const <PlayableItem>[],
        audioStream: null,
        duration: null,
        errorMessage: error.toString(),
      );
      _publishMediaSession();
      if (persistAfterLoad) {
        await _persistQueueSnapshot();
      }
      return false;
    }
  }

  void _applyResolvedCurrentEntry({
    required int queueIndex,
    required ResolvedQueueEntry entry,
    Duration? durationOverride,
  }) {
    final List<PlayableItem> queue = _playbackLoader.replaceQueueEntry(
      queue: state.queue,
      index: queueIndex,
      item: entry.item,
    );
    state = state.copyWith(
      queue: queue,
      currentQueueIndex: queueIndex,
      currentItem: entry.item,
      availableParts: entry.availableParts,
      audioStream: entry.audioStream,
      isLoading: false,
      isReady: true,
      duration: durationOverride ?? entry.audioStream.duration,
      statusHint: null,
      errorMessage: null,
    );
  }

  void _bindPlayerStreams() {
    _subscriptions.add(
      _audioEngine.positionStream.listen((Duration position) {
        state = state.copyWith(position: position);
        _publishMediaSession();
      }),
    );
    _subscriptions.add(
      _audioEngine.bufferedPositionStream.listen((Duration bufferedPosition) {
        state = state.copyWith(bufferedPosition: bufferedPosition);
        _publishMediaSession();
      }),
    );
    _subscriptions.add(
      _audioEngine.durationStream.listen((Duration? duration) {
        if (duration == null) {
          return;
        }
        state = state.copyWith(duration: duration);
        _publishMediaSession();
      }),
    );
    _subscriptions.add(
      _audioEngine.errorStream.listen((audio.PlayerException error) {
        state = state.copyWith(
          isLoading: false,
          isPlaying: false,
          isBuffering: false,
          statusHint: PlayerStatusHint.error,
          errorMessage: '播放器错误: ${error.message}',
        );
        _publishMediaSession();
      }),
    );
    _subscriptions.add(
      _audioEngine.playerStateStream.listen((audio.PlayerState playerState) {
        final bool isBuffering =
            playerState.processingState == audio.ProcessingState.loading ||
            playerState.processingState == audio.ProcessingState.buffering;
        final bool isReady =
            playerState.processingState != audio.ProcessingState.idle &&
            playerState.processingState != audio.ProcessingState.loading;
        final bool completed =
            playerState.processingState == audio.ProcessingState.completed;

        state = state.copyWith(
          isPlaying: playerState.playing,
          isBuffering: isBuffering,
          isReady: state.isLoading ? state.isReady : isReady,
          statusHint: state.hasError
              ? PlayerStatusHint.error
              : state.isLoading
              ? state.statusHint
              : isBuffering
              ? PlayerStatusHint.buffering
              : null,
          position: completed
              ? (state.duration ?? state.position)
              : state.position,
        );
        _publishMediaSession(
          processingState: mapAudioProcessingState(
            playerState.processingState.name,
          ),
        );

        if (completed) {
          unawaited(_handlePlaybackCompleted());
        }
      }),
    );
  }

  Future<void> _handlePlaybackCompleted() async {
    if (_isAdvancingQueue) {
      return;
    }

    if (state.queueMode == PlayerQueueMode.singleRepeat) {
      await seek(Duration.zero);
      await play();
      return;
    }

    await skipToNext();
  }

  int _nextGeneration() {
    _operationGeneration += 1;
    return _operationGeneration;
  }

  bool _isCurrentGeneration(int generation) {
    return generation == _operationGeneration;
  }

  Future<void> _persistQueueSnapshot() async {
    final PersistedPlaybackQueue? snapshot = _buildSnapshot();
    if (snapshot == null) {
      await _queueRepository.clear();
      return;
    }
    await _queueRepository.save(snapshot);
  }

  PersistedPlaybackQueue? _buildSnapshot() {
    if (!state.hasQueue) {
      return null;
    }

    return PersistedPlaybackQueue(
      queue: state.queue
          .map(PersistedPlayableItem.fromPlayableItem)
          .toList(growable: false),
      currentQueueIndex: state.currentQueueIndex,
      queueMode: state.queueMode,
      queueSourceLabel: state.queueSourceLabel,
      resumePositionMs: _resolveResumePositionMs(),
      savedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  int _resolveResumePositionMs() {
    if (!state.hasActiveQueueIndex) {
      return 0;
    }

    final Duration position = state.position;
    if (position <= Duration.zero) {
      return 0;
    }

    final Duration? duration = state.duration;
    if (duration == null || duration <= Duration.zero) {
      return position.inMilliseconds;
    }

    final int remainingMs = duration.inMilliseconds - position.inMilliseconds;
    if (remainingMs <= const Duration(seconds: 2).inMilliseconds) {
      return 0;
    }

    if (position < const Duration(seconds: 3)) {
      return 0;
    }

    return position.inMilliseconds.clamp(0, duration.inMilliseconds);
  }

  void _publishMediaSession({AudioProcessingState? processingState}) {
    final List<MediaItem> queueItems = state.queue
        .map(
          (PlayableItem item) => buildPlayerQueueMediaItem(
            item,
            queueSourceLabel: state.queueSourceLabel,
          ),
        )
        .toList(growable: false);
    _audioHandler.updateQueue(queueItems);

    final PlayableItem? currentItem = state.currentItem;
    final audioStream = state.audioStream;
    if (currentItem == null || audioStream == null) {
      _audioHandler.updateCurrentMediaItem(
        currentItem == null
            ? null
            : buildPlayerQueueMediaItem(
                currentItem,
                queueSourceLabel: state.queueSourceLabel,
                duration: state.duration,
              ),
      );
    } else {
      _audioHandler.updateCurrentMediaItem(
        buildPlayerMediaItem(
          currentItem,
          audioStream: audioStream,
          queueSourceLabel: state.queueSourceLabel,
          duration: state.duration,
        ),
      );
    }

    _audioHandler.updatePlaybackSnapshot(
      isPlaying: state.isPlaying,
      isBuffering: state.isBuffering,
      hasPrevious:
          state.hasPrevious || state.position > const Duration(seconds: 3),
      hasNext: state.queueMode == PlayerQueueMode.singleRepeat || state.hasNext,
      position: state.position,
      bufferedPosition: state.bufferedPosition,
      duration: state.duration,
      processingState:
          processingState ??
          (state.isLoading
              ? AudioProcessingState.loading
              : state.isBuffering
              ? AudioProcessingState.buffering
              : state.isReady
              ? AudioProcessingState.ready
              : AudioProcessingState.idle),
    );
  }

  void _logPlayerEvent(String event, {Map<String, Object?>? details}) {
    final String detailText = details == null || details.isEmpty
        ? ''
        : details.entries
              .map(
                (MapEntry<String, Object?> entry) =>
                    '${entry.key}=${entry.value}',
              )
              .join(', ');
    _logger.d(
      detailText.isEmpty
          ? '[PlayerDebug] $event'
          : '[PlayerDebug] $event | $detailText',
    );
  }
}
