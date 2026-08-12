import 'dart:convert';
import 'dart:io';

import 'package:bilimusic/core/cache/app_cache_manager.dart';
import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_cache_repository.g.dart';

@riverpod
PlayerAudioCacheRepository playerAudioCacheRepository(Ref ref) {
  final AppSettingsStore store = ref.read(appSettingsStoreProvider);
  return PlayerAudioCacheRepository(
    AppAudioCacheManager.instance,
    readIndex: () async =>
        store.readString(HiveKeys.playerAudioCacheIndex, defaultValue: '[]'),
    writeIndex: (String value) =>
        store.writeString(HiveKeys.playerAudioCacheIndex, value),
  );
}

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
    this.schemaVersion = 2,
  });

  final String cacheKey;
  final String bvid;
  final int aid;
  final int cid;
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
  }) : _readIndex = readIndex ?? (() async => '[]'),
       _writeIndex = writeIndex ?? ((String _) async {}),
       _readCachedFile =
           readCachedFile ??
           ((String key) async =>
               (await cacheManager!.getFileFromCache(key))?.file),
       _downloadFile =
           downloadFile ??
           ((String url, String key, Map<String, String>? headers) =>
               cacheManager!.getSingleFile(url, key: key, headers: headers)),
       _removeFile = removeFile ?? cacheManager!.removeFile;

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
  final Map<String, Future<File>> _inflightDownloads = <String, Future<File>>{};
  Future<void> _indexUpdates = Future<void>.value();

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
  }) async {
    final int? cid = item.cid;
    await _indexUpdates;
    final List<AudioCacheMetadata> matching = (await _readMetadata())
        .where(
          (AudioCacheMetadata metadata) =>
              (cid == null || cid <= 0 || metadata.cid == cid) &&
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
    final List<AudioCacheMetadata> preferredCandidates = targetQualityId == null
        ? matching
        : matching
              .where(
                (AudioCacheMetadata metadata) =>
                    metadata.qualityId == targetQualityId,
              )
              .toList(growable: false);
    final Iterable<AudioCacheMetadata> candidates = preferredCandidates.isEmpty
        ? matching
        : preferredCandidates;
    AudioCacheMetadata? selected;
    for (final AudioCacheMetadata candidate in candidates) {
      if (selected == null || candidate.bandwidth > selected.bandwidth) {
        selected = candidate;
      }
    }
    return selected == null ? null : _validated(selected);
  }

  Future<File?> getCachedFile({
    required PlayableItem item,
    required AudioStreamInfo audioStream,
  }) async {
    await _indexUpdates;
    final String key = buildCacheKey(item: item, audioStream: audioStream);
    AudioCacheMetadata? metadata;
    for (final AudioCacheMetadata entry in await _readMetadata()) {
      if (entry.cacheKey == key) {
        metadata = entry;
        break;
      }
    }
    return metadata == null ? null : (await _validated(metadata))?.file;
  }

  Future<void> removeCachedFile({
    required PlayableItem item,
    required AudioStreamInfo audioStream,
  }) {
    return _invalidate(buildCacheKey(item: item, audioStream: audioStream));
  }

  Future<File> cacheAudio({
    required PlayableItem item,
    required AudioStreamInfo audioStream,
  }) async {
    final File? existing = await getCachedFile(
      item: item,
      audioStream: audioStream,
    );
    if (existing != null) {
      return existing;
    }

    final String key = buildCacheKey(item: item, audioStream: audioStream);
    final Future<File> future = _inflightDownloads.putIfAbsent(
      key,
      () => _downloadAndIndex(key, item, audioStream),
    );
    try {
      return await future;
    } finally {
      if (identical(_inflightDownloads[key], future)) {
        _inflightDownloads.remove(key);
      }
    }
  }

  Future<File> _downloadAndIndex(
    String key,
    PlayableItem item,
    AudioStreamInfo stream,
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
      qualityId: stream.qualityId,
      qualityLabel: stream.qualityLabel,
      bandwidth: stream.bandwidth,
      durationMs: stream.duration?.inMilliseconds,
      pageTitle: stream.pageTitle ?? item.pageTitle,
      byteLength: length,
      sha256Hash: hash,
      completedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _updateIndex((List<AudioCacheMetadata> entries) async {
      entries.removeWhere((AudioCacheMetadata entry) => entry.cacheKey == key);
      entries.insert(0, metadata);
      final List<AudioCacheMetadata> evicted = entries.length > 120
          ? entries.sublist(120)
          : const <AudioCacheMetadata>[];
      await _writeMetadata(entries.take(120));
      for (final AudioCacheMetadata entry in evicted) {
        await _removeFile(entry.cacheKey);
      }
    });
    return file;
  }

  Future<CachedAudio?> _validated(AudioCacheMetadata metadata) async {
    final File? file = await _readCachedFile(metadata.cacheKey);
    if (file == null || !await file.exists()) {
      await _invalidate(metadata.cacheKey);
      return null;
    }
    final int length = await file.length();
    final String hash = length > 0
        ? (await sha256.bind(file.openRead()).first).toString()
        : '';
    if (length != metadata.byteLength || hash != metadata.sha256Hash) {
      await _invalidate(metadata.cacheKey);
      return null;
    }
    return CachedAudio(file: file, metadata: metadata);
  }

  Future<void> _invalidate(String key) async {
    await _removeFile(key);
    await _updateIndex((List<AudioCacheMetadata> entries) async {
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
