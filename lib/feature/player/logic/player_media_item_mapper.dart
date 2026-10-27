import 'package:audio_service/audio_service.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/logic/utils/player_display_metadata.dart';

MediaItem buildPlayerMediaItem(
  PlayableItem item, {
  required AudioStreamInfo audioStream,
  required String? queueSourceLabel,
  Duration? duration,
  PlayerDisplayInfo? display,
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
    display: display,
  ).copyWith(displayDescription: descriptionParts.join(' · '));
}

MediaItem buildPlayerQueueMediaItem(
  PlayableItem item, {
  required String? queueSourceLabel,
  Duration? duration,
  PlayerDisplayInfo? display,
}) {
  final PlayerDisplayInfo info = display?.stableId == item.stableId
      ? display!
      : resolvePlayerDisplayInfo(
          item: item,
          metadata: null,
          source: PlayerDisplaySource.bilibili,
        );
  final String album = queueSourceLabel?.trim() ?? '';

  return MediaItem(
    id: item.stableId,
    album: album.isEmpty ? 'Bilibili' : album,
    title: info.title ?? item.title,
    artist: info.artist ?? item.author,
    artUri: info.coverUrl == null ? null : Uri.tryParse(info.coverUrl!),
    duration: duration,
    displayTitle: info.title ?? item.title,
    displaySubtitle: info.artist ?? item.author,
    displayDescription: item.pageTitle?.trim() ?? '',
  );
}
