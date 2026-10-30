import 'package:bilimusic/feature/player/domain/bili_subtitle.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_subtitle_state.freezed.dart';

@freezed
abstract class PlayerSubtitleState with _$PlayerSubtitleState {
  const factory PlayerSubtitleState({
    String? stableId,
    @Default(<BiliSubtitleTrack>[]) List<BiliSubtitleTrack> tracks,
    String? selectedTrackId,
    String? pendingTrackId,
    @Default(<BiliSubtitleLine>[]) List<BiliSubtitleLine> lines,
    @Default(0) int offsetMs,
    @Default(false) bool isDiscovering,
    String? errorMessage,
  }) = _PlayerSubtitleState;

  const PlayerSubtitleState._();

  bool get usesSubtitles => selectedTrackId != null && lines.isNotEmpty;
  bool get hasTracks => tracks.isNotEmpty;
}
