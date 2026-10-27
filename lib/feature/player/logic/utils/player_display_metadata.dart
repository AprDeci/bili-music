import 'package:bilimusic/common/domain/meta_lyrics.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';

String? resolveDisplayTitle({
  required PlayableItem? item,
  required Metadata? metadata,
  required bool useMetadata,
}) {
  final String title = useMetadata
      ? _metadataForItem(item, metadata)?.title?.trim() ?? ''
      : '';
  return title.isNotEmpty ? title : item?.title;
}

String? resolveDisplayArtist({
  required PlayableItem? item,
  required Metadata? metadata,
  required bool useMetadata,
}) {
  final String artist = useMetadata
      ? _metadataForItem(item, metadata)?.artist?.trim() ?? ''
      : '';
  return artist.isNotEmpty ? artist : item?.author;
}

bool usesMetadataArtist({
  required PlayableItem? item,
  required Metadata? metadata,
  required bool useMetadata,
}) {
  return useMetadata &&
      (_metadataForItem(item, metadata)?.artist?.trim().isNotEmpty ?? false);
}

String? resolveDisplayCoverUrl({
  required PlayableItem? item,
  required Metadata? metadata,
  required bool useMetadataCover,
}) {
  if (useMetadataCover) {
    final String metadataCoverUrl =
        _metadataForItem(item, metadata)?.albumArtUrl?.trim() ?? '';
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

bool hasSwitchableDisplay({
  required PlayableItem? item,
  required Metadata? metadata,
}) {
  final Metadata? currentMetadata = _metadataForItem(item, metadata);
  return (currentMetadata?.title?.trim().isNotEmpty ?? false) ||
      (currentMetadata?.artist?.trim().isNotEmpty ?? false) ||
      (currentMetadata?.albumArtUrl?.trim().isNotEmpty ?? false);
}

Metadata? _metadataForItem(PlayableItem? item, Metadata? metadata) {
  return item != null && metadata?.stableId == item.stableId ? metadata : null;
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
