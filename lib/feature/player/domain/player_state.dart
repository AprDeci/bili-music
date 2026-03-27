import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_state.freezed.dart';

@freezed
abstract class PlayerState with _$PlayerState {
  const factory PlayerState({
    PlayableItem? currentItem,
    AudioStreamInfo? audioStream,
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
}
