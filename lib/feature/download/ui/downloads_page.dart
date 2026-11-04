import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/util/format_util.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/download/domain/download_task.dart';
import 'package:bilimusic/feature/download/domain/downloaded_track.dart';
import 'package:bilimusic/feature/download/logic/download_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadsPage extends ConsumerWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DownloadState state = ref.watch(downloadControllerProvider);
    final List<DownloadTask> activeTasks = state.tasks.values
        .where((DownloadTask task) => task.isActive)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('离线下载'),
        actions: <Widget>[
          if (state.tracks.isNotEmpty)
            IconButton(
              tooltip: '清空下载',
              onPressed: () => _confirmClearAll(context, ref),
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: state.tracks.isEmpty && activeTasks.isEmpty
          ? const StatusView(
              icon: Icons.download_done_rounded,
              title: '还没有下载的歌曲',
              description: '在播放器菜单、收藏列表或分P/时间轴面板中可以下载歌曲',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: <Widget>[
                for (final DownloadTask task in activeTasks)
                  _DownloadingTile(task: task),
                for (int index = 0; index < state.tracks.length; index += 1)
                  _DownloadedTrackTile(
                    track: state.tracks[index],
                    onPlay: () => _playFrom(context, ref, state, index),
                    onDelete: () =>
                        _deleteTrack(context, ref, state.tracks[index]),
                  ),
              ],
            ),
    );
  }

  Future<void> _playFrom(
    BuildContext context,
    WidgetRef ref,
    DownloadState state,
    int index,
  ) async {
    final List<PlayableItem> items = state.tracks
        .map((DownloadedTrack track) => track.toPlayableItem())
        .toList(growable: false);
    await PlayerUtil.playQueueAndOpenPlayer(
      context,
      ref,
      items: items,
      startIndex: index,
      sourceLabel: '离线下载',
    );
  }

  Future<void> _deleteTrack(
    BuildContext context,
    WidgetRef ref,
    DownloadedTrack track,
  ) async {
    await ref.read(downloadControllerProvider.notifier).removeTrack(track);
    if (!context.mounted) {
      return;
    }
    ToastUtil.show('已删除下载');
  }

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('清空下载'),
          content: const Text('将删除全部已下载的歌曲文件，确认继续？'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('清空'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    await ref.read(downloadControllerProvider.notifier).clearAll();
    if (!context.mounted) {
      return;
    }
    ToastUtil.show('已清空下载');
  }
}

class _DownloadingTile extends StatelessWidget {
  const _DownloadingTile({required this.task});

  final DownloadTask task;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final double? progress = task.progress;
    final String label = switch (task.status) {
      DownloadTaskStatus.queued => '等待下载',
      DownloadTaskStatus.running =>
        progress == null
            ? '下载中'
            : '下载中 ${(progress * 100).toStringAsFixed(0)}%',
      DownloadTaskStatus.failed => '下载失败',
    };

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.downloading_rounded),
      title: Text(label, style: theme.textTheme.titleSmall),
      subtitle:
          task.status == DownloadTaskStatus.failed &&
              (task.errorMessage?.isNotEmpty ?? false)
          ? Text(
              task.errorMessage!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(top: 6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
    );
  }
}

class _DownloadedTrackTile extends StatelessWidget {
  const _DownloadedTrackTile({
    required this.track,
    required this.onPlay,
    required this.onDelete,
  });

  final DownloadedTrack track;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final List<String> subtitleParts = <String>[
      if (track.author.trim().isNotEmpty) track.author,
      if (track.qualityLabel?.trim().isNotEmpty ?? false) track.qualityLabel!,
      formatBytes(track.byteLength),
    ];

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CommonCachedImage(
        imageUrl: track.coverUrl,
        width: 48,
        height: 48,
        borderRadius: BorderRadius.circular(10),
        fallbackIcon: Icons.music_note_rounded,
        iconColor: colorScheme.primary,
      ),
      title: Text(
        track.title.isEmpty ? '未命名歌曲' : track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitleParts.join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: IconButton(
        tooltip: '删除下载',
        onPressed: onDelete,
        icon: const Icon(Icons.delete_outline_rounded, size: 20),
      ),
      onTap: onPlay,
    );
  }
}
