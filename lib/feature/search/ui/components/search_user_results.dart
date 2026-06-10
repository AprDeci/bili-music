import 'package:bilimusic/common/components/user_avatar.dart';
import 'package:bilimusic/feature/search/domain/search_user_item.dart';
import 'package:bilimusic/feature/search/ui/components/search_results_view.dart';
import 'package:flutter/material.dart';

class SearchUserResults extends StatelessWidget {
  const SearchUserResults({
    super.key,
    required this.submittedQuery,
    required this.results,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.errorMessage,
    required this.loadMoreErrorMessage,
    required this.onRetryLoadMore,
    required this.onTapItem,
  });

  final String? submittedQuery;
  final List<SearchUserItem> results;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final String? loadMoreErrorMessage;
  final VoidCallback onRetryLoadMore;
  final ValueChanged<SearchUserItem> onTapItem;

  @override
  Widget build(BuildContext context) {
    final bool hasQuery = submittedQuery != null && submittedQuery!.isNotEmpty;

    if (!hasQuery) {
      return _SearchUserStatusSliver(
        icon: Icons.person_search_rounded,
        iconColor: Theme.of(context).colorScheme.primary,
        title: '输入关键词搜索 UP 主',
      );
    }

    if (isLoading) {
      return _SearchUserLoadingSliver(title: '正在搜索 "$submittedQuery"');
    }

    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return _SearchUserErrorSliver(onRetry: onRetryLoadMore);
    }

    if (results.isEmpty) {
      return const _SearchUserStatusSliver(
        icon: Icons.person_off_rounded,
        title: '没有找到相关 UP 主',
        description: '试试更换关键词，或者确认当前登录态和 Cookie 是否可用。',
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.builder(
        itemCount: results.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == results.length) {
            return SearchResultFooter(
              isLoadingMore: isLoadingMore,
              hasMore: hasMore,
              errorMessage: loadMoreErrorMessage,
              onRetry: onRetryLoadMore,
            );
          }

          return _SearchUserTile(item: results[index], onTap: onTapItem);
        },
      ),
    );
  }
}

class _SearchUserTile extends StatelessWidget {
  const _SearchUserTile({required this.item, required this.onTap});

  final SearchUserItem item;
  final ValueChanged<SearchUserItem> onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onTap(item),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: <Widget>[
              UserAvatar(
                avatarUrl: item.avatarUrl,
                officialType: item.officialType,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'LV·${item.level}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '粉丝 ${item.fansText}  ·  投稿 ${item.videoCountText}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (item.sign.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        item.sign,
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
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchUserLoadingSliver extends StatelessWidget {
  const _SearchUserLoadingSliver({required this.title});

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

class _SearchUserErrorSliver extends StatelessWidget {
  const _SearchUserErrorSliver({required this.onRetry});

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

class _SearchUserStatusSliver extends StatelessWidget {
  const _SearchUserStatusSliver({
    required this.icon,
    required this.title,
    this.description,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? description;
  final Color? iconColor;

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
                icon,
                size: 30,
                color: iconColor ?? colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
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
