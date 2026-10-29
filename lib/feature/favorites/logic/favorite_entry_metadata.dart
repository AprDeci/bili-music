import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_view_mode_logic.dart';
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

@riverpod
String? favoriteEntryCoverUrl(Ref ref, FavoriteEntry? entry) {
  if (entry == null) {
    return null;
  }
  if (ref.watch(favoritesViewModeLogicProvider) == FavoriteListViewMode.video) {
    return entry.coverUrl;
  }
  final String coverUrl =
      ref
          .watch(favoriteEntryMetadataProvider(entry.contentId))
          .asData
          ?.value
          ?.albumArtUrl
          ?.trim() ??
      '';
  return coverUrl.isEmpty ? entry.coverUrl : coverUrl;
}
