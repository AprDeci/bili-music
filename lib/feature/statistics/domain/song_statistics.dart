import 'package:freezed_annotation/freezed_annotation.dart';

part 'song_statistics.freezed.dart';

@freezed
abstract class SongStatistics with _$SongStatistics {
  const factory SongStatistics({
    required String stableId,
    @Default('') String title,
    @Default('') String author,
    @Default('') String coverUrl,
    @Default(0) int playCount,
    @Default(0) int totalPlayedMs,
    int? firstPlayedAtEpochMs,
    int? lastPlayedAtEpochMs,
  }) = _SongStatistics;
}
