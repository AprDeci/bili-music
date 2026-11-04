import 'dart:async';

import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/player/domain/player_event.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/logic/playback/audio_source_resolver.dart';
import 'package:bilimusic/feature/player/logic/playback/player_audio_engine.dart';
import 'package:bilimusic/feature/player/logic/playback/player_playback_loader.dart';
import 'package:bilimusic/feature/player/logic/playback/player_queue_manager.dart';

abstract interface class PlayerSessionHost {
  PlayerState get sessionState;

  set sessionState(PlayerState value);

  int nextGeneration();

  bool isCurrentGeneration(int generation);

  bool get isAdvancingQueue;

  int? qualityOverrideFor(String stableId);

  PlayerAudioQualityPreference get qualityPreference;

  void publishPlaybackState();

  Future<void> persistQueueSnapshot();

  Future<void> enqueueAvailableParts(List<PlayableItem> parts);

  void resetEnginePlaybackSnapshot({
    required PlayerEngineProcessingState processingState,
  });

  void suspendListening();

  void logPlayerEvent(String event, {Map<String, Object?>? details});

  void emitPlayerEvent(PlayerEventType type);

  Future<void> activateAudioSessionForPlayback();

  Future<void> playCurrentSource();

  Future<void> seekSession(Duration position);

  Future<void> skipToNextTrack();

  Future<void> stopAudioEngine();

  Future<void> pauseAudioEngine();

  Future<Duration> resumeListeningPosition(
    PlayableItem item, {
    required Duration fallback,
    required bool Function() isCurrent,
  });

  void beginListening(PlayableItem item, Duration position, Duration? duration);

  void recordRecentPlayback(PlayableItem item);

  void showToast(String message);
}

class PlayerSessionCoordinator {
  PlayerSessionCoordinator({
    required this._host,
    required this._playbackLoader,
    required this._queueManager,
    this._maxPlaybackRetries = 3,
  });

  final PlayerSessionHost _host;
  final PlayerPlaybackLoader _playbackLoader;
  final PlayerQueueManager _queueManager;
  final int _maxPlaybackRetries;

  int _retryGeneration = 0;
  int _engineRetryCount = 0;
  bool _isWaitingForRetry = false;
  bool _isHandlingPlaybackCompleted = false;

  PlayerState get _state => _host.sessionState;

  void _setState(PlayerState value) => _host.sessionState = value;

  int get engineRetryCount => _engineRetryCount;

  bool get isWaitingForRetry => _isWaitingForRetry;

  void resetEngineRetryCount() {
    _engineRetryCount = 0;
  }

  void cancelPendingRetry() {
    _retryGeneration += 1;
  }

  Future<bool> load(
    int queueIndex, {
    required bool autoplay,
    required Duration initialPosition,
    int? generation,
    bool persistAfterLoad = true,
    int retryCount = 0,
    Set<String> skippedUnavailableStableIds = const <String>{},
    bool hasShownUnavailableToast = false,
  }) async {
    if (queueIndex < 0 || queueIndex >= _state.queue.length) {
      return false;
    }

    if (retryCount == 0) {
      _engineRetryCount = 0;
    }
    final int effectiveGeneration = generation ?? _host.nextGeneration();
    final PlayableItem targetItem = _state.queue[queueIndex];
    _host.logPlayerEvent(
      'loadQueueIndex:start',
      details: <String, Object?>{
        'generation': effectiveGeneration,
        'queueIndex': queueIndex,
        'autoplay': autoplay,
        'stableId': targetItem.stableId,
        'title': targetItem.title,
        'positionMs': initialPosition.inMilliseconds,
        'retryCount': retryCount,
      },
    );

    _host.suspendListening();
    _host.resetEnginePlaybackSnapshot(
      processingState: PlayerEngineProcessingState.loading,
    );
    _setState(
      _state.copyWith(
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
      ),
    );
    _host.publishPlaybackState();

    try {
      await _host.stopAudioEngine();
      if (!_host.isCurrentGeneration(effectiveGeneration)) {
        return false;
      }

      await _host.activateAudioSessionForPlayback();
      if (!_host.isCurrentGeneration(effectiveGeneration)) {
        return false;
      }
      final ResolvedQueueEntry entry = await _playbackLoader.resolveQueueEntry(
        targetItem,
        preferredQualityId: _host.qualityOverrideFor(targetItem.stableId),
      );
      if (!_host.isCurrentGeneration(effectiveGeneration)) {
        return false;
      }

      Duration startPosition = initialPosition;
      if (entry.item.isSpoken) {
        startPosition = await _host.resumeListeningPosition(
          entry.item,
          fallback: initialPosition,
          isCurrent: () => _host.isCurrentGeneration(effectiveGeneration),
        );
        if (!_host.isCurrentGeneration(effectiveGeneration)) {
          return false;
        }
        final Duration? duration = entry.audioStream.duration;
        if (startPosition < Duration.zero ||
            (duration != null && startPosition >= duration)) {
          startPosition = Duration.zero;
        }
      }
      final Duration? loadedDuration = await _playbackLoader.setSourceForEntry(
        entry: entry,
        initialPosition: startPosition,
        isCurrent: () => _host.isCurrentGeneration(effectiveGeneration),
        onStatusHint: (PlayerStatusHint hint) {
          _setState(_state.copyWith(statusHint: hint));
        },
      );
      if (!_host.isCurrentGeneration(effectiveGeneration)) {
        return false;
      }

      _applyResolvedCurrentEntry(
        queueIndex: queueIndex,
        entry: entry,
        durationOverride: loadedDuration,
      );
      _setState(_state.copyWith(position: startPosition));
      await _host.enqueueAvailableParts(entry.availableParts);
      _host.beginListening(entry.item, startPosition, _state.duration);
      if (entry.cachedFile != null) {
        unawaited(
          _completeCachedEntryParts(
            generation: effectiveGeneration,
            queueIndex: queueIndex,
            entry: entry,
          ),
        );
      }
      _queueManager.recordVisit(
        queue: _state.queue,
        mode: _state.queueMode,
        index: queueIndex,
      );
      if (autoplay) {
        _host.recordRecentPlayback(entry.item);
      }
      _host.publishPlaybackState();

      if (autoplay) {
        await _host.playCurrentSource();
      } else {
        await _host.pauseAudioEngine();
      }
      if (!_host.isCurrentGeneration(effectiveGeneration)) {
        return false;
      }

      if (persistAfterLoad) {
        await _host.persistQueueSnapshot();
      }
      _host.publishPlaybackState();
      return true;
    } on BiliPlayerException catch (error) {
      if (!_host.isCurrentGeneration(effectiveGeneration)) {
        return false;
      }

      if (error.shouldSkipQueueItem) {
        return _skipUnavailableQueueItem(
          failedIndex: queueIndex,
          autoplay: autoplay,
          generation: effectiveGeneration,
          persistAfterLoad: persistAfterLoad,
          error: error,
          skippedUnavailableStableIds: skippedUnavailableStableIds,
          hasShownUnavailableToast: hasShownUnavailableToast,
        );
      }

      return retryOrSkipFailedQueueItem(
        error: error,
        failedIndex: queueIndex,
        autoplay: autoplay,
        initialPosition: initialPosition,
        generation: effectiveGeneration,
        persistAfterLoad: persistAfterLoad,
        retryCount: retryCount,
        skippedUnavailableStableIds: skippedUnavailableStableIds,
      );
    } on Object catch (error) {
      if (!_host.isCurrentGeneration(effectiveGeneration)) {
        return false;
      }

      return retryOrSkipFailedQueueItem(
        error: error,
        failedIndex: queueIndex,
        autoplay: autoplay,
        initialPosition: initialPosition,
        generation: effectiveGeneration,
        persistAfterLoad: persistAfterLoad,
        retryCount: retryCount,
        skippedUnavailableStableIds: skippedUnavailableStableIds,
      );
    }
  }

  Future<bool> retryOrSkipFailedQueueItem({
    required Object error,
    required int failedIndex,
    required bool autoplay,
    required Duration initialPosition,
    required int generation,
    required bool persistAfterLoad,
    required int retryCount,
    required Set<String> skippedUnavailableStableIds,
  }) async {
    if (error is! TimeoutException && retryCount < _maxPlaybackRetries) {
      final int nextRetryCount = retryCount + 1;
      _engineRetryCount = nextRetryCount;
      final PlayableItem failedItem = _state.queue[failedIndex];
      _playbackLoader.clearResolvedEntryCache(
        item: failedItem,
        preference: _host.qualityPreference,
        preferredQualityId: _host.qualityOverrideFor(failedItem.stableId),
      );
      _host.logPlayerEvent(
        'loadQueueIndex:retry',
        details: <String, Object?>{
          'generation': generation,
          'queueIndex': failedIndex,
          'retryCount': nextRetryCount,
          'error': error,
        },
      );
      _setState(
        _state.copyWith(
          isLoading: true,
          isPlaying: false,
          isBuffering: false,
          statusHint: PlayerStatusHint.connectingStream,
          errorMessage: null,
        ),
      );
      _host.publishPlaybackState();
      final int retryGeneration = _retryGeneration;
      _isWaitingForRetry = true;
      try {
        await Future<void>.delayed(const Duration(seconds: 1));
        if (!_host.isCurrentGeneration(generation) ||
            retryGeneration != _retryGeneration) {
          return false;
        }
      } finally {
        _isWaitingForRetry = false;
      }
      return load(
        failedIndex,
        autoplay: autoplay,
        initialPosition: initialPosition,
        generation: generation,
        persistAfterLoad: persistAfterLoad,
        retryCount: nextRetryCount,
        skippedUnavailableStableIds: skippedUnavailableStableIds,
      );
    }

    return _skipFailedQueueItem(
      error: error,
      failedIndex: failedIndex,
      autoplay: autoplay,
      generation: generation,
      persistAfterLoad: persistAfterLoad,
      skippedUnavailableStableIds: skippedUnavailableStableIds,
    );
  }

  Future<void> handlePlaybackCompleted(int generation) async {
    if (_isHandlingPlaybackCompleted || _host.isAdvancingQueue) {
      return;
    }
    if (!_host.isCurrentGeneration(generation)) {
      return;
    }

    _isHandlingPlaybackCompleted = true;
    try {
      if (!_host.isCurrentGeneration(generation)) {
        return;
      }

      if (_state.queueMode == PlayerQueueMode.singleRepeat) {
        await _host.seekSession(Duration.zero);
        if (!_host.isCurrentGeneration(generation)) {
          return;
        }
        await _host.playCurrentSource();
        return;
      }

      await _host.skipToNextTrack();
    } finally {
      _isHandlingPlaybackCompleted = false;
    }
  }

  Future<bool> _skipUnavailableQueueItem({
    required int failedIndex,
    required bool autoplay,
    required int generation,
    required bool persistAfterLoad,
    required BiliPlayerException error,
    required Set<String> skippedUnavailableStableIds,
    required bool hasShownUnavailableToast,
  }) async {
    if (!hasShownUnavailableToast) {
      _host.showToast(error.message);
    }

    return _skipFailedQueueItem(
      error: error,
      failedIndex: failedIndex,
      autoplay: autoplay,
      generation: generation,
      persistAfterLoad: persistAfterLoad,
      skippedUnavailableStableIds: skippedUnavailableStableIds,
    );
  }

  Future<bool> _skipFailedQueueItem({
    required Object error,
    required int failedIndex,
    required bool autoplay,
    required int generation,
    required bool persistAfterLoad,
    required Set<String> skippedUnavailableStableIds,
  }) async {
    _engineRetryCount = 0;
    final Set<String> nextSkippedUnavailableStableIds = <String>{
      ...skippedUnavailableStableIds,
      _state.queue[failedIndex].stableId,
    };
    final int? nextIndex = _resolveNextAvailableQueueIndex(
      failedIndex: failedIndex,
      skippedStableIds: nextSkippedUnavailableStableIds,
    );

    if (nextIndex == null) {
      return _failCurrentLoad(error, persistAfterLoad: persistAfterLoad);
    }

    return load(
      nextIndex,
      autoplay: autoplay,
      initialPosition: Duration.zero,
      generation: generation,
      persistAfterLoad: persistAfterLoad,
      skippedUnavailableStableIds: nextSkippedUnavailableStableIds,
      hasShownUnavailableToast: true,
    );
  }

  int? _resolveNextAvailableQueueIndex({
    required int failedIndex,
    required Set<String> skippedStableIds,
  }) {
    final List<PlayableItem> queue = _state.queue;
    if (queue.isEmpty) {
      return null;
    }

    return _queueManager.resolveNextAvailableIndex(
      queue: queue,
      failedIndex: failedIndex,
      mode: _state.queueMode,
      skippedStableIds: skippedStableIds,
    );
  }

  Future<bool> _failCurrentLoad(
    Object error, {
    required bool persistAfterLoad,
  }) async {
    _setState(
      _state.copyWith(
        isLoading: false,
        isReady: false,
        isPlaying: false,
        isBuffering: false,
        statusHint: PlayerStatusHint.error,
        availableParts: const <PlayableItem>[],
        audioStream: null,
        duration: null,
        errorMessage: error.toString(),
      ),
    );
    _host.publishPlaybackState();
    if (persistAfterLoad) {
      await _host.persistQueueSnapshot();
    }
    return false;
  }

  void _applyResolvedCurrentEntry({
    required int queueIndex,
    required ResolvedQueueEntry entry,
    Duration? durationOverride,
  }) {
    final String? previousStableId = _state.currentItem?.stableId;
    final List<PlayableItem> queue = _playbackLoader.replaceQueueEntry(
      queue: _state.queue,
      index: queueIndex,
      item: entry.item,
    );
    _setState(
      _state.copyWith(
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
      ),
    );
    if (previousStableId != entry.item.stableId) {
      _host.emitPlayerEvent(PlayerEventType.trackChanged);
    }
  }

  Future<void> _completeCachedEntryParts({
    required int generation,
    required int queueIndex,
    required ResolvedQueueEntry entry,
  }) async {
    final ResolvedQueueEntry? completed = await _playbackLoader
        .resolveCachedEntryParts(entry);
    if (completed == null ||
        !_host.isCurrentGeneration(generation) ||
        _state.currentQueueIndex != queueIndex ||
        queueIndex >= _state.queue.length ||
        _state.currentItem?.stableId != entry.item.stableId ||
        _state.queue[queueIndex].stableId != entry.item.stableId) {
      return;
    }

    _setState(
      _state.copyWith(
        queue: _playbackLoader.replaceQueueEntry(
          queue: _state.queue,
          index: queueIndex,
          item: completed.item,
        ),
        currentItem: completed.item,
        availableParts: completed.availableParts,
        audioStream: completed.audioStream,
      ),
    );
    await _host.enqueueAvailableParts(completed.availableParts);
    _host.publishPlaybackState();
    unawaited(_host.persistQueueSnapshot());
  }
}
