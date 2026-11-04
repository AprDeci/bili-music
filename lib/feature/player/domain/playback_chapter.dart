import 'package:freezed_annotation/freezed_annotation.dart';

part 'playback_chapter.freezed.dart';

@freezed
abstract class PlaybackChapter with _$PlaybackChapter {
  const factory PlaybackChapter({
    required Duration start,
    Duration? end,
    required String title,
  }) = _PlaybackChapter;
}
