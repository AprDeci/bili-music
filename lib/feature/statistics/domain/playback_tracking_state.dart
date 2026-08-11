import 'package:freezed_annotation/freezed_annotation.dart';

part 'playback_tracking_state.freezed.dart';

@freezed
abstract class PlaybackTrackingState with _$PlaybackTrackingState {
  const factory PlaybackTrackingState({
    String? stableId,
    @Default('') String title,
    @Default('') String author,
    @Default('') String coverUrl,
    @Default(0) int durationMs,
    @Default(0) int playedMs,
    @Default(0) int attemptPlayedMs,
    @Default(0) int lastPositionMs,
    @Default(false) bool isPlaying,
    @Default(false) bool counted,
  }) = _PlaybackTrackingState;
}
