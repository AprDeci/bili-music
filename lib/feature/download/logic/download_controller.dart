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
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_controller.g.dart';

class DownloadState {
  const DownloadState({
    this.tracks = const <DownloadedTrack>[],
    this.tasks = const <String, DownloadTask>{},
    this.totalBytes = 0,
    this.errorMessage,
  });

  final List<DownloadedTrack> tracks;
  final Map<String, DownloadTask> tasks;
  final int totalBytes;
  final String? errorMessage;

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

  int get activeTaskCount => tasks.values.where((task) => task.isActive).length;

  bool get hasActiveTasks => activeTaskCount > 0;

  DownloadState copyWith({
    List<DownloadedTrack>? tracks,
    Map<String, DownloadTask>? tasks,
    int? totalBytes,
  }) {
    return DownloadState(
      tracks: tracks ?? this.tracks,
      tasks: tasks ?? this.tasks,
      totalBytes: totalBytes ?? this.totalBytes,
      errorMessage: errorMessage,
    );
  }
}

@Riverpod(keepAlive: true)
class DownloadController extends _$DownloadController {
  final AppLogger _logger = AppLogger('DownloadController');
  Future<void> _mutations = Future<void>.value();
  bool _enabled = false;
  bool _draining = false;
  CancelToken? _activeToken;
  String? _activeContentId;

  DownloadRepository get _repository => ref.read(downloadRepositoryProvider);

  @override
  DownloadState build() {
    ref.onDispose(() => _activeToken?.cancel());
    try {
      return _loadState();
    } on Object {
      _logger.w('download queue could not be loaded');
      return const DownloadState(errorMessage: '下载队列读取失败，请重启应用后重试');
    }
  }

  DownloadState _loadState() {
    final List<DownloadedTrack> tracks = _repository.loadAll();
    final Set<String> downloaded = tracks
        .map((track) => track.contentId)
        .toSet();
    final List<DownloadTask> tasks = _repository.loadTasks();
    return DownloadState(
      tracks: tracks,
      totalBytes: _totalBytesOf(tracks),
      tasks: <String, DownloadTask>{
        for (final DownloadTask task in tasks)
          if (!downloaded.contains(task.contentId))
            task.contentId: task.status == DownloadTaskStatus.running
                ? task.copyWith(
                    status: DownloadTaskStatus.queued,
                    receivedBytes: 0,
                    totalBytes: 0,
                  )
                : task,
      },
    );
  }

  Future<void> initialize() async {
    _enabled = true;
    _start();
  }

  bool isDownloaded(PlayableItem item) => state.contains(item.contentId);

  Future<bool> download(PlayableItem item) async =>
      await downloadAll(<PlayableItem>[item]) > 0;

  Future<int> downloadAll(List<PlayableItem> items) async {
    final int added = await _mutate(() async {
      final Map<String, DownloadTask> tasks = Map.of(state.tasks);
      int count = 0;
      for (final PlayableItem item in items) {
        if (!item.hasIdentity || (item.page != null && item.page! <= 0)) {
          throw ArgumentError('歌曲信息无效，无法下载');
        }
        if (state.contains(item.contentId) ||
            (tasks[item.contentId]?.isActive ?? false)) {
          continue;
        }
        tasks.remove(item.contentId);
        tasks[item.contentId] = DownloadTask(item: item);
        count++;
      }
      if (count > 0) {
        await _saveTasks(tasks);
      }
      return count;
    });
    _enabled = true;
    _start();
    return added;
  }

  Future<void> cancel(String contentId) => _mutate(() async {
    if (!state.tasks.containsKey(contentId)) {
      return;
    }
    final DownloadTask task = state.tasks[contentId]!;
    if (_activeContentId != contentId) {
      await _repository.discardPartial(task.item);
    }
    final Map<String, DownloadTask> tasks = Map.of(state.tasks)
      ..remove(contentId);
    await _saveTasks(tasks);
    if (_activeContentId == contentId) {
      _activeToken?.cancel();
    }
  });

  Future<bool> retry(String contentId) async {
    final DownloadTask? task = state.tasks[contentId];
    if (task == null || task.status != DownloadTaskStatus.failed) {
      return false;
    }
    return download(task.item);
  }

  Future<int> retryFailed() => downloadAll(<PlayableItem>[
    for (final DownloadTask task in state.tasks.values)
      if (task.status == DownloadTaskStatus.failed) task.item,
  ]);

  Future<void> removeTrack(DownloadedTrack track) => _mutate(() async {
    await _repository.saveTasks(state.tasks.values.toList(growable: false));
    await _repository.remove(track);
    if (!ref.mounted) {
      return;
    }
    final List<DownloadedTrack> tracks = state.tracks
        .where((item) => item.contentId != track.contentId)
        .toList(growable: false);
    state = state.copyWith(tracks: tracks, totalBytes: _totalBytesOf(tracks));
  });

  Future<void> clearAll() => _mutate(() async {
    await _repository.saveTasks(state.tasks.values.toList(growable: false));
    for (final DownloadedTrack track in state.tracks.toList(growable: false)) {
      await _repository.remove(track);
      if (!ref.mounted) {
        return;
      }
      final List<DownloadedTrack> tracks = state.tracks
          .where((item) => item.contentId != track.contentId)
          .toList(growable: false);
      state = state.copyWith(tracks: tracks, totalBytes: _totalBytesOf(tracks));
    }
  });

  Future<T> _mutate<T>(Future<T> Function() action) {
    final Future<T> next = _mutations.then((_) {
      if (!ref.mounted) {
        throw StateError('下载队列已关闭');
      }
      if (state.errorMessage != null) {
        throw StateError(state.errorMessage!);
      }
      return action();
    });
    _mutations = next.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return next;
  }

  Future<void> _saveTasks(Map<String, DownloadTask> tasks) async {
    final Map<String, DownloadTask> previous = state.tasks;
    await _repository.saveTasks(tasks.values.toList(growable: false));
    if (ref.mounted) {
      state = state.copyWith(
        tasks: <String, DownloadTask>{
          for (final MapEntry<String, DownloadTask> entry in tasks.entries)
            entry.key: identical(entry.value, previous[entry.key])
                ? (state.tasks[entry.key] ?? entry.value)
                : entry.value,
        },
      );
    }
  }

  void _start() {
    if (!_enabled || _draining || !ref.mounted || state.errorMessage != null) {
      return;
    }
    unawaited(_drain());
  }

  Future<void> _drain() async {
    _draining = true;
    try {
      while (ref.mounted) {
        DownloadTask? next;
        for (final DownloadTask task in state.tasks.values) {
          if (task.status == DownloadTaskStatus.queued) {
            next = task;
            break;
          }
        }
        if (next == null) {
          return;
        }
        await _runDownload(next);
      }
    } finally {
      _draining = false;
    }
  }

  Future<void> _runDownload(DownloadTask task) async {
    final String contentId = task.contentId;
    final CancelToken token = CancelToken();
    try {
      final bool claimed = await _mutate(() async {
        if (!identical(state.tasks[contentId], task)) {
          return false;
        }
        _activeContentId = contentId;
        _activeToken = token;
        state = state.copyWith(
          tasks: Map<String, DownloadTask>.of(state.tasks)
            ..[contentId] = task.copyWith(status: DownloadTaskStatus.running),
        );
        return true;
      });
      if (!claimed || !ref.mounted || token.isCancelled) {
        return;
      }
      await _repository.discardPartial(task.item);
      if (!ref.mounted || token.isCancelled) {
        return;
      }
      final BiliSession? session = ref.read(biliSessionControllerProvider);
      final PlayerAudioQualityPreference preference = ref.read(
        playerAudioQualityPreferenceLogicProvider,
      );
      final PlayerLoadResult result = await Future.any<PlayerLoadResult>([
        ref
            .read(biliPlayerRepositoryProvider)
            .resolveAudioStream(
              task.item,
              session: session,
              qualityPreference: preference,
            ),
        token.whenCancel.then((error) => throw error),
      ]);
      if (!ref.mounted || token.isCancelled) {
        return;
      }
      final DownloadedTrack track = await _repository.downloadTrack(
        item: result.item,
        stream: result.audioStream,
        cancelToken: token,
        onProgress: (int received, int total) {
          _updateProgress(contentId, token, received, total);
        },
      );
      await _mutate(() async {
        if (token.isCancelled || !state.tasks.containsKey(contentId)) {
          await _repository.remove(track);
          return;
        }
        final Map<String, DownloadTask> tasks = Map.of(state.tasks)
          ..remove(contentId);
        try {
          await _repository.saveTasks(tasks.values.toList(growable: false));
        } on Object {
          _logger.w('completed task cleanup could not be persisted');
        }
        if (!ref.mounted) {
          return;
        }
        final List<DownloadedTrack> tracks = <DownloadedTrack>[
          track,
          ...state.tracks.where((existing) => existing.contentId != contentId),
        ];
        state = state.copyWith(
          tracks: tracks,
          totalBytes: _totalBytesOf(tracks),
          tasks: tasks,
        );
      });
    } on Object catch (error) {
      if (!ref.mounted || token.isCancelled) {
        return;
      }
      await _mutate(() async {
        if (token.isCancelled || !state.tasks.containsKey(contentId)) {
          return;
        }
        final String message = switch (error) {
          DioException(type: DioExceptionType.connectionTimeout) ||
          DioException(
            type: DioExceptionType.receiveTimeout,
          ) => '下载超时，请检查网络后重试',
          DioException(type: DioExceptionType.connectionError) =>
            '网络连接失败，请检查网络后重试',
          _ => '下载失败，请检查网络、登录状态或存储空间后重试',
        };
        final Map<String, DownloadTask> tasks = Map.of(state.tasks)
          ..[contentId] = task.copyWith(
            status: DownloadTaskStatus.failed,
            errorMessage: message,
          );
        try {
          await _saveTasks(tasks);
        } on Object {
          if (ref.mounted) {
            state = state.copyWith(
              tasks: tasks
                ..[contentId] = tasks[contentId]!.copyWith(
                  errorMessage: '$message（队列保存失败）',
                ),
            );
          }
          _logger.w('failed task could not be persisted');
        }
      });
    } finally {
      if (identical(_activeToken, token)) {
        _activeToken = null;
        _activeContentId = null;
      }
    }
  }

  void _updateProgress(
    String contentId,
    CancelToken token,
    int received,
    int total,
  ) {
    if (!ref.mounted || token.isCancelled || !identical(_activeToken, token)) {
      return;
    }
    final DownloadTask? task = state.tasks[contentId];
    if (task == null || task.status != DownloadTaskStatus.running) {
      return;
    }
    if (task.receivedBytes ~/ 65536 == received ~/ 65536 &&
        task.totalBytes == total &&
        received != total) {
      return;
    }
    state = state.copyWith(
      tasks: Map<String, DownloadTask>.of(state.tasks)
        ..[contentId] = task.copyWith(
          receivedBytes: received,
          totalBytes: total,
        ),
    );
  }

  int _totalBytesOf(List<DownloadedTrack> tracks) => tracks.fold<int>(
    0,
    (int sum, DownloadedTrack track) => sum + track.byteLength,
  );
}
