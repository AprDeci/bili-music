import 'dart:async';
import 'dart:math';

import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/data/player_queue_local_repository.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/persisted_playback_queue.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_media_item_mapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' as audio;

final NotifierProvider<PlayerController, PlayerState> playerControllerProvider =
    NotifierProvider<PlayerController, PlayerState>(PlayerController.new);

class PlayerController extends Notifier<PlayerState> {
  PlayerController() : _random = Random();

  late final BiliPlayerRepository _repository = ref.read(
    biliPlayerRepositoryProvider,
  );
  late final PlayerQueueLocalRepository _queueRepository = ref.read(
    playerQueueLocalRepositoryProvider,
  );
  late final audio.AudioPlayer _audioPlayer = audio.AudioPlayer(
    useProxyForRequestHeaders: !_shouldDisableRequestHeadersProxy,
  );
  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];
  final Map<String, _ResolvedQueueEntry> _resolvedEntries =
      <String, _ResolvedQueueEntry>{};
  bool _isDisposed = false;
  bool _isBound = false;
  bool _isAdvancingQueue = false;
  bool _isRestoringFromPersistence = false;
  bool _isRebuildingWindow = false;
  bool _isSettingPlaylist = false;
  final Random _random;
  _SlidingQueueWindow? _activeWindow;
  _PendingQueueRebuildRequest? _pendingRebuildRequest;

  static bool get _shouldDisableRequestHeadersProxy {
    if (kIsWeb) {
      return true;
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.windows => true,
      TargetPlatform.linux => true,
      _ => false,
    };
  }

  @override
  PlayerState build() {
    if (!_isBound) {
      _bindPlayerStreams();
      _isBound = true;
    }
    ref.onDispose(() {
      unawaited(_disposePlayer());
    });
    return const PlayerState();
  }

  Future<void> _disposePlayer() async {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;

    for (final StreamSubscription<dynamic> subscription in _subscriptions) {
      await subscription.cancel();
    }

    try {
      await _audioPlayer.dispose();
    } on Object {
      // Avoid surfacing platform-dispose failures as uncaught errors.
    }
  }

  Future<void> loadFromItem(PlayableItem item, {bool autoplay = true}) async {
    await setQueue(
      <PlayableItem>[item],
      startIndex: 0,
      sourceLabel: state.queueSourceLabel,
      autoplay: autoplay,
    );
  }

  Future<void> play() async {
    if (!state.isReady) {
      return;
    }
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    await _persistQueueSnapshot();
  }

  Future<void> togglePlayback() async {
    if (state.isPlaying) {
      await pause();
      return;
    }
    await play();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> seekBy(Duration offset) async {
    final Duration effectiveDuration = state.duration ?? Duration.zero;
    final Duration nextPosition = _audioPlayer.position + offset;
    final Duration clamped = nextPosition < Duration.zero
        ? Duration.zero
        : effectiveDuration > Duration.zero && nextPosition > effectiveDuration
        ? effectiveDuration
        : nextPosition;
    await _audioPlayer.seek(clamped);
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    state = state.copyWith(
      isPlaying: false,
      isBuffering: false,
      position: Duration.zero,
      bufferedPosition: Duration.zero,
    );
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

    final int resolvedIndex = startIndex.clamp(0, items.length - 1);
    final List<PlayableItem> queue = List<PlayableItem>.unmodifiable(items);
    state = state.copyWith(
      queue: queue,
      currentQueueIndex: resolvedIndex,
      queueSourceLabel: sourceLabel,
      errorMessage: null,
    );
    await _rebuildWindowAtQueueIndex(
      resolvedIndex,
      autoplay: autoplay,
      initialPosition: Duration.zero,
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
    final List<PlayableItem> nextQueue = List<PlayableItem>.of(state.queue);
    nextQueue[currentIndex] = item;
    _resolvedEntries.remove(state.queue[currentIndex].stableId);
    state = state.copyWith(queue: List<PlayableItem>.unmodifiable(nextQueue));
    await _rebuildWindowAtQueueIndex(
      currentIndex,
      autoplay: autoplay,
      initialPosition: Duration.zero,
    );
  }

  Future<void> enqueue(List<PlayableItem> items) async {
    if (items.isEmpty) {
      return;
    }
    state = state.copyWith(
      queue: List<PlayableItem>.unmodifiable(<PlayableItem>[
        ...state.queue,
        ...items,
      ]),
    );
    await _refreshWindowAfterQueueMutation();
  }

  Future<void> playNext(PlayableItem item) async {
    if (!state.hasActiveQueueIndex) {
      await setQueue(<PlayableItem>[item]);
      return;
    }

    final int insertIndex = state.currentQueueIndex! + 1;
    final List<PlayableItem> nextQueue = List<PlayableItem>.of(state.queue);
    nextQueue.insert(insertIndex, item);
    state = state.copyWith(queue: List<PlayableItem>.unmodifiable(nextQueue));
    await _refreshWindowAfterQueueMutation();
  }

  Future<void> removeQueueItemAt(int index) async {
    if (index < 0 || index >= state.queue.length) {
      return;
    }

    final PlayableItem removedItem = state.queue[index];
    final List<PlayableItem> nextQueue = List<PlayableItem>.of(state.queue)
      ..removeAt(index);
    final int? currentIndex = state.currentQueueIndex;
    _resolvedEntries.remove(removedItem.stableId);

    if (nextQueue.isEmpty) {
      await stop();
      _activeWindow = null;
      state = state.copyWith(
        queue: const <PlayableItem>[],
        currentQueueIndex: null,
        currentItem: null,
        availableParts: const <PlayableItem>[],
        audioStream: null,
        isReady: false,
        duration: null,
      );
      await _queueRepository.clear();
      return;
    }

    int? nextCurrentIndex = currentIndex;
    if (currentIndex != null) {
      if (index < currentIndex) {
        nextCurrentIndex = currentIndex - 1;
      } else if (index == currentIndex) {
        nextCurrentIndex = currentIndex >= nextQueue.length
            ? nextQueue.length - 1
            : currentIndex;
      }
    }

    state = state.copyWith(
      queue: List<PlayableItem>.unmodifiable(nextQueue),
      currentQueueIndex: nextCurrentIndex,
    );

    if (nextCurrentIndex == null) {
      await _persistQueueSnapshot();
      return;
    }

    await _rebuildWindowAtQueueIndex(
      nextCurrentIndex,
      autoplay: state.isPlaying,
      initialPosition: index == currentIndex
          ? Duration.zero
          : _audioPlayer.position,
    );
  }

  Future<void> clearQueue() async {
    await stop();
    _activeWindow = null;
    state = state.copyWith(
      queue: const <PlayableItem>[],
      currentQueueIndex: null,
      currentItem: null,
      availableParts: const <PlayableItem>[],
      audioStream: null,
      queueSourceLabel: null,
      isReady: false,
      duration: null,
      errorMessage: null,
    );
    await _queueRepository.clear();
  }

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

  Future<void> skipToNext() async {
    if (_isAdvancingQueue) {
      return;
    }

    _isAdvancingQueue = true;
    try {
      final int? targetIndex = _resolveNextQueueIndex();
      if (targetIndex == null) {
        state = state.copyWith(isPlaying: false, isBuffering: false);
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
    await _rebuildWindowAtQueueIndex(
      index,
      autoplay: autoplay,
      initialPosition: Duration.zero,
    );
  }

  void toggleQueueMode() {
    final PlayerQueueMode nextMode = switch (state.queueMode) {
      PlayerQueueMode.sequence => PlayerQueueMode.singleRepeat,
      PlayerQueueMode.singleRepeat => PlayerQueueMode.shuffle,
      PlayerQueueMode.shuffle => PlayerQueueMode.sequence,
    };
    state = state.copyWith(queueMode: nextMode);
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

    _isRestoringFromPersistence = true;
    state = state.copyWith(
      queue: List<PlayableItem>.unmodifiable(restoredQueue),
      currentQueueIndex: restoredIndex,
      currentItem: restoredQueue[restoredIndex],
      queueMode: snapshot.queueMode,
      queueSourceLabel: snapshot.queueSourceLabel,
      errorMessage: null,
    );

    try {
      await _rebuildWindowAtQueueIndex(
        restoredIndex,
        autoplay: false,
        initialPosition: Duration.zero,
      );
      if (!state.isReady) {
        state = state.copyWith(
          isPlaying: false,
          isBuffering: false,
          errorMessage: state.errorMessage ?? '恢复播放队列失败，请重试。',
        );
        return;
      }
      await _restorePosition(snapshot.resumePositionMs);
      await pause();
      state = state.copyWith(isPlaying: false, isBuffering: false);
    } on Object catch (_) {
      state = state.copyWith(
        isLoading: false,
        isReady: false,
        isPlaying: false,
        isBuffering: false,
        audioStream: null,
        availableParts: const <PlayableItem>[],
        duration: null,
        errorMessage: '恢复播放队列失败，请重试。',
      );
    } finally {
      _isRestoringFromPersistence = false;
    }

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

  Future<void> _refreshWindowAfterQueueMutation() async {
    if (!state.hasActiveQueueIndex) {
      await _persistQueueSnapshot();
      return;
    }

    await _rebuildWindowAtQueueIndex(
      state.currentQueueIndex!,
      autoplay: state.isPlaying,
      initialPosition: _audioPlayer.position,
    );
  }

  Future<void> _rebuildWindowAtQueueIndex(
    int queueIndex, {
    required bool autoplay,
    required Duration initialPosition,
  }) async {
    if (queueIndex < 0 || queueIndex >= state.queue.length) {
      return;
    }

    if (_isRebuildingWindow) {
      _pendingRebuildRequest = _PendingQueueRebuildRequest(
        queueIndex: queueIndex,
        autoplay: autoplay,
        initialPosition: initialPosition,
      );
      return;
    }

    final List<PlayableItem> queue = state.queue;
    final PlayableItem requestedItem = queue[queueIndex];
    state = state.copyWith(
      currentQueueIndex: queueIndex,
      currentItem: requestedItem,
      isLoading: true,
      isReady: false,
      isPlaying: false,
      isBuffering: false,
      position: Duration.zero,
      bufferedPosition: Duration.zero,
      audioStream: null,
      duration: null,
      errorMessage: null,
    );

    _isRebuildingWindow = true;
    try {
      final _SlidingQueueWindow desiredWindow = _buildSlidingWindow(queueIndex);
      final List<_ResolvedQueueSource> resolvedSources =
          <_ResolvedQueueSource>[];

      for (int i = 0; i < desiredWindow.queueIndexes.length; i++) {
        final int targetIndex = desiredWindow.queueIndexes[i];
        final bool isCurrent = targetIndex == queueIndex;
        try {
          final _ResolvedQueueEntry entry = await _resolveQueueEntry(
            state.queue[targetIndex],
          );
          resolvedSources.add(
            _ResolvedQueueSource(
              queueIndex: targetIndex,
              entry: entry,
              source: _buildAudioSource(entry),
            ),
          );
        } on Object catch (error) {
          if (isCurrent) {
            rethrow;
          }
          state = state.copyWith(errorMessage: error.toString());
        }
      }

      final int currentWindowIndex = resolvedSources.indexWhere(
        (_ResolvedQueueSource source) => source.queueIndex == queueIndex,
      );
      if (currentWindowIndex < 0) {
        throw const BiliPlayerException('当前播放项解析失败，请重试。');
      }

      final _SlidingQueueWindow activeWindow = _SlidingQueueWindow(
        queueIndexes: resolvedSources
            .map((_ResolvedQueueSource source) => source.queueIndex)
            .toList(growable: false),
        currentWindowIndex: currentWindowIndex,
      );

      _isSettingPlaylist = true;
      try {
        final Duration? loadedDuration = await _audioPlayer.setAudioSources(
          resolvedSources
              .map((_ResolvedQueueSource source) => source.source)
              .toList(growable: false),
          initialIndex: currentWindowIndex,
          initialPosition: initialPosition,
        );
        _activeWindow = activeWindow;

        final _ResolvedQueueEntry currentEntry =
            resolvedSources[currentWindowIndex].entry;
        _applyResolvedCurrentEntry(
          queueIndex: queueIndex,
          entry: currentEntry,
          durationOverride: loadedDuration,
        );

        if (autoplay) {
          await _audioPlayer.play();
        } else {
          await _audioPlayer.pause();
        }
      } finally {
        _isSettingPlaylist = false;
      }

      if (!_isRestoringFromPersistence) {
        await _persistQueueSnapshot();
      }
    } on Object catch (error) {
      state = state.copyWith(
        isLoading: false,
        isReady: false,
        isPlaying: false,
        isBuffering: false,
        availableParts: const <PlayableItem>[],
        errorMessage: error.toString(),
        audioStream: null,
        duration: null,
      );
      if (!_isRestoringFromPersistence) {
        await _persistQueueSnapshot();
      }
    } finally {
      _isRebuildingWindow = false;
      final _PendingQueueRebuildRequest? pendingRequest =
          _takePendingRebuildRequest();
      if (pendingRequest != null) {
        unawaited(
          _rebuildWindowAtQueueIndex(
            pendingRequest.queueIndex,
            autoplay: pendingRequest.autoplay,
            initialPosition: pendingRequest.initialPosition,
          ),
        );
      }
    }
  }

  _PendingQueueRebuildRequest? _takePendingRebuildRequest() {
    final _PendingQueueRebuildRequest? pendingRequest = _pendingRebuildRequest;
    _pendingRebuildRequest = null;
    return pendingRequest;
  }

  _SlidingQueueWindow _buildSlidingWindow(int queueIndex) {
    final int length = state.queue.length;
    if (length <= 1) {
      return _SlidingQueueWindow(
        queueIndexes: <int>[queueIndex],
        currentWindowIndex: 0,
      );
    }
    if (length == 2) {
      return _SlidingQueueWindow(
        queueIndexes: const <int>[0, 1],
        currentWindowIndex: queueIndex,
      );
    }

    final int previousIndex = _wrapQueueIndex(queueIndex - 1, length);
    final int nextIndex = _wrapQueueIndex(queueIndex + 1, length);
    return _SlidingQueueWindow(
      queueIndexes: <int>[previousIndex, queueIndex, nextIndex],
      currentWindowIndex: 1,
    );
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
      availableParts: List<PlayableItem>.unmodifiable(
        loadResult.availableParts,
      ),
      audioStream: loadResult.audioStream,
    );
    _resolvedEntries[item.stableId] = entry;
    _resolvedEntries[loadResult.item.stableId] = entry;
    return entry;
  }

  audio.AudioSource _buildAudioSource(_ResolvedQueueEntry entry) {
    final Map<String, String>? headers =
        _shouldDisableRequestHeadersProxy || entry.audioStream.headers.isEmpty
        ? null
        : entry.audioStream.headers;
    return audio.AudioSource.uri(
      Uri.parse(entry.audioStream.streamUrl),
      headers: headers,
      tag: buildPlayerMediaItem(
        entry.item,
        audioStream: entry.audioStream,
        queueSourceLabel: state.queueSourceLabel,
        duration: entry.audioStream.duration,
      ),
    );
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

  int _wrapQueueIndex(int value, int length) {
    if (length <= 0) {
      return 0;
    }
    return ((value % length) + length) % length;
  }

  void _bindPlayerStreams() {
    _subscriptions.add(
      _audioPlayer.currentIndexStream.listen((int? index) {
        if (index == null || _activeWindow == null) {
          return;
        }
        final _SlidingQueueWindow activeWindow = _activeWindow!;
        if (index < 0 || index >= activeWindow.queueIndexes.length) {
          return;
        }

        final int queueIndex = activeWindow.queueIndexes[index];
        final PlayableItem queueItem = state.queue[queueIndex];
        final _ResolvedQueueEntry? entry = _resolvedEntries[queueItem.stableId];
        if (entry != null) {
          _applyResolvedCurrentEntry(queueIndex: queueIndex, entry: entry);
        } else {
          state = state.copyWith(
            currentQueueIndex: queueIndex,
            currentItem: queueItem,
            errorMessage: null,
          );
        }

        if (_isSettingPlaylist || _isRebuildingWindow) {
          return;
        }
        if (state.queue.length <= 2 ||
            activeWindow.currentWindowIndex == index) {
          return;
        }

        unawaited(
          _rebuildWindowAtQueueIndex(
            queueIndex,
            autoplay: _audioPlayer.playing,
            initialPosition: _audioPlayer.position,
          ),
        );
      }),
    );
    _subscriptions.add(
      _audioPlayer.positionStream.listen((Duration position) {
        state = state.copyWith(position: position);
      }),
    );
    _subscriptions.add(
      _audioPlayer.bufferedPositionStream.listen((Duration bufferedPosition) {
        state = state.copyWith(bufferedPosition: bufferedPosition);
      }),
    );
    _subscriptions.add(
      _audioPlayer.durationStream.listen((Duration? duration) {
        if (duration != null) {
          state = state.copyWith(duration: duration);
        }
      }),
    );
    _subscriptions.add(
      _audioPlayer.errorStream.listen((audio.PlayerException error) {
        state = state.copyWith(
          isLoading: false,
          isPlaying: false,
          isBuffering: false,
          errorMessage: '播放器错误: ${error.message}',
        );
      }),
    );
    _subscriptions.add(
      _audioPlayer.playerStateStream.listen((audio.PlayerState playerState) {
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

  Future<void> _restorePosition(int resumePositionMs) async {
    if (resumePositionMs <= 0) {
      return;
    }

    final Duration? duration = state.duration;
    if (duration == null || duration <= Duration.zero) {
      await seek(Duration(milliseconds: resumePositionMs));
      return;
    }

    final int targetMs = resumePositionMs.clamp(0, duration.inMilliseconds);
    if (targetMs <= 0) {
      return;
    }

    await seek(Duration(milliseconds: targetMs));
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

class _ResolvedQueueSource {
  const _ResolvedQueueSource({
    required this.queueIndex,
    required this.entry,
    required this.source,
  });

  final int queueIndex;
  final _ResolvedQueueEntry entry;
  final audio.AudioSource source;
}

class _SlidingQueueWindow {
  const _SlidingQueueWindow({
    required this.queueIndexes,
    required this.currentWindowIndex,
  });

  final List<int> queueIndexes;
  final int currentWindowIndex;
}

class _PendingQueueRebuildRequest {
  const _PendingQueueRebuildRequest({
    required this.queueIndex,
    required this.autoplay,
    required this.initialPosition,
  });

  final int queueIndex;
  final bool autoplay;
  final Duration initialPosition;
}
