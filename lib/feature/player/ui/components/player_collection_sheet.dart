import 'package:bilimusic/common/util/toast_util.dart';
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

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.68,
      minChildSize: 0.34,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
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
                  ? _EmptyCollectionHint(tab: _selectedTab)
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: collections.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
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

                        return _CollectionTile(
                          collection: collection,
                          count: count,
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
    Navigator.of(context).pop(true);

    final FavoritesState favoritesState = ref.read(favoritesControllerProvider);
    final List<PlayableItem> itemsToAdd = widget.items
        .where(
          (PlayableItem item) => !favoritesState.containsItemInCollection(
            collectionId: collection.id,
            item: item,
          ),
        )
        .toList(growable: false);
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: selected
                ? Colors.black
                : Colors.black.withValues(alpha: 0.45),
            fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EmptyCollectionHint extends StatelessWidget {
  const _EmptyCollectionHint({required this.tab});

  final _CollectionListTab tab;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return Center(
      child: Text(
        tab == _CollectionListTab.remote ? '暂无网络歌单' : '暂无本地歌单',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({
    required this.collection,
    required this.count,
    required this.addedItemCount,
    required this.totalItemCount,
    required this.onTap,
  });

  final FavoriteCollection collection;
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
      color: allAdded
          ? colorScheme.primary.withValues(alpha: 0.1)
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 22,
                backgroundColor: allAdded
                    ? colorScheme.primary
                    : colorScheme.primary.withValues(alpha: 0.12),
                foregroundColor: allAdded
                    ? colorScheme.onPrimary
                    : colorScheme.primary,
                child: Icon(
                  collection.isRemote
                      ? Icons.cloud_outlined
                      : Icons.folder_open_rounded,
                ),
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
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count 首 · 已添加 $addedItemCount / $totalItemCount 项',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.64),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                allAdded
                    ? Icons.check_circle_rounded
                    : Icons.add_circle_outline_rounded,
                color: allAdded
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
