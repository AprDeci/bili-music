import 'package:bilimusic/common/components/video_card.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/up/domain/up_video_item.dart';
import 'package:bilimusic/feature/up/logic/up_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpVideoList extends ConsumerWidget {
  const UpVideoList({
    super.key,
    required this.mid,
    required this.items,
    required this.isLoadingMore,
    required this.hasMore,
    this.error,
    this.loadMoreError,
  });

  final int mid;
  final List<UpVideoItem> items;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final String? loadMoreError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesState = ref.watch(favoritesControllerProvider);

    if (items.isEmpty && error != null) {
      return _RetryMessage(
        message: error!,
        onRetry: () => ref.invalidate(upPageControllerProvider(mid)),
      );
    }
    if (items.isEmpty) {
      return const _EmptyMessage(message: '暂无投稿');
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification.metrics.extentAfter < 320 && hasMore) {
          ref.read(upPageControllerProvider(mid).notifier).loadMoreVideos();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: items.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == items.length) {
            return _ListFooter(
              isLoadingMore: isLoadingMore,
              hasMore: hasMore,
              error: loadMoreError,
              onRetry: () => ref
                  .read(upPageControllerProvider(mid).notifier)
                  .loadMoreVideos(),
            );
          }
          final UpVideoItem item = items[index];
          final cardData = item.toVideoCardData();
          final PlayableItem playableItem = item.toPlayableItem();
          final bool isFavorite = favoritesState.isLikedVideoPage(
            aid: item.aid,
            bvid: item.bvid,
            page: 1,
          );

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: VideoCard(
              data: VideoCardData(
                title: cardData.title,
                coverUrl: cardData.coverUrl,
                primaryMeta: cardData.primaryMeta,
                secondaryMeta: cardData.secondaryMeta,
                tag: '投稿',
              ),
              onTap: () => PlayerUtil.playItemAndOpenPlayer(
                context,
                ref,
                item: playableItem,
                sourceLabel: item.ownerName,
              ),
              isFavorite: isFavorite,
              onFavoriteToggle: () =>
                  _toggleFavorite(context, ref, playableItem),
              onPlayNext: () => _playNext(context, ref, playableItem),
              onEnqueue: () => _enqueue(context, ref, playableItem),
            ),
          );
        },
      ),
    );
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    PlayableItem item,
  ) async {
    try {
      final PlayableItem resolvedItem = await ref
          .read(biliPlayerRepositoryProvider)
          .resolvePreferredPart(item, preferredPage: 1);
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

  Future<void> _playNext(
    BuildContext context,
    WidgetRef ref,
    PlayableItem item,
  ) async {
    try {
      final PlayableItem resolvedItem = await ref
          .read(biliPlayerRepositoryProvider)
          .resolvePreferredPart(item, preferredPage: 1);
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

  Future<void> _enqueue(
    BuildContext context,
    WidgetRef ref,
    PlayableItem item,
  ) async {
    try {
      final PlayableItem resolvedItem = await ref
          .read(biliPlayerRepositoryProvider)
          .resolvePreferredPart(item, preferredPage: 1);
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
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({
    required this.isLoadingMore,
    required this.hasMore,
    required this.onRetry,
    this.error,
  });

  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback onRetry;
  final String? error;

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: TextButton(onPressed: onRetry, child: Text(error!)),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(child: Text(hasMore ? '继续滚动加载' : '没有更多了')),
    );
  }
}

class _RetryMessage extends StatelessWidget {
  const _RetryMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(onPressed: onRetry, child: Text(message)),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}
