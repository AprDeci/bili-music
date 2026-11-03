import 'dart:async';

import 'package:bilimusic/common/components/login_required.dart';
import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/home/ui/car/car_content_widgets.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CarFavoriteCollectionPage extends ConsumerStatefulWidget {
  const CarFavoriteCollectionPage({super.key, required this.collectionId});

  final String collectionId;

  @override
  ConsumerState<CarFavoriteCollectionPage> createState() =>
      _CarFavoriteCollectionPageState();
}

class _CarFavoriteCollectionPageState
    extends ConsumerState<CarFavoriteCollectionPage> {
  bool _syncing = false;
  bool _syncFailed = false;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    unawaited(Future<void>.microtask(_sync));
  }

  @override
  void didUpdateWidget(covariant CarFavoriteCollectionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.collectionId != widget.collectionId) {
      _requestId++;
      _syncing = false;
      _syncFailed = false;
      unawaited(Future<void>.microtask(_sync));
    }
  }

  FavoriteCollection? _collection(FavoritesState state) {
    for (final FavoriteCollection collection in state.collections) {
      if (collection.id == widget.collectionId) {
        return collection;
      }
    }
    return null;
  }

  Future<void> _sync({bool force = false}) async {
    if (!mounted || _syncing) {
      return;
    }
    final FavoriteCollection? collection = _collection(
      ref.read(favoritesControllerProvider),
    );
    if (collection == null || !collection.isRemote) {
      return;
    }
    final int requestId = ++_requestId;
    setState(() {
      _syncing = true;
      _syncFailed = false;
    });
    try {
      final RemoteCollectionSyncResult result = await ref
          .read(favoritesControllerProvider.notifier)
          .syncRemoteCollectionIfStale(collection.id, force: force);
      if (mounted && requestId == _requestId) {
        setState(
          () => _syncFailed = result == RemoteCollectionSyncResult.incomplete,
        );
      }
    } on Object catch (error) {
      if (mounted && requestId == _requestId) {
        setState(() => _syncFailed = true);
        LoginPrompt.handle(context, error, reason: '网络歌单需要重新登录');
      }
    } finally {
      if (mounted && requestId == _requestId) {
        setState(() => _syncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(favoritesControllerProvider, (previous, next) {
      if (_collection(next)?.isRemote == true &&
          (previous == null || _collection(previous) == null)) {
        unawaited(Future<void>.microtask(_sync));
      }
    });
    final FavoritesState state = ref.watch(favoritesControllerProvider);
    final FavoriteCollection? collection = _collection(state);
    final List<PlayableItem> items = collection == null
        ? const <PlayableItem>[]
        : state
              .itemsForCollection(collection.id)
              .map((item) => item.toPlayableItem(collection: collection))
              .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        CarContentHeader(
          title: collection?.name ?? '歌单',
          backLocation: '/profile',
          action: collection?.isRemote == true
              ? IconButton(
                  tooltip: '同步歌单',
                  constraints: const BoxConstraints(
                    minWidth: 56,
                    minHeight: 56,
                  ),
                  onPressed: _syncing ? null : () => _sync(force: true),
                  icon: const Icon(Icons.sync_rounded),
                )
              : null,
        ),
        if (_syncing)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: LinearProgressIndicator(semanticsLabel: '正在同步歌单'),
          ),
        if (_syncFailed && items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              children: <Widget>[
                const Text('同步未完成，正在显示已缓存的歌曲'),
                TextButton.icon(
                  style: TextButton.styleFrom(minimumSize: const Size(56, 56)),
                  onPressed: _syncing ? null : () => _sync(force: true),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('重试'),
                ),
              ],
            ),
          ),
        Expanded(
          child: collection == null
              ? const StatusView(
                  title: '歌单不存在',
                  description: '歌单可能已被移除，请返回我的音乐。',
                  icon: Icons.folder_off_rounded,
                )
              : _syncing && items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _syncFailed && items.isEmpty
              ? StatusView(
                  title: '歌单同步失败',
                  description: '请检查网络连接后重试。',
                  icon: Icons.cloud_off_rounded,
                  iconColor: Theme.of(context).colorScheme.error,
                  onRetry: () => _sync(force: true),
                )
              : RefreshIndicator(
                  onRefresh: () => _sync(force: true),
                  child: CarSongList(
                    items: items,
                    sourceLabel: collection.name,
                    emptyTitle: '这个歌单还是空的',
                    emptyDescription: collection.isRemote
                        ? '同步完成后暂无可播放内容，可稍后再次同步。'
                        : '在搜索页或播放器收藏歌曲后，即可在这里收听。',
                  ),
                ),
        ),
      ],
    );
  }
}
