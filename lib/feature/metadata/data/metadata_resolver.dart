import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/meting/domain/meting_search_item.dart';

class MetadataLookupResult {
  const MetadataLookupResult({
    required this.metadata,
    required this.searchResults,
    this.searchKeyword,
  });

  final Metadata metadata;
  final List<MetingSearchItem> searchResults;
  final String? searchKeyword;
}

abstract final class MetadataResolver {
  const MetadataResolver._();

  static MetadataLookupResult buildLookupResult({
    required String stableId,
    required String? artist,
    required String? title,
    required String? lyrics,
    MetaLyrics? metaLyrics,
    required String? albumArtUrl,
    required List<MetingSearchItem> searchResults,
    String? searchKeyword,
  }) {
    return MetadataLookupResult(
      metadata: Metadata(
        stableId: stableId,
        artist: _normalizeText(artist),
        title: _normalizeText(title),
        lyrics: _normalizeText(lyrics),
        metaLyrics: _normalizeMetaLyrics(metaLyrics),
        albumArtUrl: _normalizeText(albumArtUrl),
        updatedAt: DateTime.now(),
      ),
      searchResults: searchResults,
      searchKeyword: _normalizeText(searchKeyword),
    );
  }

  static Metadata fromCacheLikeValues({
    required String stableId,
    String? artist,
    String? title,
    String? lyrics,
    MetaLyrics? metaLyrics,
    String? albumArtUrl,
    int lyricOffsetMs = 0,
    DateTime? updatedAt,
  }) {
    return Metadata(
      stableId: stableId,
      artist: _normalizeText(artist),
      title: _normalizeText(title),
      lyrics: _normalizeText(lyrics),
      metaLyrics: _normalizeMetaLyrics(metaLyrics),
      albumArtUrl: _normalizeText(albumArtUrl),
      lyricOffsetMs: lyricOffsetMs,
      updatedAt: updatedAt,
    );
  }

  static String? _normalizeText(String? value) {
    final String trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  static MetaLyrics? _normalizeMetaLyrics(MetaLyrics? value) {
    if (value == null) {
      return null;
    }

    final MetaLyrics normalized = MetaLyrics(
      lyric: _normalizeText(value.lyric),
      translatedLyric: _normalizeText(value.translatedLyric),
      romanizedLyric: _normalizeText(value.romanizedLyric),
      karaokeLyric: _normalizeText(value.karaokeLyric),
      karaokeTranslatedLyric: _normalizeText(value.karaokeTranslatedLyric),
    );
    return normalized.hasLyrics ? normalized : null;
  }
}
