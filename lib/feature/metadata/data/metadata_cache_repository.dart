import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'metadata_cache_repository.g.dart';

const String metadataCacheBoxName = 'metadata_cache';

@riverpod
MetadataCacheRepository metadataCacheRepository(Ref ref) {
  return MetadataCacheRepository(Hive.lazyBox<Metadata>(metadataCacheBoxName));
}

class MetadataCacheRepository {
  MetadataCacheRepository(this._box);

  final LazyBox<Metadata> _box;

  String buildCacheKey({required PlayableItem item}) {
    return 'metadata:${item.contentId}';
  }

  Future<Metadata?> getCachedMetadata({required PlayableItem item}) async {
    final String key = buildCacheKey(item: item);
    final Metadata? metadata = await _box.get(key);
    if (metadata == null) {
      return null;
    }

    return metadata.copyWith(stableId: item.stableId);
  }

  Future<void> putCachedMetadata({
    required PlayableItem item,
    required Metadata metadata,
  }) async {
    await _box.put(
      buildCacheKey(item: item),
      metadata.copyWith(
        stableId: item.stableId,
        updatedAt: metadata.updatedAt ?? DateTime.now(),
      ),
    );
  }

  Future<void> removeCachedMetadata({required PlayableItem item}) {
    return _box.delete(buildCacheKey(item: item));
  }

  Future<void> clear() {
    return _box.clear();
  }
}
