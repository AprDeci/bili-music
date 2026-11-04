import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/login_required.dart';
import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/download/logic/download_controller.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorite_entry_metadata.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/favorites/ui/components/collection_kind_dialog.dart';
import 'package:bilimusic/feature/profile/ui/components/remote_collection_import_dialog.dart';
import 'package:bilimusic/feature/profile/ui/components/user_card.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _showAllCollections = false;
  bool _didRefreshRemoteCollections = false;
  bool _isRefreshingRemoteCollections = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_refreshRemoteCollectionsOnEnter);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<BiliSession?>(biliSessionControllerProvider, (
      BiliSession? previous,
      BiliSession? next,
    ) {
      if ((previous?.isLoggedIn ?? false) || !(next?.isLoggedIn ?? false)) {
        return;
      }
      _didRefreshRemoteCollections = false;
      _refreshRemoteCollectionsOnEnter();
    });
    final bool isLoggedIn =
        (ref.watch(biliSessionControllerProvider)?.isLoggedIn ?? false);
    final FavoritesState favoritesState = ref.watch(
      favoritesControllerProvider,
    );
    final int likedCount = favoritesState.itemCountForCollection(
      FavoriteCollection.likedCollectionId,
    );
    final int recentCount = ref.watch(recentPlaybackControllerProvider).length;
    final int downloadCount = ref
        .watch(downloadControllerProvider)
        .tracks
        .length;
    final List<FavoriteCollection> collections =
        <FavoriteCollection>[
          ...favoritesState.collections.where(
            (FavoriteCollection collection) =>
                collection.isLocal && !collection.isSystem,
          ),
          if (isLoggedIn)
            ...favoritesState.collections.where(
              (FavoriteCollection collection) => collection.isRemote,
            ),
        ]..sort(
          (FavoriteCollection left, FavoriteCollection right) =>
              right.updatedAt.compareTo(left.updatedAt),
        );
    final bool shouldCollapse = collections.length > 5;
    final List<FavoriteCollection> visibleCollections =
        shouldCollapse && !_showAllCollections
        ? collections.take(5).toList(growable: false)
        : collections;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          children: <Widget>[
            UserCard(onSettingsPressed: () => context.push('/settings')),
            const SizedBox(height: 18),
            _ProfileQuickActions(
              likedCount: likedCount,
              recentCount: recentCount,
              downloadCount: downloadCount,
              onLikedTap: () => context.push(
                '/profile/favorites/${FavoriteCollection.likedCollectionId}',
              ),
              onLikedLongPressStart: (LongPressStartDetails details) =>
                  _showCollectionActionMenu(
                    details: details,
                    collection: favoritesState.likedCollection,
                  ),
              onRecentTap: () => context.push('/profile/recent'),
              onDownloadTap: () => context.push('/profile/downloads'),
            ),
            const SizedBox(height: 16),
            _ProfileSectionHeader(onAddPressed: _handleAddPressed),
            if (visibleCollections.isNotEmpty) const SizedBox(height: 14),
            ...visibleCollections.map((FavoriteCollection collection) {
              final List<FavoriteEntry> items = favoritesState
                  .itemsForCollection(collection.id);
              final FavoriteEntry? latestItem = items.isEmpty
                  ? null
                  : items.first;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PlaylistTile(
                  title: collection.name,
                  count: favoritesState.itemCountForCollection(collection.id),
                  isRemote: collection.isRemote,
                  coverUrl: ref.watch(
                    favoriteEntryCoverUrlProvider(collection.id, latestItem),
                  ),
                  onTap: () =>
                      context.push('/profile/favorites/${collection.id}'),
                  onLongPressStart: (LongPressStartDetails details) {
                    _showCollectionActionMenu(
                      details: details,
                      collection: collection,
                    );
                  },
                ),
              );
            }),
            if (shouldCollapse)
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showAllCollections = !_showAllCollections;
                    });
                  },
                  iconAlignment: IconAlignment.end,
                  icon: Icon(
                    _showAllCollections
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 22,
                  ),
                  label: Text(_showAllCollections ? '收起歌单' : '展开全部歌单'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF7A8598),
                    textStyle: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            const BottomPageSpacer(),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateCollectionDialog(BuildContext context) async {
    final String? result = await showDialog<String>(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return const _CollectionNameDialog(
          title: '新建歌单',
          hintText: '例如：深夜循环',
          confirmText: '创建',
        );
      },
    );

    if (result == null || result.trim().isEmpty) {
      if (result != null) {
        _showMessage('歌单名称不能为空');
      }
      return;
    }

    if (!context.mounted) return;
    final CollectionKind? kind = await showCollectionKindDialog(
      context: context,
    );
    if (!mounted || kind == null) return;

    final FavoritesController controller = ref.read(
      favoritesControllerProvider.notifier,
    );
    final FavoriteCollection? collection = await controller.createCollection(
      result,
      kind: kind,
    );
    if (!mounted) {
      return;
    }

    if (collection == null) {
      _showMessage('歌单名称已存在');
    }
  }

  Future<void> _showRemoteImportDialog() async {
    final FavoritesController controller = ref.read(
      favoritesControllerProvider.notifier,
    );
    final FavoriteCollection? collection = await showDialog<FavoriteCollection>(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return RemoteCollectionImportDialog(
          collectionsFuture: controller.fetchImportableRemoteCollections(),
        );
      },
    );

    if (!mounted || collection == null) {
      return;
    }

    final CollectionKind? kind = await showCollectionKindDialog(
      context: context,
      initialKind: collection.kind,
    );
    if (!mounted || kind == null) return;

    final _RemoteImportMode? mode = await showDialog<_RemoteImportMode>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('导入“${collection.name}”'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () =>
                  Navigator.of(context).pop(_RemoteImportMode.localCopy),
              child: const ListTile(
                leading: Icon(Icons.playlist_add_check_rounded),
                title: Text('导入为本地歌单'),
                subtitle: Text('拷贝一份到本地，之后 B 站改动不影响这里'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            SimpleDialogOption(
              onPressed: () =>
                  Navigator.of(context).pop(_RemoteImportMode.bindAndSync),
              child: const ListTile(
                leading: Icon(Icons.sync_rounded),
                title: Text('绑定并保持同步'),
                subtitle: Text('与 B 站收藏夹双向同步，增删会同步到 B 站'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        );
      },
    );
    if (!mounted || mode == null) return;

    if (mode == _RemoteImportMode.localCopy) {
      final FavoriteCollection? created = await controller
          .importRemoteCollectionAsLocal(collection, kind: kind);
      if (!mounted) {
        return;
      }
      _showMessage(
        created == null ? '导入失败，请稍后重试' : '已导入为本地歌单“${created.name}”',
      );
      return;
    }

    await controller.bindRemoteCollection(collection.copyWith(kind: kind));
    await controller.refreshRemoteCollectionItems(collectionId: collection.id);
    if (!mounted) {
      return;
    }
    _showMessage('已绑定“${collection.name}”，将保持同步');
  }

  Future<void> _refreshRemoteCollectionsOnEnter() async {
    if (_didRefreshRemoteCollections || _isRefreshingRemoteCollections) {
      return;
    }

    final BiliSession? session = ref.read(biliSessionControllerProvider);
    if (!(session?.isLoggedIn ?? false)) {
      return;
    }

    _didRefreshRemoteCollections = true;
    _isRefreshingRemoteCollections = true;
    try {
      await ref
          .read(favoritesControllerProvider.notifier)
          .refreshRemoteCollections();
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      if (LoginPrompt.handle(context, error, reason: '网络歌单需要重新登录')) {
        return;
      }
      _showMessage('网络歌单同步失败，请稍后重试');
    } finally {
      _isRefreshingRemoteCollections = false;
    }
  }

  Future<void> _handleAddPressed() async {
    final bool isLoggedIn =
        (ref.read(biliSessionControllerProvider)?.isLoggedIn ?? false);
    final _AddAction? action = await showModalBottomSheet<_AddAction>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.playlist_add_rounded),
                title: const Text('新建歌单'),
                subtitle: const Text('只在本地保存，不同步 B 站'),
                onTap: () => Navigator.of(context).pop(_AddAction.localCreate),
              ),
              if (isLoggedIn)
                ListTile(
                  leading: const Icon(Icons.cloud_download_outlined),
                  title: const Text('从 B站收藏夹导入'),
                  subtitle: const Text('默认拷贝一份到本地，也可选择绑定同步'),
                  onTap: () =>
                      Navigator.of(context).pop(_AddAction.remoteImport),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case _AddAction.localCreate:
        await _showCreateCollectionDialog(context);
      case _AddAction.remoteImport:
        if (!isLoggedIn) {
          LoginPrompt.show(context, reason: '导入 B站收藏夹需要登录 B 站账号');
          return;
        }
        await _showRemoteImportDialog();
    }
  }

  Future<void> _showCollectionActionMenu({
    required LongPressStartDetails details,
    required FavoriteCollection collection,
  }) async {
    final OverlayState overlay = Overlay.of(context);
    final RenderBox overlayBox =
        overlay.context.findRenderObject()! as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        details.globalPosition,
        details.globalPosition.translate(1, 1),
      ),
      Offset.zero & overlayBox.size,
    );

    HapticFeedback.lightImpact();
    final _CollectionAction? action = await showMenu<_CollectionAction>(
      context: context,
      position: position,
      items: <PopupMenuEntry<_CollectionAction>>[
        if (!collection.isSystem)
          PopupMenuItem<_CollectionAction>(
            value: _CollectionAction.rename,
            child: ListTile(
              leading: Icon(Icons.drive_file_rename_outline_rounded),
              title: Text(collection.isRemote ? '重命名 B 站收藏夹' : '重命名'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (collection.isRemote)
          PopupMenuItem<_CollectionAction>(
            value: _CollectionAction.sync,
            child: ListTile(
              leading: Icon(Icons.sync_rounded),
              title: Text('同步'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (collection.isRemote)
          PopupMenuItem<_CollectionAction>(
            value: _CollectionAction.remove,
            child: ListTile(
              leading: Icon(Icons.remove_circle_outline_rounded),
              title: Text('解除绑定'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (!collection.isSystem)
          PopupMenuItem<_CollectionAction>(
            value: _CollectionAction.delete,
            child: ListTile(
              leading: Icon(Icons.delete_outline_rounded),
              title: Text('删除'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (!collection.isSystem || collection.isRemote)
          const PopupMenuDivider(),
        const PopupMenuItem<_CollectionAction>(
          value: _CollectionAction.changeKind,
          child: ListTile(
            leading: Icon(Icons.category_outlined),
            title: Text('修改类型'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case _CollectionAction.changeKind:
        final CollectionKind? kind = await showCollectionKindDialog(
          context: context,
          initialKind: collection.kind,
          title: '修改类型',
        );
        if (!mounted || kind == null || kind == collection.kind) return;
        bool saved;
        try {
          saved = await ref
              .read(favoritesControllerProvider.notifier)
              .setCollectionKind(collectionId: collection.id, kind: kind);
        } on Object {
          saved = false;
        }
        if (!saved) {
          _showMessage('类型保存失败，请重试');
        }
      case _CollectionAction.rename:
        await _showRenameCollectionDialog(collection);
      case _CollectionAction.sync:
        await _syncRemoteCollection(collection);
      case _CollectionAction.delete:
        await _showDeleteCollectionDialog(collection);
      case _CollectionAction.remove:
        await _showRemoveRemoteCollectionDialog(collection);
    }
  }

  Future<void> _syncRemoteCollection(FavoriteCollection collection) async {
    _showMessage('正在同步“${collection.name}”…');
    try {
      await ref
          .read(favoritesControllerProvider.notifier)
          .syncRemoteCollectionIfStale(collection.id, force: true);
      if (!mounted) {
        return;
      }
      _showMessage('同步完成');
    } on Object {
      if (!mounted) {
        return;
      }
      _showMessage('同步失败，请稍后重试');
    }
  }

  Future<void> _showRenameCollectionDialog(
    FavoriteCollection collection,
  ) async {
    final String? result = await showDialog<String>(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return _CollectionNameDialog(
          title: '重命名歌单',
          hintText: '请输入歌单名称',
          confirmText: '保存',
          initialValue: collection.name,
        );
      },
    );

    if (result == null) {
      return;
    }

    final String trimmedName = result.trim();
    if (trimmedName.isEmpty) {
      _showMessage('歌单名称不能为空');
      return;
    }

    if (trimmedName == collection.name.trim()) {
      return;
    }

    final bool renamed = await ref
        .read(favoritesControllerProvider.notifier)
        .renameCollection(collectionId: collection.id, name: trimmedName);
    if (!mounted) {
      return;
    }

    _showMessage(renamed ? '已重命名歌单' : '歌单名称已存在');
  }

  Future<void> _showDeleteCollectionDialog(
    FavoriteCollection collection,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('删除歌单'),
          content: Text(
            collection.isRemote
                ? '确认删除“${collection.name}”？这会同时删除 B 站收藏夹，无法恢复。'
                : '确认删除“${collection.name}”？删除后无法恢复。',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final bool deleted = await ref
        .read(favoritesControllerProvider.notifier)
        .deleteCollection(collection.id);
    if (!mounted) {
      return;
    }
    ToastUtil.show(deleted ? '已删除歌单' : '删除失败');
  }

  Future<void> _showRemoveRemoteCollectionDialog(
    FavoriteCollection collection,
  ) async {
    if (!collection.isRemote) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('解除绑定'),
          content: Text(
            '确认解除“${collection.name}”与 App 的绑定？只会从列表移除，不会删除 B 站收藏夹。',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('解除绑定'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final bool removed = await ref
        .read(favoritesControllerProvider.notifier)
        .removeRemoteCollection(collection.id);
    if (!mounted) {
      return;
    }
    ToastUtil.show(removed ? '已解除绑定' : '解除绑定失败');
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ToastUtil.show(message);
  }
}

enum _CollectionAction { rename, delete, remove, changeKind, sync }

enum _AddAction { localCreate, remoteImport }

enum _RemoteImportMode { localCopy, bindAndSync }

class _CollectionNameDialog extends StatefulWidget {
  const _CollectionNameDialog({
    required this.title,
    required this.hintText,
    required this.confirmText,
    this.initialValue = '',
  });

  final String title;
  final String hintText;
  final String confirmText;
  final String initialValue;

  @override
  State<_CollectionNameDialog> createState() => _CollectionNameDialogState();
}

class _CollectionNameDialogState extends State<_CollectionNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        maxLength: 24,
        autofocus: true,
        decoration: InputDecoration(hintText: widget.hintText),
        onSubmitted: (String value) {
          Navigator.of(context).pop(value);
        },
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
}

class _ProfileQuickActions extends StatelessWidget {
  const _ProfileQuickActions({
    required this.likedCount,
    required this.recentCount,
    required this.downloadCount,
    required this.onLikedTap,
    required this.onLikedLongPressStart,
    required this.onRecentTap,
    required this.onDownloadTap,
  });

  final int likedCount;
  final int recentCount;
  final int downloadCount;
  final VoidCallback onLikedTap;
  final GestureLongPressStartCallback onLikedLongPressStart;
  final VoidCallback onRecentTap;
  final VoidCallback onDownloadTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _ProfileQuickActionCard(
            icon: Icons.favorite_rounded,
            title: '我喜欢',
            count: likedCount,
            onTap: onLikedTap,
            onLongPressStart: onLikedLongPressStart,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ProfileQuickActionCard(
            icon: Icons.history_rounded,
            title: '历史记录',
            count: recentCount,
            onTap: onRecentTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ProfileQuickActionCard(
            icon: Icons.library_music_rounded,
            title: '本地',
            count: downloadCount,
            onTap: onDownloadTap,
          ),
        ),
      ],
    );
  }
}

class _ProfileQuickActionCard extends StatelessWidget {
  const _ProfileQuickActionCard({
    required this.icon,
    required this.title,
    required this.count,
    this.onTap,
    this.onLongPressStart,
  });

  final IconData icon;
  final String title;
  final int count;
  final VoidCallback? onTap;
  final GestureLongPressStartCallback? onLongPressStart;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return GestureDetector(
      onLongPressStart: onLongPressStart,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        hoverColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: <Widget>[
              Icon(icon, color: colorScheme.primary, size: 26),
              const SizedBox(height: 4),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSectionHeader extends StatelessWidget {
  const _ProfileSectionHeader({required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Text(
          '歌单',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onAddPressed,
            child: SizedBox(
              width: 38,
              height: 38,
              child: Icon(
                Icons.add_rounded,
                color: Colors.grey.withValues(alpha: 0.9),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  const _PlaylistTile({
    required this.title,
    required this.count,
    required this.isRemote,
    required this.coverUrl,
    required this.onTap,
    required this.onLongPressStart,
  });

  final String title;
  final int count;
  final bool isRemote;
  final String? coverUrl;
  final VoidCallback onTap;
  final ValueChanged<LongPressStartDetails> onLongPressStart;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onLongPressStart: onLongPressStart,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: <Widget>[
                _PlaylistCover(coverUrl: coverUrl),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (isRemote) ...<Widget>[
                            const SizedBox(width: 6),
                            _RemoteSourceBadge(colorScheme: colorScheme),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$count 首',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RemoteSourceBadge extends StatelessWidget {
  const _RemoteSourceBadge({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.sync_rounded, size: 10, color: colorScheme.primary),
          const SizedBox(width: 2),
          Text(
            'B站',
            style: TextStyle(
              fontSize: 9,
              height: 1.3,
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaylistCover extends StatelessWidget {
  const _PlaylistCover({required this.coverUrl});

  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return CommonCachedImage(
      imageUrl: coverUrl,
      width: 64,
      height: 64,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(8),
      placeholder: _PlaylistPlaceholder(primary: primary),
      errorWidget: _PlaylistPlaceholder(primary: primary),
    );
  }
}

class _PlaylistPlaceholder extends StatelessWidget {
  const _PlaylistPlaceholder({required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            primary.withValues(alpha: 0.18),
            primary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.queue_music_rounded, color: primary, size: 28),
    );
  }
}
