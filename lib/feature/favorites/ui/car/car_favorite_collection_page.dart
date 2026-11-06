import 'dart:async';

import 'package:bilimusic/common/components/car/car_content_widgets.dart';
import 'package:bilimusic/common/components/login_required.dart';
import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/favorites/logic/favorite_entry_metadata.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_view_mode_logic.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorite_entry_subtitle.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorites_metadata_toolbar_buttons.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/ui/components/player_collection_sheet.dart';
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
  bool _selectionMode = false;
  bool _busy = false;
  bool _deleting = false;
  Set<String> _selectedItemIds = <String>{};
  String? _operationError;

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
      _selectionMode = false;
      _selectedItemIds = <String>{};
      _operationError = null;
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
    if (!mounted || _syncing || _busy) {
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

  void _setSelectionMode(bool enabled) {
    setState(() {
      _selectionMode = enabled;
      _selectedItemIds = <String>{};
      _operationError = null;
    });
  }

  void _toggleItem(String itemId) {
    if (_busy) return;
    setState(() {
      _selectionMode = true;
      if (!_selectedItemIds.add(itemId)) {
        _selectedItemIds.remove(itemId);
      }
      _operationError = null;
    });
  }

  Future<void> _play(FavoriteCollection collection, int index) async {
    final List<PlayableItem> items = ref
        .read(favoritesControllerProvider)
        .itemsForCollection(collection.id)
        .map((entry) => entry.toPlayableItem(collection: collection))
        .toList(growable: false);
    if (index < 0 || index >= items.length) return;
    try {
      await PlayerUtil.playQueueAndOpenPlayer(
        context,
        ref,
        items: items,
        startIndex: index,
        sourceLabel: collection.name,
      );
    } on Object {
      if (mounted) ToastUtil.show('播放失败，请重试');
    }
  }

  Future<void> _addSelected(
    FavoriteCollection collection,
    List<FavoriteEntry> selected,
  ) async {
    if (_busy || selected.isEmpty) return;
    setState(() => _busy = true);
    try {
      final bool? added = await showPlayerCollectionItemsSheet(
        context: context,
        items: selected
            .map((entry) => entry.toPlayableItem(collection: collection))
            .toList(growable: false),
        carStyle: true,
      );
      if (mounted && widget.collectionId == collection.id && added == true) {
        _setSelectionMode(false);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteSelected(
    FavoriteCollection collection,
    List<FavoriteEntry> selected,
  ) async {
    if (_busy || _syncing || selected.isEmpty) return;
    final FavoritesController controller = ref.read(
      favoritesControllerProvider.notifier,
    );
    setState(() {
      _busy = true;
      _operationError = null;
    });
    try {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('删除收藏'),
          content: Text(
            '确定从“${collection.name}”移除 ${selected.length} 项吗？${collection.isRemote ? '\n此操作也会删除 B 站收藏夹中的对应视频。' : ''}',
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(80, 56)),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(80, 56)),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('删除'),
            ),
          ],
        ),
      );
      if (confirmed != true ||
          !mounted ||
          widget.collectionId != collection.id) {
        return;
      }
      setState(() => _deleting = true);
      int removedCount = 0;
      for (final FavoriteEntry entry in selected) {
        try {
          if (await controller.removeFromCollection(
            collectionId: collection.id,
            itemId: entry.itemId,
          )) {
            removedCount++;
          }
        } on Object catch (error) {
          if (mounted &&
              LoginPrompt.handle(context, error, reason: '删除网络收藏需要重新登录')) {
            break;
          }
        }
      }
      if (!mounted || widget.collectionId != collection.id) return;
      final Set<String> remaining = ref
          .read(favoritesControllerProvider)
          .itemsForCollection(collection.id)
          .map((entry) => entry.itemId)
          .toSet();
      setState(() {
        _selectedItemIds = selected
            .map((entry) => entry.itemId)
            .toSet()
            .intersection(remaining);
        _selectionMode = _selectedItemIds.isNotEmpty;
        _operationError = _selectedItemIds.isEmpty
            ? null
            : '已移除 $removedCount / ${selected.length} 项，未移除项已保留选中，请重试。';
      });
      ToastUtil.show('已移除 $removedCount / ${selected.length} 项');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _deleting = false;
        });
      }
    }
  }

  Widget _toolbar(FavoriteCollection collection, List<FavoriteEntry> entries) {
    final List<FavoriteEntry> selected = entries
        .where((entry) => _selectedItemIds.contains(entry.itemId))
        .toList(growable: false);
    final bool allSelected =
        entries.isNotEmpty && selected.length == entries.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '已选 ${selected.length} 项',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(80, 56)),
            onPressed: _busy
                ? null
                : () => setState(
                    () => _selectedItemIds = allSelected
                        ? <String>{}
                        : entries.map((entry) => entry.itemId).toSet(),
                  ),
            child: Text(allSelected ? '取消全选' : '全选'),
          ),
          FilledButton.tonalIcon(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 56)),
            onPressed: _busy || selected.isEmpty
                ? null
                : () => _addSelected(collection, selected),
            icon: const Icon(Icons.playlist_add_rounded),
            label: const Text('添加到歌单'),
          ),
          TextButton.icon(
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 56),
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: _busy || _syncing || selected.isEmpty
                ? null
                : () => _deleteSelected(collection, selected),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('删除'),
          ),
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(80, 56)),
            onPressed: _busy ? null : () => _setSelectionMode(false),
            child: const Text('完成'),
          ),
        ],
      ),
    );
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
    final List<FavoriteEntry> items = collection == null
        ? const <FavoriteEntry>[]
        : state.itemsForCollection(collection.id);
    final FavoriteListViewMode viewMode = collection == null
        ? FavoriteListViewMode.video
        : ref.watch(effectiveFavoritesViewModeProvider(collection.id));
    return PopScope(
      canPop: !_busy && !_selectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_busy && _selectionMode) _setSelectionMode(false);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CarContentHeader(
            title: collection?.name ?? '歌单',
            backLocation: _busy || _selectionMode ? null : '/profile',
            action: collection == null
                ? null
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!collection.isSpoken)
                        MetadataViewModeButton(
                          viewMode: viewMode,
                          buttonSize: 56,
                          onPressed: () => ref
                              .read(
                                favoritesViewModeLogicProvider(
                                  collection.id,
                                ).notifier,
                              )
                              .toggle(),
                        ),
                      if (collection.isRemote)
                        IconButton(
                          tooltip: '同步歌单',
                          constraints: const BoxConstraints(
                            minWidth: 56,
                            minHeight: 56,
                          ),
                          onPressed: _syncing || _busy
                              ? null
                              : () => _sync(force: true),
                          icon: const Icon(Icons.sync_rounded),
                        ),
                    ],
                  ),
          ),
          if (collection != null && _selectionMode) _toolbar(collection, items),
          if (_operationError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                _operationError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (_syncing || _deleting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(),
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
                    style: TextButton.styleFrom(
                      minimumSize: const Size(56, 56),
                    ),
                    onPressed: _syncing || _busy
                        ? null
                        : () => _sync(force: true),
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
                    child: items.isEmpty
                        ? CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              SliverStatusView(
                                child: StatusView(
                                  title: '这个歌单还是空的',
                                  description: collection.isRemote
                                      ? '同步完成后暂无可播放内容，可稍后再次同步。'
                                      : '在搜索页或播放器收藏歌曲后，即可在这里收听。',
                                  icon: Icons.music_note_rounded,
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final FavoriteEntry entry = items[index];
                              return _CarFavoriteSongTile(
                                key: ValueKey(
                                  '${collection.id}:${entry.itemId}',
                                ),
                                entry: entry,
                                collection: collection,
                                index: index,
                                viewMode: viewMode,
                                selectionMode: _selectionMode,
                                selected: _selectedItemIds.contains(
                                  entry.itemId,
                                ),
                                onTap: _busy
                                    ? null
                                    : () => _selectionMode
                                          ? _toggleItem(entry.itemId)
                                          : _play(collection, index),
                                onLongPress: _busy
                                    ? null
                                    : () => _toggleItem(entry.itemId),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CarFavoriteSongTile extends ConsumerWidget {
  const _CarFavoriteSongTile({
    super.key,
    required this.entry,
    required this.collection,
    required this.index,
    required this.viewMode,
    required this.selectionMode,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final FavoriteEntry entry;
  final FavoriteCollection collection;
  final int index;
  final FavoriteListViewMode viewMode;
  final bool selectionMode;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool metadataView = viewMode == FavoriteListViewMode.metadata;
    final Metadata? metadata = metadataView
        ? ref
              .watch(favoriteEntryMetadataProvider(entry.contentId))
              .asData
              ?.value
        : null;
    final String title = metadata?.title?.trim() ?? '';
    final String artist = metadata?.artist?.trim() ?? '';
    final String cover = metadata?.albumArtUrl?.trim() ?? '';
    return CarSongTile(
      item: entry.toPlayableItem(collection: collection),
      index: index,
      title: title.isNotEmpty ? title : entry.title,
      subtitle: metadataView
          ? '${artist.isNotEmpty ? artist : entry.author}${metadata?.hasContent == true ? '' : ' · 未解析'}'
          : buildFavoriteEntrySubtitle(entry),
      coverUrl: cover.isNotEmpty ? cover : entry.coverUrl,
      selected: selectionMode ? selected : null,
      onTap: onTap,
      onLongPress: onLongPress,
      trailing: selectionMode
          ? Checkbox(
              value: selected,
              onChanged: onTap == null ? null : (_) => onTap!(),
              materialTapTargetSize: MaterialTapTargetSize.padded,
              visualDensity: const VisualDensity(horizontal: 4, vertical: 4),
            )
          : null,
    );
  }
}
