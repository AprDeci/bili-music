import 'dart:typed_data';

import 'package:bilimusic/feature/setting/data/app_transfer_repository.dart';
import 'package:bilimusic/feature/setting/domain/app_import_preview.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_transfer_controller.g.dart';

@riverpod
AppTransferController appTransferController(Ref ref) {
  return AppTransferController(
    repository: ref.read(appTransferRepositoryProvider),
  );
}

class AppTransferController {
  AppTransferController({required AppTransferRepository repository})
    : _repository = repository;

  final AppTransferRepository _repository;

  Future<String> buildExportJson() {
    return _repository.buildExportJson();
  }

  Future<void> saveExportToPath({required String json, required String path}) {
    return _repository.saveExportToPath(json: json, path: path);
  }

  Future<AppImportPreview> previewImport(Uint8List bytes) {
    return _repository.previewImport(bytes);
  }

  Future<void> importBytes({
    required Uint8List bytes,
    required bool importLikedCollection,
    required Set<String> selectedCollectionIds,
    required bool importSettings,
  }) async {
    return _repository.importBytes(
      bytes: bytes,
      importLikedCollection: importLikedCollection,
      selectedCollectionIds: selectedCollectionIds,
      importSettings: importSettings,
    );
  }
}
