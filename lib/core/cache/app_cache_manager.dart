import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AppImageCacheManager extends CacheManager with ImageCacheManager {
  AppImageCacheManager._()
    : super(
        Config(
          _cacheKey,
          stalePeriod: const Duration(days: 14),
          maxNrOfCacheObjects: 400,
        ),
      );

  static const String _cacheKey = 'bilimusic_image_cache';

  static AppImageCacheManager _instance = AppImageCacheManager._();

  static AppImageCacheManager get instance => _instance;

  static Future<void> resetNetworkClient() async {
    final AppImageCacheManager previous = _instance;
    try {
      await previous.dispose();
    } finally {
      _instance = AppImageCacheManager._();
    }
  }
}

class AppAudioCacheManager extends CacheManager {
  AppAudioCacheManager._()
    : super(
        Config(
          _cacheKey,
          stalePeriod: const Duration(days: 365),
          maxNrOfCacheObjects: 120,
        ),
      );

  static const String _cacheKey = 'bilimusic_audio_cache';

  static final AppAudioCacheManager instance = AppAudioCacheManager._();
}

class AppLyricsCacheManager extends CacheManager {
  AppLyricsCacheManager._()
    : super(
        Config(
          _cacheKey,
          stalePeriod: const Duration(days: 60),
          maxNrOfCacheObjects: 500,
        ),
      );

  static const String _cacheKey = 'bilimusic_lyrics_cache';

  static final AppLyricsCacheManager instance = AppLyricsCacheManager._();
}
