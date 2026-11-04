import 'package:bilimusic/common/bm_icons.dart';
import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_controller.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_progress_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _RecentAction { play, remove }

class DesktopRecentPlaybackPage extends ConsumerWidget {
  const DesktopRecentPlaybackPage({super.key});

  static const String _sourceLabel = '最近播放';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color primary = colorScheme.primary;
    final List<RecentPlaybackEntry> items = ref.watch(
      recentPlaybackControllerProvider,
    );
    final Map<String, int> progress = ref.watch(
      recentPlaybackProgressControllerProvider,
    );
    final List<PlayableItem> queueItems = items
        .map((RecentPlaybackEntry item) => item.toPlayableItem())
        .toList(growable: false);

    if (items.isEmpty) {
      return Scaffold(
        body: StatusView(
          icon: Icons.history_rounded,
          iconColor: primary,
          title: '还没有最近播放',
          description: '播放过的内容会按时间出现在这里。',
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
            child: Row(
              children: <Widget>[
                Text(
                  _sourceLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _clearAll(context, ref),
                  icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                  label: const Text('清空'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: items.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == items.length) {
                  return const BottomPageSpacer();
                }

                final RecentPlaybackEntry item = items[index];
                final int? progressMs = progress[item.stableId];
                final bool isEvenRow = index.isEven;
                return Material(
                  color: isEvenRow ? Colors.transparent : null,
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    tileColor: isEvenRow
                        ? Colors.transparent
                        : const Color.fromARGB(
                            255,
                            189,
                            189,
                            189,
                          ).withValues(alpha: 0.1),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 0,
                    ),
                    leading: CommonCachedImage(
                      imageUrl: item.coverUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(14),
                      fallbackIcon: Icons.music_note_rounded,
                      iconColor: primary,
                      backgroundColor: primary.withValues(alpha: 0.14),
                    ),
                    title: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      _buildSubtitle(item, progressMs),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    trailing: PopupMenuButton<_RecentAction>(
                      tooltip: '更多操作',
                      onSelected: (_RecentAction action) async {
                        switch (action) {
                          case _RecentAction.play:
                            await _playRecentItem(
                              context,
                              ref,
                              queueItems,
                              index,
                              progressMs: progressMs,
                            );
                          case _RecentAction.remove:
                            await _removeItem(ref, item);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          const <PopupMenuEntry<_RecentAction>>[
                            PopupMenuItem<_RecentAction>(
                              value: _RecentAction.play,
                              child: Text('播放'),
                            ),
                            PopupMenuItem<_RecentAction>(
                              value: _RecentAction.remove,
                              child: Text('删除'),
                            ),
                          ],
                      icon: const Icon(BmIcons.addPlaylist),
                    ),
                    onTap: () async {
                      await _playRecentItem(
                        context,
                        ref,
                        queueItems,
                        index,
                        progressMs: progressMs,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _buildSubtitle(RecentPlaybackEntry item, int? progressMs) {
    final List<String> segments = <String>[item.author];
    final String pageTitle = item.pageTitle?.trim() ?? '';

    if (pageTitle.isNotEmpty) {
      segments.add(pageTitle);
    }
    if (progressMs != null && progressMs > 0) {
      segments.add('已听 ${_formatPosition(progressMs)}');
    }

    return segments.join(' · ');
  }

  String _formatPosition(int positionMs) {
    final Duration position = Duration(milliseconds: positionMs);
    final int minutes = position.inMinutes;
    final int seconds = position.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _playRecentItem(
    BuildContext context,
    WidgetRef ref,
    List<PlayableItem> queueItems,
    int index, {
    int? progressMs,
  }) {
    return PlayerUtil.playQueueAndOpenPlayer(
      context,
      ref,
      items: queueItems,
      startIndex: index,
      sourceLabel: _sourceLabel,
      initialPosition: progressMs == null
          ? Duration.zero
          : Duration(milliseconds: progressMs),
    );
  }

  Future<void> _removeItem(WidgetRef ref, RecentPlaybackEntry item) async {
    await ref
        .read(recentPlaybackControllerProvider.notifier)
        .removeEntry(item.stableId);
    await ref
        .read(recentPlaybackProgressControllerProvider.notifier)
        .remove(item.stableId);
  }

  Future<void> _clearAll(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('清空最近播放？'),
        content: const Text('将删除全部最近播放记录与收听进度，且无法恢复。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('清空'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await ref.read(recentPlaybackControllerProvider.notifier).clear();
    await ref
        .read(recentPlaybackProgressControllerProvider.notifier)
        .clearAll();
  }
}
