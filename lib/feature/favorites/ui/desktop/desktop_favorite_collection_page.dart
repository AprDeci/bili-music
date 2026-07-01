import 'dart:async';

import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/favorites/domain/bili_favorite_collection_page.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorite_entry_search.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorite_collection_search_field.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorite_search_empty_state.dart';
import 'package:bilimusic/feature/favorites/ui/components/desktop/desktop_favorite_collection_items_list.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorite_entry_subtitle.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/ui/components/player_collection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DesktopFavoriteCollectionPage extends ConsumerStatefulWidget {
  const DesktopFavoriteCollectionPage({super.key, required this.collectionId});

  static final AppLogger _logger = AppLogger('DesktopFavoriteCollectionPage');

  final String collectionId;

  @override
  ConsumerState<DesktopFavoriteCollectionPage> createState() =>
      _DesktopFavoriteCollectionPageState();
}

class _DesktopFavoriteCollectionPageState
    extends ConsumerState<DesktopFavoriteCollectionPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _nextRemotePageNumber = 2;
  int _remoteRefreshRequestId = 0;
  bool _remoteHasMore = false;
  bool _isLoadingRemotePage = false;
  bool _remoteRefreshFailed = false;
  bool _remoteLoadMoreFailed = false;

  @override
  void initState() {
    super.initState();
    _refreshRemoteCollectionItems();
  }

  @override
  void didUpdateWidget(covariant DesktopFavoriteCollectionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.collectionId != widget.collectionId) {
      _resetSearchState();
      _resetRemotePagingState();
      _refreshRemoteCollectionItems();
    }
  }

  void _refreshRemoteCollectionItems() {
    if (_isLoadingRemotePage) {
      return;
    }

    final String collectionId = widget.collectionId;
    final int requestId = ++_remoteRefreshRequestId;
    unawaited(
      Future<void>.microtask(() async {
        try {
          if (mounted) {
            setState(() {
              _isLoadingRemotePage = true;
              _remoteRefreshFailed = false;
            });
          }
          final BiliFavoriteCollectionPage? page = await ref
              .read(favoritesControllerProvider.notifier)
              .refreshRemoteCollectionItems(collectionId: collectionId);
          if (!_canApplyRemoteRefreshResult(collectionId, requestId) ||
              page == null) {
            return;
          }
          setState(() {
            _remoteRefreshFailed = false;
            _remoteLoadMoreFailed = false;
            _remoteHasMore = page.hasMore;
            _nextRemotePageNumber = page.pageNumber + 1;
          });
        } on Object catch (error, stackTrace) {
          DesktopFavoriteCollectionPage._logger.w(
            'Failed to refresh remote collection',
            error,
            stackTrace,
          );
          if (_canApplyRemoteRefreshResult(collectionId, requestId)) {
            setState(() {
              _remoteRefreshFailed = true;
            });
            ToastUtil.show('网络歌单同步失败，请稍后重试');
          }
        } finally {
          if (_canApplyRemoteRefreshResult(collectionId, requestId)) {
            setState(() {
              _isLoadingRemotePage = false;
            });
          }
        }
      }),
    );
  }

  void _resetRemotePagingState() {
    _nextRemotePageNumber = 2;
    _remoteRefreshRequestId++;
    _remoteHasMore = false;
    _isLoadingRemotePage = false;
    _remoteRefreshFailed = false;
    _remoteLoadMoreFailed = false;
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_searchQuery.isNotEmpty ||
        !_remoteHasMore ||
        _isLoadingRemotePage ||
        _remoteLoadMoreFailed) {
      return false;
    }
    if (notification.metrics.extentAfter > 320) {
      return false;
    }
    _loadMoreRemoteCollectionItems();
    return false;
  }

  void _loadMoreRemoteCollectionItems() {
    if (_isLoadingRemotePage || !_remoteHasMore) {
      return;
    }

    final String collectionId = widget.collectionId;
    final int pageNumber = _nextRemotePageNumber;
    unawaited(
      Future<void>.microtask(() async {
        try {
          if (!mounted) {
            return;
          }
          setState(() {
            _isLoadingRemotePage = true;
            _remoteLoadMoreFailed = false;
          });
          final BiliFavoriteCollectionPage? page = await ref
              .read(favoritesControllerProvider.notifier)
              .loadMoreRemoteCollectionItems(
                collectionId: collectionId,
                pageNumber: pageNumber,
              );
          if (!mounted || widget.collectionId != collectionId || page == null) {
            return;
          }
          setState(() {
            _remoteLoadMoreFailed = false;
            _remoteHasMore = page.hasMore;
            _nextRemotePageNumber = page.pageNumber + 1;
          });
        } on Object catch (error, stackTrace) {
          DesktopFavoriteCollectionPage._logger.w(
            'Failed to load more remote collection items',
            error,
            stackTrace,
          );
          if (mounted && widget.collectionId == collectionId) {
            setState(() {
              _remoteLoadMoreFailed = true;
            });
            ToastUtil.show('加载更多失败，请重试');
          }
        } finally {
          if (mounted && widget.collectionId == collectionId) {
            setState(() {
              _isLoadingRemotePage = false;
            });
          }
        }
      }),
    );
  }

  bool _canApplyRemoteRefreshResult(String collectionId, int requestId) {
    return mounted &&
        widget.collectionId == collectionId &&
        _remoteRefreshRequestId == requestId;
  }

  @override
  void deactivate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _resetSearchState();
    });
    super.deactivate();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateSearchQuery(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _clearSearchQuery() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void _resetSearchState() {
    if (_searchQuery.isEmpty && _searchController.text.isEmpty) {
      return;
    }

    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final FavoritesState state = ref.watch(favoritesControllerProvider);
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color primary = colorScheme.primary;
    FavoriteCollection? collection;
    for (final FavoriteCollection item in state.collections) {
      if (item.id == widget.collectionId) {
        collection = item;
        break;
      }
    }

    if (collection == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('歌单')),
        body: const Center(child: Text('歌单不存在')),
      );
    }

    final FavoriteCollection resolvedCollection = collection;

    final List<FavoriteEntry> items = state.itemsForCollection(
      resolvedCollection.id,
    );
    final List<FavoriteEntry> visibleItems = filterFavoriteEntries(
      items,
      _searchQuery,
    );
    final List<PlayableItem> queueItems = visibleItems
        .map((FavoriteEntry item) => item.toPlayableItem())
        .toList(growable: false);
    return Scaffold(
      body: items.isEmpty && _remoteRefreshFailed
          ? _RemoteCollectionErrorState(
              isRetrying: _isLoadingRemotePage,
              onRetry: _refreshRemoteCollectionItems,
            )
          : items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: Icon(
                        resolvedCollection.isLikedCollection
                            ? Icons.favorite_border_rounded
                            : Icons.folder_open_rounded,
                        color: primary,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '这个歌单还是空的',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '先去搜索页或者播放器点亮爱心，喜欢的内容会出现在这里。',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                  child: FavoriteCollectionSearchField(
                    controller: _searchController,
                    query: _searchQuery,
                    onChanged: _updateSearchQuery,
                    onClear: _clearSearchQuery,
                  ),
                ),
                Expanded(
                  child: visibleItems.isEmpty
                      ? ListView(
                          padding: EdgeInsets.zero,
                          children: <Widget>[
                            FavoriteSearchEmptyState(
                              onSearchOnline: () => context.go('/search'),
                            ),
                            const BottomPageSpacer.overlay(),
                          ],
                        )
                      : DesktopFavoriteCollectionItemsList(
                          items: visibleItems,
                          footer: _buildListFooter(theme),
                          onNotification: _handleScrollNotification,
                          onTapItem: (int itemIndex, FavoriteEntry item) async {
                            await _playCollectionItem(
                              context,
                              ref,
                              collectionName: resolvedCollection.name,
                              queueItems: queueItems,
                              index: itemIndex,
                            );
                          },
                          onPlayItem:
                              (int itemIndex, FavoriteEntry item) async {
                                await _playCollectionItem(
                                  context,
                                  ref,
                                  collectionName: resolvedCollection.name,
                                  queueItems: queueItems,
                                  index: itemIndex,
                                );
                              },
                          onMoreItem:
                              (int itemIndex, FavoriteEntry item) async {
                                await _showItemActionSheet(
                                  context,
                                  ref,
                                  collection: resolvedCollection,
                                  item: item,
                                );
                              },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildListFooter(ThemeData theme) {
    if (_remoteLoadMoreFailed) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 28),
        child: Center(
          child: TextButton.icon(
            onPressed: _loadMoreRemoteCollectionItems,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('加载失败，重试'),
          ),
        ),
      );
    }

    if (_remoteHasMore || _isLoadingRemotePage) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 28),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      );
    }
    return const BottomPageSpacer.overlay();
  }

  Future<void> _playCollectionItem(
    BuildContext context,
    WidgetRef ref, {
    required String collectionName,
    required List<PlayableItem> queueItems,
    required int index,
  }) async {
    DesktopFavoriteCollectionPage._logger.d(
      '[FavoriteDebug] tapPlay | collection=$collectionName, '
      'index=$index, queueLength=${queueItems.length}, '
      'itemStableId=${queueItems[index].stableId}, '
      'itemTitle=${queueItems[index].title}',
    );
    await PlayerUtil.playQueueAndOpenPlayer(
      context,
      ref,
      items: queueItems,
      startIndex: index,
      sourceLabel: collectionName,
    );
  }

  Future<void> _showItemActionSheet(
    BuildContext context,
    WidgetRef ref, {
    required FavoriteCollection collection,
    required FavoriteEntry item,
  }) async {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final PlayableItem playableItem = item.toPlayableItem();

    await showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      builder: (BuildContext sheetContext) {
        final double bottomInset = MediaQuery.of(
          sheetContext,
        ).viewInsets.bottom;

        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 24 + bottomInset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                    leading: CommonCachedImage(
                      imageUrl: item.coverUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(14),
                      fallbackIcon: Icons.music_note_rounded,
                      iconColor: colorScheme.primary,
                      backgroundColor: colorScheme.primary.withValues(
                        alpha: 0.14,
                      ),
                    ),
                    title: Text(
                      buildFavoriteEntryTitle(item),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(
                      buildFavoriteEntrySubtitle(item),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _FavoriteActionTile(
                    icon: Icons.heart_broken_rounded,
                    title: '取消收藏',
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      final bool removed = await ref
                          .read(favoritesControllerProvider.notifier)
                          .removeFromCollection(
                            collectionId: collection.id,
                            itemId: item.itemId,
                          );
                      if (!context.mounted) {
                        return;
                      }
                      ToastUtil.show(
                        removed ? '已从“${collection.name}”移除' : '取消收藏失败',
                      );
                    },
                  ),
                  _FavoriteActionTile(
                    icon: Icons.playlist_add_rounded,
                    title: '加到歌单',
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await showPlayerCollectionSheet(
                        context: context,
                        item: playableItem,
                      );
                    },
                  ),
                  _FavoriteActionTile(
                    icon: Icons.person_rounded,
                    title: '查看UP主',
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _openOwnerPage(context, item);
                    },
                  ),
                  _FavoriteActionTile(
                    icon: Icons.skip_next_rounded,
                    title: '下一首播放',
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await PlayerUtil.playItemNextWithMultiPart(
                        context,
                        ref,
                        item: playableItem,
                      );
                      if (!context.mounted) {
                        return;
                      }
                      ToastUtil.show('已加入下一首');
                    },
                  ),
                  _FavoriteActionTile(
                    icon: Icons.share_rounded,
                    title: '分享',
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      ToastUtil.show('分享功能暂未开放');
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openOwnerPage(BuildContext context, FavoriteEntry item) {
    final int? ownerMid = item.ownerMid;
    if (ownerMid == null || ownerMid <= 0) {
      ToastUtil.show('暂无UP主信息');
      return;
    }
    context.push('/up/$ownerMid');
  }
}

class _RemoteCollectionErrorState extends StatelessWidget {
  const _RemoteCollectionErrorState({
    required this.isRetrying,
    required this.onRetry,
  });

  final bool isRetrying;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.wifi_off_rounded, color: colorScheme.primary, size: 42),
            const SizedBox(height: 16),
            Text(
              '网络歌单同步失败',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '请检查网络后重试。',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: isRetrying ? null : onRetry,
              icon: isRetrying
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded, size: 18),
              label: Text(isRetrying ? '同步中' : '重试'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteActionTile extends StatelessWidget {
  const _FavoriteActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onTap: onTap,
    );
  }
}
