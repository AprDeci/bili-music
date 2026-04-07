import 'package:bilimusic/core/cache/app_cache_manager.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheUtil {
  CacheUtil._();

  static CacheManager get imageCacheManager => AppImageCacheManager.instance;
  static CacheManager get audioCacheManager => AppAudioCacheManager.instance;

  static Future<void> clearImageCache() async {
    await imageCacheManager.emptyCache();
  }

  static Future<void> clearAudioCache() async {
    await audioCacheManager.emptyCache();
  }

  static Future<void> clearAllCache() async {
    await Future.wait(<Future<void>>[clearImageCache(), clearAudioCache()]);
  }

  static Future<void> removeImageCache(String url) async {
    await imageCacheManager.removeFile(url);
  }

  static Future<void> removeAudioCache(String url) async {
    await audioCacheManager.removeFile(url);
  }

  static Future<FileInfo?> getImageCache(String url) async {
    return await imageCacheManager.getFileFromCache(url);
  }

  static Future<FileInfo?> getAudioCache(String url) async {
    return await audioCacheManager.getFileFromCache(url);
  }

  static Future<int> getImageCacheSizeBytes() async {
    return imageCacheManager.store.getCacheSize();
  }

  static Future<int> getAudioCacheSizeBytes() async {
    return audioCacheManager.store.getCacheSize();
  }

  static Future<int> getTotalCacheSizeBytes() async {
    final List<int> sizes = await Future.wait<int>(<Future<int>>[
      getImageCacheSizeBytes(),
      getAudioCacheSizeBytes(),
    ]);
    return sizes.fold<int>(0, (int total, int item) => total + item);
  }
}
