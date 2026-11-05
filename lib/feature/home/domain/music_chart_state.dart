import 'package:bilimusic/feature/home/domain/music_chart.dart';
import 'package:bilimusic/feature/home/domain/music_chart_catalog.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'music_chart_state.freezed.dart';

@freezed
abstract class MusicChartState with _$MusicChartState {
  const factory MusicChartState({
    @Default(MusicChartCatalog.defaultChart) MusicChart chart,
    @Default(<MusicChartTrack>[]) List<MusicChartTrack> tracks,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _MusicChartState;

  const MusicChartState._();

  MusicChartPlatform get platform => chart.platform;

  List<MusicChart> get charts => MusicChartCatalog.chartsFor(chart.platform);

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  bool get isEmpty => !isLoading && !hasError && tracks.isEmpty;
}
