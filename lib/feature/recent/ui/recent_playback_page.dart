import 'package:bilimusic/common/bm_icons.dart';
import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecentPlaybackPage extends ConsumerWidget {
  const RecentPlaybackPage({super.key});

  static const String _sourceLabel = '最近播放';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color primary = colorScheme.primary;
    final List<RecentPlaybackEntry> items = ref.watch(
      recentPlaybackControllerProvider,
    );
    final List<PlayableItem> queueItems = items
        .map((RecentPlaybackEntry item) => item.toPlayableItem())
        .toList(growable: false);

    return Scaffold(
      backgroundColor: colorScheme.surface.withValues(alpha: 0.4),
      appBar: AppBar(title: const Text(_sourceLabel)),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: Icon(
                        Icons.history_rounded,
                        color: primary,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '还没有最近播放',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '播放过的内容会按时间出现在这里。',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: items.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == items.length) {
                  return const BottomPageSpacer.tab();
                }

                final RecentPlaybackEntry item = items[index];
                final PlayableItem playableItem = item.toPlayableItem();
                return Material(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 0,
                    ),
                    leading: CommonCachedImage(
                      imageUrl: item.coverUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(8),
                      fallbackIcon: Icons.music_note_rounded,
                      iconColor: primary,
                      backgroundColor: primary.withValues(alpha: 0.14),
                    ),
                    title: Text(
                      playableItem.displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      playableItem.displaySubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    trailing: IconButton(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      tooltip: '播放',
                      onPressed: () async {
                        await _playRecentItem(context, ref, queueItems, index);
                      },
                      icon: const Icon(BmIcons.addPlaylist),
                    ),
                    onTap: () async {
                      await _playRecentItem(context, ref, queueItems, index);
                    },
                  ),
                );
              },
            ),
    );
  }

  Future<void> _playRecentItem(
    BuildContext context,
    WidgetRef ref,
    List<PlayableItem> queueItems,
    int index,
  ) {
    return PlayerUtil.playQueueAndOpenPlayer(
      context,
      ref,
      items: queueItems,
      startIndex: index,
      sourceLabel: _sourceLabel,
    );
  }
}
