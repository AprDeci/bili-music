import 'package:bilimusic/common/components/cachedImage.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecentPlaybackSection extends ConsumerWidget {
  const RecentPlaybackSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final List<RecentPlaybackEntry> items = ref.watch(
      recentPlaybackControllerProvider,
    );

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '最近播放',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
              fontSize: 18,
              letterSpacing: -1.3,
              height: 1,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 156,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(width: 12);
              },
              itemBuilder: (BuildContext context, int index) {
                final RecentPlaybackEntry item = items[index];

                return _RecentPlaybackTile(
                  item: item,
                  onTap: () async {
                    await PlayerUtil.playItemAndOpenPlayer(
                      context,
                      ref,
                      item: item.toPlayableItem(),
                      sourceLabel: '最近播放',
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentPlaybackTile extends StatelessWidget {
  const _RecentPlaybackTile({required this.item, required this.onTap});

  final RecentPlaybackEntry item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return SizedBox(
      width: 108,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 108,
                  height: 108,
                  child: CommonCachedImage(
                    imageUrl: item.coverUrl,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.music_note_rounded,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
