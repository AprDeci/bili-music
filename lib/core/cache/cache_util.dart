import 'dart:convert';
import 'package:bilimusic/core/cache/app_cache_manager.dart';
import 'package:bilimusic/feature/metadata/data/metadata_cache_repository.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive_ce/hive.dart';

class CacheUtil {
  CacheUtil._();

  static CacheManager get imageCacheManager => AppImageCacheManager.instance;
  static CacheManager get audioCacheManager => AppAudioCacheManager.instance;
  static CacheManager get lyricsCacheManager => AppLyricsCacheManager.instance;
  static Future<void> clearImageCache() async {
    await imageCacheManager.emptyCache();
  }

  static Future<void> clearAudioCache() async {
    await audioCacheManager.emptyCache();
  }

  static Future<void> clearLyricsCache() => lyricsCacheManager.emptyCache();

  static Future<void> clearMetadataCache() async {
    await Hive.lazyBox<Metadata>(metadataCacheBoxName).clear();
  }

  static Future<void> clearAllCache() async {
    await Future.wait(<Future<void>>[
      clearImageCache(),
      clearAudioCache(),
      clearLyricsCache(),
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
    await Hive.lazyBox<Metadata>(metadataCacheBoxName).delete(key);
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

  static Future<Metadata?> getMetadataCache(String key) {
    return Hive.lazyBox<Metadata>(metadataCacheBoxName).get(key);
  }

  static Future<int> getImageCacheSizeBytes() async {
    return imageCacheManager.store.getCacheSize();
  }

  static Future<int> getAudioCacheSizeBytes() async {
    return audioCacheManager.store.getCacheSize();
  }

  static Future<int> getLyricsCacheSizeBytes() {
    return lyricsCacheManager.store.getCacheSize();
  }

  static Future<int> getMetadataCacheSizeBytes() async {
    final LazyBox<Metadata> box = Hive.lazyBox<Metadata>(metadataCacheBoxName);
    int total = 0;
    for (final Object key in box.keys) {
      final Metadata? metadata = await box.get(key);
      if (metadata == null) {
        continue;
      }
      total += utf8.encode(jsonEncode(metadata.toJson())).length;
    }
    return total;
  }

  static Future<int> getTotalCacheSizeBytes() async {
    final List<int> sizes = await Future.wait<int>(<Future<int>>[
      getImageCacheSizeBytes(),
      getAudioCacheSizeBytes(),
      getLyricsCacheSizeBytes(),
      getMetadataCacheSizeBytes(),
    ]);
    return sizes.fold<int>(0, (int total, int item) => total + item);
  }
}
