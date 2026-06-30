import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:audio_service/audio_service.dart';

MediaItem buildPlayerMediaItem(
  PlayableItem item, {
  required AudioStreamInfo audioStream,
  required String? queueSourceLabel,
  Duration? duration,
}) {
  final String album = _resolveAlbumLabel(queueSourceLabel);
  final String pageTitle = audioStream.pageTitle?.trim() ?? '';
  final String qualityLabel = audioStream.qualityLabel?.trim() ?? '';
  final List<String> descriptionParts = <String>[
    if (pageTitle.isNotEmpty) pageTitle,
    if (qualityLabel.isNotEmpty) qualityLabel,
  ];
  final Uri? artUri = _tryParseUri(item.coverUrl);

  return MediaItem(
    id: item.stableId,
    album: album,
    title: item.title,
    artist: item.author,
    artUri: artUri,
    duration: duration ?? audioStream.duration,
    displayTitle: item.title,
    displaySubtitle: item.author,
    displayDescription: descriptionParts.join(' · '),
  );
}

MediaItem buildPlayerQueueMediaItem(
  PlayableItem item, {
  required String? queueSourceLabel,
  Duration? duration,
}) {
  final String album = _resolveAlbumLabel(queueSourceLabel);
  final String pageTitle = item.pageTitle?.trim() ?? '';
  final String displayTitle = pageTitle.isEmpty
      ? item.title
      : _buildPageDisplayTitle(item, pageTitle);
  final String displaySubtitle = pageTitle.isEmpty ? item.author : item.title;
  final Uri? artUri = _tryParseUri(item.coverUrl);

  return MediaItem(
    id: item.stableId,
    album: album,
    title: displayTitle,
    artist: item.author,
    artUri: artUri,
    duration: duration,
    displayTitle: displayTitle,
    displaySubtitle: displaySubtitle,
    displayDescription: pageTitle.isEmpty ? '' : item.author,
  );
}

String _resolveAlbumLabel(String? queueSourceLabel) {
  final String trimmed = queueSourceLabel?.trim() ?? '';
  return trimmed.isEmpty ? 'Bilibili' : trimmed;
}

String _buildPageDisplayTitle(PlayableItem item, String pageTitle) {
  final int? page = item.page;
  if (page == null || page <= 0) {
    return pageTitle;
  }
  return 'P$page · $pageTitle';
}

Uri? _tryParseUri(String value) {
  final String trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  return Uri.tryParse(trimmed);
}
