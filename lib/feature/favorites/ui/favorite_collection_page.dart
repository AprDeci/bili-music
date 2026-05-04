import 'package:bilimusic/common/bm_icons.dart';
import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorite_entry_search.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorite_collection_search_field.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorite_search_empty_state.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_collection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FavoriteCollectionPage extends ConsumerStatefulWidget {
  const FavoriteCollectionPage({super.key, required this.collectionId});

  static final AppLogger _logger = AppLogger('FavoriteCollectionPage');

  final String collectionId;

  @override
  ConsumerState<FavoriteCollectionPage> createState() =>
      _FavoriteCollectionPageState();
}

class _FavoriteCollectionPageState
    extends ConsumerState<FavoriteCollectionPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void didUpdateWidget(covariant FavoriteCollectionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.collectionId != widget.collectionId) {
      _resetSearchState();
    }
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

  void _resetSearchStateWithoutSetState() {
    if (_searchQuery.isEmpty && _searchController.text.isEmpty) {
      return;
    }

    _searchController.clear();
    _searchQuery = '';
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
      backgroundColor: colorScheme.surface.withValues(alpha: 0.4),
      appBar: AppBar(title: Text(resolvedCollection.name)),
      body: items.isEmpty
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
          : ListView(
              padding: EdgeInsets.zero,
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
                if (visibleItems.isEmpty)
                  FavoriteSearchEmptyState(
                    onSearchOnline: () => context.go('/search'),
                  )
                else
                  ...List<Widget>.generate(visibleItems.length, (int index) {
                    final FavoriteEntry item = visibleItems[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == visibleItems.length - 1 ? 0 : 0,
                      ),
                      child: Material(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 0,
                          ),
                          leading: CommonCachedImage(
                            imageUrl: item.coverUrl,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(8),
                            fallbackIcon: Icons.music_note_rounded,
                            iconColor: primary,
                            backgroundColor: primary.withValues(alpha: 0.14),
                          ),
                          title: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                            _buildSubtitle(item),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            spacing: 0,
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                tooltip: '播放',
                                onPressed: () async {
                                  await _playCollectionItem(
                                    context,
                                    ref,
                                    collectionName: resolvedCollection.name,
                                    queueItems: queueItems,
                                    index: index,
                                  );
                                },
                                icon: const Icon(BmIcons.addPlaylist),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                tooltip: '更多',
                                onPressed: () async {
                                  await _showItemActionSheet(
                                    context,
                                    ref,
                                    collection: resolvedCollection,
                                    item: item,
                                  );
                                },
                                icon: const Icon(Icons.more_vert_outlined),
                              ),
                            ],
                          ),
                          onTap: () async {
                            await _playCollectionItem(
                              context,
                              ref,
                              collectionName: resolvedCollection.name,
                              queueItems: queueItems,
                              index: index,
                            );
                          },
                        ),
                      ),
                    );
                  }),
                const BottomPageSpacer.overlay(),
              ],
            ),
    );
  }

  String _buildSubtitle(FavoriteEntry item) {
    final List<String> segments = <String>[item.author];
    final int? page = item.page;
    final String pageTitle = item.pageTitle?.trim() ?? '';

    if (page != null && page > 0) {
      segments.add('P$page');
    }
    if (pageTitle.isNotEmpty) {
      segments.add(pageTitle);
    }
    if (item.durationText != null && item.durationText!.isNotEmpty) {
      segments.add(item.durationText!);
    }

    return segments.join(' · ');
  }

  Future<void> _playCollectionItem(
    BuildContext context,
    WidgetRef ref, {
    required String collectionName,
    required List<PlayableItem> queueItems,
    required int index,
  }) async {
    FavoriteCollectionPage._logger.d(
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
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(
                      _buildSubtitle(item),
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
                    icon: Icons.skip_next_rounded,
                    title: '下一首播放',
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await ref
                          .read(playerControllerProvider.notifier)
                          .playNext(playableItem);
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
