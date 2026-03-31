import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AppImageCacheManager extends CacheManager {
  AppImageCacheManager._()
    : super(
        Config(
          _cacheKey,
          stalePeriod: const Duration(days: 14),
          maxNrOfCacheObjects: 400,
        ),
      );

  static const String _cacheKey = 'bilimusic_image_cache';

  static final AppImageCacheManager instance = AppImageCacheManager._();
}
