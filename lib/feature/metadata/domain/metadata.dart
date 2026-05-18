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

  bool get hasLyrics =>
      (lyrics != null && lyrics!.trim().isNotEmpty) ||
      (metaLyrics != null && metaLyrics!.hasLyrics);
}

@freezed
abstract class MetaLyrics with _$MetaLyrics {
  const factory MetaLyrics({
    String? lyric,
    String? translatedLyric,
    String? romanizedLyric,
    String? karaokeLyric,
    String? karaokeTranslatedLyric,
  }) = _MetaLyrics;

  const MetaLyrics._();

  factory MetaLyrics.fromJson(Map<String, dynamic> json) =>
      _$MetaLyricsFromJson(json);

  bool get hasLyrics =>
      _hasText(lyric) ||
      _hasText(translatedLyric) ||
      _hasText(romanizedLyric) ||
      _hasText(karaokeLyric) ||
      _hasText(karaokeTranslatedLyric);

  String? get preferredMainLyric =>
      _firstNonEmpty(<String?>[karaokeLyric, lyric]);

  String? get preferredTranslationLyric =>
      _firstNonEmpty(<String?>[karaokeTranslatedLyric, translatedLyric]);
}

bool _hasText(String? value) {
  return value != null && value.trim().isNotEmpty;
}

String? _firstNonEmpty(Iterable<String?> values) {
  for (final String? value in values) {
    final String trimmed = value?.trim() ?? '';
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return null;
}
