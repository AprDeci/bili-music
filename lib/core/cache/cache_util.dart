import 'dart:io';

import 'package:bilimusic/core/cache/app_cache_manager.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

class CacheUtil {
  CacheUtil._();

  static const String _lyricsCacheDirectoryName = 'bilimusic_lyrics_cache';

  static CacheManager get imageCacheManager => AppImageCacheManager.instance;
  static CacheManager get audioCacheManager => AppAudioCacheManager.instance;
  static CacheManager get lyricsCacheManager => AppLyricsCacheManager.instance;
  static CacheManager get metadataCacheManager =>
      AppMetadataCacheManager.instance;

  static Future<void> clearImageCache() async {
    await imageCacheManager.emptyCache();
  }

  static Future<void> clearAudioCache() async {
    await audioCacheManager.emptyCache();
  }

  static Future<void> clearLyricsCache() async {
    await lyricsCacheManager.emptyCache();

    final Directory lyricsCacheDirectory = await _getLyricsCacheDirectory();
    if (!await lyricsCacheDirectory.exists()) {
      return;
    }

    await for (final FileSystemEntity entity in lyricsCacheDirectory.list()) {
      try {
        await entity.delete(recursive: true);
      } on FileSystemException {
        // Ignore already-removed or locked cache entries and continue.
      }
    }
  }

  static Future<void> clearMetadataCache() async {
    await metadataCacheManager.emptyCache();
  }

  static Future<void> clearAllCache() async {
    await Future.wait(<Future<void>>[
      clearImageCache(),
      clearAudioCache(),
      clearMetadataCache(),
    ]);
  }

  static Future<void> removeImageCache(String url) async {
    await imageCacheManager.removeFile(url);
  }

  static Future<void> removeAudioCache(String url) async {
    await audioCacheManager.removeFile(url);
  }

  static Future<void> removeLyricsCache(String key) async {
    await lyricsCacheManager.removeFile(key);
  }

  static Future<void> removeMetadataCache(String key) async {
    await metadataCacheManager.removeFile(key);
  }

  static Future<FileInfo?> getImageCache(String url) async {
    return await imageCacheManager.getFileFromCache(url);
  }

  static Future<FileInfo?> getAudioCache(String url) async {
    return await audioCacheManager.getFileFromCache(url);
  }

  static Future<FileInfo?> getLyricsCache(String key) async {
    return await lyricsCacheManager.getFileFromCache(key);
  }

  static Future<FileInfo?> getMetadataCache(String key) async {
    return await metadataCacheManager.getFileFromCache(key);
  }

  static Future<int> getImageCacheSizeBytes() async {
    return imageCacheManager.store.getCacheSize();
  }

  static Future<int> getAudioCacheSizeBytes() async {
    return audioCacheManager.store.getCacheSize();
  }

  static Future<int> getLyricsCacheSizeBytes() async {
    final Directory lyricsCacheDirectory = await _getLyricsCacheDirectory();
    if (!await lyricsCacheDirectory.exists()) {
      return 0;
    }

    int total = 0;
    await for (final FileSystemEntity entity in lyricsCacheDirectory.list()) {
      if (entity is! File) {
        continue;
      }
      total += await entity.length();
    }
    return total;
  }

  static Future<int> getMetadataCacheSizeBytes() async {
    final Directory metadataCacheDirectory = await _getMetadataCacheDirectory();
    if (!await metadataCacheDirectory.exists()) {
      return 0;
    }

    int total = 0;
    await for (final FileSystemEntity entity in metadataCacheDirectory.list()) {
      if (entity is! File) {
        continue;
      }
      total += await entity.length();
    }
    return total;
  }

  static Future<Directory> _getMetadataCacheDirectory() async {
    final Directory baseDirectory = await getTemporaryDirectory();
    return Directory.fromUri(
      baseDirectory.uri.resolve('$_lyricsCacheDirectoryName/'),
    );
  }

  static Future<Directory> _getLyricsCacheDirectory() async {
    final Directory baseDirectory = await getTemporaryDirectory();
    return Directory.fromUri(
      baseDirectory.uri.resolve('$_lyricsCacheDirectoryName/'),
    );
  }

  static Future<int> getTotalCacheSizeBytes() async {
    final List<int> sizes = await Future.wait<int>(<Future<int>>[
      getImageCacheSizeBytes(),
      getAudioCacheSizeBytes(),
      getMetadataCacheSizeBytes(),
    ]);
    return sizes.fold<int>(0, (int total, int item) => total + item);
  }
}
