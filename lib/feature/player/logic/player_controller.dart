import 'dart:async';

import 'package:bilimusic/core/bili/net/bili_api_client.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' as audio;

final Provider<BiliPlayerRepository> biliPlayerRepositoryProvider =
    Provider<BiliPlayerRepository>((Ref ref) {
      return BiliPlayerRepository(ref.read(biliApiClientProvider));
    });

final NotifierProvider<PlayerController, PlayerState> playerControllerProvider =
    NotifierProvider<PlayerController, PlayerState>(PlayerController.new);

class PlayerController extends Notifier<PlayerState> {
  late final BiliPlayerRepository _repository = ref.read(
    biliPlayerRepositoryProvider,
  );
  late final audio.AudioPlayer _audioPlayer = audio.AudioPlayer(
    useProxyForRequestHeaders: !_shouldDisableRequestHeadersProxy,
  );
  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];
  bool _isDisposed = false;
  bool _isBound = false;

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
    if (!item.hasIdentity) {
      state = state.copyWith(
        currentItem: item,
        isLoading: false,
        isReady: false,
        isPlaying: false,
        errorMessage: '当前搜索结果缺少可播放的视频标识。',
        audioStream: null,
        duration: null,
      );
      return;
    }

    final bool isSameItem = state.currentItem == item;
    if (isSameItem && state.isReady) {
      if (autoplay && !state.isPlaying) {
        await play();
      }
      return;
    }

    state = state.copyWith(
      currentItem: item,
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
      final audioStream = await _repository.resolveAudioStream(
        item,
        session: session,
      );

      final Map<String, String>? headers =
          _shouldDisableRequestHeadersProxy || audioStream.headers.isEmpty
              ? null
              : audioStream.headers;

      final audio.AudioSource source = audio.AudioSource.uri(
        Uri.parse(audioStream.streamUrl),
        headers: headers,
      );

      final Duration? duration = await _audioPlayer.setAudioSource(source);

      state = state.copyWith(
        audioStream: audioStream,
        isLoading: false,
        isReady: true,
        duration: duration ?? audioStream.duration,
        errorMessage: null,
      );

      if (autoplay) {
        await play();
      }
    } on Object catch (error) {
      state = state.copyWith(
        isLoading: false,
        isReady: false,
        isPlaying: false,
        isBuffering: false,
        errorMessage: error.toString(),
        audioStream: null,
        duration: null,
      );
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
      }),
    );
  }
}
