import 'package:freezed_annotation/freezed_annotation.dart';

part 'meta_lyrics.freezed.dart';
part 'meta_lyrics.g.dart';

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

  bool get hasAnyLyrics =>
      _hasText(lyric) ||
      _hasText(translatedLyric) ||
      _hasText(romanizedLyric) ||
      _hasText(karaokeLyric) ||
      _hasText(karaokeTranslatedLyric);

  bool get hasRenderableMainLyric => preferredMainLyric != null;

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
