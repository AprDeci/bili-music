import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_import_preview.freezed.dart';

@freezed
abstract class AppImportPreview with _$AppImportPreview {
  const AppImportPreview._();

  const factory AppImportPreview({
    required bool hasLikedCollection,
    required int likedItemCount,
    required int customCollectionCount,
    required int totalEntryCount,
    @Default(false) bool hasSettings,
    @Default(<AppImportCollectionPreview>[])
    List<AppImportCollectionPreview> collections,
    @Default(<String>{}) Set<String> conflictingCollectionNames,
  }) = _AppImportPreview;
}

@freezed
abstract class AppImportCollectionPreview with _$AppImportCollectionPreview {
  const factory AppImportCollectionPreview({
    required String sourceCollectionId,
    required String name,
    required bool isLikedCollection,
    required int itemCount,
    required bool hasNameConflict,
  }) = _AppImportCollectionPreview;
}
