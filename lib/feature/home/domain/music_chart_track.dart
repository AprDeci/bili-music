import 'package:bilimusic/feature/home/domain/music_chart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'music_chart_track.freezed.dart';

@freezed
abstract class MusicChartTrack with _$MusicChartTrack {
  const factory MusicChartTrack({
    required MusicChart chart,
    required int rank,
    required String title,
    required String artist,
    required String coverUrl,
    @Default(0) int durationSeconds,
  }) = _MusicChartTrack;

  const MusicChartTrack._();

  String get key => '${chart.key}:$rank:$title:$artist';

  String get searchKeyword => '$title $artist'.trim();

  String get durationText {
    if (durationSeconds <= 0) {
      return '--:--';
    }
    final int minutes = durationSeconds ~/ 60;
    final int seconds = durationSeconds % 60;
    if (minutes >= 60) {
      final int hours = minutes ~/ 60;
      return '${hours.toString().padLeft(2, '0')}:'
          '${(minutes % 60).toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}
