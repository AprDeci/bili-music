import 'package:bilimusic/common/components/video_card.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/up/domain/up_page_state.dart';
import 'package:bilimusic/feature/up/domain/up_video_item.dart';
import 'package:bilimusic/feature/up/logic/up_page_controller.dart';
import 'package:bilimusic/feature/up/ui/components/up_collection_list.dart';
import 'package:bilimusic/feature/up/ui/components/up_profile_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopUpPage extends ConsumerStatefulWidget {
  const DesktopUpPage({super.key, required this.mid});

  final int mid;

  @override
  ConsumerState<DesktopUpPage> createState() => _DesktopUpPageState();
}

class _DesktopUpPageState extends ConsumerState<DesktopUpPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      return;
    }
    ref
        .read(upPageControllerProvider(widget.mid).notifier)
        .selectTab(
          _tabController.index == 0 ? UpPageTab.videos : UpPageTab.collections,
        );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<UpPageState> state = ref.watch(
      upPageControllerProvider(widget.mid),
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) => Center(
            child: TextButton(
              onPressed: () =>
                  ref.invalidate(upPageControllerProvider(widget.mid)),
              child: Text(error.toString()),
            ),
          ),
          data: _buildContent,
        ),
      ),
    );
  }

  Widget _buildContent(UpPageState data) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final int nextIndex = data.selectedTab == UpPageTab.videos ? 0 : 1;
    if (_tabController.index != nextIndex) {
      _tabController.index = nextIndex;
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification.metrics.extentAfter >= 320) {
          return false;
        }
        if (data.selectedTab == UpPageTab.videos && data.hasMoreVideos) {
          ref
              .read(upPageControllerProvider(widget.mid).notifier)
              .loadMoreVideos();
        }
        if (data.selectedTab == UpPageTab.collections &&
            data.hasMoreCollections) {
          ref
              .read(upPageControllerProvider(widget.mid).notifier)
              .loadMoreCollections();
        }
        return false;
      },
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: false,
            floating: true,
            snap: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: UpProfileHeader(
                  profile: data.profile,
                  error: data.profileError,
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedTabBarDelegate(
              child: ColoredBox(
                color: colorScheme.surface,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: TabBar(
                      controller: _tabController,
                      tabs: const <Widget>[
                        Tab(text: '投稿'),
                        Tab(text: '合集'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (data.selectedTab == UpPageTab.videos)
            _DesktopUpVideoSliverList(
              mid: widget.mid,
              items: data.videos,
              isLoadingMore: data.isLoadingVideosMore,
              hasMore: data.hasMoreVideos,
              error: data.videoError,
              loadMoreError: data.videoLoadMoreError,
            )
          else
            SliverFillRemaining(
              hasScrollBody: true,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: UpCollectionList(
                    mid: widget.mid,
                    ownerName: data.profile?.name ?? '',
                    items: data.collections,
                    isLoadingMore: data.isLoadingCollectionsMore,
                    hasMore: data.hasMoreCollections,
                    error: data.collectionError,
                    loadMoreError: data.collectionLoadMoreError,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DesktopUpVideoSliverList extends ConsumerWidget {
  const _DesktopUpVideoSliverList({
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
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: TextButton(
            onPressed: () => ref.invalidate(upPageControllerProvider(mid)),
            child: Text(error!),
          ),
        ),
      );
    }
    if (items.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text('暂无投稿')),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList.builder(
        itemCount: items.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == items.length) {
            return _DesktopListFooter(
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

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: VideoCard(
                data: VideoCardData(
                  title: cardData.title,
                  coverUrl: cardData.coverUrl,
                  primaryMeta: cardData.primaryMeta,
                  secondaryMeta: cardData.secondaryMeta,
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

class _DesktopListFooter extends StatelessWidget {
  const _DesktopListFooter({
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

class _PinnedTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedTabBarDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => kTextTabBarHeight;

  @override
  double get maxExtent => kTextTabBarHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _PinnedTabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
