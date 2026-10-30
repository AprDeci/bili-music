import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool?> showPlayerCollectionSheet({
  required BuildContext context,
  required PlayableItem item,
}) {
  return showPlayerCollectionItemsSheet(
    context: context,
    items: <PlayableItem>[item],
  );
}

Future<bool?> showPlayerCollectionItemsSheet({
  required BuildContext context,
  required List<PlayableItem> items,
}) async {
  if (items.isEmpty) {
    return false;
  }

  return showModalBottomSheet<bool>(
    useRootNavigator: true,
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (BuildContext context) {
      return SafeArea(child: _PlayerCollectionSheet(items: items));
    },
  );
}

class _PlayerCollectionSheet extends ConsumerStatefulWidget {
  const _PlayerCollectionSheet({required this.items});

  final List<PlayableItem> items;

  @override
  ConsumerState<_PlayerCollectionSheet> createState() =>
      _PlayerCollectionSheetState();
}

class _PlayerCollectionSheetState
    extends ConsumerState<_PlayerCollectionSheet> {
  _CollectionListTab _selectedTab = _CollectionListTab.remote;

  @override
  Widget build(BuildContext context) {
    final FavoritesState favoritesState = ref.watch(
      favoritesControllerProvider,
    );
    final List<FavoriteCollection> collections = _collectionsForSelectedTab(
      favoritesState,
    );
    final ThemeData theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      minChildSize: 0.28,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '添加 ${widget.items.length} 首到歌单',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      _CollectionTabButton(
                        label: '网络歌单',
                        selected: _selectedTab == _CollectionListTab.remote,
                        onTap: () => _selectTab(_CollectionListTab.remote),
                      ),
                      const SizedBox(width: 22),
                      _CollectionTabButton(
                        label: '本地歌单',
                        selected: _selectedTab == _CollectionListTab.local,
                        onTap: () => _selectTab(_CollectionListTab.local),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: collections.isEmpty
                  ? StatusView(
                      icon: Icons.queue_music_outlined,
                      title: _selectedTab == _CollectionListTab.remote
                          ? '暂无网络歌单'
                          : '暂无本地歌单',
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.only(bottom: 24),
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemCount: collections.length,
                      itemBuilder: (BuildContext context, int index) {
                        final FavoriteCollection collection =
                            collections[index];
                        final int addedItemCount = widget.items
                            .where(
                              (PlayableItem item) =>
                                  favoritesState.containsItemInCollection(
                                    collectionId: collection.id,
                                    item: item,
                                  ),
                            )
                            .length;
                        final int count = favoritesState.itemCountForCollection(
                          collection.id,
                        );

                        final String coverUrl =
                            collection.coverUrl?.trim() ?? '';
                        return _CollectionTile(
                          collection: collection,
                          coverUrl: coverUrl.isNotEmpty
                              ? coverUrl
                              : favoritesState
                                    .itemsForCollection(collection.id)
                                    .map((entry) => entry.coverUrl.trim())
                                    .firstWhere(
                                      (String url) => url.isNotEmpty,
                                      orElse: () => '',
                                    ),
                          count: collection.isRemote
                              ? collection.itemCount
                              : count,
                          addedItemCount: addedItemCount,
                          totalItemCount: widget.items.length,
                          onTap: () => _handleCollectionTap(
                            context: context,
                            collection: collection,
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  List<FavoriteCollection> _collectionsForSelectedTab(FavoritesState state) {
    final List<FavoriteCollection> collections = state.collections
        .where((FavoriteCollection collection) {
          return switch (_selectedTab) {
            _CollectionListTab.remote => collection.isRemote,
            _CollectionListTab.local =>
              collection.isLocal && !collection.isLikedCollection,
          };
        })
        .toList(growable: false);
    collections.sort(
      (FavoriteCollection a, FavoriteCollection b) =>
          b.updatedAt.compareTo(a.updatedAt),
    );
    return collections;
  }

  void _selectTab(_CollectionListTab tab) {
    if (_selectedTab == tab) {
      return;
    }
    setState(() {
      _selectedTab = tab;
    });
  }

  Future<void> _handleCollectionTap({
    required BuildContext context,
    required FavoriteCollection collection,
  }) async {
    final FavoritesState favoritesState = ref.read(favoritesControllerProvider);
    final List<PlayableItem> itemsToAdd = widget.items
        .where(
          (PlayableItem item) => !favoritesState.containsItemInCollection(
            collectionId: collection.id,
            item: item,
          ),
        )
        .toList(growable: false);
    if (itemsToAdd.isEmpty) {
      ToastUtil.showCenter('已经添加过了', icon: Icons.error_outline_rounded);
      return;
    }
    Navigator.of(context).pop(true);

    int addedCount = 0;
    for (final PlayableItem item in itemsToAdd) {
      final bool added = await ref
          .read(favoritesControllerProvider.notifier)
          .addToCollection(collectionId: collection.id, item: item);
      if (added) {
        addedCount++;
      }
    }

    if (!context.mounted) {
      return;
    }
    ToastUtil.show(
      '已新增 $addedCount / ${itemsToAdd.length} 项到“${collection.name}”',
    );
  }
}

enum _CollectionListTab { remote, local }

class _CollectionTabButton extends StatelessWidget {
  const _CollectionTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Semantics(
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({
    required this.collection,
    required this.coverUrl,
    required this.count,
    required this.addedItemCount,
    required this.totalItemCount,
    required this.onTap,
  });

  final FavoriteCollection collection;
  final String coverUrl;
  final int count;
  final int addedItemCount;
  final int totalItemCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool allAdded = addedItemCount == totalItemCount;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.grey.withValues(alpha: allAdded ? 0.5 : 0),
              BlendMode.srcATop,
            ),
            child: Row(
              children: <Widget>[
                CommonCachedImage(
                  imageUrl: coverUrl,
                  width: 48,
                  height: 48,
                  borderRadius: BorderRadius.circular(4),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  iconColor: colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.45,
                  ),
                  fallbackIcon: Icons.library_music_outlined,
                  iconSize: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        collection.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$count 首',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
