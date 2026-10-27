import 'package:bilimusic/common/domain/meta_lyrics.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_display_info.dart';

PlayerDisplayInfo resolvePlayerDisplayInfo({
  required PlayableItem? item,
  required Metadata? metadata,
  required PlayerDisplaySource source,
}) {
  if (item == null) {
    return PlayerDisplayInfo(source: source);
  }
  final Metadata? matchedMetadata = metadata?.stableId == item.stableId
      ? metadata
      : null;
  final String title = matchedMetadata?.title?.trim() ?? '';
  final String artist = matchedMetadata?.artist?.trim() ?? '';
  final String coverUrl = matchedMetadata?.albumArtUrl?.trim() ?? '';
  final bool useMetadata = source == PlayerDisplaySource.metadata;
  final bool useMetadataArtist = useMetadata && artist.isNotEmpty;
  final String selectedCover = useMetadata && coverUrl.isNotEmpty
      ? coverUrl
      : item.coverUrl.trim();

  return PlayerDisplayInfo(
    stableId: item.stableId,
    title: useMetadata && title.isNotEmpty ? title : item.title,
    artist: useMetadataArtist ? artist : item.author,
    coverUrl: selectedCover.isEmpty ? null : selectedCover,
    source: source,
    canToggleSource:
        title.isNotEmpty || artist.isNotEmpty || coverUrl.isNotEmpty,
    artistUpMid: !useMetadataArtist && (item.ownerMid ?? 0) > 0
        ? item.ownerMid
        : null,
  );
}

String? resolveDisplayLyrics(Metadata? metadata) {
  final String lyrics =
      metadata?.metaLyrics?.preferredMainLyric?.trim() ??
      metadata?.lyrics?.trim() ??
      '';
  return lyrics.isEmpty ? null : lyrics;
}

MetaLyrics? resolveDisplayMetaLyrics(Metadata? metadata) {
  return metadata?.metaLyrics;
}

String? resolveDisplayTranslationLyrics(Metadata? metadata) {
  return metadata?.metaLyrics?.preferredTranslationLyric;
}

int resolveDisplayLyricOffsetMs(Metadata? metadata) {
  return metadata?.lyricOffsetMs ?? 0;
}
