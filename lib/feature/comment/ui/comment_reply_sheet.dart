import 'package:bilimusic/feature/comment/domain/comment_item.dart';
import 'package:bilimusic/feature/comment/domain/comment_reply_state.dart';
import 'package:bilimusic/feature/comment/domain/comment_target.dart';
import 'package:bilimusic/feature/comment/logic/comment_reply_controller.dart';
import 'package:bilimusic/feature/comment/ui/components/comment_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showCommentReplySheet({
  required BuildContext context,
  required CommentTarget target,
  required CommentItem rootItem,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (BuildContext context) {
      return SafeArea(
        child: _CommentReplySheet(
          args: CommentReplySheetArgs(target: target, rootItem: rootItem),
        ),
      );
    },
  );
}

class _CommentReplySheet extends ConsumerStatefulWidget {
  const _CommentReplySheet({required this.args});

  final CommentReplySheetArgs args;

  @override
  ConsumerState<_CommentReplySheet> createState() => _CommentReplySheetState();
}

class _CommentReplySheetState extends ConsumerState<_CommentReplySheet> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(commentReplyControllerProvider(widget.args).notifier)
          .loadInitial();
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
    if (_scrollController.position.extentAfter <= 220) {
      ref
          .read(commentReplyControllerProvider(widget.args).notifier)
          .loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final CommentReplyState state = ref.watch(
      commentReplyControllerProvider(widget.args),
    );
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.94,
      builder: (BuildContext context, ScrollController dragController) {
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '回复',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${state.totalCount} 条回复',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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
                  CommentCard(
                    item: state.rootItem,
                    showReplyPreview: false,
                    showReplyEntry: false,
                    showTopBadge: false,
                  ),
                  const SizedBox(height: 20),
                  Divider(
                    height: 1,
                    thickness: 0.3,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 20),
                  if (state.isLoading && state.items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.errorMessage != null && state.items.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(state.errorMessage!),
                      ),
                    )
                  else ...<Widget>[
                    ...state.items.map(
                      (CommentItem item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CommentCard(
                          item: item,
                          showReplyPreview: false,
                          showReplyEntry: false,
                          showTopBadge: false,
                          showHiddenBadge: false,
                        ),
                      ),
                    ),
                    if (state.loadMoreErrorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          state.loadMoreErrorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                    if (state.isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (!state.isLoadingMore && state.items.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Center(
                          child: Text(
                            state.hasMore ? '继续上滑加载更多' : '没有更多回复了',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
