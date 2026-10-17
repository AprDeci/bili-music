import 'package:bilimusic/common/domain/meta_lyrics.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'metadata.freezed.dart';
part 'metadata.g.dart';

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

  factory Metadata.fromJson(Map<String, dynamic> json) =>
      _$MetadataFromJson(json);

  bool get hasLyrics =>
      (lyrics != null && lyrics!.trim().isNotEmpty) ||
      (metaLyrics != null && metaLyrics!.hasRenderableMainLyric);

  bool get hasContent =>
      (artist?.trim().isNotEmpty ?? false) ||
      (title?.trim().isNotEmpty ?? false) ||
      (albumArtUrl?.trim().isNotEmpty ?? false) ||
      hasLyrics;
}
