import 'dart:async';
import 'dart:math';

import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/data/player_queue_local_repository.dart';
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
  bool _isDisposed = false;
  bool _isBound = false;
  bool _isAdvancingQueue = false;
  bool _isRestoringFromPersistence = false;
  final Random _random;

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
    if (!_isRestoringFromPersistence) {
      await _persistQueueSnapshot();
    }

    if (!item.hasIdentity) {
      state = state.copyWith(
        currentItem: item,
        availableParts: const <PlayableItem>[],
        isLoading: false,
        isReady: false,
        isPlaying: false,
        errorMessage: '当前搜索结果缺少可播放的视频标识。',
        audioStream: null,
        duration: null,
      );
      if (!_isRestoringFromPersistence) {
        await _persistQueueSnapshot();
      }
      return;
    }

    final bool isSameItem = state.currentItem == item;
    if (isSameItem && state.isReady) {
      if (autoplay && !state.isPlaying) {
        await play();
      } else if (!_isRestoringFromPersistence) {
        await _persistQueueSnapshot();
      }
      return;
    }

    state = state.copyWith(
      currentItem: item,
      availableParts: state.availableParts,
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

    try {
      await _audioPlayer.stop();
      final BiliSession? session = ref.read(biliSessionControllerProvider);
      final PlayerLoadResult loadResult = await _repository.resolveAudioStream(
        item,
        session: session,
      );
      final PlayableItem resolvedItem = loadResult.item;
      final List<PlayableItem> availableParts = loadResult.availableParts;
      final audioStream = loadResult.audioStream;

      final Map<String, String>? headers =
          _shouldDisableRequestHeadersProxy || audioStream.headers.isEmpty
          ? null
          : audioStream.headers;

      final audio.AudioSource source = audio.AudioSource.uri(
        Uri.parse(audioStream.streamUrl),
        headers: headers,
        tag: buildPlayerMediaItem(
          resolvedItem,
          audioStream: audioStream,
          queueSourceLabel: state.queueSourceLabel,
          duration: audioStream.duration,
        ),
      );

      final Duration? duration = await _audioPlayer.setAudioSource(source);

      state = state.copyWith(
        currentItem: resolvedItem,
        availableParts: availableParts,
        queue: _replaceCurrentQueueEntryIfNeeded(resolvedItem),
        audioStream: audioStream,
        isLoading: false,
        isReady: true,
        duration: duration ?? audioStream.duration,
        errorMessage: null,
      );

      if (autoplay) {
        await play();
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
    }
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
    await loadFromItem(queue[resolvedIndex], autoplay: autoplay);
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
    state = state.copyWith(queue: List<PlayableItem>.unmodifiable(nextQueue));
    await loadFromItem(item, autoplay: autoplay);
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
    await _persistQueueSnapshot();
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
    await _persistQueueSnapshot();
  }

  Future<void> removeQueueItemAt(int index) async {
    if (index < 0 || index >= state.queue.length) {
      return;
    }

    final List<PlayableItem> nextQueue = List<PlayableItem>.of(state.queue)
      ..removeAt(index);
    final int? currentIndex = state.currentQueueIndex;

    if (nextQueue.isEmpty) {
      await stop();
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

    if (currentIndex == null) {
      state = state.copyWith(queue: List<PlayableItem>.unmodifiable(nextQueue));
      await _persistQueueSnapshot();
      return;
    }

    if (index < currentIndex) {
      state = state.copyWith(
        queue: List<PlayableItem>.unmodifiable(nextQueue),
        currentQueueIndex: currentIndex - 1,
      );
      await _persistQueueSnapshot();
      return;
    }

    if (index > currentIndex) {
      state = state.copyWith(queue: List<PlayableItem>.unmodifiable(nextQueue));
      await _persistQueueSnapshot();
      return;
    }

    final int targetIndex = currentIndex >= nextQueue.length
        ? nextQueue.length - 1
        : currentIndex;
    state = state.copyWith(
      queue: List<PlayableItem>.unmodifiable(nextQueue),
      currentQueueIndex: targetIndex,
    );
    await loadFromItem(nextQueue[targetIndex]);
  }

  Future<void> clearQueue() async {
    await stop();
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

    if (state.hasPrevious) {
      await skipToQueueIndex(state.currentQueueIndex! - 1);
      return;
    }

    await seek(Duration.zero);
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
    state = state.copyWith(currentQueueIndex: index, errorMessage: null);
    await loadFromItem(state.queue[index], autoplay: autoplay);
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
      await loadFromItem(restoredQueue[restoredIndex], autoplay: false);
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

  List<PlayableItem> _replaceCurrentQueueEntryIfNeeded(PlayableItem item) {
    if (!state.hasActiveQueueIndex) {
      return state.queue;
    }

    final int currentIndex = state.currentQueueIndex!;
    final List<PlayableItem> nextQueue = List<PlayableItem>.of(state.queue);
    nextQueue[currentIndex] = item;
    return List<PlayableItem>.unmodifiable(nextQueue);
  }

  int? _resolveNextQueueIndex() {
    if (!state.hasActiveQueueIndex || state.queue.isEmpty) {
      return null;
    }

    return switch (state.queueMode) {
      PlayerQueueMode.singleRepeat => state.currentQueueIndex,
      PlayerQueueMode.sequence =>
        state.hasNext ? state.currentQueueIndex! + 1 : null,
      PlayerQueueMode.shuffle => _pickRandomNextQueueIndex(),
    };
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

  void _bindPlayerStreams() {
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
