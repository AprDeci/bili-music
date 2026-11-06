import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/home/domain/music_ranking_item.dart';
import 'package:bilimusic/feature/home/logic/music_ranking_controller.dart';
import 'package:bilimusic/common/components/car/car_content_widgets.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CarHomePage extends ConsumerWidget {
  const CarHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ranking = ref.watch(musicRankingControllerProvider);
    final recent = ref.watch(recentPlaybackControllerProvider);
    final favorites = ref.watch(favoritesControllerProvider);
    final List<PlayableItem> recentQueue = recent
        .map((item) => item.toPlayableItem())
        .toList(growable: false);
    return Column(
      children: <Widget>[
        const CarContentHeader(title: '为你推荐'),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(musicRankingControllerProvider.notifier).refresh(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) => SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: (constraints.crossAxisExtent / 240)
                            .floor()
                            .clamp(1, 3),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        mainAxisExtent: 152,
                      ),
                      delegate: SliverChildListDelegate(<Widget>[
                        CarContentCard(
                          title: '最近播放',
                          subtitle: recent.isEmpty
                              ? '从一首好歌开始'
                              : '${recent.length} 首 · 继续听',
                          icon: Icons.history_rounded,
                          coverUrl: recent.firstOrNull?.coverUrl,
                          onTap: () => context.push('/profile/recent'),
                        ),
                        CarContentCard(
                          title: '我喜欢',
                          subtitle:
                              '${favorites.itemCountForCollection(FavoriteCollection.likedCollectionId)} 首歌曲',
                          icon: Icons.favorite_rounded,
                          onTap: () => context.push('/profile/favorites/liked'),
                        ),
                        CarContentCard(
                          title: '我的歌单',
                          subtitle: '为这段旅程选一张歌单',
                          icon: Icons.library_music_rounded,
                          onTap: () => context.go('/profile'),
                        ),
                      ]),
                    ),
                  ),
                ),
                if (recentQueue.isNotEmpty) ...<Widget>[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              '接着听',
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              minimumSize: const Size(56, 56),
                            ),
                            onPressed: () => context.push('/profile/recent'),
                            child: const Text('查看全部'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    sliver: SliverList.builder(
                      itemCount: recentQueue.length.clamp(0, 3),
                      itemBuilder: (context, index) => CarSongTile(
                        item: recentQueue[index],
                        index: index,
                        onTap: () =>
                            _play(context, ref, recentQueue, index, '最近播放'),
                      ),
                    ),
                  ),
                ],
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '近期音乐榜',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          tooltip: '刷新排行榜',
                          constraints: const BoxConstraints(
                            minWidth: 56,
                            minHeight: 56,
                          ),
                          onPressed: ranking.isLoading
                              ? null
                              : () => ref
                                    .read(
                                      musicRankingControllerProvider.notifier,
                                    )
                                    .refresh(),
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
                ranking.when(
                  skipLoadingOnRefresh: false,
                  loading: () => const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (error, stackTrace) => SliverToBoxAdapter(
                    child: StatusView(
                      title: '排行榜加载失败',
                      description: '请检查网络连接后重试。',
                      icon: Icons.cloud_off_rounded,
                      iconColor: theme.colorScheme.error,
                      onRetry: () => ref
                          .read(musicRankingControllerProvider.notifier)
                          .refresh(),
                    ),
                  ),
                  data: (List<MusicRankingItem> items) {
                    if (items.isEmpty) {
                      return SliverToBoxAdapter(
                        child: StatusView(
                          title: '暂无排行榜内容',
                          icon: Icons.music_note_rounded,
                          onRetry: () => ref
                              .read(musicRankingControllerProvider.notifier)
                              .refresh(),
                        ),
                      );
                    }
                    final List<PlayableItem> queue = items
                        .map((item) => item.toPlayableItem())
                        .toList(growable: false);
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      sliver: SliverList.builder(
                        itemCount: queue.length,
                        itemBuilder: (context, index) => CarSongTile(
                          item: queue[index],
                          index: index,
                          onTap: () =>
                              _play(context, ref, queue, index, '近期音乐榜'),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _play(
    BuildContext context,
    WidgetRef ref,
    List<PlayableItem> items,
    int index,
    String sourceLabel,
  ) async {
    try {
      await PlayerUtil.playQueueAndOpenPlayer(
        context,
        ref,
        items: items,
        startIndex: index,
        sourceLabel: sourceLabel,
      );
    } on Object {
      if (context.mounted) {
        ToastUtil.show('播放失败，请重试');
      }
    }
  }
}
