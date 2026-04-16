import 'dart:typed_data';

import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/setting/data/webdav_repository.dart';
import 'package:bilimusic/feature/setting/domain/favorites_import_preview.dart';
import 'package:bilimusic/feature/setting/domain/webdav_config.dart';
import 'package:bilimusic/feature/setting/logic/favorites_transfer_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'webdav_logic.g.dart';

@riverpod
WebDavLogic webDavLogic(Ref ref) {
  return WebDavLogic(
    repository: ref.read(webDavRepositoryProvider),
    favoritesTransferController: ref.read(favoritesTransferControllerProvider),
    ref: ref,
  );
}

class WebDavLogic {
  WebDavLogic({
    required WebDavRepository repository,
    required FavoritesTransferController favoritesTransferController,
    required Ref ref,
  }) : _repository = repository,
       _favoritesTransferController = favoritesTransferController,
       _ref = ref;

  final WebDavRepository _repository;
  final FavoritesTransferController _favoritesTransferController;
  final Ref _ref;

  WebDavConfig loadConfig() {
    return _repository.loadConfig();
  }

  Future<void> saveConfig(WebDavConfig config) {
    return _repository.saveConfig(config);
  }

  Future<void> testConnection() {
    return _repository.testConnection();
  }

  Future<List<WebDavBackupItem>> listBackups() {
    return _repository.listBackupFiles();
  }

  Future<void> uploadCurrentFavoritesBackup() async {
    final String json = await _favoritesTransferController.buildExportJson();
    await _repository.uploadFavoritesBackup(json, _buildBackupFileName());
  }

  Future<FavoritesImportPreview> downloadBackupPreview(
    String remotePath,
  ) async {
    final Uint8List bytes = await _repository.downloadBackupBytes(remotePath);
    return _favoritesTransferController.previewImport(bytes);
  }

  Future<void> importBackup({
    required String remotePath,
    required bool importLikedCollection,
    required Set<String> selectedCollectionIds,
  }) async {
    final Uint8List bytes = await _repository.downloadBackupBytes(remotePath);
    await _favoritesTransferController.importBytes(
      bytes: bytes,
      importLikedCollection: importLikedCollection,
      selectedCollectionIds: selectedCollectionIds,
    );
    await _ref.read(favoritesControllerProvider.notifier).reload();
  }

  Future<void> deleteBackup(String remotePath) {
    return _repository.deleteBackup(remotePath);
  }

  String _buildBackupFileName() {
    final DateTime now = DateTime.now();
    final String yyyy = now.year.toString().padLeft(4, '0');
    final String mm = now.month.toString().padLeft(2, '0');
    final String dd = now.day.toString().padLeft(2, '0');
    final String hh = now.hour.toString().padLeft(2, '0');
    final String min = now.minute.toString().padLeft(2, '0');
    final String ss = now.second.toString().padLeft(2, '0');
    return 'bilimusic-favorites-v1-$yyyy$mm$dd-$hh$min$ss.json';
  }
}
