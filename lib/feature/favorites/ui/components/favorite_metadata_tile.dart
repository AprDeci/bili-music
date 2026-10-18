import 'package:bilimusic/common/bm_icons.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/tag.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/logic/favorite_entry_metadata.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/statistics/logic/statistics_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

// 元信息视图的行：与视频视图共用同一套 ListTile 结构（同尺寸、同内边距），
// 只替换封面/标题/副标题的内容，保证两种视图布局一致。
class FavoriteMetadataTile extends ConsumerWidget {
  const FavoriteMetadataTile({
    super.key,
    required this.entry,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
    required this.onPlay,
    required this.onMore,
    this.coverRadius = 8,
    this.titleWeight = FontWeight.w500,
  });

  final FavoriteEntry entry;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onPlay;
  final VoidCallback onMore;
  final double coverRadius;
  final FontWeight titleWeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AsyncValue<Metadata?> metadataAsync = ref.watch(
      favoriteEntryMetadataProvider(entry.contentId),
    );
    final Metadata? metadata = switch (metadataAsync) {
      AsyncData<Metadata?>(:final value) => value,
      _ => null,
    };
    final bool resolved = metadata?.hasContent ?? false;

    final String metadataCover = metadata?.albumArtUrl?.trim() ?? '';
    final String coverUrl = resolved && metadataCover.isNotEmpty
        ? metadataCover
        : entry.coverUrl;
    final String title = resolved
        ? _firstNonEmpty(metadata?.title, entry.title)
        : entry.title;
    final String subtitle = resolved
        ? _firstNonEmpty(metadata?.artist, entry.author)
        : entry.author;
    final int playCount =
        ref.watch(statisticsTrackerProvider).read(entry.itemId)?.playCount ?? 0;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        leading: CommonCachedImage(
          imageUrl: coverUrl,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(coverRadius),
          fallbackIcon: Icons.music_note_rounded,
          iconColor: colorScheme.primary,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.14),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: titleWeight),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
            if (playCount > 0) ...<Widget>[
              const SizedBox(width: 6),
              Tag(
                text: '$playCount',
                padding: const EdgeInsets.symmetric(horizontal: 4),
                color: Colors.grey.withValues(alpha: 0.2),
                textColor: const Color.fromARGB(255, 134, 134, 134),
                size: TagSize.small,
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedHeadphones,
                  size: 12,
                ),
              ),
            ],
            if (!resolved) ...<Widget>[
              const SizedBox(width: 6),
              Tag(
                text: '未解析',
                padding: const EdgeInsets.symmetric(horizontal: 4),
                color: Colors.grey.withValues(alpha: 0.2),
                textColor: const Color.fromARGB(255, 134, 134, 134),
                size: TagSize.small,
              ),
            ],
          ],
        ),
        trailing: _buildTrailing(),
        selected: selected,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }

  Widget _buildTrailing() {
    return Row(
      spacing: 0,
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          tooltip: '播放',
          onPressed: onPlay,
          icon: const Icon(BmIcons.addPlaylist),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          tooltip: '更多',
          onPressed: onMore,
          icon: const Icon(Icons.more_vert_outlined),
        ),
      ],
    );
  }

  String _firstNonEmpty(String? value, String fallback) {
    final String trimmed = value?.trim() ?? '';
    return trimmed.isNotEmpty ? trimmed : fallback;
  }
}
