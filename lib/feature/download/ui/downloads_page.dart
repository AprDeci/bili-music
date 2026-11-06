import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/selectable_auto_scroll_list_view.dart';
import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/util/format_util.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/screen_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/download/domain/download_task.dart';
import 'package:bilimusic/feature/download/domain/downloaded_track.dart';
import 'package:bilimusic/feature/download/logic/download_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadsPage extends ConsumerStatefulWidget {
  const DownloadsPage({super.key});

  @override
  ConsumerState<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends ConsumerState<DownloadsPage> {
  Set<String> _selectedIds = <String>{};
  bool _selectionMode = false;
  bool _deleting = false;

  void _setSelectionMode(bool enabled) {
    setState(() {
      _selectionMode = enabled;
      if (!enabled) {
        _selectedIds = <String>{};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final DownloadState state = ref.watch(downloadControllerProvider);
    ref.listen(downloadControllerProvider, (_, next) {
      final Set<String> availableIds = next.tracks
          .map((DownloadedTrack track) => track.contentId)
          .toSet();
      setState(() {
        _selectedIds = _selectedIds.intersection(availableIds);
        if (availableIds.isEmpty) {
          _selectionMode = false;
        }
      });
    });
    final bool desktop = ScreenUtil.shouldUseDesktopShell(context);
    final List<DownloadTask> activeTasks = state.tasks.values
        .where((DownloadTask task) => task.isActive)
        .toList(growable: false);

    return Scaffold(
      appBar: desktop ? null : AppBar(title: const Text('离线下载')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (desktop)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
              child: Text(
                '离线下载',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          if (state.tracks.isNotEmpty) _buildToolbar(state),
          Expanded(
            child: state.tracks.isEmpty && activeTasks.isEmpty
                ? const StatusView(
                    icon: Icons.download_done_rounded,
                    title: '还没有下载的歌曲',
                    description: '在播放器菜单、收藏列表或分P/时间轴面板中可以下载歌曲',
                  )
                : IgnorePointer(
                    ignoring: _deleting,
                    child:
                        SelectableAutoScrollListView<DownloadedTrack, String>(
                          items: state.tracks,
                          itemKeyOf: (DownloadedTrack track) => track.contentId,
                          selectedKeys: _selectedIds,
                          multiSelectEnabled: _selectionMode,
                          onMultiSelectModeChanged: _setSelectionMode,
                          onSelectionChanged: (Set<String> ids) =>
                              setState(() => _selectedIds = ids),
                          onItemTap: (DownloadedTrack track) => _playFrom(
                            state.tracks,
                            state.tracks.indexOf(track),
                          ),
                          padding: EdgeInsets.zero,
                          header: activeTasks.isEmpty
                              ? null
                              : Column(
                                  children: <Widget>[
                                    for (final DownloadTask task in activeTasks)
                                      _DownloadingTile(task: task),
                                  ],
                                ),
                          footer: const BottomPageSpacer(),
                          titleBuilder: (context, track, itemState) =>
                              Text(track.title),
                          itemBuilder: (context, track, itemState) =>
                              _buildTrackTile(track, itemState, desktop),
                          selectionItemBuilder: (context, track, itemState) =>
                              _buildTrackTile(track, itemState, desktop),
                        ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(DownloadState state) {
    final bool allSelected = _selectedIds.length == state.tracks.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              _selectionMode
                  ? '已选 ${_selectedIds.length} 项'
                  : '已下载 ${state.tracks.length} 首 · ${formatBytes(state.totalBytes)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          if (_selectionMode) ...<Widget>[
            TextButton(
              onPressed: _deleting
                  ? null
                  : () => setState(() {
                      _selectedIds = allSelected
                          ? <String>{}
                          : state.tracks
                                .map((DownloadedTrack track) => track.contentId)
                                .toSet();
                    }),
              child: Text(allSelected ? '取消全选' : '全选'),
            ),
            IconButton(
              tooltip: '删除所选下载',
              onPressed: _deleting || _selectedIds.isEmpty
                  ? null
                  : () => _confirmDelete(
                      state.tracks
                          .where(
                            (track) => _selectedIds.contains(track.contentId),
                          )
                          .toList(growable: false),
                    ),
              color: Theme.of(context).colorScheme.error,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
            IconButton(
              tooltip: '退出批量操作',
              onPressed: _deleting ? null : () => _setSelectionMode(false),
              icon: const Icon(Icons.close_rounded),
            ),
          ] else ...<Widget>[
            IconButton(
              tooltip: '多选',
              onPressed: _deleting ? null : () => _setSelectionMode(true),
              icon: const Icon(Icons.checklist_rounded),
            ),
            IconButton(
              tooltip: '清空下载',
              onPressed: _deleting
                  ? null
                  : () => _confirmDelete(state.tracks, clearAll: true),
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrackTile(
    DownloadedTrack track,
    SelectableListItemState<DownloadedTrack, String> state,
    bool desktop,
  ) {
    return _DownloadedTrackTile(
      track: track,
      desktop: desktop,
      selected: state.selected,
      selectionMode: state.multiSelectEnabled,
      index: state.index,
      onTap: state.handleTap,
      onLongPress: state.enterMultiSelectAndToggle,
      onToggle: state.toggleSelected,
    );
  }

  Future<void> _playFrom(List<DownloadedTrack> tracks, int index) async {
    final List<PlayableItem> items = tracks
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

  Future<void> _confirmDelete(
    List<DownloadedTrack> tracks, {
    bool clearAll = false,
  }) async {
    if (_deleting || tracks.isEmpty) {
      return;
    }
    setState(() => _deleting = true);
    try {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(clearAll ? '清空下载' : '删除下载'),
          content: Text(
            clearAll
                ? '将删除全部已下载的歌曲文件，确认继续？'
                : '将删除所选的 ${tracks.length} 首歌曲文件，确认继续？',
          ),
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
              child: Text(clearAll ? '清空' : '删除'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) {
        return;
      }
      final DownloadController controller = ref.read(
        downloadControllerProvider.notifier,
      );
      for (final DownloadedTrack track in tracks) {
        await controller.removeTrack(track);
      }
      if (mounted) {
        _setSelectionMode(false);
        ToastUtil.show(clearAll ? '已清空下载' : '已删除 ${tracks.length} 首下载');
      }
    } finally {
      if (mounted) {
        setState(() => _deleting = false);
      }
    }
  }
}

class _DownloadingTile extends StatelessWidget {
  const _DownloadingTile({required this.task});

  final DownloadTask task;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      leading: const SizedBox.square(
        dimension: 44,
        child: Icon(Icons.downloading_rounded),
      ),
      title: Text(label, style: theme.textTheme.titleSmall),
      subtitle:
          task.status == DownloadTaskStatus.failed &&
              (task.errorMessage?.isNotEmpty ?? false)
          ? Text(
              task.errorMessage!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
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
    required this.desktop,
    required this.selected,
    required this.selectionMode,
    required this.index,
    required this.onTap,
    required this.onLongPress,
    required this.onToggle,
  });

  final DownloadedTrack track;
  final bool desktop;
  final bool selected;
  final bool selectionMode;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final List<String> subtitleParts = <String>[
      if (track.author.trim().isNotEmpty) track.author,
      if (track.qualityLabel?.trim().isNotEmpty ?? false) track.qualityLabel!,
      formatBytes(track.byteLength),
    ];

    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        shape: desktop
            ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
            : null,
        tileColor: desktop && index.isOdd
            ? Color.alphaBlend(
                const Color(0xFFBDBDBD).withValues(alpha: 0.1),
                colors.surface,
              )
            : null,
        leading: CommonCachedImage(
          imageUrl: track.coverUrl,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(desktop ? 14 : 8),
          fallbackIcon: Icons.music_note_rounded,
          iconColor: colors.primary,
          backgroundColor: colors.primary.withValues(alpha: 0.14),
        ),
        title: Text(
          track.title.isEmpty ? '未命名歌曲' : track.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: desktop ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitleParts.join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        trailing: selectionMode
            ? Checkbox(
                value: selected,
                semanticLabel: '选择 ${track.title}',
                onChanged: (_) => onToggle(),
              )
            : null,
        selected: selected,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
