import 'package:bilimusic/common/domain/meta_lyrics.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'metadata.freezed.dart';

@freezed
abstract class Metadata with _$Metadata {
  const factory Metadata({
    required String stableId,
    String? artist,
    String? title,
    String? lyrics,
    MetaLyrics? metaLyrics,
    String? albumArtUrl,
    @Default(0) int lyricOffsetMs,
    DateTime? updatedAt,
  }) = _Metadata;

  const Metadata._();

  bool get hasLyrics =>
      (lyrics != null && lyrics!.trim().isNotEmpty) ||
      (metaLyrics != null && metaLyrics!.hasRenderableMainLyric);
}
