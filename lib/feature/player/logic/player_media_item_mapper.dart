import 'package:audio_service/audio_service.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/logic/utils/player_display_metadata.dart';

MediaItem buildPlayerMediaItem(
  PlayableItem item, {
  required AudioStreamInfo audioStream,
  required String? queueSourceLabel,
  Duration? duration,
  Metadata? metadata,
  bool useMetadata = true,
}) {
  final String pageTitle = audioStream.pageTitle?.trim() ?? '';
  final String qualityLabel = audioStream.qualityLabel?.trim() ?? '';
  final List<String> descriptionParts = <String>[
    if (pageTitle.isNotEmpty) pageTitle,
    if (qualityLabel.isNotEmpty) qualityLabel,
  ];

  return buildPlayerQueueMediaItem(
    item,
    queueSourceLabel: queueSourceLabel,
    duration: duration ?? audioStream.duration,
    metadata: metadata,
    useMetadata: useMetadata,
  ).copyWith(displayDescription: descriptionParts.join(' · '));
}

MediaItem buildPlayerQueueMediaItem(
  PlayableItem item, {
  required String? queueSourceLabel,
  Duration? duration,
  Metadata? metadata,
  bool useMetadata = true,
}) {
  final String title = resolveDisplayTitle(
    item: item,
    metadata: metadata,
    useMetadata: useMetadata,
  )!;
  final String artist = resolveDisplayArtist(
    item: item,
    metadata: metadata,
    useMetadata: useMetadata,
  )!;
  final String? coverUrl = resolveDisplayCoverUrl(
    item: item,
    metadata: metadata,
    useMetadataCover: useMetadata,
  );

  return MediaItem(
    id: item.stableId,
    album: _resolveAlbumLabel(queueSourceLabel),
    title: title,
    artist: artist,
    artUri: _tryParseUri(coverUrl),
    duration: duration,
    displayTitle: title,
    displaySubtitle: artist,
    displayDescription: item.pageTitle?.trim() ?? '',
  );
}

String _resolveAlbumLabel(String? queueSourceLabel) {
  final String trimmed = queueSourceLabel?.trim() ?? '';
  return trimmed.isEmpty ? 'Bilibili' : trimmed;
}

Uri? _tryParseUri(String? value) {
  final String trimmed = value?.trim() ?? '';
  return trimmed.isEmpty ? null : Uri.tryParse(trimmed);
}
