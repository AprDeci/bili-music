import 'package:freezed_annotation/freezed_annotation.dart';

part 'bili_subtitle.freezed.dart';

@freezed
abstract class BiliSubtitleTrack with _$BiliSubtitleTrack {
  const factory BiliSubtitleTrack({
    required String id,
    required String language,
    required String label,
    required String url,
    @Default(false) bool isTranslated,
  }) = _BiliSubtitleTrack;
}

@freezed
abstract class BiliSubtitleLine with _$BiliSubtitleLine {
  const factory BiliSubtitleLine({
    required int startMs,
    required int endMs,
    required String text,
  }) = _BiliSubtitleLine;
}
