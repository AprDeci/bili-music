import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_state.freezed.dart';

enum PlayerQueueMode { sequence, singleRepeat, shuffle }

@freezed
abstract class PlayerState with _$PlayerState {
  const factory PlayerState({
    PlayableItem? currentItem,
    AudioStreamInfo? audioStream,
    @Default(<PlayableItem>[]) List<PlayableItem> availableParts,
    @Default(<PlayableItem>[]) List<PlayableItem> queue,
    int? currentQueueIndex,
    String? queueSourceLabel,
    @Default(PlayerQueueMode.sequence) PlayerQueueMode queueMode,
    @Default(false) bool isLoading,
    @Default(false) bool isReady,
    @Default(false) bool isPlaying,
    @Default(false) bool isBuffering,
    @Default(Duration.zero) Duration position,
    @Default(Duration.zero) Duration bufferedPosition,
    Duration? duration,
    String? errorMessage,
  }) = _PlayerState;

  const PlayerState._();

  bool get hasItem => currentItem != null;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  bool get hasQueue => queue.isNotEmpty;
  bool get hasActiveQueueIndex =>
      currentQueueIndex != null &&
      currentQueueIndex! >= 0 &&
      currentQueueIndex! < queue.length;
  PlayableItem? get currentQueueItem =>
      hasActiveQueueIndex ? queue[currentQueueIndex!] : null;
  bool get hasPrevious => hasActiveQueueIndex && currentQueueIndex! > 0;
  bool get hasNext =>
      hasActiveQueueIndex && currentQueueIndex! < queue.length - 1;
}
