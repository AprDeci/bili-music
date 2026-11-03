import 'dart:async';

import 'package:bilimusic/common/components/login_required.dart';
import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/common/components/car/car_content_widgets.dart';
import 'package:bilimusic/feature/profile/ui/components/add_collection_dialog.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CarProfilePage extends ConsumerStatefulWidget {
  const CarProfilePage({super.key});

  @override
  ConsumerState<CarProfilePage> createState() => _CarProfilePageState();
}

class _CarProfilePageState extends ConsumerState<CarProfilePage> {
  bool _refreshing = false;
  bool _refreshFailed = false;

  @override
  void initState() {
    super.initState();
    unawaited(Future<void>.microtask(_refreshRemoteCollections));
  }

  Future<void> _refreshRemoteCollections() async {
    if (!mounted || _refreshing) {
      return;
    }
    if (!(ref.read(biliSessionControllerProvider)?.isLoggedIn ?? false)) {
      return;
    }
    setState(() {
      _refreshing = true;
      _refreshFailed = false;
    });
    try {
      await ref
          .read(favoritesControllerProvider.notifier)
          .refreshRemoteCollections();
    } on Object catch (error) {
      if (mounted) {
        setState(() => _refreshFailed = true);
        LoginPrompt.handle(context, error, reason: '网络歌单需要重新登录');
      }
    } finally {
      if (mounted) {
        setState(() => _refreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(biliSessionControllerProvider, (previous, next) {
      if (next?.isLoggedIn ?? false) {
        unawaited(_refreshRemoteCollections());
      }
    });
    final FavoritesState favorites = ref.watch(favoritesControllerProvider);
    final recent = ref.watch(recentPlaybackControllerProvider);
    final List<FavoriteCollection> local = favorites.collections
        .where((collection) => collection.isLocal && !collection.isSystem)
        .toList(growable: false);
    final List<FavoriteCollection> remote = favorites.collections
        .where((collection) => collection.isRemote)
        .toList(growable: false);
    return Column(
      children: <Widget>[
        const CarContentHeader(title: '我的音乐'),
        Expanded(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) => SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: (constraints.crossAxisExtent / 240)
                          .floor()
                          .clamp(1, 2),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 152,
                    ),
                    delegate: SliverChildListDelegate(<Widget>[
                      CarContentCard(
                        title: '最近播放',
                        subtitle: '${recent.length} 首歌曲',
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
                    ]),
                  ),
                ),
              ),
              _sectionTitle(context, '网络歌单', remote: true),
              if (_refreshing)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: LinearProgressIndicator(),
                  ),
                ),
              if (_refreshFailed)
                SliverToBoxAdapter(
                  child: StatusView(
                    title: '网络歌单同步失败',
                    description: '已保留本地缓存，可重试同步。',
                    icon: Icons.cloud_off_rounded,
                    iconColor: Theme.of(context).colorScheme.error,
                    onRetry: _refreshRemoteCollections,
                    isRetrying: _refreshing,
                  ),
                ),
              if (remote.isEmpty && !_refreshing && !_refreshFailed)
                const SliverToBoxAdapter(
                  child: StatusView(
                    title: '还没有网络歌单',
                    description: '点击标题旁的 +，导入 B 站收藏夹或新建网络歌单。',
                    icon: Icons.cloud_queue_rounded,
                  ),
                )
              else
                _collectionGrid(favorites, remote),
              _sectionTitle(context, '自建歌单', remote: false),
              if (local.isEmpty)
                const SliverToBoxAdapter(
                  child: StatusView(
                    title: '还没有自建歌单',
                    description: '点击标题旁的 +，创建自己的歌单。',
                    icon: Icons.library_music_rounded,
                  ),
                )
              else
                _collectionGrid(favorites, local),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(
    BuildContext context,
    String title, {
    required bool remote,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Row(
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(width: 8),
            IconButton(
              tooltip: '添加$title',
              constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
              onPressed: () => showAddCollectionDialog(
                context: context,
                ref: ref,
                remote: remote,
              ),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _collectionGrid(
    FavoritesState favorites,
    List<FavoriteCollection> collections,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) => SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: (constraints.crossAxisExtent / 320).floor().clamp(
              1,
              3,
            ),
            mainAxisExtent: 144,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: collections.length,
          itemBuilder: (context, index) {
            final FavoriteCollection collection = collections[index];
            final int count = collection.isRemote
                ? collection.itemCount
                : favorites.itemCountForCollection(collection.id);
            final String? cover = collection.coverUrl;
            return CarContentCard(
              title: collection.name,
              subtitle: '$count ${collection.isSpoken ? '集' : '首歌曲'}',
              icon: collection.isRemote
                  ? Icons.cloud_queue_rounded
                  : Icons.queue_music_rounded,
              coverUrl: cover?.isNotEmpty ?? false
                  ? cover
                  : favorites
                        .itemsForCollection(collection.id)
                        .firstOrNull
                        ?.coverUrl,
              onTap: () => context.push(
                '/profile/favorites/${Uri.encodeComponent(collection.id)}',
              ),
            );
          },
        ),
      ),
    );
  }
}
