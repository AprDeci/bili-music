import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/feature/comment/domain/comment_item.dart';
import 'package:bilimusic/feature/comment/domain/comment_sort.dart';
import 'package:bilimusic/feature/comment/domain/comment_state.dart';
import 'package:bilimusic/feature/comment/domain/comment_target.dart';
import 'package:bilimusic/feature/comment/logic/comment_controller.dart';
import 'package:bilimusic/feature/comment/ui/components/comment_card.dart';
import 'package:bilimusic/feature/comment/ui/comment_reply_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommentPage extends ConsumerStatefulWidget {
  const CommentPage({super.key, required this.target});

  final CommentTarget target;

  @override
  ConsumerState<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends ConsumerState<CommentPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(commentControllerProvider(widget.target).notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    if (_scrollController.position.extentAfter <= 240) {
      ref
          .read(commentControllerProvider(widget.target).notifier)
          .loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final CommentState state = ref.watch(
      commentControllerProvider(widget.target),
    );
    final CommentController controller = ref.read(
      commentControllerProvider(widget.target).notifier,
    );
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('评论')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: <Widget>[
              _CommentHeader(target: widget.target),
              const SizedBox(height: 36),
              if (state.isLoading &&
                  state.items.isEmpty &&
                  state.hotItems.isEmpty &&
                  state.topItem == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.errorMessage != null &&
                  state.items.isEmpty &&
                  state.hotItems.isEmpty &&
                  state.topItem == null)
                _CommentErrorCard(
                  message: state.errorMessage!,
                  onRetry: controller.loadInitial,
                )
              else ...<Widget>[
                if (state.topItem != null) ...<Widget>[
                  _CommentSectionTitle(title: '置顶评论'),
                  const SizedBox(height: 8),
                  CommentCard(item: state.topItem!),
                  const SizedBox(height: 16),
                ],
                if (state.hotItems.isNotEmpty) ...<Widget>[
                  _CommentSectionTitle(title: '热评'),
                  const SizedBox(height: 8),
                  ..._buildCommentCards(state.hotItems),
                  const SizedBox(height: 16),
                ],
                _CommentSectionHeader(
                  title: '全部评论',
                  state: state,
                  controller: controller,
                ),
                const SizedBox(height: 8),
                if (state.items.isEmpty)
                  _CommentEmptyCard(isReadOnly: state.isReadOnly)
                else
                  ..._buildCommentCards(state.items),
                if (state.loadMoreErrorMessage != null) ...<Widget>[
                  const SizedBox(height: 12),
                  _CommentLoadMoreError(
                    message: state.loadMoreErrorMessage!,
                    onRetry: controller.loadNextPage,
                  ),
                ],
                if (state.isLoadingMore) ...<Widget>[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
                if (!state.isLoadingMore && state.items.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      state.hasMore ? '继续上滑加载更多' : '没有更多评论了',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCommentCards(List<CommentItem> items) {
    return items
        .map(
          (CommentItem item) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.only(bottom: 12),
            child: CommentCard(
              item: item,
              showReplyPreview: true,
              showReplyEntry: true,
              onOpenReplies: item.replyCount > 0
                  ? () => showCommentReplySheet(
                      context: context,
                      target: widget.target,
                      rootItem: item,
                    )
                  : null,
            ),
          ),
        )
        .toList();
  }
}

class _CommentHeader extends StatelessWidget {
  const _CommentHeader({required this.target});

  final CommentTarget target;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String title = target.title?.trim().isNotEmpty == true
        ? target.title!.trim()
        : '评论';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 72,
            height: 72,
            color: colorScheme.surfaceContainerHigh,
            child: CommonCachedImage(
              imageUrl: target.coverUrl,
              fit: BoxFit.cover,
              fallbackIcon: Icons.music_video_outlined,
              iconColor: colorScheme.onSurfaceVariant,
              iconSize: 28,
              backgroundColor: colorScheme.surfaceContainerHigh,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
              if (target.bvid?.isNotEmpty == true) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  target.bvid!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentSectionHeader extends StatelessWidget {
  const _CommentSectionHeader({
    required this.title,
    required this.state,
    required this.controller,
  });

  final String title;
  final CommentState state;
  final CommentController controller;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final List<CommentSort> sorts = state.supportedSorts.isEmpty
        ? const <CommentSort>[CommentSort.time, CommentSort.like]
        : state.supportedSorts;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        PopupMenuButton<CommentSort>(
          tooltip: '切换排序',
          onSelected: controller.changeSort,
          itemBuilder: (BuildContext context) {
            return sorts.map((CommentSort sort) {
              return PopupMenuItem<CommentSort>(
                value: sort,
                child: Text(
                  sort.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: state.sort == sort
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              );
            }).toList();
          },
          child: Text(
            state.sort.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _CommentSectionTitle extends StatelessWidget {
  const _CommentSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}


class _CommentErrorCard extends StatelessWidget {
  const _CommentErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: <Widget>[
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}

class _CommentLoadMoreError extends StatelessWidget {
  const _CommentLoadMoreError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.errorContainer,
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(message)),
          TextButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}

class _CommentEmptyCard extends StatelessWidget {
  const _CommentEmptyCard({required this.isReadOnly});

  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isReadOnly ? '当前评论区为只读状态' : '还没有评论',
        textAlign: TextAlign.center,
      ),
    );
  }
}
