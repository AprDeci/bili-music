import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart' hide PlayerState;
import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/player/data/audio_cache_repository.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/data/player_queue_local_repository.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/persisted_playback_queue.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/app_audio_handler.dart';
import 'package:bilimusic/feature/player/logic/player_audio_engine.dart';
import 'package:bilimusic/feature/player/logic/player_media_item_mapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' as audio;

final NotifierProvider<PlayerController, PlayerState> playerControllerProvider =
    NotifierProvider<PlayerController, PlayerState>(PlayerController.new);

class PlayerController extends Notifier<PlayerState>
    implements PlayerCommandTarget {
  PlayerController() : _random = Random();

  final AppLogger _logger = AppLogger('PlayerController');
  final Random _random;

  late final BiliPlayerRepository _repository = ref.read(
    biliPlayerRepositoryProvider,
  );
  late final PlayerAudioCacheRepository _audioCacheRepository = ref.read(
    playerAudioCacheRepositoryProvider,
  );
  late final PlayerQueueLocalRepository _queueRepository = ref.read(
    playerQueueLocalRepositoryProvider,
  );
  late final AppAudioHandler _audioHandler = ref.read(appAudioHandlerProvider);
  late final PlayerAudioEngine _audioEngine = PlayerAudioEngine();

  final Map<String, _ResolvedQueueEntry> _resolvedEntries =
      <String, _ResolvedQueueEntry>{};
  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];
  final List<int> _shuffleHistory = <int>[];

  bool _isBound = false;
  bool _isDisposed = false;
  bool _isAdvancingQueue = false;
  int _operationGeneration = 0;

  @override
  PlayerState build() {
    if (!_isBound) {
      _bindPlayerStreams();
      _audioHandler.attachTarget(this);
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
      await _loadQueueIndex(
        0,
        autoplay: true,
        initialPosition: state.position,
      );
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
    _shuffleHistory
      ..clear()
      ..add(resolvedIndex);
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
    nextQueue[currentIndex] = item;
    _resolvedEntries.remove(previousItem.stableId);
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
    final List<PlayableItem> nextQueue = List<PlayableItem>.of(state.queue)
      ..removeAt(index);
    _resolvedEntries.remove(removedItem.stableId);

    if (nextQueue.isEmpty) {
      await clearQueue();
      return;
    }

    int? nextCurrentIndex = state.currentQueueIndex;
    if (nextCurrentIndex != null) {
      if (index < nextCurrentIndex) {
        nextCurrentIndex -= 1;
      } else if (index == nextCurrentIndex) {
        nextCurrentIndex = nextCurrentIndex >= nextQueue.length
            ? nextQueue.length - 1
            : nextCurrentIndex;
      }
    }

    final int generation = _nextGeneration();
    final int? previousCurrentIndex = state.currentQueueIndex;
    state = state.copyWith(
      queue: List<PlayableItem>.unmodifiable(nextQueue),
      currentQueueIndex: nextCurrentIndex,
      currentItem: nextCurrentIndex == null ? null : nextQueue[nextCurrentIndex],
      availableParts:
          index == previousCurrentIndex
          ? const <PlayableItem>[]
          : state.availableParts,
      audioStream: index == previousCurrentIndex ? null : state.audioStream,
      duration: index == previousCurrentIndex ? null : state.duration,
      position: index == previousCurrentIndex
          ? Duration.zero
          : state.position,
      bufferedPosition: index == previousCurrentIndex
          ? Duration.zero
          : state.bufferedPosition,
      isReady: index == previousCurrentIndex ? false : state.isReady,
      isPlaying: index == previousCurrentIndex ? false : state.isPlaying,
      isBuffering: false,
      errorMessage: null,
    );
    _publishMediaSession();

    if (nextCurrentIndex == null) {
      await _persistQueueSnapshot();
      return;
    }

    if (index == previousCurrentIndex) {
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
    _shuffleHistory.clear();
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

    final int? targetIndex = _resolvePreviousQueueIndex();
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
      final int? targetIndex = _resolveNextQueueIndex();
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
    if (nextMode != PlayerQueueMode.shuffle) {
      _shuffleHistory
        ..clear()
        ..addAll(state.hasActiveQueueIndex
            ? <int>[state.currentQueueIndex!]
            : const <int>[]);
    }
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
    _shuffleHistory
      ..clear()
      ..addAll(snapshot.queueMode == PlayerQueueMode.shuffle
          ? <int>[restoredIndex]
          : const <int>[]);
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

  int? _resolveNextQueueIndex() {
    if (!state.hasActiveQueueIndex || state.queue.isEmpty) {
      return null;
    }

    return switch (state.queueMode) {
      PlayerQueueMode.singleRepeat => state.currentQueueIndex,
      PlayerQueueMode.sequence => _wrapQueueIndex(
        state.currentQueueIndex! + 1,
        state.queue.length,
      ),
      PlayerQueueMode.shuffle => _pickRandomNextQueueIndex(),
    };
  }

  int? _resolvePreviousQueueIndex() {
    if (!state.hasActiveQueueIndex || state.queue.isEmpty) {
      return null;
    }

    if (state.queueMode == PlayerQueueMode.singleRepeat) {
      return state.currentQueueIndex;
    }

    if (state.queueMode == PlayerQueueMode.shuffle) {
      if (_shuffleHistory.length >= 2) {
        _shuffleHistory.removeLast();
        return _shuffleHistory.last;
      }
      return state.currentQueueIndex;
    }

    if (state.queue.length == 1) {
      return state.currentQueueIndex;
    }
    return _wrapQueueIndex(state.currentQueueIndex! - 1, state.queue.length);
  }

  int? _pickRandomNextQueueIndex() {
    final int length = state.queue.length;
    if (length == 0) {
      return null;
    }
    if (length == 1) {
      return state.currentQueueIndex;
    }

    final int currentIndex = state.currentQueueIndex ?? 0;
    int nextIndex = currentIndex;
    while (nextIndex == currentIndex) {
      nextIndex = _random.nextInt(length);
    }
    return nextIndex;
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
      availableParts: const <PlayableItem>[],
      audioStream: null,
      duration: null,
      position: Duration.zero,
      bufferedPosition: Duration.zero,
      errorMessage: null,
    );
    _publishMediaSession();

    try {
      final _ResolvedQueueEntry entry = await _resolveQueueEntry(targetItem);
      if (!_isCurrentGeneration(effectiveGeneration)) {
        return false;
      }

      final Duration? loadedDuration = await _setSourceForEntry(
        entry: entry,
        initialPosition: initialPosition,
      );
      if (!_isCurrentGeneration(effectiveGeneration)) {
        return false;
      }

      _applyResolvedCurrentEntry(
        queueIndex: queueIndex,
        entry: entry,
        durationOverride: loadedDuration,
      );
      _recordQueueVisit(queueIndex);
      _publishMediaSession();

      if (autoplay) {
        await _audioEngine.play();
      } else {
        await _audioEngine.pause();
      }
      if (!_isCurrentGeneration(effectiveGeneration)) {
        return false;
      }

      unawaited(_cacheEntryInBackground(entry));

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

  Future<_ResolvedQueueEntry> _resolveQueueEntry(PlayableItem item) async {
    final _ResolvedQueueEntry? cached = _resolvedEntries[item.stableId];
    if (cached != null) {
      return cached;
    }

    if (!item.hasIdentity) {
      throw const BiliPlayerException('当前搜索结果缺少可播放的视频标识。');
    }

    final BiliSession? session = ref.read(biliSessionControllerProvider);
    final PlayerLoadResult loadResult = await _repository.resolveAudioStream(
      item,
      session: session,
    );
    final _ResolvedQueueEntry entry = _ResolvedQueueEntry(
      item: loadResult.item,
      availableParts: List<PlayableItem>.unmodifiable(loadResult.availableParts),
      audioStream: loadResult.audioStream,
    );
    _resolvedEntries[item.stableId] = entry;
    _resolvedEntries[loadResult.item.stableId] = entry;
    return entry;
  }

  Future<Duration?> _setSourceForEntry({
    required _ResolvedQueueEntry entry,
    required Duration initialPosition,
  }) async {
    final MediaItem mediaItem = buildPlayerMediaItem(
      entry.item,
      audioStream: entry.audioStream,
      queueSourceLabel: state.queueSourceLabel,
      duration: entry.audioStream.duration,
    );
    final Duration? effectiveInitialPosition = initialPosition > Duration.zero
        ? initialPosition
        : null;
    final File? cachedFile = await _audioCacheRepository.getCachedFile(
      item: entry.item,
      audioStream: entry.audioStream,
    );

    if (cachedFile != null) {
      try {
        _logPlayerEvent(
          'loadQueueIndex:cache-hit',
          details: <String, Object?>{
            'stableId': entry.item.stableId,
            'path': cachedFile.path,
          },
        );
        return await _audioEngine.setFileSource(
          filePath: cachedFile.path,
          tag: mediaItem,
          initialPosition: effectiveInitialPosition,
        );
      } on Object catch (error) {
        _logPlayerEvent(
          'loadQueueIndex:cache-fallback',
          details: <String, Object?>{
            'stableId': entry.item.stableId,
            'error': error,
          },
        );
        await _audioCacheRepository.removeCachedFile(
          item: entry.item,
          audioStream: entry.audioStream,
        );
      }
    }

    _logPlayerEvent(
      'loadQueueIndex:remote-source',
      details: <String, Object?>{'stableId': entry.item.stableId},
    );
    return _audioEngine.setRemoteSource(
      uri: Uri.parse(entry.audioStream.streamUrl),
      headers: entry.audioStream.headers.isEmpty
          ? null
          : entry.audioStream.headers,
      tag: mediaItem,
      initialPosition: effectiveInitialPosition,
    );
  }

  Future<void> _cacheEntryInBackground(_ResolvedQueueEntry entry) async {
    try {
      await _audioCacheRepository.cacheAudio(
        item: entry.item,
        audioStream: entry.audioStream,
      );
      _logPlayerEvent(
        'audio-cache:completed',
        details: <String, Object?>{'stableId': entry.item.stableId},
      );
    } on Object catch (error) {
      _logPlayerEvent(
        'audio-cache:failed',
        details: <String, Object?>{
          'stableId': entry.item.stableId,
          'error': error,
        },
      );
    }
  }

  void _applyResolvedCurrentEntry({
    required int queueIndex,
    required _ResolvedQueueEntry entry,
    Duration? durationOverride,
  }) {
    final List<PlayableItem> queue = _replaceQueueEntry(queueIndex, entry.item);
    state = state.copyWith(
      queue: queue,
      currentQueueIndex: queueIndex,
      currentItem: entry.item,
      availableParts: entry.availableParts,
      audioStream: entry.audioStream,
      isLoading: false,
      isReady: true,
      duration: durationOverride ?? entry.audioStream.duration,
      errorMessage: null,
    );
  }

  List<PlayableItem> _replaceQueueEntry(int index, PlayableItem item) {
    if (index < 0 || index >= state.queue.length) {
      return state.queue;
    }
    final List<PlayableItem> nextQueue = List<PlayableItem>.of(state.queue);
    nextQueue[index] = item;
    return List<PlayableItem>.unmodifiable(nextQueue);
  }

  void _recordQueueVisit(int index) {
    if (state.queueMode != PlayerQueueMode.shuffle) {
      return;
    }
    if (_shuffleHistory.isEmpty || _shuffleHistory.last != index) {
      _shuffleHistory.add(index);
    }
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

  int _wrapQueueIndex(int value, int length) {
    if (length <= 0) {
      return 0;
    }
    return ((value % length) + length) % length;
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
    final AudioStreamInfo? audioStream = state.audioStream;
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
      hasPrevious: state.hasPrevious || state.position > const Duration(seconds: 3),
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

class _ResolvedQueueEntry {
  const _ResolvedQueueEntry({
    required this.item,
    required this.availableParts,
    required this.audioStream,
  });

  final PlayableItem item;
  final List<PlayableItem> availableParts;
  final AudioStreamInfo audioStream;
}
