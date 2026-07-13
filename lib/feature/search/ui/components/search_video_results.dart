import 'package:bilimusic/common/components/video_card.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:bilimusic/feature/search/domain/search_sort.dart';
import 'package:bilimusic/feature/search/ui/components/search_results_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchVideoResults extends StatelessWidget {
  const SearchVideoResults({
    super.key,
    required this.submittedQuery,
    required this.results,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.errorMessage,
    required this.loadMoreErrorMessage,
    required this.sort,
    required this.onRetryLoadMore,
    required this.onPlayItem,
    required this.onPlayNext,
    required this.onEnqueue,
    required this.onChangeSort,
  });

  final String? submittedQuery;
  final List<SearchResultItem> results;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final String? loadMoreErrorMessage;
  final SearchSort sort;
  final VoidCallback onRetryLoadMore;
  final Future<void> Function(SearchResultItem item) onPlayItem;
  final Future<void> Function(SearchResultItem item) onPlayNext;
  final Future<void> Function(SearchResultItem item) onEnqueue;
  final Future<void> Function(SearchSort sort) onChangeSort;

  @override
  Widget build(BuildContext context) {
    final bool hasQuery = submittedQuery != null && submittedQuery!.isNotEmpty;

    if (!hasQuery) {
      return _SearchStatusSliver(
        icon: Icons.search_rounded,
        iconColor: Theme.of(context).colorScheme.primary,
        title: '输入关键词开始搜索',
        iconSize: 28,
        iconBoxSize: 56,
      );
    }

    if (isLoading) {
      return _SearchLoadingSliver(title: '正在搜索 "$submittedQuery"');
    }

    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return _SearchErrorSliver(onRetry: onRetryLoadMore);
    }

    if (results.isEmpty) {
      return const _SearchStatusSliver(
        icon: Icons.search_off_rounded,
        title: '没有找到相关视频',
        description: '试试更换关键词，或者确认当前登录态和 Cookie 是否可用。',
      );
    }

    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final favoritesState = ref.watch(favoritesControllerProvider);

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.builder(
            itemCount: results.length + 2,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return _SearchSortChips(sort: sort, onChangeSort: onChangeSort);
              }

              if (index == results.length + 1) {
                return SearchResultFooter(
                  isLoadingMore: isLoadingMore,
                  hasMore: hasMore,
                  errorMessage: loadMoreErrorMessage,
                  onRetry: onRetryLoadMore,
                );
              }

              final SearchResultItem item = results[index - 1];
              final PlayableItem playableItem = item.toPlayableItem();
              final bool isFavorite = favoritesState.isLikedVideoPage(
                aid: item.aid,
                bvid: item.bvid,
                page: 1,
              );

              return VideoCard(
                data: VideoCardData(
                  title: item.title,
                  coverUrl: item.coverUrl,
                  primaryMeta: '${item.author} · ${item.publishTimeText}',
                  secondaryMeta:
                      '播放 ${item.playCountText}  ·  弹幕 ${item.danmakuCountText}  ·  ${item.duration}',
                  tag: item.tagText,
                ),
                onTap: () => onPlayItem(item),
                isFavorite: isFavorite,
                playableActions: VideoCardPlayableActions(
                  playableItem: playableItem,
                  isFavorite: isFavorite,
                ),
                onFavoriteToggle: () async {
                  try {
                    final PlayableItem resolvedItem = await ref
                        .read(biliPlayerRepositoryProvider)
                        .resolvePreferredPart(playableItem, preferredPage: 1);
                    final bool liked = await ref
                        .read(favoritesControllerProvider.notifier)
                        .toggleLiked(resolvedItem);
                    if (context.mounted) {
                      ToastUtil.show(liked ? '已收藏 P1' : '已从“我喜欢”移除');
                    }
                  } on Object catch (error) {
                    if (context.mounted) {
                      ToastUtil.show('收藏失败: $error');
                    }
                  }
                },
                onPlayNext: () async {
                  try {
                    await onPlayNext(item);
                    if (context.mounted) {
                      ToastUtil.show('已加入下一首');
                    }
                  } on Object catch (error) {
                    if (context.mounted) {
                      ToastUtil.show('操作失败: $error');
                    }
                  }
                },
                onEnqueue: () async {
                  try {
                    await onEnqueue(item);
                    if (context.mounted) {
                      ToastUtil.show('已加入播放队列');
                    }
                  } on Object catch (error) {
                    if (context.mounted) {
                      ToastUtil.show('操作失败: $error');
                    }
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _SearchSortChips extends StatelessWidget {
  const _SearchSortChips({required this.sort, required this.onChangeSort});

  final SearchSort sort;
  final Future<void> Function(SearchSort sort) onChangeSort;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: SearchSort.values.map((SearchSort item) {
            final bool selected = item == sort;
            return Padding(
              padding: const EdgeInsets.only(right: 18),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: selected ? null : () => onChangeSort(item),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    item.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SearchLoadingSliver extends StatelessWidget {
  const _SearchLoadingSliver({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            children: <Widget>[
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.6),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchErrorSliver extends StatelessWidget {
  const _SearchErrorSliver({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            children: <Widget>[
              Icon(
                Icons.error_outline_rounded,
                size: 30,
                color: colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                '搜索失败',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(onPressed: onRetry, child: const Text('点击重试')),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchStatusSliver extends StatelessWidget {
  const _SearchStatusSliver({
    required this.icon,
    required this.title,
    this.description,
    this.iconColor,
    this.iconSize = 30,
    this.iconBoxSize,
  });

  final IconData icon;
  final String title;
  final String? description;
  final Color? iconColor;
  final double iconSize;
  final double? iconBoxSize;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Widget iconWidget = Icon(
      icon,
      size: iconSize,
      color: iconColor ?? colorScheme.onSurfaceVariant,
    );

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
          child: Column(
            children: <Widget>[
              if (iconBoxSize == null)
                iconWidget
              else
                SizedBox(
                  width: iconBoxSize,
                  height: iconBoxSize,
                  child: iconWidget,
                ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (description != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
