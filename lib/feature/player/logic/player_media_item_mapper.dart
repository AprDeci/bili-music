import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:just_audio_background/just_audio_background.dart';

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

String _resolveAlbumLabel(String? queueSourceLabel) {
  final String trimmed = queueSourceLabel?.trim() ?? '';
  return trimmed.isEmpty ? 'Bilibili' : trimmed;
}

Uri? _tryParseUri(String value) {
  final String trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  return Uri.tryParse(trimmed);
}
