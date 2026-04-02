import 'package:bilimusic/common/components/cachedImage.dart';
import 'package:bilimusic/feature/comment/domain/comment_item.dart';
import 'package:flutter/material.dart';

class CommentCard extends StatelessWidget {
  const CommentCard({
    super.key,
    required this.item,
    this.onOpenReplies,
    this.showReplyPreview = false,
    this.showReplyEntry = false,
    this.showTopBadge = true,
    this.showHiddenBadge = true,
  });

  final CommentItem item;
  final VoidCallback? onOpenReplies;
  final bool showReplyPreview;
  final bool showReplyEntry;
  final bool showTopBadge;
  final bool showHiddenBadge;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipOval(
              child: CommonCachedImage(
                imageUrl: item.memberAvatarUrl,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                fallbackIcon: Icons.person_outline_rounded,
                iconColor: colorScheme.onSurfaceVariant,
                iconSize: 18,
                backgroundColor: colorScheme.surfaceContainerHigh,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          item.memberName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (showTopBadge && item.isTop)
                        _CommentBadge(label: '置顶', color: colorScheme.primary),
                      if (showHiddenBadge && item.isHidden)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: _CommentBadge(
                            label: '隐藏',
                            color: colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.message.isEmpty ? '该评论没有文本内容' : item.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: <Widget>[
                      _CommentMetaText(text: _formatDateTime(item.publishedAt)),
                      _CommentMetaText(text: '点赞 ${item.likeCount}'),
                      _CommentMetaText(text: '回复 ${item.replyCount}'),
                      if (item.isLiked)
                        _CommentMetaText(text: '已点赞', highlight: true),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showReplyPreview && item.replies.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: colorScheme.surfaceContainerLow),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: item.replies.take(2).map((CommentItem reply) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                      children: <InlineSpan>[
                        TextSpan(
                          text: '${reply.memberName}: ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: reply.message.length > 20
                              ? '${reply.message.substring(0, 20)}...'
                              : reply.message,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        if (showReplyEntry && item.replyCount > 0) ...<Widget>[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onOpenReplies,
            behavior: HitTestBehavior.opaque,
            child: Text(
              '查看全部 ${item.replyCount} 条回复',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDateTime(DateTime value) {
    final String year = value.year.toString().padLeft(4, '0');
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    final String hour = value.hour.toString().padLeft(2, '0');
    final String minute = value.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }
}

class _CommentBadge extends StatelessWidget {
  const _CommentBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CommentMetaText extends StatelessWidget {
  const _CommentMetaText({required this.text, this.highlight = false});

  final String text;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        color: highlight ? colorScheme.primary : colorScheme.onSurfaceVariant,
        fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
      ),
    );
  }
}
