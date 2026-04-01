import 'dart:io';

import 'package:bilimusic/core/cache/app_cache_manager.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheUtil {
  CacheUtil._();

  static CacheManager get imageCacheManager => AppImageCacheManager.instance;
  static CacheManager get audioCacheManager => AppAudioCacheManager.instance;

  static Future<void> clearImageCache() async {
    await imageCacheManager.emptyCache();
    await audioCacheManager.emptyCache();
  }

  static Future<void> removeImageCache(String url) async {
    await imageCacheManager.removeFile(url);
    await audioCacheManager.removeFile(url);
  }

  static Future<FileInfo?> getImageCache(String url) async {
    return await imageCacheManager.getFileFromCache(url);
  }

  static Future<FileInfo?> getAudioCache(String url) async {
    return await audioCacheManager.getFileFromCache(url);
  }

  static Future<String> getImageCacheSize() async {
    final int cacheSize = await imageCacheManager.store.getCacheSize();
    final int audioCacheSize = await audioCacheManager.store.getCacheSize();
    //转换为MB 精确小数点两位
    return ((cacheSize + audioCacheSize).toDouble() / 1024 / 1024)
        .toStringAsFixed(2);
  }
}
