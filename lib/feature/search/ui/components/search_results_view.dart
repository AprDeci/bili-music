import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:bilimusic/feature/search/domain/search_sort.dart';
import 'package:bilimusic/feature/search/domain/search_state.dart';
import 'package:bilimusic/feature/search/domain/search_type.dart';
import 'package:bilimusic/feature/search/domain/search_user_item.dart';
import 'package:bilimusic/feature/search/ui/components/search_user_results.dart';
import 'package:bilimusic/feature/search/ui/components/search_video_results.dart';
import 'package:flutter/material.dart';

class SearchResultsView extends StatelessWidget {
  const SearchResultsView({
    super.key,
    required this.state,
    required this.tabController,
    required this.onLoadMore,
    required this.onChangeSort,
    required this.onPlayItem,
    required this.onPlayNext,
    required this.onEnqueue,
    required this.onTapUser,
  });

  final SearchState state;
  final TabController tabController;
  final VoidCallback onLoadMore;
  final Future<void> Function(SearchSort sort) onChangeSort;
  final Future<void> Function(SearchResultItem item) onPlayItem;
  final Future<void> Function(SearchResultItem item) onPlayNext;
  final Future<void> Function(SearchResultItem item) onEnqueue;
  final ValueChanged<SearchUserItem> onTapUser;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SearchTypeTabBar(controller: tabController),
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: <Widget>[
              _SearchTabScrollView(
                type: SearchType.video,
                activeType: state.type,
                onLoadMore: onLoadMore,
                sliver: SearchVideoResults(
                  submittedQuery: state.submittedQuery,
                  results: state.results,
                  isLoading: state.isLoadingFor(SearchType.video),
                  isLoadingMore: state.isLoadingMoreFor(SearchType.video),
                  hasMore: state.hasMoreFor(SearchType.video),
                  errorMessage: state.errorMessageFor(SearchType.video),
                  loadMoreErrorMessage: state.loadMoreErrorMessageFor(
                    SearchType.video,
                  ),
                  sort: state.sort,
                  onRetryLoadMore: onLoadMore,
                  onPlayItem: onPlayItem,
                  onPlayNext: onPlayNext,
                  onEnqueue: onEnqueue,
                  onChangeSort: onChangeSort,
                ),
              ),
              _SearchTabScrollView(
                type: SearchType.up,
                activeType: state.type,
                onLoadMore: onLoadMore,
                sliver: SearchUserResults(
                  submittedQuery: state.submittedQuery,
                  results: state.userResults,
                  isLoading: state.isLoadingFor(SearchType.up),
                  isLoadingMore: state.isLoadingMoreFor(SearchType.up),
                  hasMore: state.hasMoreFor(SearchType.up),
                  errorMessage: state.errorMessageFor(SearchType.up),
                  loadMoreErrorMessage: state.loadMoreErrorMessageFor(
                    SearchType.up,
                  ),
                  onRetryLoadMore: onLoadMore,
                  onTapItem: onTapUser,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SearchResultFooter extends StatelessWidget {
  const SearchResultFooter({
    super.key,
    required this.isLoadingMore,
    required this.hasMore,
    required this.errorMessage,
    required this.onRetry,
  });

  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    if (isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
            const SizedBox(width: 12),
            Text(
              '正在加载更多结果',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Center(
          child: TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              '加载更多失败，点击重试',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Center(
          child: Text(
            '已经到底了',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _SearchTypeTabBar extends StatelessWidget {
  const _SearchTypeTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return TabBar(
      controller: controller,
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      indicatorColor: colorScheme.primary,
      labelStyle: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      tabs: SearchType.values.map((SearchType item) {
        return Tab(height: 40, child: Text(item.label));
      }).toList(),
    );
  }
}

class _SearchTabScrollView extends StatefulWidget {
  const _SearchTabScrollView({
    required this.type,
    required this.activeType,
    required this.onLoadMore,
    required this.sliver,
  });

  final SearchType type;
  final SearchType activeType;
  final VoidCallback onLoadMore;
  final Widget sliver;

  @override
  State<_SearchTabScrollView> createState() => _SearchTabScrollViewState();
}

class _SearchTabScrollViewState extends State<_SearchTabScrollView> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (widget.activeType != widget.type || !_controller.hasClients) {
      return;
    }
    if (_controller.position.extentAfter <= 200) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _controller,
      slivers: <Widget>[
        widget.sliver,
        const SliverToBoxAdapter(child: BottomPageSpacer.overlay()),
      ],
    );
  }
}
