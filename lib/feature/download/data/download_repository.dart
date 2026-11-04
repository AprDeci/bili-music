import 'dart:convert';
import 'dart:io';

import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/common/util/platform_util.dart';
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

@riverpod
DownloadRepository downloadRepository(Ref ref) {
  return DownloadRepository(_openIndexStore());
}

DownloadIndexStore _openIndexStore() {
  try {
    return HiveDownloadIndexStore(Hive.box<String>(downloadedTracksBoxName));
  } on Object {
    return _MemoryDownloadIndexStore();
  }
}

abstract interface class DownloadIndexStore {
  Map<String, String> loadAll();

  Future<void> put(String contentId, String json);

  Future<void> remove(String contentId);

  Future<void> clear();
}

class _MemoryDownloadIndexStore implements DownloadIndexStore {
  final Map<String, String> _values = <String, String>{};

  @override
  Map<String, String> loadAll() => Map<String, String>.of(_values);

  @override
  Future<void> put(String contentId, String json) async {
    _values[contentId] = json;
  }

  @override
  Future<void> remove(String contentId) async {
    _values.remove(contentId);
  }

  @override
  Future<void> clear() async {
    _values.clear();
  }
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
    Future<List<int>> Function({
      required String url,
      required Map<String, String> headers,
      void Function(int received, int total)? onProgress,
    });

class DownloadRepository {
  DownloadRepository(
    this._store, {
    DownloadFetcher? fetcher,
    Future<Directory> Function()? readDirectory,
  }) : _fetcher = fetcher ?? _defaultFetcher,
       _readDirectory = readDirectory ?? _defaultDirectory;

  static final AppLogger _logger = AppLogger('DownloadRepository');

  final DownloadIndexStore _store;
  final DownloadFetcher _fetcher;
  final Future<Directory> Function() _readDirectory;

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
    void Function(int received, int total)? onProgress,
  }) async {
    final File file = await _targetFile(item);
    final List<int> bytes = await _fetcher(
      url: stream.streamUrl,
      headers: stream.headers,
      onProgress: onProgress,
    );
    if (bytes.isEmpty) {
      throw const FileSystemException('音频下载结果为空');
    }

    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);

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
      byteLength: bytes.length,
      downloadedAtMs: DateTime.now().millisecondsSinceEpoch,
      durationMs: stream.duration?.inMilliseconds,
      qualityId: stream.qualityId,
      qualityLabel: stream.qualityLabel,
      bandwidth: stream.bandwidth,
      collectionId: item.collectionId,
      kind: item.kind,
    );
    await _store.put(track.contentId, jsonEncode(track.toJson()));
    return track;
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

  static Future<List<int>> _defaultFetcher({
    required String url,
    required Map<String, String> headers,
    void Function(int received, int total)? onProgress,
  }) async {
    final Dio dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(minutes: 10),
      ),
    );
    try {
      final Response<List<int>> response = await dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: headers,
          followRedirects: true,
        ),
        onReceiveProgress: onProgress,
      );
      return response.data ?? const <int>[];
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
