import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/car/car_side_panel.dart';
import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/layout/app_layout.dart';
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
  bool carStyle = false,
}) async {
  if (items.isEmpty) {
    return false;
  }

  if (AppLayoutScope.of(context) == AppLayout.car) {
    return showCarSidePanel<bool>(
      context: context,
      alignment: Alignment.centerRight,
      slideFrom: const Offset(1, 0),
      builder: (_) =>
          _PlayerCollectionSheet(items: items, carStyle: true, sidePanel: true),
    );
  }
  return showModalBottomSheet<bool>(
    useRootNavigator: true,
    context: context,
    showDragHandle: false,
    enableDrag: false,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (BuildContext context) {
      return SafeArea(
        child: _PlayerCollectionSheet(items: items, carStyle: carStyle),
      );
    },
  );
}

class _PlayerCollectionSheet extends ConsumerStatefulWidget {
  const _PlayerCollectionSheet({
    required this.items,
    this.carStyle = false,
    this.sidePanel = false,
  });

  final List<PlayableItem> items;
  final bool carStyle;
  final bool sidePanel;

  @override
  ConsumerState<_PlayerCollectionSheet> createState() =>
      _PlayerCollectionSheetState();
}

class _PlayerCollectionSheetState
    extends ConsumerState<_PlayerCollectionSheet> {
  _CollectionListTab _selectedTab = _CollectionListTab.remote;
  bool _isAdding = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final FavoritesState favoritesState = ref.watch(
      favoritesControllerProvider,
    );
    final List<FavoriteCollection> collections = _collectionsForSelectedTab(
      favoritesState,
    );
    final ThemeData theme = Theme.of(context);

    Widget buildContent(ScrollController? scrollController) {
      return Column(
        children: <Widget>[
          if (!widget.sidePanel)
            SizedBox(
              height: 32,
              child: Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, widget.sidePanel ? 20 : 0, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '添加 ${widget.items.length} 首到歌单',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    fontSize: widget.carStyle ? 24 : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    _CollectionTabButton(
                      label: '网络歌单',
                      carStyle: widget.carStyle,
                      selected: _selectedTab == _CollectionListTab.remote,
                      onTap: () => _selectTab(_CollectionListTab.remote),
                    ),
                    const SizedBox(width: 22),
                    _CollectionTabButton(
                      label: '本地歌单',
                      carStyle: widget.carStyle,
                      selected: _selectedTab == _CollectionListTab.local,
                      onTap: () => _selectTab(_CollectionListTab.local),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isAdding) const LinearProgressIndicator(),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                _errorMessage!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                  fontSize: widget.carStyle ? 20 : null,
                ),
                semanticsLabel: _errorMessage,
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
                      final FavoriteCollection collection = collections[index];
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

                      final String coverUrl = collection.coverUrl?.trim() ?? '';
                      return _CollectionTile(
                        collection: collection,
                        carStyle: widget.carStyle,
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
                        onTap: () =>
                            _handleCollectionTap(collection: collection),
                      );
                    },
                  ),
          ),
        ],
      );
    }

    return PopScope<bool>(
      canPop: !_isAdding,
      child: AbsorbPointer(
        absorbing: _isAdding,
        child: widget.sidePanel
            ? buildContent(null)
            : DraggableScrollableSheet(
                expand: false,
                shouldCloseOnMinExtent: !_isAdding,
                initialChildSize: widget.carStyle ? 0.75 : 0.5,
                minChildSize: 0.28,
                maxChildSize: 0.9,
                builder: (_, scrollController) =>
                    buildContent(scrollController),
              ),
      ),
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
    required FavoriteCollection collection,
  }) async {
    if (_isAdding) {
      return;
    }
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
    final FavoritesController controller = ref.read(
      favoritesControllerProvider.notifier,
    );
    setState(() {
      _isAdding = true;
      _errorMessage = null;
    });

    int addedCount = 0;
    bool failed = false;
    try {
      for (final PlayableItem item in itemsToAdd) {
        final bool added = await controller.addToCollection(
          collectionId: collection.id,
          item: item,
        );
        if (added) {
          addedCount++;
        } else {
          failed = true;
        }
      }
    } on Object {
      failed = true;
    }

    if (!mounted) {
      return;
    }
    final String result =
        '已新增 $addedCount / ${itemsToAdd.length} 项到“${collection.name}”';
    setState(() {
      _isAdding = false;
      _errorMessage = failed ? '$result，部分添加失败，请点击歌单重试' : null;
    });
    if (failed) {
      return;
    }
    Navigator.of(context).pop(true);
    ToastUtil.show(result);
  }
}

enum _CollectionListTab { remote, local }

class _CollectionTabButton extends StatelessWidget {
  const _CollectionTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.carStyle = false,
  });

  final String label;
  final bool selected;
  final bool carStyle;
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
          constraints: BoxConstraints(minHeight: carStyle ? 56 : 48),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: carStyle ? 22 : null,
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
    this.carStyle = false,
  });

  final FavoriteCollection collection;
  final String coverUrl;
  final int count;
  final int addedItemCount;
  final int totalItemCount;
  final VoidCallback onTap;
  final bool carStyle;

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
                  width: carStyle ? 64 : 48,
                  height: carStyle ? 64 : 48,
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
                          fontSize: carStyle ? 22 : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$count 首',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: carStyle ? 20 : null,
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
