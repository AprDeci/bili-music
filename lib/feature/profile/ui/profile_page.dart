import 'package:bilimusic/common/bm_icons.dart';
import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/searchBar.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/auth/data/bili_auth_repository.dart';
import 'package:bilimusic/feature/auth/logic/bili_auth_controller.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/profile/ui/components/remote_collection_import_dialog.dart';
import 'package:bilimusic/feature/profile/ui/components/user_card.dart';
import 'package:bilimusic/feature/up/logic/favorite_up_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _showAllCollections = false;
  bool _didRefreshRemoteCollections = false;
  bool _isRefreshingRemoteCollections = false;
  _FavoriteListTab _selectedTab = _FavoriteListTab.remote;

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
    ref.watch(biliSessionControllerProvider);
    final FavoritesState favoritesState = ref.watch(
      favoritesControllerProvider,
    );
    final int likedCount = favoritesState.itemCountForCollection(
      FavoriteCollection.likedCollectionId,
    );
    final int favoriteUpCount = ref.watch(favoriteUpControllerProvider).length;
    final List<FavoriteCollection> remoteCollections = favoritesState
        .collections
        .where((FavoriteCollection collection) => collection.isRemote)
        .toList(growable: false);
    final List<FavoriteCollection> localCollections = favoritesState.collections
        .where(
          (FavoriteCollection collection) =>
              collection.isLocal && !collection.isSystem,
        )
        .toList(growable: false);
    final List<FavoriteCollection> selectedCollections = switch (_selectedTab) {
      _FavoriteListTab.remote => remoteCollections,
      _FavoriteListTab.local => localCollections,
    };
    final bool shouldCollapse = selectedCollections.length > 5;
    final List<FavoriteCollection> visibleCollections =
        shouldCollapse && !_showAllCollections
        ? selectedCollections.take(5).toList(growable: false)
        : selectedCollections;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        title: CommonSearchBar(
          onTap: () => context.push('/search?from=/profile'),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        children: <Widget>[
          UserCard(onLogoutPressed: _handleLogoutPressed),
          const SizedBox(height: 18),
          _ProfileQuickActions(
            likedCount: likedCount,
            favoriteUpCount: favoriteUpCount,
            onLikedTap: () => context.push(
              '/profile/favorites/${FavoriteCollection.likedCollectionId}',
            ),
            onFavoriteUpTap: () => context.push('/profile/favorite-ups'),
          ),
          const SizedBox(height: 16),
          _ProfileSectionHeader(
            selectedTab: _selectedTab,
            onTabChanged: _handleTabChanged,
            onAddPressed: _handleAddPressed,
            onImportPressed: _handleImportPressed,
          ),
          if (visibleCollections.isNotEmpty) const SizedBox(height: 14),
          ...visibleCollections.map((FavoriteCollection collection) {
            final List<FavoriteEntry> items = favoritesState.itemsForCollection(
              collection.id,
            );
            final FavoriteEntry? latestItem = items.isEmpty
                ? null
                : items.first;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PlaylistTile(
                title: collection.name,
                count: collection.isRemote
                    ? collection.itemCount
                    : items.length,
                coverUrl: latestItem?.coverUrl,
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
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          const BottomPageSpacer.tab(),
        ],
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

    final FavoritesController controller = ref.read(
      favoritesControllerProvider.notifier,
    );
    final FavoriteCollection? collection = await controller.createCollection(
      result,
    );
    if (!mounted) {
      return;
    }

    if (collection == null) {
      _showMessage('歌单名称已存在');
    }
  }

  Future<void> _showCreateRemoteCollectionDialog() async {
    final String? result = await showDialog<String>(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return const _CollectionNameDialog(
          title: '新建网络歌单',
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

    final FavoriteCollection? collection = await ref
        .read(favoritesControllerProvider.notifier)
        .createRemoteCollection(result);
    if (!mounted) {
      return;
    }

    if (collection == null) {
      _showMessage('创建网络歌单失败');
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

    await controller.bindRemoteCollection(collection);
    await controller.refreshRemoteCollectionItems(collectionId: collection.id);
    if (!mounted) {
      return;
    }
    _showMessage('已导入“${collection.name}”');
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
    } on Object {
      if (!mounted) {
        return;
      }
      _showMessage('网络歌单同步失败，请稍后重试');
    } finally {
      _isRefreshingRemoteCollections = false;
    }
  }

  Future<void> _showRemoteAddOptions(BuildContext context) async {
    final _RemoteAddAction? action = await showDialog<_RemoteAddAction>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('添加网络歌单'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () =>
                  Navigator.of(context).pop(_RemoteAddAction.import),
              child: const ListTile(
                leading: Icon(Icons.cloud_download_outlined),
                title: Text('导入已有收藏夹'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            SimpleDialogOption(
              onPressed: () =>
                  Navigator.of(context).pop(_RemoteAddAction.create),
              child: const ListTile(
                leading: Icon(Icons.add_rounded),
                title: Text('新建网络歌单'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case _RemoteAddAction.import:
        await _showRemoteImportDialog();
      case _RemoteAddAction.create:
        if (!mounted) {
          return;
        }
        await _showCreateRemoteCollectionDialog();
    }
  }

  void _handleTabChanged(_FavoriteListTab tab) {
    if (_selectedTab == tab) {
      return;
    }
    setState(() {
      _selectedTab = tab;
      _showAllCollections = false;
    });
  }

  void _handleAddPressed() {
    switch (_selectedTab) {
      case _FavoriteListTab.remote:
        _showRemoteAddOptions(context);
      case _FavoriteListTab.local:
        _showCreateCollectionDialog(context);
    }
  }

  void _handleImportPressed() {
    context.push('/profile/import');
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
        PopupMenuItem<_CollectionAction>(
          value: _CollectionAction.rename,
          child: ListTile(
            leading: Icon(Icons.drive_file_rename_outline_rounded),
            title: Text('重命名'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        if (collection.isRemote)
          PopupMenuItem<_CollectionAction>(
            value: _CollectionAction.remove,
            child: ListTile(
              leading: Icon(Icons.remove_circle_outline_rounded),
              title: Text('移除'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        PopupMenuItem<_CollectionAction>(
          value: _CollectionAction.delete,
          child: ListTile(
            leading: Icon(Icons.delete_outline_rounded),
            title: Text('删除'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case _CollectionAction.rename:
        await _showRenameCollectionDialog(collection);
      case _CollectionAction.delete:
        await _showDeleteCollectionDialog(collection);
      case _CollectionAction.remove:
        await _showRemoveRemoteCollectionDialog(collection);
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

  Future<void> _handleLogoutPressed() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('退出登录'),
          content: const Text('确认退出当前 B 站账号吗？'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('退出'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final LogoutResult result = await ref
        .read(biliAuthControllerProvider.notifier)
        .logout();
    if (!mounted) {
      return;
    }

    final String message = result.remoteLoggedOut
        ? '已退出登录'
        : (result.message?.isNotEmpty == true
              ? '服务端退出失败，已清除本地登录状态'
              : '已清除本地登录状态');
    ToastUtil.show(message);
  }

  Future<void> _showDeleteCollectionDialog(
    FavoriteCollection collection,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('删除歌单'),
          content: Text('确认删除“${collection.name}”？删除后无法恢复。'),
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
          title: const Text('移除网络歌单'),
          content: Text('确认从列表中移除“${collection.name}”？不会删除 B 站收藏夹。'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('移除'),
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
    ToastUtil.show(removed ? '已移除网络歌单' : '移除失败');
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ToastUtil.show(message);
  }
}

enum _CollectionAction { rename, delete, remove }

enum _FavoriteListTab { remote, local }

enum _RemoteAddAction { import, create }

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
    required this.favoriteUpCount,
    required this.onLikedTap,
    required this.onFavoriteUpTap,
  });

  final int likedCount;
  final int favoriteUpCount;
  final VoidCallback onLikedTap;
  final VoidCallback onFavoriteUpTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _ProfileQuickActionCard(
            icon: Icons.favorite_rounded,
            title: '收藏',
            count: likedCount,
            onTap: onLikedTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ProfileQuickActionCard(
            icon: BmIcons.bilier,
            title: 'UP主',
            count: favoriteUpCount,
            onTap: onFavoriteUpTap,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _ProfileQuickActionCard(
            icon: Icons.library_music_rounded,
            title: '本地',
            count: 0,
            enabled: false,
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
    this.enabled = true,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final int count;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color accentColor = enabled
        ? colorScheme.primary
        : colorScheme.outline.withValues(alpha: 0.7);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: enabled ? onTap : null,
      hoverColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: <Widget>[
            Icon(icon, color: accentColor, size: 26),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: enabled ? colorScheme.onSurface : colorScheme.outline,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$count',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: enabled
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.outline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSectionHeader extends StatelessWidget {
  const _ProfileSectionHeader({
    required this.selectedTab,
    required this.onTabChanged,
    required this.onAddPressed,
    required this.onImportPressed,
  });

  final _FavoriteListTab selectedTab;
  final ValueChanged<_FavoriteListTab> onTabChanged;
  final VoidCallback onAddPressed;
  final VoidCallback onImportPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              _PlaylistTabButton(
                label: '网络歌单',
                selected: selectedTab == _FavoriteListTab.remote,
                onTap: () => onTabChanged(_FavoriteListTab.remote),
              ),
              const SizedBox(width: 22),
              _PlaylistTabButton(
                label: '本地歌单',
                selected: selectedTab == _FavoriteListTab.local,
                onTap: () => onTabChanged(_FavoriteListTab.local),
              ),
            ],
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(999),
          // 导入外部歌单
          onTap: onImportPressed,
          child: Icon(
            BmIcons.importright,
            size: 20,
            color: Colors.black.withValues(alpha: 0.6),
          ),
        ),
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
                color: Colors.black.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaylistTabButton extends StatelessWidget {
  const _PlaylistTabButton({
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
    final ColorScheme colorScheme = theme.colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: selected
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  const _PlaylistTile({
    required this.title,
    required this.count,
    required this.coverUrl,
    required this.onTap,
    required this.onLongPressStart,
  });

  final String title;
  final int count;
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
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
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
      borderRadius: BorderRadius.circular(18),
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
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(Icons.queue_music_rounded, color: primary, size: 28),
    );
  }
}
