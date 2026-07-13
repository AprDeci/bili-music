import 'dart:async';

import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_collection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class VideoCardPlayableActions {
  const VideoCardPlayableActions({
    required this.playableItem,
    required this.isFavorite,
  });

  final PlayableItem playableItem;
  final bool isFavorite;
}

class VideoCard extends ConsumerWidget {
  const VideoCard({
    super.key,
    required this.data,
    required this.onTap,
    this.isFavorite = false,
    this.playableActions,
    this.onFavoriteToggle,
    this.onPlayNext,
    this.onEnqueue,
    this.onAddToCollection,
  });

  final VideoCardData data;
  final VoidCallback onTap;
  final bool isFavorite;
  final VideoCardPlayableActions? playableActions;
  final FutureOr<void> Function()? onFavoriteToggle;
  final FutureOr<void> Function()? onPlayNext;
  final FutureOr<void> Function()? onEnqueue;
  final FutureOr<void> Function()? onAddToCollection;

  bool get _hasActions =>
      onFavoriteToggle != null ||
      onPlayNext != null ||
      onEnqueue != null ||
      onAddToCollection != null ||
      playableActions != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final VideoCardPlayableActions? actions = playableActions;
    final bool resolvedIsFavorite = actions?.isFavorite ?? isFavorite;

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
                              fontWeight: FontWeight.w500,
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
                  isFavorite: resolvedIsFavorite,
                  onFavoriteToggle: onFavoriteToggle,
                  onPlayNext: onPlayNext,
                  onEnqueue: onEnqueue,
                  onAddToCollection: onAddToCollection,
                  playableActions: actions,
                  ref: ref,
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
    required this.ref,
    required this.onFavoriteToggle,
    required this.onPlayNext,
    required this.onEnqueue,
    required this.onAddToCollection,
    required this.playableActions,
  });

  final bool isFavorite;
  final WidgetRef ref;
  final FutureOr<void> Function()? onFavoriteToggle;
  final FutureOr<void> Function()? onPlayNext;
  final FutureOr<void> Function()? onEnqueue;
  final FutureOr<void> Function()? onAddToCollection;
  final VideoCardPlayableActions? playableActions;

  Future<void> _toggleFavorite(BuildContext context) async {
    final VideoCardPlayableActions? actions = playableActions;
    if (actions == null) {
      final FutureOr<void> Function()? callback = onFavoriteToggle;
      if (callback != null) {
        await Future<void>.sync(callback);
      }
      return;
    }

    try {
      final PlayableItem resolvedItem = await ref
          .read(biliPlayerRepositoryProvider)
          .resolvePreferredPart(actions.playableItem, preferredPage: 1);
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
  }

  Future<void> _playNext(BuildContext context) async {
    final VideoCardPlayableActions? actions = playableActions;
    if (actions == null) {
      final FutureOr<void> Function()? callback = onPlayNext;
      if (callback != null) {
        await Future<void>.sync(callback);
      }
      return;
    }

    try {
      final PlayableItem resolvedItem = await ref
          .read(biliPlayerRepositoryProvider)
          .resolvePreferredPart(actions.playableItem, preferredPage: 1);
      await ref.read(playerControllerProvider.notifier).playNext(resolvedItem);
      if (context.mounted) {
        ToastUtil.show('已加入下一首');
      }
    } on Object catch (error) {
      if (context.mounted) {
        ToastUtil.show('操作失败: $error');
      }
    }
  }

  Future<void> _enqueue(BuildContext context) async {
    final VideoCardPlayableActions? actions = playableActions;
    if (actions == null) {
      final FutureOr<void> Function()? callback = onEnqueue;
      if (callback != null) {
        await Future<void>.sync(callback);
      }
      return;
    }

    try {
      final PlayableItem resolvedItem = await ref
          .read(biliPlayerRepositoryProvider)
          .resolvePreferredPart(actions.playableItem, preferredPage: 1);
      await ref.read(playerControllerProvider.notifier).enqueue(<PlayableItem>[
        resolvedItem,
      ]);
      if (context.mounted) {
        ToastUtil.show('已加入播放队列');
      }
    } on Object catch (error) {
      if (context.mounted) {
        ToastUtil.show('操作失败: $error');
      }
    }
  }

  Future<void> _enqueueAllParts(BuildContext context) async {
    final VideoCardPlayableActions? actions = playableActions;
    if (actions == null) {
      return;
    }

    try {
      final int addedCount = await PlayerUtil.enqueueAllParts(
        ref,
        actions.playableItem,
      );
      if (context.mounted) {
        ToastUtil.show(addedCount > 0 ? '已加入 $addedCount 个分P' : '全部分P已在播放队列中');
      }
    } on Object catch (error) {
      if (context.mounted) {
        ToastUtil.show('操作失败: $error');
      }
    }
  }

  Future<void> _addToCollection(BuildContext context) async {
    final VideoCardPlayableActions? actions = playableActions;
    if (actions == null) {
      final FutureOr<void> Function()? callback = onAddToCollection;
      if (callback != null) {
        await Future<void>.sync(callback);
      }
      return;
    }

    await showPlayerCollectionSheet(
      context: context,
      item: actions.playableItem,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasFavoriteAction =
        onFavoriteToggle != null || playableActions != null;
    final bool hasQueueActions =
        onPlayNext != null || onEnqueue != null || playableActions != null;
    final bool hasCollectionAction =
        onAddToCollection != null || playableActions != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (hasFavoriteAction)
          VideoCardIconAction(
            icon: isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            isActive: isFavorite,
            activeColor: Theme.of(context).colorScheme.secondary,
            tooltip: isFavorite ? '取消收藏' : '收藏',
            onTap: () => unawaited(_toggleFavorite(context)),
          ),
        if (hasFavoriteAction && hasQueueActions) const SizedBox(height: 8),
        if (hasQueueActions || hasCollectionAction)
          PopupMenuButton<_VideoCardQueueAction>(
            tooltip: '队列操作',
            padding: EdgeInsets.zero,
            onSelected: (_VideoCardQueueAction action) {
              switch (action) {
                case _VideoCardQueueAction.playNext:
                  unawaited(_playNext(context));
                case _VideoCardQueueAction.enqueue:
                  unawaited(_enqueue(context));
                case _VideoCardQueueAction.enqueueAllParts:
                  unawaited(_enqueueAllParts(context));
                case _VideoCardQueueAction.addToCollection:
                  unawaited(_addToCollection(context));
              }
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<_VideoCardQueueAction>>[
                  if (onPlayNext != null || playableActions != null)
                    const PopupMenuItem<_VideoCardQueueAction>(
                      value: _VideoCardQueueAction.playNext,
                      child: ListTile(
                        leading: Icon(Icons.skip_next_rounded),
                        title: Text('下一首播放'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  if (onEnqueue != null || playableActions != null)
                    const PopupMenuItem<_VideoCardQueueAction>(
                      value: _VideoCardQueueAction.enqueue,
                      child: ListTile(
                        leading: Icon(Icons.queue_music_rounded),
                        title: Text('加入队列'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  if (playableActions != null)
                    const PopupMenuItem<_VideoCardQueueAction>(
                      value: _VideoCardQueueAction.enqueueAllParts,
                      child: ListTile(
                        leading: Icon(Icons.library_add_rounded),
                        title: Text('添加全部分P'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  if (onAddToCollection != null || playableActions != null)
                    const PopupMenuItem<_VideoCardQueueAction>(
                      value: _VideoCardQueueAction.addToCollection,
                      child: ListTile(
                        leading: Icon(Icons.playlist_add_rounded),
                        title: Text('添加到歌单'),
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

enum _VideoCardQueueAction {
  playNext,
  enqueue,
  enqueueAllParts,
  addToCollection,
}

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
