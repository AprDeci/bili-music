import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'music_chart.freezed.dart';

@freezed
abstract class MusicChart with _$MusicChart {
  const factory MusicChart({
    required MusicChartPlatform platform,
    required String chartId,
    required String name,
  }) = _MusicChart;

  const MusicChart._();

  String get key => '${platform.name}:$chartId';

  String get displayTitle => '${platform.label}$name';
}
