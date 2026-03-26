import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';

class PlayerState {
  const PlayerState({
    this.currentItem,
    this.audioStream,
    this.isLoading = false,
    this.isReady = false,
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.duration,
    this.errorMessage,
  });

  final PlayableItem? currentItem;
  final AudioStreamInfo? audioStream;
  final bool isLoading;
  final bool isReady;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration bufferedPosition;
  final Duration? duration;
  final String? errorMessage;

  bool get hasItem => currentItem != null;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  PlayerState copyWith({
    PlayableItem? currentItem,
    bool clearCurrentItem = false,
    AudioStreamInfo? audioStream,
    bool clearAudioStream = false,
    bool? isLoading,
    bool? isReady,
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? bufferedPosition,
    Duration? duration,
    bool clearDuration = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return PlayerState(
      currentItem: clearCurrentItem
          ? null
          : currentItem ?? this.currentItem,
      audioStream: clearAudioStream ? null : audioStream ?? this.audioStream,
      isLoading: isLoading ?? this.isLoading,
      isReady: isReady ?? this.isReady,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      duration: clearDuration ? null : duration ?? this.duration,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}
