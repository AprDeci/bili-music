import 'package:bilimusic/common/components/cachedImage.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/search/domain/search_state.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';
import 'package:bilimusic/feature/search/logic/search_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _scrollController = ScrollController()..addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    if (_scrollController.position.extentAfter <= 200) {
      ref.read(searchPageControllerProvider.notifier).loadNextPage();
    }
  }

  Future<void> _submitSearch(
    SearchPageController controller, [
    String? value,
  ]) async {
    await controller.submitSearch(value);
    if (!mounted || !_scrollController.hasClients) {
      return;
    }

    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _selectKeyword(
    SearchPageController controller,
    String value,
  ) async {
    await _submitSearch(controller, value);
  }

  @override
  Widget build(BuildContext context) {
    final SearchState state = ref.watch(searchPageControllerProvider);
    final SearchPageController controller = ref.read(
      searchPageControllerProvider.notifier,
    );
    final ThemeData theme = Theme.of(context);

    if (_controller.text != state.query) {
      _controller.value = TextEditingValue(
        text: state.query,
        selection: TextSelection.collapsed(offset: state.query.length),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFD8E2EC)),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x120F172A),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.search,
                        onChanged: controller.updateQuery,
                        onSubmitted: (_) => _submitSearch(controller),
                        decoration: InputDecoration(
                          hintText: '搜索歌曲、歌手或视频',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF7D8C9B),
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF5B6F82),
                            size: 20,
                          ),
                          suffixIcon: state.query.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _controller.clear();
                                    controller.clearQuery();
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: <Widget>[
                  if (state.recentKeywords.isNotEmpty &&
                      state.submittedQuery == null) ...<Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          '搜索历史',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: controller.clearHistory,
                          child: const Text('清空'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: state.recentKeywords.map((String item) {
                        return ActionChip(
                          label: Text(item),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFD8E2EC)),
                          labelStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                          ),
                          onPressed: () {
                            _selectKeyword(controller, item);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (state.submittedQuery != null &&
                      state.submittedQuery!.isNotEmpty)
                    Row(
                      children: <Widget>[
                        Text(
                          '搜索结果',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${state.results.length} 条',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  _SearchResultSection(
                    submittedQuery: state.submittedQuery,
                    results: state.results,
                    isLoading: state.isLoading,
                    isLoadingMore: state.isLoadingMore,
                    hasMore: state.hasMore,
                    errorMessage: state.errorMessage,
                    loadMoreErrorMessage: state.loadMoreErrorMessage,
                    onRetryLoadMore: controller.loadNextPage,
                    onPlayItem: (SearchResultItem item) async {
                      await PlayerUtil.playItemAndOpenPlayer(
                        context,
                        ref,
                        item: item.toPlayableItem(),
                        sourceLabel: '搜索结果',
                      );
                    },
                    onPlayNext: (SearchResultItem item) async {
                      final PlayableItem resolvedItem = await ref
                          .read(biliPlayerRepositoryProvider)
                          .resolvePreferredPart(
                            item.toPlayableItem(),
                            preferredPage: 1,
                          );
                      await ref
                          .read(playerControllerProvider.notifier)
                          .playNext(resolvedItem);
                    },
                    onEnqueue: (SearchResultItem item) async {
                      final PlayableItem resolvedItem = await ref
                          .read(biliPlayerRepositoryProvider)
                          .resolvePreferredPart(
                            item.toPlayableItem(),
                            preferredPage: 1,
                          );
                      await ref.read(playerControllerProvider.notifier).enqueue(
                        <PlayableItem>[resolvedItem],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultSection extends StatelessWidget {
  const _SearchResultSection({
    required this.submittedQuery,
    required this.results,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.errorMessage,
    required this.loadMoreErrorMessage,
    required this.onRetryLoadMore,
    required this.onPlayItem,
    required this.onPlayNext,
    required this.onEnqueue,
  });

  final String? submittedQuery;
  final List<SearchResultItem> results;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final String? loadMoreErrorMessage;
  final VoidCallback onRetryLoadMore;
  final Future<void> Function(SearchResultItem item) onPlayItem;
  final Future<void> Function(SearchResultItem item) onPlayNext;
  final Future<void> Function(SearchResultItem item) onEnqueue;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool hasQuery = submittedQuery != null && submittedQuery!.isNotEmpty;

    if (!hasQuery) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
        child: Column(
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              child: Icon(
                Icons.search_rounded,
                color: colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '输入关键词开始搜索',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    }

    if (isLoading) {
      return Container(
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
              '正在搜索 "$submittedQuery"',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
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
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    if (results.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          children: <Widget>[
            Icon(
              Icons.search_off_rounded,
              size: 30,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              '没有找到相关视频',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '试试更换关键词，或者确认当前登录态和 Cookie 是否可用。',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final favoritesState = ref.watch(favoritesControllerProvider);

        return Column(
          children: <Widget>[
            ...results.map((SearchResultItem item) {
              final playableItem = item.toPlayableItem();
              final bool isFavorite = favoritesState.isLikedVideoPage(
                aid: item.aid,
                bvid: item.bvid,
                page: 1,
              );

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onPlayItem(item),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Container(
                              width: 82,
                              height: 82,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: CommonCachedImage(
                                imageUrl: item.coverUrl,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(8),
                                fallbackIcon: Icons.music_video_rounded,
                                iconColor: colorScheme.primary,
                                backgroundColor: Colors.transparent,
                                iconSize: 30,
                              ),
                            ),
                            Positioned(
                              left: 8,
                              bottom: 8,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: colorScheme.surface.withValues(
                                    alpha: 0.92,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.onSurface,
                                            height: 1.3,
                                            fontSize: 14,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _ResultTag(label: item.tagText),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${item.author} · ${item.publishTimeText}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 8,
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '播放 ${item.playCountText}  ·  弹幕 ${item.danmakuCountText}  ·  ${item.duration}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 8,
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            InkResponse(
                              onTap: () async {
                                final ScaffoldMessengerState messenger =
                                    ScaffoldMessenger.of(context);
                                try {
                                  final resolvedItem = await ref
                                      .read(biliPlayerRepositoryProvider)
                                      .resolvePreferredPart(
                                        playableItem,
                                        preferredPage: 1,
                                      );
                                  final bool liked = await ref
                                      .read(
                                        favoritesControllerProvider.notifier,
                                      )
                                      .toggleLiked(resolvedItem);
                                  if (context.mounted) {
                                    messenger
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            liked ? '已收藏 P1' : '已从“我喜欢”移除',
                                          ),
                                        ),
                                      );
                                  }
                                } on Object catch (error) {
                                  if (context.mounted) {
                                    messenger
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        SnackBar(content: Text('收藏失败: $error')),
                                      );
                                  }
                                }
                              },
                              radius: 18,
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isFavorite
                                      ? colorScheme.secondaryContainer
                                      : colorScheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: colorScheme.secondary,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            PopupMenuButton<_SearchQueueAction>(
                              tooltip: '队列操作',
                              padding: EdgeInsets.zero,
                              onSelected: (_SearchQueueAction action) async {
                                final ScaffoldMessengerState messenger =
                                    ScaffoldMessenger.of(context);
                                try {
                                  switch (action) {
                                    case _SearchQueueAction.playNext:
                                      await onPlayNext(item);
                                      if (context.mounted) {
                                        messenger
                                          ..hideCurrentSnackBar()
                                          ..showSnackBar(
                                            const SnackBar(
                                              content: Text('已加入下一首'),
                                            ),
                                          );
                                      }
                                    case _SearchQueueAction.enqueue:
                                      await onEnqueue(item);
                                      if (context.mounted) {
                                        messenger
                                          ..hideCurrentSnackBar()
                                          ..showSnackBar(
                                            const SnackBar(
                                              content: Text('已加入播放队列'),
                                            ),
                                          );
                                      }
                                  }
                                } on Object catch (error) {
                                  if (context.mounted) {
                                    messenger
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        SnackBar(content: Text('操作失败: $error')),
                                      );
                                  }
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  const <PopupMenuEntry<_SearchQueueAction>>[
                                    PopupMenuItem<_SearchQueueAction>(
                                      value: _SearchQueueAction.playNext,
                                      child: ListTile(
                                        leading: Icon(Icons.skip_next_rounded),
                                        title: Text('下一首播放'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    PopupMenuItem<_SearchQueueAction>(
                                      value: _SearchQueueAction.enqueue,
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.queue_music_rounded,
                                        ),
                                        title: Text('加入队列'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.more_horiz_rounded,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            _SearchResultFooter(
              isLoadingMore: isLoadingMore,
              hasMore: hasMore,
              errorMessage: loadMoreErrorMessage,
              onRetry: onRetryLoadMore,
            ),
          ],
        );
      },
    );
  }
}

enum _SearchQueueAction { playNext, enqueue }

class _SearchResultFooter extends StatelessWidget {
  const _SearchResultFooter({
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

class _ResultTag extends StatelessWidget {
  const _ResultTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 8,
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
