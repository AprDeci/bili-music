import 'dart:async';

import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/download/data/download_repository.dart';
import 'package:bilimusic/feature/download/domain/download_task.dart';
import 'package:bilimusic/feature/download/domain/downloaded_track.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/player/logic/playback/player_audio_quality_preference_logic.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_controller.g.dart';

class DownloadState {
  const DownloadState({
    this.tracks = const <DownloadedTrack>[],
    this.tasks = const <String, DownloadTask>{},
    this.totalBytes = 0,
  });

  final List<DownloadedTrack> tracks;
  final Map<String, DownloadTask> tasks;
  final int totalBytes;

  bool contains(String contentId) {
    return tracks.any((DownloadedTrack track) => track.contentId == contentId);
  }

  DownloadedTrack? trackFor(String contentId) {
    for (final DownloadedTrack track in tracks) {
      if (track.contentId == contentId) {
        return track;
      }
    }
    return null;
  }

  DownloadTask? taskFor(String contentId) => tasks[contentId];

  bool get hasActiveTasks =>
      tasks.values.any((DownloadTask task) => task.isActive);

  DownloadState copyWith({
    List<DownloadedTrack>? tracks,
    Map<String, DownloadTask>? tasks,
    int? totalBytes,
  }) {
    return DownloadState(
      tracks: tracks ?? this.tracks,
      tasks: tasks ?? this.tasks,
      totalBytes: totalBytes ?? this.totalBytes,
    );
  }
}

@Riverpod(keepAlive: true)
class DownloadController extends _$DownloadController {
  final AppLogger _logger = AppLogger('DownloadController');
  Future<void> _queue = Future<void>.value();

  DownloadRepository get _repository => ref.read(downloadRepositoryProvider);

  @override
  DownloadState build() {
    try {
      final List<DownloadedTrack> tracks = _repository.loadAll();
      return DownloadState(
        tracks: tracks,
        totalBytes: tracks.fold<int>(
          0,
          (int sum, DownloadedTrack track) => sum + track.byteLength,
        ),
      );
    } on Object catch (error) {
      _logger.w('load downloads failed: $error');
      return const DownloadState();
    }
  }

  bool isDownloaded(PlayableItem item) => state.contains(item.contentId);

  Future<bool> download(PlayableItem item) async {
    final String contentId = item.contentId;
    if (state.contains(contentId)) {
      return false;
    }
    final DownloadTask? existing = state.taskFor(contentId);
    if (existing != null && existing.isActive) {
      return false;
    }

    _setTask(
      DownloadTask(contentId: contentId, status: DownloadTaskStatus.queued),
    );
    _queue = _queue.then((_) => _runDownload(item));
    return true;
  }

  Future<void> removeTrack(DownloadedTrack track) async {
    try {
      await _repository.remove(track);
    } on Object catch (error) {
      _logger.w('remove download failed: $error');
    }
    final List<DownloadedTrack> tracks = state.tracks
        .where((DownloadedTrack item) => item.contentId != track.contentId)
        .toList(growable: false);
    state = state.copyWith(tracks: tracks, totalBytes: _totalBytesOf(tracks));
  }

  Future<void> clearAll() async {
    try {
      await _repository.clearAll();
    } on Object catch (error) {
      _logger.w('clear downloads failed: $error');
    }
    state = const DownloadState();
  }

  Future<void> _runDownload(PlayableItem item) async {
    final String contentId = item.contentId;
    if (state.contains(contentId)) {
      _removeTask(contentId);
      return;
    }

    _setTask(
      DownloadTask(contentId: contentId, status: DownloadTaskStatus.running),
    );
    try {
      final BiliSession? session = ref.read(biliSessionControllerProvider);
      final PlayerAudioQualityPreference preference = ref.read(
        playerAudioQualityPreferenceLogicProvider,
      );
      final PlayerLoadResult result = await ref
          .read(biliPlayerRepositoryProvider)
          .resolveAudioStream(
            item,
            session: session,
            qualityPreference: preference,
          );
      final DownloadedTrack track = await _repository.downloadTrack(
        item: result.item,
        stream: result.audioStream,
        onProgress: (int received, int total) {
          _updateProgress(contentId, received, total);
        },
      );
      if (!ref.mounted) {
        return;
      }
      final List<DownloadedTrack> tracks = <DownloadedTrack>[
        track,
        ...state.tracks.where(
          (DownloadedTrack existing) => existing.contentId != contentId,
        ),
      ];
      state = state.copyWith(
        tracks: tracks,
        totalBytes: _totalBytesOf(tracks),
        tasks: Map<String, DownloadTask>.of(state.tasks)..remove(contentId),
      );
      _logger.d('download completed: ${item.title}');
    } on Object catch (error) {
      _logger.w('download failed: $error');
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        tasks: Map<String, DownloadTask>.of(state.tasks)
          ..[contentId] = DownloadTask(
            contentId: contentId,
            status: DownloadTaskStatus.failed,
            errorMessage: error.toString(),
          ),
      );
    }
  }

  void _setTask(DownloadTask task) {
    state = state.copyWith(
      tasks: Map<String, DownloadTask>.of(state.tasks)..[task.contentId] = task,
    );
  }

  void _removeTask(String contentId) {
    if (!state.tasks.containsKey(contentId)) {
      return;
    }
    state = state.copyWith(
      tasks: Map<String, DownloadTask>.of(state.tasks)..remove(contentId),
    );
  }

  void _updateProgress(String contentId, int received, int total) {
    final DownloadTask? task = state.tasks[contentId];
    if (task == null || !ref.mounted) {
      return;
    }
    final int previousPercent = task.totalBytes <= 0
        ? -1
        : (task.receivedBytes * 100 ~/ task.totalBytes);
    final int nextPercent = total <= 0 ? -1 : (received * 100 ~/ total);
    if (previousPercent == nextPercent && task.totalBytes == total) {
      return;
    }
    state = state.copyWith(
      tasks: Map<String, DownloadTask>.of(state.tasks)
        ..[contentId] = task.copyWith(
          status: DownloadTaskStatus.running,
          receivedBytes: received,
          totalBytes: total,
        ),
    );
  }

  int _totalBytesOf(List<DownloadedTrack> tracks) {
    return tracks.fold<int>(
      0,
      (int sum, DownloadedTrack track) => sum + track.byteLength,
    );
  }
}
