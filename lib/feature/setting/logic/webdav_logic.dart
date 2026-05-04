import 'dart:typed_data';

import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/setting/data/webdav_repository.dart';
import 'package:bilimusic/feature/setting/domain/app_import_preview.dart';
import 'package:bilimusic/feature/setting/domain/webdav_config.dart';
import 'package:bilimusic/feature/setting/logic/app_transfer_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'webdav_logic.g.dart';

@riverpod
WebDavLogic webDavLogic(Ref ref) {
  return WebDavLogic(
    repository: ref.read(webDavRepositoryProvider),
    appTransferController: ref.read(appTransferControllerProvider),
    favoritesController: ref.read(favoritesControllerProvider.notifier),
  );
}

class WebDavLogic {
  WebDavLogic({
    required this._repository,
    required this._appTransferController,
    required this._favoritesController,
  });

  final WebDavRepository _repository;
  final AppTransferController _appTransferController;
  final FavoritesController _favoritesController;

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
    final String json = await _appTransferController.buildExportJson();
    await _repository.uploadFavoritesBackup(json, _buildBackupFileName());
  }

  Future<AppImportPreview> downloadBackupPreview(String remotePath) async {
    final Uint8List bytes = await _repository.downloadBackupBytes(remotePath);
    return _appTransferController.previewImport(bytes);
  }

  Future<void> importBackup({
    required String remotePath,
    required bool importLikedCollection,
    required Set<String> selectedCollectionIds,
    required bool importSettings,
  }) async {
    final Uint8List bytes = await _repository.downloadBackupBytes(remotePath);
    await _appTransferController.importBytes(
      bytes: bytes,
      importLikedCollection: importLikedCollection,
      selectedCollectionIds: selectedCollectionIds,
      importSettings: importSettings,
    );
    await _favoritesController.reload();
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
    return 'bilimusic-backup-$yyyy$mm$dd-$hh$min$ss.json';
  }
}
