import 'dart:typed_data';

import 'package:bilimusic/feature/setting/data/favorites_transfer_repository.dart';
import 'package:bilimusic/feature/setting/domain/favorites_import_preview.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorites_transfer_controller.g.dart';

@riverpod
FavoritesTransferController favoritesTransferController(Ref ref) {
  return FavoritesTransferController(
    repository: ref.read(favoritesTransferRepositoryProvider),
  );
}

class FavoritesTransferController {
  FavoritesTransferController({required FavoritesTransferRepository repository})
    : _repository = repository;

  final FavoritesTransferRepository _repository;

  Future<String> buildExportJson() {
    return _repository.buildExportJson();
  }

  Future<void> saveExportToPath({required String json, required String path}) {
    return _repository.saveExportToPath(json: json, path: path);
  }

  Future<FavoritesImportPreview> previewImport(Uint8List bytes) {
    return _repository.previewImport(bytes);
  }

  Future<void> importBytes({
    required Uint8List bytes,
    required bool importLikedCollection,
    required Set<String> selectedCollectionIds,
  }) async {
    return _repository.importBytes(
      bytes: bytes,
      importLikedCollection: importLikedCollection,
      selectedCollectionIds: selectedCollectionIds,
    );
  }
}
