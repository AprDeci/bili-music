import 'package:bilimusic/feature/metadata/data/metadata_cache_repository.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorite_entry_metadata.g.dart';

@riverpod
Future<Metadata?> favoriteEntryMetadata(Ref ref, String contentId) {
  return ref
      .read(metadataCacheRepositoryProvider)
      .getCachedMetadataByContentId(contentId);
}
