import 'dart:io';

import 'package:bilimusic/core/cache/app_cache_manager.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheUtil {
  CacheUtil._();

  static CacheManager get imageCacheManager => AppImageCacheManager.instance;

  static Future<void> clearImageCache() {
    return imageCacheManager.emptyCache();
  }

  static Future<void> removeImageCache(String url) {
    return imageCacheManager.removeFile(url);
  }

  static Future<FileInfo?> getImageCache(String url) {
    return imageCacheManager.getFileFromCache(url);
  }

  static Future<String> getImageCacheSize() async {
    final int cacheSize = await imageCacheManager.store.getCacheSize();
    //转换为MB 精确小数点两位
    return (cacheSize.toDouble() / 1024 / 1024).toStringAsFixed(2);
  }
}
