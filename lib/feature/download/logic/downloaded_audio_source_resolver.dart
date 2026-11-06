import 'dart:io';

import 'package:bilimusic/feature/download/data/download_repository.dart';
import 'package:bilimusic/feature/download/domain/downloaded_track.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/logic/playback/audio_source_resolver.dart';

class DownloadedAudioSourceResolver implements AudioSourceResolver {
  const DownloadedAudioSourceResolver(this._repository);

  final DownloadRepository _repository;

  @override
  String get id => 'downloaded-audio';

  @override
  Future<ResolvedQueueEntry?> resolve(AudioResolutionRequest request) async {
    final DownloadedTrack? track = _repository.findByContentId(
      request.item.contentId,
    );
    if (track == null) {
      return null;
    }

    final File file = File(track.filePath);
    if (!await file.exists()) {
      return null;
    }

    return ResolvedQueueEntry(
      item: request.item.copyWith(
        cid: track.cid,
        page: track.page,
        pageTitle: track.pageTitle ?? request.item.pageTitle,
      ),
      availableParts: const <PlayableItem>[],
      audioStream: AudioStreamInfo(
        streamUrl: '',
        backupUrls: const <String>[],
        headers: const <String, String>{},
        cid: track.cid,
        duration: track.durationMs == null
            ? null
            : Duration(milliseconds: track.durationMs!),
        bandwidth: track.bandwidth ?? 0,
        availableQualities: <AudioQualityOption>[
          AudioQualityOption(
            qualityId: track.qualityId,
            bandwidth: track.bandwidth ?? 0,
            label: track.qualityLabel ?? '离线下载',
            isSelected: true,
          ),
        ],
        pageTitle: track.pageTitle,
        qualityId: track.qualityId,
        qualityLabel: track.qualityLabel,
      ),
      cachedFile: file,
    );
  }
}
