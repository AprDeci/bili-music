import 'dart:async';

import 'package:bilimusic/common/components/cached_image.dart';
import 'package:flutter/material.dart';

class VideoCardData {
  const VideoCardData({
    required this.title,
    required this.coverUrl,
    required this.primaryMeta,
    required this.secondaryMeta,
    this.tag,
  });

  final String title;
  final String coverUrl;
  final String primaryMeta;
  final String secondaryMeta;
  final String? tag;
}

class VideoCard extends StatelessWidget {
  const VideoCard({
    super.key,
    required this.data,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onPlayNext,
    this.onEnqueue,
  });

  final VideoCardData data;
  final VoidCallback onTap;
  final bool isFavorite;
  final FutureOr<void> Function()? onFavoriteToggle;
  final FutureOr<void> Function()? onPlayNext;
  final FutureOr<void> Function()? onEnqueue;

  bool get _hasActions =>
      onFavoriteToggle != null || onPlayNext != null || onEnqueue != null;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 1),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  SizedBox(
                    width: 82,
                    height: 82,
                    child: CommonCachedImage(
                      imageUrl: data.coverUrl,
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
                        color: colorScheme.surface.withValues(alpha: 0.92),
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
                            data.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                              height: 1.3,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (data.tag case final String tag) ...<Widget>[
                          const SizedBox(width: 8),
                          VideoCardTag(label: tag),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.primaryMeta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 8,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.secondaryMeta,
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
              if (_hasActions) ...<Widget>[
                const SizedBox(width: 12),
                _VideoCardActions(
                  isFavorite: isFavorite,
                  onFavoriteToggle: onFavoriteToggle,
                  onPlayNext: onPlayNext,
                  onEnqueue: onEnqueue,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoCardActions extends StatelessWidget {
  const _VideoCardActions({
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onPlayNext,
    required this.onEnqueue,
  });

  final bool isFavorite;
  final FutureOr<void> Function()? onFavoriteToggle;
  final FutureOr<void> Function()? onPlayNext;
  final FutureOr<void> Function()? onEnqueue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (onFavoriteToggle != null)
          VideoCardIconAction(
            icon: isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            isActive: isFavorite,
            activeColor: Theme.of(context).colorScheme.secondary,
            tooltip: isFavorite ? '取消收藏' : '收藏',
            onTap: () => unawaited(Future<void>.sync(onFavoriteToggle!)),
          ),
        if (onFavoriteToggle != null &&
            (onPlayNext != null || onEnqueue != null))
          const SizedBox(height: 8),
        if (onPlayNext != null || onEnqueue != null)
          PopupMenuButton<_VideoCardQueueAction>(
            tooltip: '队列操作',
            padding: EdgeInsets.zero,
            onSelected: (_VideoCardQueueAction action) {
              switch (action) {
                case _VideoCardQueueAction.playNext:
                  final FutureOr<void> Function()? callback = onPlayNext;
                  if (callback != null) {
                    unawaited(Future<void>.sync(callback));
                  }
                case _VideoCardQueueAction.enqueue:
                  final FutureOr<void> Function()? callback = onEnqueue;
                  if (callback != null) {
                    unawaited(Future<void>.sync(callback));
                  }
              }
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<_VideoCardQueueAction>>[
                  if (onPlayNext != null)
                    const PopupMenuItem<_VideoCardQueueAction>(
                      value: _VideoCardQueueAction.playNext,
                      child: ListTile(
                        leading: Icon(Icons.skip_next_rounded),
                        title: Text('下一首播放'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  if (onEnqueue != null)
                    const PopupMenuItem<_VideoCardQueueAction>(
                      value: _VideoCardQueueAction.enqueue,
                      child: ListTile(
                        leading: Icon(Icons.queue_music_rounded),
                        title: Text('加入队列'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                ],
            child: const VideoCardIconAction(
              icon: Icons.more_horiz_rounded,
              onTap: null,
              tooltip: '队列操作',
            ),
          ),
      ],
    );
  }
}

enum _VideoCardQueueAction { playNext, enqueue }

class VideoCardIconAction extends StatelessWidget {
  const VideoCardIconAction({
    super.key,
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.activeColor,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool isActive;
  final Color? activeColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color iconColor = isActive
        ? activeColor ?? colorScheme.secondary
        : colorScheme.onSurfaceVariant;
    final Widget button = InkResponse(
      onTap: onTap,
      radius: 18,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.secondaryContainer
              : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );

    if (tooltip == null) {
      return button;
    }
    return Tooltip(message: tooltip!, child: button);
  }
}

class VideoCardTag extends StatelessWidget {
  const VideoCardTag({super.key, required this.label});

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
