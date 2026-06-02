import 'dart:async';

import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/favorites/domain/import/favorites_import_candidate.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/import/favorites_import_platform.dart';
import 'package:bilimusic/feature/favorites/domain/import/favorites_import_result.dart';
import 'package:bilimusic/feature/favorites/domain/import/favorites_import_status.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/favorites/logic/import/favorites_import_controller.dart';
import 'package:bilimusic/feature/favorites/logic/import/favorites_import_state.dart';
import 'package:bilimusic/feature/favorites/ui/import/manual_match_sheet.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/router/player_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImportPage extends ConsumerStatefulWidget {
  const ImportPage({super.key});

  @override
  ConsumerState<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends ConsumerState<ImportPage> {
  late final TextEditingController _playlistIdController;
  bool _isSavingImport = false;

  @override
  void initState() {
    super.initState();
    markPlayerPageVisible();
    final FavoritesImportState state = ref.read(
      favoritesImportControllerProvider,
    );
    _playlistIdController = TextEditingController(
      text: state.request.playlistId,
    );
  }

  @override
  void dispose() {
    _playlistIdController.dispose();
    markPlayerPageHidden();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FavoritesImportState state = ref.watch(
      favoritesImportControllerProvider,
    );
    final bool hasQueue = _hasQueue(state);

    return Scaffold(
      appBar: AppBar(
        title: Text(hasQueue ? '匹配队列' : '导入歌单'),
        centerTitle: true,
        actions: <Widget>[
          if (hasQueue)
            if (state.isRunning)
              TextButton(
                onPressed: ref
                    .read(favoritesImportControllerProvider.notifier)
                    .cancelImport,
                child: const Text('取消'),
              )
            else
              TextButton(
                onPressed: ref
                    .read(favoritesImportControllerProvider.notifier)
                    .reset,
                child: const Text('清空'),
              ),
        ],
      ),
      body: SafeArea(
        child: hasQueue
            ? _ImportQueueView(
                state: state,
                isSavingImport: _isSavingImport,
                onImportPressed: () => _importMatchedResults(state),
              )
            : _ImportFormView(
                state: state,
                playlistIdController: _playlistIdController,
              ),
      ),
    );
  }

  bool _hasQueue(FavoritesImportState state) {
    return state.status != FavoritesImportStatus.idle ||
        state.results.isNotEmpty ||
        state.totalCount > 0;
  }

  Future<void> _importMatchedResults(FavoritesImportState state) async {
    final List<PlayableItem> items = state.results
        .where((FavoritesImportResult result) => result.isMatched)
        .map(
          (FavoritesImportResult result) => result.candidate!.toPlayableItem(),
        )
        .toList(growable: false);
    if (items.isEmpty) {
      ToastUtil.show('没有可导入的匹配结果');
      return;
    }

    final String? name = await _showImportNameDialog(state);
    if (name == null) {
      return;
    }

    setState(() {
      _isSavingImport = true;
    });

    try {
      final FavoritesController controller = ref.read(
        favoritesControllerProvider.notifier,
      );
      final FavoriteCollection? collection = await controller.createCollection(
        name,
      );
      if (collection == null) {
        ToastUtil.show('创建歌单失败，请检查名称是否为空或重复');
        return;
      }

      final int importedCount = await controller.addItemsToCollection(
        collectionId: collection.id,
        items: items,
      );
      ToastUtil.show('已导入 $importedCount 首到「${collection.name}」');
    } on Object catch (error) {
      ToastUtil.show('导入失败：$error');
    } finally {
      if (mounted) {
        setState(() {
          _isSavingImport = false;
        });
      }
    }
  }

  Future<String?> _showImportNameDialog(FavoritesImportState state) {
    return showDialog<String>(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return _ImportNameDialog(
          initialValue: '导入歌单 ${state.request.playlistId}',
        );
      },
    );
  }
}

class _ImportFormView extends ConsumerWidget {
  const _ImportFormView({
    required this.state,
    required this.playlistIdController,
  });

  final FavoritesImportState state;
  final TextEditingController playlistIdController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          padding: const EdgeInsets.all(20),
          shrinkWrap: true,
          children: <Widget>[
            TextField(
              controller: playlistIdController,
              enabled: !state.isRunning,
              decoration: InputDecoration(
                labelText: '歌单 ID',
                hintText: '请输入歌单 ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: ref
                  .read(favoritesImportControllerProvider.notifier)
                  .updatePlaylistId,
            ),
            const SizedBox(height: 16),
            _PlatformRadioGroup(state: state),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: state.canStart && state.request.isValid
                  ? () {
                      unawaited(
                        ref
                            .read(favoritesImportControllerProvider.notifier)
                            .startImport(),
                      );
                    }
                  : null,
              icon: const Icon(Icons.playlist_add_check_rounded),
              label: Text(state.isRunning ? '正在导入' : '开始导入'),
            ),
            if (state.errorMessage != null) ...<Widget>[
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlatformRadioGroup extends ConsumerWidget {
  const _PlatformRadioGroup({required this.state});

  final FavoritesImportState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    return InputDecorator(
      decoration: InputDecoration(
        labelText: '平台',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: RadioGroup<FavoritesImportPlatform>(
        groupValue: state.request.platform,
        onChanged: (FavoritesImportPlatform? platform) {
          if (state.isRunning || platform == null) {
            return;
          }
          ref
              .read(favoritesImportControllerProvider.notifier)
              .updatePlatform(platform);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: FavoritesImportPlatform.values
              .map(
                (FavoritesImportPlatform platform) =>
                    RadioListTile<FavoritesImportPlatform>(
                      value: platform,
                      title: Text(platform.label),
                      enabled: !state.isRunning,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      activeColor: theme.colorScheme.primary,
                    ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _ImportQueueView extends StatelessWidget {
  const _ImportQueueView({
    required this.state,
    required this.isSavingImport,
    required this.onImportPressed,
  });

  final FavoritesImportState state;
  final bool isSavingImport;
  final VoidCallback onImportPressed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(0),
      children: <Widget>[
        _ImportProgressCard(
          state: state,
          isSavingImport: isSavingImport,
          onImportPressed: onImportPressed,
        ),
        const SizedBox(height: 12),
        if (state.results.isEmpty)
          const _EmptyQueueHint()
        else
          ...state.results.reversed.map(
            (FavoritesImportResult result) => _ResultTile(result),
          ),
      ],
    );
  }
}

class _ImportProgressCard extends StatelessWidget {
  const _ImportProgressCard({
    required this.state,
    required this.isSavingImport,
    required this.onImportPressed,
  });

  final FavoritesImportState state;
  final bool isSavingImport;
  final VoidCallback onImportPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double progress = state.totalCount <= 0
        ? 0
        : state.processedCount / state.totalCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: [
                      Text(_statusText(state.status)),
                      Text('·${state.processedCount}/${state.totalCount}'),
                    ],
                  ),
                ),
                if (!state.isRunning && state.matchedCount > 0) ...<Widget>[
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: isSavingImport ? null : onImportPressed,
                    icon: const Icon(Icons.library_add_rounded),
                    label: Text(isSavingImport ? '正在导入' : '导入歌单'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: state.isRunning && state.totalCount == 0
                  ? null
                  : progress.clamp(0, 1),
            ),
            if (state.currentCandidate != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                '候选：${state.currentCandidate!.title} · ${state.currentCandidate!.durationText}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (state.errorMessage != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _statusText(FavoritesImportStatus status) {
    return switch (status) {
      FavoritesImportStatus.idle => '等待开始',
      FavoritesImportStatus.loadingPlaylist => '正在获取歌单',
      FavoritesImportStatus.running => '正在匹配',
      FavoritesImportStatus.canceling => '正在取消',
      FavoritesImportStatus.canceled => '已取消',
      FavoritesImportStatus.completed => '匹配完成',
      FavoritesImportStatus.failed => '导入失败',
    };
  }
}

class _ResultTile extends ConsumerWidget {
  const _ResultTile(this.result);

  final FavoritesImportResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool matched = result.isMatched;
    return InkWell(
      onTap: () => _openManualMatchSheet(context, ref),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  matched
                      ? Icons.check_circle_rounded
                      : Icons.error_outline_rounded,
                  color: matched ? Colors.green : colorScheme.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${result.track.title} - ${result.track.author}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (matched)
                        _MatchedCandidateSummary(candidate: result.candidate!)
                      else
                        Text(
                          result.message ?? '匹配失败',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _openManualMatchSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final FavoritesImportController controller = ref.read(
      favoritesImportControllerProvider.notifier,
    );
    final String initialKeyword = controller.buildManualSearchKeyword(
      result.track,
    );
    final FavoritesImportCandidate? candidate =
        await showModalBottomSheet<FavoritesImportCandidate>(
          context: context,
          useSafeArea: true,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return ManualMatchSheet(
              result: result,
              initialKeyword: initialKeyword,
            );
          },
        );
    if (candidate == null) {
      return;
    }
    controller.replaceResultCandidate(result: result, candidate: candidate);
  }
}

class _MatchedCandidateSummary extends StatelessWidget {
  const _MatchedCandidateSummary({required this.candidate});

  final FavoritesImportCandidate candidate;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CommonCachedImage(
          imageUrl: candidate.coverUrl,
          width: 56,
          height: 56,
          borderRadius: BorderRadius.circular(8),
          fallbackIcon: Icons.music_video_rounded,
          iconColor: colorScheme.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                candidate.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 12
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${candidate.author} · ${candidate.durationText}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyQueueHint extends StatelessWidget {
  const _EmptyQueueHint();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(child: Text('暂无匹配结果')),
    );
  }
}

class _ImportNameDialog extends StatefulWidget {
  const _ImportNameDialog({required this.initialValue});

  final String initialValue;

  @override
  State<_ImportNameDialog> createState() => _ImportNameDialogState();
}

class _ImportNameDialogState extends State<_ImportNameDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('导入歌单'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: '歌单名称',
          hintText: '请输入歌单名称',
          errorText: _errorText,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _submit, child: const Text('导入')),
      ],
    );
  }

  void _submit() {
    final String name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() {
        _errorText = '请输入歌单名称';
      });
      return;
    }
    Navigator.of(context).pop(name);
  }
}
