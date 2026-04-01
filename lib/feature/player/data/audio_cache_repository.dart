import 'dart:io';

import 'package:bilimusic/core/cache/app_cache_manager.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_cache_repository.g.dart';

@riverpod
PlayerAudioCacheRepository playerAudioCacheRepository(Ref ref) {
  return PlayerAudioCacheRepository(AppAudioCacheManager.instance);
}

class PlayerAudioCacheRepository {
  PlayerAudioCacheRepository(this._cacheManager);

  final CacheManager _cacheManager;
  final Map<String, Future<File>> _inflightDownloads = <String, Future<File>>{};

  String buildCacheKey({
    required PlayableItem item,
    required AudioStreamInfo audioStream,
  }) {
    final String? quality = audioStream.qualityLabel?.trim();
    final String qualityKey = quality == null || quality.isEmpty
        ? 'default'
        : quality;
    return 'audio:${item.stableId}:$qualityKey';
  }

  Future<File?> getCachedFile({
    required PlayableItem item,
    required AudioStreamInfo audioStream,
  }) async {
    final String key = buildCacheKey(item: item, audioStream: audioStream);
    final FileInfo? fileInfo = await _cacheManager.getFileFromCache(key);
    if (fileInfo == null) {
      return null;
    }

    if (!await fileInfo.file.exists()) {
      await _cacheManager.removeFile(key);
      return null;
    }

    return fileInfo.file;
  }

  Future<void> removeCachedFile({
    required PlayableItem item,
    required AudioStreamInfo audioStream,
  }) {
    final String key = buildCacheKey(item: item, audioStream: audioStream);
    return _cacheManager.removeFile(key);
  }

  Future<File> cacheAudio({
    required PlayableItem item,
    required AudioStreamInfo audioStream,
  }) async {
    final String key = buildCacheKey(item: item, audioStream: audioStream);
    final File? cachedFile = await getCachedFile(
      item: item,
      audioStream: audioStream,
    );
    if (cachedFile != null) {
      return cachedFile;
    }

    final Future<File> inFlight = _inflightDownloads.putIfAbsent(
      key,
      () => _downloadAudio(key: key, audioStream: audioStream),
    );

    try {
      return await inFlight;
    } finally {
      _inflightDownloads.remove(key);
    }
  }

  Future<File> _downloadAudio({
    required String key,
    required AudioStreamInfo audioStream,
  }) async {
    final List<String> candidateUrls = <String>[
      audioStream.streamUrl,
      ...audioStream.backupUrls,
    ].where((String url) => url.isNotEmpty).toList(growable: false);

    Object? lastError;
    for (final String url in candidateUrls) {
      try {
        return await _cacheManager.getSingleFile(
          url,
          key: key,
          headers: audioStream.headers.isEmpty ? null : audioStream.headers,
        );
      } on Object catch (error) {
        lastError = error;
      }
    }

    throw lastError ?? const FileSystemException('Failed to cache audio file.');
  }
}
