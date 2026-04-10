import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorites_import_preview.freezed.dart';

@freezed
abstract class FavoritesImportPreview with _$FavoritesImportPreview {
  const FavoritesImportPreview._();

  const factory FavoritesImportPreview({
    required bool hasLikedCollection,
    required int likedItemCount,
    required int customCollectionCount,
    required int totalEntryCount,
    @Default(<FavoritesImportCollectionPreview>[])
    List<FavoritesImportCollectionPreview> collections,
    @Default(<String>{}) Set<String> conflictingCollectionNames,
  }) = _FavoritesImportPreview;
}

@freezed
abstract class FavoritesImportCollectionPreview
    with _$FavoritesImportCollectionPreview {
  const factory FavoritesImportCollectionPreview({
    required String sourceCollectionId,
    required String name,
    required bool isLikedCollection,
    required int itemCount,
    required bool hasNameConflict,
  }) = _FavoritesImportCollectionPreview;
}
