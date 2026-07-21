import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/feature/favorites/domain/favorited_season.dart';
import 'package:bilimusic/feature/favorites/logic/favorited_season_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FavoritedSeasonsList extends ConsumerWidget {
  const FavoritedSeasonsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<FavoritedSeason> seasons = ref.watch(
      favoritedSeasonControllerProvider,
    );
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    if (seasons.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.bookmarks_outlined,
                color: colorScheme.primary,
                size: 40,
              ),
              const SizedBox(height: 16),
              Text(
                '还没有收藏合集',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      itemCount: seasons.length + 1,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        if (index == seasons.length) {
          return const BottomPageSpacer.overlay();
        }
        final FavoritedSeason season = seasons[index];
        return Material(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () =>
                context.push('/up/${season.mid}/collection/${season.seasonId}'),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CommonCachedImage(
                    imageUrl: season.coverUrl,
                    width: 96,
                    height: 64,
                    borderRadius: BorderRadius.circular(6),
                    fallbackIcon: Icons.queue_music_rounded,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 64,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            season.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '共 ${season.total} 个视频',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (season.description != null) ...<Widget>[
                            const SizedBox(height: 4),
                            Text(
                              season.description!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: '取消收藏',
                    onPressed: () => ref
                        .read(favoritedSeasonControllerProvider.notifier)
                        .remove(season.seasonId),
                    icon: const Icon(Icons.bookmark_remove_outlined),
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
