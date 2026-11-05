import 'package:bilimusic/common/bm_icons.dart';
import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/selectable_auto_scroll_list_view.dart';
import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecentPlaybackPage extends ConsumerStatefulWidget {
  const RecentPlaybackPage({super.key, this.desktop = false});

  final bool desktop;

  @override
  ConsumerState<RecentPlaybackPage> createState() => _RecentPlaybackPageState();
}

class _RecentPlaybackPageState extends ConsumerState<RecentPlaybackPage> {
  static const String _sourceLabel = '最近播放';
  Set<String> _selectedIds = <String>{};
  bool _selectionMode = false;
  bool _deleting = false;

  void _setSelectionMode(bool enabled) {
    setState(() {
      _selectionMode = enabled;
      _selectedIds = <String>{};
    });
  }

  Future<void> _deleteSelected(Set<String> selectedIds) async {
    if (_deleting || selectedIds.isEmpty) {
      return;
    }
    setState(() => _deleting = true);
    try {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('删除最近播放？'),
          content: Text('确定删除选中的 ${selectedIds.length} 条最近播放记录吗？此操作无法恢复。'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('删除'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) {
        return;
      }
      await ref
          .read(recentPlaybackControllerProvider.notifier)
          .removeEntries(selectedIds);
      if (mounted) {
        _setSelectionMode(false);
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('删除失败，请重试')));
      }
    } finally {
      if (mounted) {
        setState(() => _deleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final List<RecentPlaybackEntry> items = ref.watch(
      recentPlaybackControllerProvider,
    );
    final Set<String> itemIds = items.map((item) => item.stableId).toSet();
    final Set<String> selectedIds = _selectedIds.intersection(itemIds);
    final List<PlayableItem> queueItems = items
        .map((RecentPlaybackEntry item) => item.toPlayableItem())
        .toList(growable: false);

    Future<void> play(RecentPlaybackEntry item) {
      return PlayerUtil.playQueueAndOpenPlayer(
        context,
        ref,
        items: queueItems,
        startIndex: items.indexOf(item),
        sourceLabel: _sourceLabel,
      );
    }

    Widget cover(RecentPlaybackEntry item) => CommonCachedImage(
      imageUrl: item.coverUrl,
      width: 44,
      height: 44,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(widget.desktop ? 14 : 8),
      fallbackIcon: Icons.music_note_rounded,
      iconColor: colorScheme.primary,
      backgroundColor: colorScheme.primary.withValues(alpha: 0.14),
    );

    Widget title(RecentPlaybackEntry item) => Text(
      item.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: widget.desktop ? FontWeight.w700 : FontWeight.w500,
      ),
    );

    Widget subtitle(RecentPlaybackEntry item) => Text(
      <String>[
        item.author,
        if (item.pageTitle?.trim().isNotEmpty ?? false) item.pageTitle!.trim(),
      ].join(' · '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        height: 1.5,
      ),
    );

    return Scaffold(
      appBar: widget.desktop ? null : AppBar(title: const Text(_sourceLabel)),
      body: items.isEmpty
          ? StatusView(
              icon: Icons.history_rounded,
              iconColor: colorScheme.primary,
              title: '还没有最近播放',
              description: '播放过的内容会按时间出现在这里。',
            )
          : Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _selectionMode
                              ? '已选 ${selectedIds.length} 项'
                              : _sourceLabel,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (_selectionMode) ...<Widget>[
                        TextButton(
                          onPressed: _deleting
                              ? null
                              : () => setState(() {
                                  _selectedIds =
                                      selectedIds.length == itemIds.length
                                      ? <String>{}
                                      : itemIds;
                                }),
                          child: Text(
                            selectedIds.length == itemIds.length
                                ? '取消全选'
                                : '全选',
                          ),
                        ),
                        IconButton(
                          tooltip: '删除',
                          onPressed: _deleting || selectedIds.isEmpty
                              ? null
                              : () => _deleteSelected(selectedIds),
                          color: colorScheme.error,
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                        IconButton(
                          tooltip: '退出批量操作',
                          onPressed: _deleting
                              ? null
                              : () => _setSelectionMode(false),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ] else
                        TextButton.icon(
                          onPressed: () => _setSelectionMode(true),
                          icon: const Icon(Icons.checklist_rounded),
                          label: const Text('多选'),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: AbsorbPointer(
                    absorbing: _deleting,
                    child:
                        SelectableAutoScrollListView<
                          RecentPlaybackEntry,
                          String
                        >(
                          items: items,
                          itemKeyOf: (item) => item.stableId,
                          selectedKeys: selectedIds,
                          multiSelectEnabled: _selectionMode,
                          onMultiSelectModeChanged: _setSelectionMode,
                          onSelectionChanged: (ids) =>
                              setState(() => _selectedIds = ids),
                          onItemTap: play,
                          padding: EdgeInsets.zero,
                          footer: const BottomPageSpacer(),
                          checkboxControlAffinity:
                              ListTileControlAffinity.trailing,
                          titleBuilder: (context, item, state) => title(item),
                          subtitleBuilder: (context, item, state) =>
                              subtitle(item),
                          leadingBuilder: (context, item, state) => cover(item),
                          itemBuilder: (context, item, state) => Material(
                            color: Colors.transparent,
                            child: ListTile(
                              shape: widget.desktop
                                  ? RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    )
                                  : null,
                              tileColor: widget.desktop && state.index.isOdd
                                  ? const Color.fromARGB(
                                      255,
                                      189,
                                      189,
                                      189,
                                    ).withValues(alpha: 0.1)
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              leading: cover(item),
                              title: title(item),
                              subtitle: subtitle(item),
                              trailing: IconButton(
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                tooltip: '播放',
                                onPressed: () => play(item),
                                icon: const Icon(BmIcons.addPlaylist),
                              ),
                              onTap: state.handleTap,
                              onLongPress: state.enterMultiSelectAndToggle,
                            ),
                          ),
                        ),
                  ),
                ),
              ],
            ),
    );
  }
}
