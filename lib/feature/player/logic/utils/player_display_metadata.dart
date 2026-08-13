import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/common/domain/meta_lyrics.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';

String? resolveDisplayCoverUrl({
  required PlayableItem? item,
  required Metadata? metadata,
  required bool useMetadataCover,
}) {
  if (useMetadataCover) {
    final String metadataCoverUrl = metadata?.albumArtUrl?.trim() ?? '';
    if (metadataCoverUrl.isNotEmpty) {
      return metadataCoverUrl;
    }
  }

  final String itemCoverUrl = item?.coverUrl.trim() ?? '';
  if (itemCoverUrl.isNotEmpty) {
    return itemCoverUrl;
  }

  return null;
}

bool hasSwitchableCover({
  required PlayableItem? item,
  required Metadata? metadata,
}) {
  return item?.coverUrl.trim().isNotEmpty == true &&
      metadata?.albumArtUrl?.trim().isNotEmpty == true;
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
