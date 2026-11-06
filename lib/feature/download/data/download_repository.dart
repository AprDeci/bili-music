import 'dart:convert';
import 'dart:io';

import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/feature/download/domain/download_task.dart';
import 'package:bilimusic/feature/download/domain/downloaded_track.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_repository.g.dart';

const String downloadedTracksBoxName = 'downloaded_tracks';
const String downloadTasksBoxName = 'download_tasks';

@riverpod
DownloadRepository downloadRepository(Ref ref) {
  return DownloadRepository(
    HiveDownloadIndexStore(Hive.box<String>(downloadedTracksBoxName)),
    taskStore: HiveDownloadIndexStore(Hive.box<String>(downloadTasksBoxName)),
  );
}

abstract interface class DownloadIndexStore {
  Map<String, String> loadAll();

  Future<void> put(String contentId, String json);

  Future<void> remove(String contentId);

  Future<void> clear();
}

class HiveDownloadIndexStore implements DownloadIndexStore {
  HiveDownloadIndexStore(this._box);

  final Box<String> _box;

  @override
  Map<String, String> loadAll() {
    final Map<String, String> result = <String, String>{};
    for (final String key in _box.keys.whereType<String>()) {
      final String? value = _box.get(key);
      if (value != null) {
        result[key] = value;
      }
    }
    return result;
  }

  @override
  Future<void> put(String contentId, String json) => _box.put(contentId, json);

  @override
  Future<void> remove(String contentId) => _box.delete(contentId);

  @override
  Future<void> clear() => _box.clear();
}

typedef DownloadFetcher =
    Future<void> Function({
      required String url,
      required String savePath,
      required Map<String, String> headers,
      required CancelToken cancelToken,
      void Function(int received, int total)? onProgress,
    });

class DownloadRepository {
  DownloadRepository(
    this._store, {
    this.taskStore,
    DownloadFetcher? fetcher,
    Future<Directory> Function()? readDirectory,
  }) : _fetcher = fetcher ?? _defaultFetcher,
       _readDirectory = readDirectory ?? _defaultDirectory;

  static final AppLogger _logger = AppLogger('DownloadRepository');

  final DownloadIndexStore _store;
  final DownloadIndexStore? taskStore;
  final DownloadFetcher _fetcher;
  final Future<Directory> Function() _readDirectory;

  List<DownloadTask> loadTasks() {
    final String? snapshot = taskStore?.loadAll()['queue'];
    if (snapshot == null) {
      return <DownloadTask>[];
    }
    final Object? value;
    try {
      value = jsonDecode(snapshot);
    } on FormatException {
      return <DownloadTask>[];
    }
    if (value is! List<dynamic>) {
      return <DownloadTask>[];
    }
    return value
        .map(DownloadTask.fromJson)
        .whereType<DownloadTask>()
        .map(
          (DownloadTask task) => task.status == DownloadTaskStatus.running
              ? task.copyWith(
                  status: DownloadTaskStatus.queued,
                  receivedBytes: 0,
                  totalBytes: 0,
                  errorMessage: null,
                )
              : task,
        )
        .toList(growable: false);
  }

  Future<void> saveTasks(List<DownloadTask> tasks) async {
    await taskStore?.put(
      'queue',
      jsonEncode(tasks.map((DownloadTask task) => task.toJson()).toList()),
    );
  }

  List<DownloadedTrack> loadAll() {
    final List<DownloadedTrack> tracks = <DownloadedTrack>[];
    for (final String json in _store.loadAll().values) {
      try {
        final DownloadedTrack? track = DownloadedTrack.fromJson(
          jsonDecode(json),
        );
        if (track != null) {
          tracks.add(track);
        }
      } on Object catch (error) {
        _logger.w('skip broken download record: $error');
      }
    }
    tracks.sort(
      (DownloadedTrack left, DownloadedTrack right) =>
          right.downloadedAtMs.compareTo(left.downloadedAtMs),
    );
    return tracks;
  }

  int totalBytes() {
    return loadAll().fold<int>(
      0,
      (int sum, DownloadedTrack track) => sum + track.byteLength,
    );
  }

  DownloadedTrack? findByContentId(String contentId) {
    final String? json = _store.loadAll()[contentId];
    if (json == null) {
      return null;
    }
    try {
      return DownloadedTrack.fromJson(jsonDecode(json));
    } on Object {
      return null;
    }
  }

  Future<DownloadedTrack> downloadTrack({
    required PlayableItem item,
    required AudioStreamInfo stream,
    CancelToken? cancelToken,
    void Function(int received, int total)? onProgress,
  }) async {
    final CancelToken token = cancelToken ?? CancelToken();
    _checkCancelled(token);
    final DownloadedTrack? existing = findByContentId(item.contentId);
    if (existing != null) {
      final File existingFile = File(existing.filePath);
      if (await existingFile.exists() &&
          existing.byteLength > 0 &&
          await existingFile.length() == existing.byteLength) {
        _checkCancelled(token);
        return existing;
      }
    }
    final File file = await _targetFile(item);
    final File partial = File('${file.path}.part');
    bool committed = false;
    bool indexing = false;
    int expectedBytes = 0;
    try {
      _checkCancelled(token);
      await file.parent.create(recursive: true);
      if (await partial.exists()) {
        await partial.delete();
      }
      _checkCancelled(token);
      await _fetcher(
        url: stream.streamUrl,
        savePath: partial.path,
        headers: stream.headers,
        cancelToken: token,
        onProgress: (int received, int total) {
          if (total > 0) {
            expectedBytes = total;
          }
          onProgress?.call(received, total);
        },
      );
      _checkCancelled(token);
      final int byteLength = await partial.length();
      if (byteLength <= 0) {
        throw const FileSystemException('音频下载结果为空');
      }
      if (expectedBytes > 0 && byteLength != expectedBytes) {
        throw const FileSystemException('音频下载不完整');
      }
      _checkCancelled(token);
      await partial.rename(file.path);
      committed = true;
      _checkCancelled(token);
      final DownloadedTrack track = DownloadedTrack(
        contentId: item.contentId,
        aid: item.aid,
        bvid: item.bvid,
        cid: stream.cid > 0 ? stream.cid : (item.cid ?? 0),
        page: item.page ?? 1,
        pageTitle: stream.pageTitle ?? item.pageTitle,
        title: item.title,
        author: item.author,
        coverUrl: item.coverUrl,
        filePath: file.path,
        byteLength: byteLength,
        downloadedAtMs: DateTime.now().millisecondsSinceEpoch,
        durationMs: stream.duration?.inMilliseconds,
        qualityId: stream.qualityId,
        qualityLabel: stream.qualityLabel,
        bandwidth: stream.bandwidth,
        collectionId: item.collectionId,
        kind: item.kind,
      );
      indexing = true;
      await _store.put(track.contentId, jsonEncode(track.toJson()));
      _checkCancelled(token);
      return track;
    } on Object {
      if (indexing) {
        try {
          await _store.remove(item.contentId);
        } on Object {
          _logger.w('rollback download index failed');
        }
      }
      await _deleteFile(partial);
      if (committed) {
        await _deleteFile(file);
      }
      rethrow;
    }
  }

  static void _checkCancelled(CancelToken token) {
    if (token.isCancelled) {
      throw token.cancelError!;
    }
  }

  static Future<void> _deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } on Object {
      _logger.w('cleanup download file failed');
    }
  }

  Future<void> discardPartial(PlayableItem item) async {
    final File target = await _targetFile(item);
    final File partial = File('${target.path}.part');
    if (await partial.exists()) {
      await partial.delete();
    }
  }

  Future<void> remove(DownloadedTrack track) async {
    await _store.remove(track.contentId);
    try {
      final File file = File(track.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } on Object catch (error) {
      _logger.w('delete downloaded file failed: $error');
    }
  }

  Future<void> clearAll() async {
    final List<DownloadedTrack> tracks = loadAll();
    await _store.clear();
    for (final DownloadedTrack track in tracks) {
      try {
        final File file = File(track.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } on Object catch (error) {
        _logger.w('delete downloaded file failed: $error');
      }
    }
  }

  Future<File> _targetFile(PlayableItem item) async {
    final Directory directory = await _readDirectory();
    final String name = sha1.convert(utf8.encode(item.contentId)).toString();
    return File('${directory.path}${Platform.pathSeparator}$name.m4a');
  }

  static Future<void> _defaultFetcher({
    required String url,
    required String savePath,
    required Map<String, String> headers,
    required CancelToken cancelToken,
    void Function(int received, int total)? onProgress,
  }) async {
    final Dio dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(minutes: 10),
      ),
    );
    try {
      await dio.download(
        url,
        savePath,
        cancelToken: cancelToken,
        options: Options(
          headers: headers,
          followRedirects: true,
          receiveDataWhenStatusError: false,
        ),
        onReceiveProgress: onProgress,
      );
    } finally {
      dio.close();
    }
  }

  static Future<Directory> _defaultDirectory() async {
    final Directory base = PlatformUtil.isDesktop
        ? await getApplicationSupportDirectory()
        : await getApplicationDocumentsDirectory();
    final Directory directory = Directory(
      '${base.path}${Platform.pathSeparator}downloads',
    );
    await directory.create(recursive: true);
    return directory;
  }
}
