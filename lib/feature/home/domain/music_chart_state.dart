import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'music_chart_state.freezed.dart';

@freezed
abstract class MusicChartState with _$MusicChartState {
  const factory MusicChartState({
    @Default(MusicChartPlatform.netease) MusicChartPlatform platform,
    @Default(<MusicChartTrack>[]) List<MusicChartTrack> tracks,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _MusicChartState;

  const MusicChartState._();

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  bool get isEmpty => !isLoading && !hasError && tracks.isEmpty;
}
