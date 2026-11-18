import 'dart:convert';
import 'dart:io';

import 'package:bilimusic/feature/player/domain/audio_cache_limit.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AudioCacheMetadata {
  const AudioCacheMetadata({
    required this.cacheKey,
    required this.bvid,
    required this.aid,
    required this.cid,
    required this.qualityId,
    required this.qualityLabel,
    required this.bandwidth,
    required this.durationMs,
    required this.pageTitle,
    required this.byteLength,
    required this.sha256Hash,
    required this.completedAt,
    this.page,
    this.schemaVersion = 2,
  });

  final String cacheKey;
  final String bvid;
  final int aid;
  final int cid;
  final int? page;
  final int? qualityId;
  final String? qualityLabel;
  final int bandwidth;
  final int? durationMs;
  final String? pageTitle;
  final int byteLength;
  final String sha256Hash;
  final int completedAt;
  final int schemaVersion;

  Map<String, Object?> toJson() => <String, Object?>{
    'cacheKey': cacheKey,
    'bvid': bvid,
    'aid': aid,
    'cid': cid,
    'page': page,
    'qualityId': qualityId,
    'qualityLabel': qualityLabel,
    'bandwidth': bandwidth,
    'durationMs': durationMs,
    'pageTitle': pageTitle,
    'byteLength': byteLength,
    'sha256': sha256Hash,
    'completedAt': completedAt,
    'schemaVersion': schemaVersion,
  };

  static AudioCacheMetadata? fromJson(Object? value) {
    if (value is! Map<dynamic, dynamic>) {
      return null;
    }

    int? readInt(String key) {
      final Object? valueAtKey = value[key];
      return valueAtKey is num ? valueAtKey.toInt() : null;
    }

    final String? cacheKey = value['cacheKey'] as String?;
    final String? hash = value['sha256'] as String?;
    final int? aid = readInt('aid');
    final int? cid = readInt('cid');
    final int? bandwidth = readInt('bandwidth');
    final int? byteLength = readInt('byteLength');
    if (cacheKey == null ||
        hash == null ||
        aid == null ||
        cid == null ||
        bandwidth == null ||
        byteLength == null) {
      return null;
    }

    return AudioCacheMetadata(
      cacheKey: cacheKey,
      bvid: value['bvid'] as String? ?? '',
      aid: aid,
      cid: cid,
      page: readInt('page'),
      qualityId: readInt('qualityId'),
      qualityLabel: value['qualityLabel'] as String?,
      bandwidth: bandwidth,
      durationMs: readInt('durationMs'),
      pageTitle: value['pageTitle'] as String?,
      byteLength: byteLength,
      sha256Hash: hash,
      completedAt: readInt('completedAt') ?? 0,
      schemaVersion: readInt('schemaVersion') ?? 2,
    );
  }
}

class CachedAudio {
  const CachedAudio({required this.file, required this.metadata});

  final File file;
  final AudioCacheMetadata metadata;
}

class PlayerAudioCacheRepository {
  PlayerAudioCacheRepository(
    CacheManager? cacheManager, {
    Future<String> Function()? readIndex,
    Future<void> Function(String)? writeIndex,
    Future<File?> Function(String key)? readCachedFile,
    Future<File> Function(String url, String key, Map<String, String>? headers)?
    downloadFile,
    Future<void> Function(String key)? removeFile,
    int Function()? readLimitBytes,
    Future<Iterable<String>> Function()? readStoredKeys,
  }) : _readStoredKeys =
           readStoredKeys ??
           (() async {
             if (cacheManager == null) return const <String>[];
             await cacheManager.store.getCacheSize();
             return (await cacheManager.config.repo.getAllObjects()).map(
               (entry) => entry.key,
             );
           }),
       _readLimitBytes = readLimitBytes ?? (() => AudioCacheLimit.mb512.bytes),
       _readIndex = readIndex ?? (() async => '[]'),
       _writeIndex = writeIndex ?? ((String _) async {}),
       _readCachedFile =
           readCachedFile ??
           ((String key) async =>
               (await cacheManager!.getFileFromCache(key))?.file),
       _downloadFile =
           downloadFile ??
           ((String url, String key, Map<String, String>? headers) =>
               cacheManager!.getSingleFile(url, key: key, headers: headers)),
       _removeFile =
           removeFile ??
           ((String key) async {
             final File? file = (await cacheManager!.getFileFromCache(
               key,
             ))?.file;
             if (file != null && await file.exists()) await file.delete();
             await cacheManager.removeFile(key);
           });

  final Future<String> Function() _readIndex;
  final Future<void> Function(String) _writeIndex;
  final Future<File?> Function(String key) _readCachedFile;
  final Future<File> Function(
    String url,
    String key,
    Map<String, String>? headers,
  )
  _downloadFile;
  final Future<void> Function(String key) _removeFile;
  final int Function() _readLimitBytes;
  final Future<Iterable<String>> Function() _readStoredKeys;
  final Map<String, Future<File?>> _inflightDownloads =
      <String, Future<File?>>{};
  final Set<String> _protectedKeys = <String>{};
  final Set<String> _pendingRemoval = <String>{};
  Future<void> _indexUpdates = Future<void>.value();
  int _generation = 0;
  int _playbackGeneration = 0;

  Future<void> releaseFiles() {
    _playbackGeneration++;
    _protectedKeys.clear();
    return trim();
  }

  Future<void> clear() {
    _generation++;
    return _updateIndex((List<AudioCacheMetadata> entries) async {
      _pendingRemoval.addAll(entries.map((entry) => entry.cacheKey));
      await _trim(entries);
    });
  }

  Future<void> trim() {
    if (_readLimitBytes() <= 0) _generation++;
    return _updateIndex(_trim);
  }

  // ponytail: 容量是下载完成后的目标；需要严格硬配额时再加入下载预留与流式限额。
  Future<void> _trim(List<AudioCacheMetadata> entries) async {
    final Set<String> indexed = entries.map((entry) => entry.cacheKey).toSet();
    for (final String key in await _readStoredKeys()) {
      if (indexed.contains(key) || _inflightDownloads.containsKey(key)) {
        continue;
      }
      if (_protectedKeys.contains(key)) {
        _pendingRemoval.add(key);
      } else {
        await _removeFile(key);
        _pendingRemoval.remove(key);
      }
    }
    final int limit = _readLimitBytes();
    int bytes = entries.fold(
      0,
      (int size, AudioCacheMetadata entry) => size + entry.byteLength,
    );
    for (final AudioCacheMetadata entry in entries.reversed.toList()) {
      if (_protectedKeys.contains(entry.cacheKey)) continue;
      if (!_pendingRemoval.contains(entry.cacheKey) &&
          (limit <= 0 || bytes <= limit && entries.length <= 120)) {
        continue;
      }
      await _removeFile(entry.cacheKey);
      entries.remove(entry);
      _pendingRemoval.remove(entry.cacheKey);
      bytes -= entry.byteLength;
    }
    await _writeMetadata(entries);
  }

  String buildCacheKey({
    required PlayableItem item,
    required AudioStreamInfo audioStream,
  }) {
    final String identity = item.bvid.isNotEmpty
        ? 'bvid:${item.bvid}'
        : 'aid:${item.aid}';
    final String quality =
        audioStream.qualityId?.toString() ??
        audioStream.qualityLabel?.trim().toLowerCase() ??
        'default';
    return 'audio:v2:$identity:cid:${audioStream.cid}'
        ':quality:$quality:bandwidth:${audioStream.bandwidth}';
  }

  Future<CachedAudio?> lookupCachedAudio({
    required PlayableItem item,
    required PlayerAudioQualityPreference preference,
    int? preferredQualityId,
    bool allowQualityFallback = true,
    bool Function()? protect,
  }) async {
    final int playbackGeneration = _playbackGeneration;
    final int? cid = item.cid;
    await _indexUpdates;
    final List<AudioCacheMetadata> matching = (await _readMetadata())
        .where(
          (AudioCacheMetadata metadata) =>
              (cid != null && cid > 0
                  ? metadata.cid == cid
                  : metadata.page == (item.page ?? 1)) &&
              (item.bvid.isNotEmpty
                  ? metadata.bvid == item.bvid
                  : metadata.bvid.isEmpty && metadata.aid == item.aid),
        )
        .toList(growable: false);
    final int? targetQualityId =
        preferredQualityId ??
        switch (preference) {
          PlayerAudioQualityPreference.hires => 30251,
          PlayerAudioQualityPreference.k192 => 30280,
          PlayerAudioQualityPreference.k132 => 30232,
          PlayerAudioQualityPreference.auto => null,
        };
    final List<AudioCacheMetadata> candidates = matching
        .where(
          (AudioCacheMetadata metadata) =>
              allowQualityFallback ||
              targetQualityId == null ||
              metadata.qualityId == targetQualityId,
        )
        .toList();
    candidates.sort((AudioCacheMetadata left, AudioCacheMetadata right) {
      if (targetQualityId != null) {
        final bool leftPreferred = left.qualityId == targetQualityId;
        final bool rightPreferred = right.qualityId == targetQualityId;
        if (leftPreferred != rightPreferred) {
          return leftPreferred ? -1 : 1;
        }
      }
      return right.bandwidth.compareTo(left.bandwidth);
    });
    for (final AudioCacheMetadata candidate in candidates) {
      final CachedAudio? cached = await _validated(
        candidate,
        protect: protect,
        playbackGeneration: playbackGeneration,
      );
      if (cached != null) {
        return cached;
      }
    }
    return null;
  }

  Future<File?> getCachedFile({
    required PlayableItem item,
    required AudioStreamInfo audioStream,
    bool Function()? protect,
  }) async {
    final int playbackGeneration = _playbackGeneration;
    await _indexUpdates;
    final String key = buildCacheKey(item: item, audioStream: audioStream);
    AudioCacheMetadata? metadata;
    for (final AudioCacheMetadata entry in await _readMetadata()) {
      if (entry.cacheKey == key) {
        metadata = entry;
        break;
      }
    }
    return metadata == null
        ? null
        : (await _validated(
            metadata,
            protect: protect,
            playbackGeneration: playbackGeneration,
          ))?.file;
  }

  Future<void> removeCachedFile({
    required PlayableItem item,
    required AudioStreamInfo audioStream,
  }) {
    return _invalidate(buildCacheKey(item: item, audioStream: audioStream));
  }

  Future<File?> cacheAudio({
    required PlayableItem item,
    required AudioStreamInfo audioStream,
  }) async {
    if (_readLimitBytes() <= 0) return null;
    final int generation = _generation;
    final File? existing = await getCachedFile(
      item: item,
      audioStream: audioStream,
    );
    if (generation != _generation || _readLimitBytes() <= 0) return null;
    if (existing != null) {
      return existing;
    }

    final String key = buildCacheKey(item: item, audioStream: audioStream);
    final Future<File?> future = _inflightDownloads.putIfAbsent(
      key,
      () => _downloadAndIndex(key, item, audioStream, generation),
    );
    try {
      return await future;
    } finally {
      if (identical(_inflightDownloads[key], future)) {
        _inflightDownloads.remove(key);
      }
    }
  }

  Future<File?> _downloadAndIndex(
    String key,
    PlayableItem item,
    AudioStreamInfo stream,
    int generation,
  ) async {
    Object? lastError;
    File? file;
    for (final String url in <String>[stream.streamUrl, ...stream.backupUrls]) {
      if (url.isEmpty) {
        continue;
      }
      try {
        file = await _downloadFile(
          url,
          key,
          stream.headers.isEmpty ? null : stream.headers,
        );
        break;
      } on Object catch (error) {
        lastError = error;
      }
    }

    if (file == null) {
      await _invalidate(key);
      throw lastError ??
          const FileSystemException('Failed to cache audio file.');
    }

    final int length = await file.length();
    if (length <= 0) {
      await _invalidate(key);
      throw const FileSystemException('Downloaded audio file is empty.');
    }

    final String hash = (await sha256.bind(file.openRead()).first).toString();
    final AudioCacheMetadata metadata = AudioCacheMetadata(
      cacheKey: key,
      bvid: item.bvid,
      aid: item.aid,
      cid: stream.cid,
      page: item.page,
      qualityId: stream.qualityId,
      qualityLabel: stream.qualityLabel,
      bandwidth: stream.bandwidth,
      durationMs: stream.duration?.inMilliseconds,
      pageTitle: stream.pageTitle ?? item.pageTitle,
      byteLength: length,
      sha256Hash: hash,
      completedAt: DateTime.now().millisecondsSinceEpoch,
    );
    bool retained = false;
    await _updateIndex((List<AudioCacheMetadata> entries) async {
      final int limit = _readLimitBytes();
      if (generation != _generation || limit <= 0 || length > limit) {
        await _removeFile(key);
        return;
      }
      entries.removeWhere((AudioCacheMetadata entry) => entry.cacheKey == key);
      entries.insert(0, metadata);
      await _trim(entries);
      retained = entries.contains(metadata);
    });
    return retained ? file : null;
  }

  Future<CachedAudio?> _validated(
    AudioCacheMetadata metadata, {
    bool Function()? protect,
    required int playbackGeneration,
  }) async {
    CachedAudio? result;
    await _updateIndex((List<AudioCacheMetadata> entries) async {
      final int index = entries.indexWhere(
        (entry) => entry.cacheKey == metadata.cacheKey,
      );
      if (index < 0) return;
      final File? file = await _readCachedFile(metadata.cacheKey);
      final int length = file != null && await file.exists()
          ? await file.length()
          : 0;
      final String hash = length > 0
          ? (await sha256.bind(file!.openRead()).first).toString()
          : '';
      if (length <= 0 ||
          length != metadata.byteLength ||
          hash != metadata.sha256Hash) {
        await _removeFile(metadata.cacheKey);
        entries.removeAt(index);
        await _writeMetadata(entries);
        return;
      }
      if (index > 0) {
        entries.insert(0, entries.removeAt(index));
        await _writeMetadata(entries);
      }
      if (protect != null) {
        if (playbackGeneration != _playbackGeneration || !protect()) return;
        _protectedKeys.add(metadata.cacheKey);
      }
      result = CachedAudio(file: file!, metadata: metadata);
    });
    return result;
  }

  Future<void> _invalidate(String key) async {
    await _updateIndex((List<AudioCacheMetadata> entries) async {
      await _removeFile(key);
      final int previousLength = entries.length;
      entries.removeWhere((AudioCacheMetadata entry) => entry.cacheKey == key);
      if (entries.length != previousLength) {
        await _writeMetadata(entries);
      }
    });
  }

  Future<List<AudioCacheMetadata>> _readMetadata() async {
    try {
      final Object? decoded = jsonDecode(await _readIndex());
      if (decoded is! List<dynamic>) {
        return <AudioCacheMetadata>[];
      }
      return decoded
          .map(AudioCacheMetadata.fromJson)
          .whereType<AudioCacheMetadata>()
          .toList();
    } on Object {
      return <AudioCacheMetadata>[];
    }
  }

  Future<void> _writeMetadata(Iterable<AudioCacheMetadata> entries) {
    return _writeIndex(
      jsonEncode(
        entries
            .map((AudioCacheMetadata entry) => entry.toJson())
            .toList(growable: false),
      ),
    );
  }

  Future<void> _updateIndex(
    Future<void> Function(List<AudioCacheMetadata>) update,
  ) {
    final Future<void> operation = _indexUpdates.then((_) async {
      await update(await _readMetadata());
    });
    _indexUpdates = operation.onError<Object>((Object _, StackTrace _) {});
    return operation;
  }
}
