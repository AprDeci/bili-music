import 'package:bilimusic/common/bm_icons.dart';
import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final List<PlayableItem> queueItems = items
        .map((RecentPlaybackEntry item) => item.toPlayableItem())
        .toList(growable: false);

    return Scaffold(
      body: items.isEmpty
          ? StatusView(
              icon: Icons.history_rounded,
              iconColor: primary,
              title: '还没有最近播放',
              description: '播放过的内容会按时间出现在这里。',
            )
          : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: items.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == items.length) {
                  return const BottomPageSpacer.overlay();
                }

                final RecentPlaybackEntry item = items[index];
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
                      _buildSubtitle(item),
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

  String _buildSubtitle(RecentPlaybackEntry item) {
    final List<String> segments = <String>[item.author];
    final String pageTitle = item.pageTitle?.trim() ?? '';

    if (pageTitle.isNotEmpty) {
      segments.add(pageTitle);
    }

    return segments.join(' · ');
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
