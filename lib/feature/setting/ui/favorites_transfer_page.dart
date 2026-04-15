import 'dart:io';
import 'dart:typed_data';

import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/setting/domain/favorites_import_preview.dart';
import 'package:bilimusic/feature/setting/logic/favorites_transfer_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesTransferPage extends ConsumerStatefulWidget {
  const FavoritesTransferPage({super.key});

  @override
  ConsumerState<FavoritesTransferPage> createState() =>
      _FavoritesTransferPageState();
}

class _FavoritesTransferPageState extends ConsumerState<FavoritesTransferPage> {
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('收藏导入导出')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('导出收藏', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '导出范围包括“我喜欢”、自建歌单及其包含的歌曲，导出为 JSON 文件。',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _isExporting ? null : _handleExportPressed,
                    icon: _isExporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download_rounded),
                    label: Text(_isExporting ? '导出中...' : '导出为 JSON'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('导入收藏', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '支持按歌单导入、覆盖同名歌单或覆盖全部本地收藏。默认会合并“我喜欢”，同名自建歌单默认新建副本。',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _isImporting ? null : _handleImportPressed,
                    icon: _isImporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload_file_rounded),
                    label: Text(_isImporting ? '处理中...' : '选择文件导入'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExportPressed() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final String? directoryPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: '选择导出目录',
      );
      if (directoryPath == null) {
        return;
      }

      final FavoritesTransferController controller = ref.read(
        favoritesTransferControllerProvider,
      );
      final String json = await controller.buildExportJson();
      final String fileName = _buildExportFileName();
      final String exportPath = '$directoryPath/$fileName';
      await controller.saveExportToPath(json: json, path: exportPath);

      if (!mounted) {
        return;
      }
      _showMessage('已导出到 $exportPath');
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage('导出失败：$error');
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _handleImportPressed() async {
    setState(() {
      _isImporting = true;
    });

    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const <String>['json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }

      final PlatformFile file = result.files.first;
      Uint8List? bytes = file.bytes;
      if (bytes == null && file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }
      if (bytes == null) {
        throw const _TransferUiException('读取导入文件失败。');
      }

      final FavoritesTransferController controller = ref.read(
        favoritesTransferControllerProvider,
      );
      final FavoritesImportPreview preview = await controller.previewImport(
        bytes,
      );
      if (!mounted) {
        return;
      }

      final _ImportDecision? decision = await showDialog<_ImportDecision>(
        context: context,
        builder: (BuildContext context) {
          return _ImportConfigDialog(preview: preview);
        },
      );
      if (decision == null) {
        return;
      }

      await controller.importBytes(
        bytes: bytes,
        importLikedCollection: decision.importLikedCollection,
        selectedCollectionIds: decision.selectedCollectionIds,
      );

      await ref.read(favoritesControllerProvider.notifier).reload();

      if (!mounted) {
        return;
      }
      _showMessage('收藏导入完成');
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage('导入失败：$error');
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  String _buildExportFileName() {
    final DateTime now = DateTime.now();
    final String yyyy = now.year.toString().padLeft(4, '0');
    final String mm = now.month.toString().padLeft(2, '0');
    final String dd = now.day.toString().padLeft(2, '0');
    final String hh = now.hour.toString().padLeft(2, '0');
    final String min = now.minute.toString().padLeft(2, '0');
    final String ss = now.second.toString().padLeft(2, '0');
    return 'bilimusic-favorites-$yyyy$mm$dd-$hh$min$ss.json';
  }

  void _showMessage(String message) {
    ToastUtil.show(message);
  }
}

class _ImportConfigDialog extends StatefulWidget {
  const _ImportConfigDialog({required this.preview});

  final FavoritesImportPreview preview;

  @override
  State<_ImportConfigDialog> createState() => _ImportConfigDialogState();
}

class _ImportConfigDialogState extends State<_ImportConfigDialog> {
  late bool _importLikedCollection;
  late Set<String> _selectedCollectionIds;

  @override
  void initState() {
    super.initState();
    _importLikedCollection = widget.preview.likedItemCount > 0;
    _selectedCollectionIds = widget.preview.collections
        .where(
          (FavoritesImportCollectionPreview collection) =>
              !collection.isLikedCollection,
        )
        .map(
          (FavoritesImportCollectionPreview collection) =>
              collection.sourceCollectionId,
        )
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AlertDialog(
      title: const Text('导入收藏'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '我喜欢 ${widget.preview.likedItemCount} 首，自建歌单 ${widget.preview.customCollectionCount} 个，歌曲 ${widget.preview.totalEntryCount} 首。',
                style: theme.textTheme.bodyMedium,
              ),
              if (widget
                  .preview
                  .conflictingCollectionNames
                  .isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  '检测到同名歌单：${widget.preview.conflictingCollectionNames.join('、')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (widget.preview.likedItemCount > 0) ...<Widget>[
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _importLikedCollection,
                  title: const Text('导入“我喜欢”'),
                  subtitle: Text(
                    '会合并 ${widget.preview.likedItemCount} 首歌曲到当前我喜欢',
                  ),
                  onChanged: (bool? value) {
                    setState(() {
                      _importLikedCollection = value ?? false;
                    });
                  },
                ),
              ],
              const SizedBox(height: 12),
              Text('选择歌单', style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              ...widget.preview.collections
                  .where(
                    (FavoritesImportCollectionPreview collection) =>
                        !collection.isLikedCollection,
                  )
                  .map((FavoritesImportCollectionPreview collection) {
                    final bool selected = _selectedCollectionIds.contains(
                      collection.sourceCollectionId,
                    );
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: selected,
                      title: Text(collection.name),
                      subtitle: Text(
                        '${collection.itemCount} 首${collection.hasNameConflict ? ' · 导入时会自动创建副本' : ''}',
                      ),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedCollectionIds.add(
                              collection.sourceCollectionId,
                            );
                          } else {
                            _selectedCollectionIds.remove(
                              collection.sourceCollectionId,
                            );
                          }
                        });
                      },
                    );
                  }),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _canSubmit
              ? () {
                  Navigator.of(context).pop(
                    _ImportDecision(
                      importLikedCollection: _importLikedCollection,
                      selectedCollectionIds: _selectedCollectionIds,
                    ),
                  );
                }
              : null,
          child: const Text('开始导入'),
        ),
      ],
    );
  }

  bool get _canSubmit {
    if (_importLikedCollection) {
      return true;
    }
    return _selectedCollectionIds.isNotEmpty;
  }
}

class _ImportDecision {
  const _ImportDecision({
    required this.importLikedCollection,
    required this.selectedCollectionIds,
  });

  final bool importLikedCollection;
  final Set<String> selectedCollectionIds;
}

class _TransferUiException implements Exception {
  const _TransferUiException(this.message);

  final String message;

  @override
  String toString() => message;
}
