import 'package:bilimusic/common/components/video_card.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/up/domain/collection_detail_state.dart';
import 'package:bilimusic/feature/up/domain/up_collection.dart';
import 'package:bilimusic/feature/up/domain/up_collection_item.dart';
import 'package:bilimusic/feature/up/logic/collection_detail_controller.dart';
import 'package:bilimusic/feature/favorites/logic/favorited_season_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CollectionDetailPage extends ConsumerWidget {
  const CollectionDetailPage({
    super.key,
    required this.mid,
    required this.seasonId,
    this.ownerName,
  });

  final int mid;
  final int seasonId;
  final String? ownerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<CollectionDetailState> state = ref.watch(
      collectionDetailControllerProvider(mid, seasonId),
    );
    final favoritesState = ref.watch(favoritesControllerProvider);
    final Set<int> favoritedSeasonIds = ref
        .watch(favoritedSeasonControllerProvider)
        .map((season) => season.seasonId)
        .toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('合集'),
        actions: <Widget>[
          state.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (CollectionDetailState data) {
              final UpCollection? collection = data.collection;
              if (collection == null) {
                return const SizedBox.shrink();
              }
              final bool isFavorited = favoritedSeasonIds.contains(
                collection.seasonId,
              );
              return IconButton(
                tooltip: isFavorited ? '取消收藏' : '收藏合集',
                onPressed: () => ref
                    .read(favoritedSeasonControllerProvider.notifier)
                    .toggle(collection),
                icon: Icon(
                  isFavorited
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_add_outlined,
                ),
              );
            },
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(
              collectionDetailControllerProvider(mid, seasonId),
            ),
            child: Text(error.toString()),
          ),
        ),
        data: (CollectionDetailState data) {
          if (data.error != null && data.items.isEmpty) {
            return Center(
              child: TextButton(
                onPressed: () => ref.invalidate(
                  collectionDetailControllerProvider(mid, seasonId),
                ),
                child: Text(data.error!),
              ),
            );
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification.metrics.extentAfter < 320 && data.hasMore) {
                ref
                    .read(
                      collectionDetailControllerProvider(
                        mid,
                        seasonId,
                      ).notifier,
                    )
                    .loadMoreItems();
              }
              return false;
            },
            child: ListView.builder(
              itemCount: data.items.length + 2,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return _CollectionHeader(
                    collection: data.collection,
                    itemCount: data.items.length,
                    onPlayAll: data.items.isEmpty
                        ? null
                        : () => _playFrom(context, ref, data, 0),
                  );
                }
                if (index == data.items.length + 1) {
                  return _CollectionFooter(
                    state: data,
                    onRetry: () => ref
                        .read(
                          collectionDetailControllerProvider(
                            mid,
                            seasonId,
                          ).notifier,
                        )
                        .loadMoreItems(),
                  );
                }

                final int itemIndex = index - 1;
                final UpCollectionItem item = data.items[itemIndex];
                final cardData = item.toVideoCardData();
                final PlayableItem playableItem = item.toPlayableItem(
                  ownerMid: data.collection?.mid ?? mid,
                  ownerName: _resolveOwnerName(),
                );
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
                    ),
                    onTap: () => _playFrom(context, ref, data, itemIndex),
                    playableActions: VideoCardPlayableActions(
                      playableItem: playableItem,
                      isFavorite: isFavorite,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _playFrom(
    BuildContext context,
    WidgetRef ref,
    CollectionDetailState data,
    int index,
  ) {
    final int ownerMid = data.collection?.mid ?? mid;
    final String resolvedOwnerName = _resolveOwnerName();
    final List<PlayableItem> queue = data.items
        .map(
          (UpCollectionItem item) => item.toPlayableItem(
            ownerMid: ownerMid,
            ownerName: resolvedOwnerName,
          ),
        )
        .toList(growable: false);
    return PlayerUtil.playQueueAndOpenPlayer(
      context,
      ref,
      items: queue,
      startIndex: index,
      sourceLabel: data.collection?.title ?? '合集',
    );
  }

  String _resolveOwnerName() {
    if (ownerName?.trim().isNotEmpty ?? false) {
      return ownerName!.trim();
    }
    return '';
  }
}

class _CollectionHeader extends StatelessWidget {
  const _CollectionHeader({
    required this.collection,
    required this.itemCount,
    required this.onPlayAll,
  });

  final UpCollection? collection;
  final int itemCount;
  final VoidCallback? onPlayAll;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final UpCollection? value = collection;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CommonCachedImage(
                imageUrl: value?.coverUrl ?? '',
                width: 108,
                height: 72,
                borderRadius: BorderRadius.circular(14),
                fallbackIcon: Icons.queue_music_rounded,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      value?.title ?? '合集',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('共 ${value?.total ?? itemCount} 个视频'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onPlayAll,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('播放全部'),
          ),
        ],
      ),
    );
  }
}

class _CollectionFooter extends StatelessWidget {
  const _CollectionFooter({required this.state, required this.onRetry});

  final CollectionDetailState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('合集暂无内容')),
      );
    }
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: TextButton(
            onPressed: onRetry,
            child: Text(state.loadMoreError!),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(child: Text(state.hasMore ? '继续滚动加载' : '没有更多了')),
    );
  }
}
