import 'package:bilimusic/common/components/bar_icon_button.dart';
import 'package:bilimusic/common/components/cached_avatar.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/common_attach_menu.dart';
import 'package:bilimusic/common/components/login_required.dart';
import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/auth/data/bili_auth_repository.dart';
import 'package:bilimusic/feature/auth/logic/bili_auth_controller.dart';
import 'package:bilimusic/feature/download/logic/download_controller.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorite_entry_metadata.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/favorites/ui/components/collection_kind_dialog.dart';
import 'package:bilimusic/feature/profile/ui/components/remote_collection_import_dialog.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class DesktopProfileSidebar extends ConsumerStatefulWidget {
  const DesktopProfileSidebar({super.key, required this.currentLocation});

  final String currentLocation;

  @override
  ConsumerState<DesktopProfileSidebar> createState() =>
      _DesktopProfileSidebarState();
}

class _DesktopProfileSidebarState extends ConsumerState<DesktopProfileSidebar> {
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
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
    final bool isLikedSelected =
        widget.currentLocation ==
        '/profile/favorites/${FavoriteCollection.likedCollectionId}';
    final bool isRecentSelected = widget.currentLocation == '/profile/recent';
    final bool isDownloadsSelected =
        widget.currentLocation == '/profile/downloads';
    final bool isLoggedIn =
        (ref.watch(biliSessionControllerProvider)?.isLoggedIn ?? false);
    final List<FavoriteCollection> visibleCollections =
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

    return Container(
      width: 232,
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _SidebarAccountHeader(),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: _SidebarShortcutButton(
                  icon: Icons.home_outlined,
                  isSelected: widget.currentLocation == '/home',
                  onTap: () => context.go('/home'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SidebarShortcutButton(
                  icon: Icons.explore_outlined,
                  isSelected: widget.currentLocation == '/search',
                  onTap: () => context.go('/search'),
                ),
              ),
            ],
          ),
          // const SizedBox(height: 10),
          // _CreateCollectionButton(
          //   onTap: () => _showCreateCollectionDialog(context, ref),
          // ),
          const SizedBox(height: 24),
          _SidebarListItem(
            leading: Icon(
              Icons.favorite_rounded,
              size: 22,
              color: isLikedSelected
                  ? Colors.black
                  : colorScheme.onSurfaceVariant,
            ),
            title: '我喜欢',
            count: likedCount,
            isSelected: isLikedSelected,
            onTap: () => context.go(
              '/profile/favorites/${FavoriteCollection.likedCollectionId}',
            ),
            onSecondaryTapDown: (TapDownDetails details) =>
                _showCollectionContextMenu(
                  context: context,
                  ref: ref,
                  collection: favoritesState.likedCollection,
                  globalPosition: details.globalPosition,
                ),
          ),
          const SizedBox(height: 8),
          _SidebarListItem(
            leading: Icon(
              Icons.history_rounded,
              size: 22,
              color: isRecentSelected
                  ? Colors.black
                  : colorScheme.onSurfaceVariant,
            ),
            title: '历史记录',
            count: recentCount,
            isSelected: isRecentSelected,
            onTap: () => context.go('/profile/recent'),
          ),
          const SizedBox(height: 8),
          _SidebarListItem(
            leading: Icon(
              Icons.library_music_rounded,
              size: 22,
              color: isDownloadsSelected
                  ? Colors.black
                  : colorScheme.onSurfaceVariant,
            ),
            title: '本地',
            count: downloadCount,
            isSelected: isDownloadsSelected,
            onTap: () => context.go('/profile/downloads'),
          ),
          const SizedBox(height: 22),
          _CollectionHeader(
            onAddPressed: () => _handleAddPressed(context, ref),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: visibleCollections.isEmpty
                ? const _EmptyCollectionHint()
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: visibleCollections.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 4),
                    itemBuilder: (BuildContext context, int index) {
                      final FavoriteCollection collection =
                          visibleCollections[index];
                      final List<FavoriteEntry> items = favoritesState
                          .itemsForCollection(collection.id);
                      final FavoriteEntry? latestItem = items.isEmpty
                          ? null
                          : items.first;

                      return _SidebarListItem(
                        leading: _SidebarPlaylistCover(
                          coverUrl: ref.watch(
                            favoriteEntryCoverUrlProvider(
                              collection.id,
                              latestItem,
                            ),
                          ),
                        ),
                        title: collection.name,
                        count: favoritesState.itemCountForCollection(
                          collection.id,
                        ),
                        isRemote: collection.isRemote,
                        isSelected:
                            widget.currentLocation ==
                            '/profile/favorites/${collection.id}',
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 7,
                        ),
                        showZeroCount: false,
                        onTap: () =>
                            context.go('/profile/favorites/${collection.id}'),
                        onSecondaryTapDown: (TapDownDetails details) {
                          _showCollectionContextMenu(
                            context: context,
                            ref: ref,
                            collection: collection,
                            globalPosition: details.globalPosition,
                          );
                        },
                      );
                    },
                  ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                BarIconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedSettings03,
                    size: 20,
                  ),
                  isActive: widget.currentLocation.startsWith('/settings'),
                  onPressed: () => context.go('/settings'),
                ),
                const SizedBox(width: 12),
                // 外观
                BarIconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedShirt01,
                    size: 20,
                  ),
                  isActive: widget.currentLocation.startsWith(
                    '/settings/theme',
                  ),
                  onPressed: () => context.go('/settings/theme'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateCollectionDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final String? result = await showDialog<String>(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return const _CollectionNameDialog();
      },
    );

    if (result == null) {
      return;
    }

    final String trimmedName = result.trim();
    if (trimmedName.isEmpty) {
      ToastUtil.show('歌单名称不能为空');
      return;
    }

    if (!context.mounted) return;
    final CollectionKind? kind = await showCollectionKindDialog(
      context: context,
    );
    if (!context.mounted || kind == null) return;

    final FavoriteCollection? collection = await ref
        .read(favoritesControllerProvider.notifier)
        .createCollection(trimmedName, kind: kind);
    if (collection == null) {
      ToastUtil.show('歌单名称已存在');
    }
  }

  Future<void> _showRemoteImportDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
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

    if (!context.mounted || collection == null) {
      return;
    }

    final CollectionKind? kind = await showCollectionKindDialog(
      context: context,
      initialKind: collection.kind,
    );
    if (!context.mounted || kind == null) return;

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
    if (!context.mounted || mode == null) return;

    if (mode == _RemoteImportMode.localCopy) {
      final FavoriteCollection? created = await controller
          .importRemoteCollectionAsLocal(collection, kind: kind);
      if (!context.mounted) {
        return;
      }
      ToastUtil.show(
        created == null ? '导入失败，请稍后重试' : '已导入为本地歌单“${created.name}”',
      );
      return;
    }

    await controller.bindRemoteCollection(collection.copyWith(kind: kind));
    await controller.refreshRemoteCollectionItems(collectionId: collection.id);
    if (!context.mounted) {
      return;
    }
    ToastUtil.show('已绑定“${collection.name}”，将保持同步');
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
      ToastUtil.show('网络歌单同步失败，请稍后重试');
    } finally {
      _isRefreshingRemoteCollections = false;
    }
  }

  Future<void> _handleAddPressed(BuildContext context, WidgetRef ref) async {
    final bool isLoggedIn =
        (ref.read(biliSessionControllerProvider)?.isLoggedIn ?? false);
    final _AddAction? action = await showDialog<_AddAction>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('添加歌单'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () =>
                  Navigator.of(context).pop(_AddAction.localCreate),
              child: const ListTile(
                leading: Icon(Icons.playlist_add_rounded),
                title: Text('新建歌单'),
                subtitle: Text('只在本地保存，不同步 B 站'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            if (isLoggedIn)
              SimpleDialogOption(
                onPressed: () =>
                    Navigator.of(context).pop(_AddAction.remoteImport),
                child: const ListTile(
                  leading: Icon(Icons.cloud_download_outlined),
                  title: Text('从 B站收藏夹导入'),
                  subtitle: Text('默认拷贝一份到本地，也可选择绑定同步'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
          ],
        );
      },
    );

    if (!context.mounted || action == null) {
      return;
    }

    switch (action) {
      case _AddAction.localCreate:
        await _showCreateCollectionDialog(context, ref);
      case _AddAction.remoteImport:
        if (!isLoggedIn) {
          LoginPrompt.show(context, reason: '导入 B站收藏夹需要登录 B 站账号');
          return;
        }
        await _showRemoteImportDialog(context, ref);
    }
  }

  void _showCollectionContextMenu({
    required BuildContext context,
    required WidgetRef ref,
    required FavoriteCollection collection,
    required Offset globalPosition,
  }) {
    final BuildContext sidebarContext = context;

    SmartDialog.showAttach<void>(
      maskColor: Colors.transparent,
      targetContext: null,
      targetBuilder: (Offset targetOffset, Size targetSize) {
        return Offset(globalPosition.dx + 70, globalPosition.dy);
      },
      alignment: Alignment.bottomLeft,
      clickMaskDismiss: true,
      keepSingle: true,
      builder: (BuildContext menuContext) {
        return Material(
          color: Theme.of(menuContext).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              width: 144,
              child: CommonAttachMenu<_CollectionAction>(
                itemHeight: 40,
                items: <CommonAttachMenuItem<_CollectionAction>>[
                  if (!collection.isSystem)
                    CommonAttachMenuItem<_CollectionAction>(
                      value: _CollectionAction.rename,
                      label: collection.isRemote ? '重命名 B 站收藏夹' : '重命名',
                      icon: const SizedBox.shrink(),
                    ),
                  if (collection.isRemote)
                    const CommonAttachMenuItem<_CollectionAction>(
                      value: _CollectionAction.sync,
                      label: '同步',
                      icon: Icons.sync_rounded,
                    ),
                  if (collection.isRemote)
                    const CommonAttachMenuItem<_CollectionAction>(
                      value: _CollectionAction.remove,
                      label: '解除绑定',
                      icon: Icons.remove_circle_outline_rounded,
                    ),
                  if (!collection.isSystem)
                    const CommonAttachMenuItem<_CollectionAction>(
                      value: _CollectionAction.delete,
                      label: '删除',
                      icon: Icons.delete_outline_rounded,
                    ),
                  const CommonAttachMenuItem<_CollectionAction>(
                    value: _CollectionAction.changeKind,
                    label: '修改类型',
                    icon: Icons.category_outlined,
                  ),
                ],
                onSelected: (_CollectionAction action) async {
                  switch (action) {
                    case _CollectionAction.changeKind:
                      final CollectionKind? kind =
                          await showCollectionKindDialog(
                            context: sidebarContext,
                            initialKind: collection.kind,
                            title: '修改类型',
                          );
                      if (!sidebarContext.mounted ||
                          kind == null ||
                          kind == collection.kind) {
                        return;
                      }
                      bool saved;
                      try {
                        saved = await ref
                            .read(favoritesControllerProvider.notifier)
                            .setCollectionKind(
                              collectionId: collection.id,
                              kind: kind,
                            );
                      } on Object {
                        saved = false;
                      }
                      if (!saved) {
                        ToastUtil.show('类型保存失败，请重试');
                      }
                    case _CollectionAction.rename:
                      await _showRenameCollectionDialog(
                        sidebarContext,
                        ref,
                        collection,
                      );
                    case _CollectionAction.delete:
                      await _showDeleteCollectionDialog(
                        sidebarContext,
                        ref,
                        collection,
                      );
                    case _CollectionAction.remove:
                      await _showRemoveRemoteCollectionDialog(
                        sidebarContext,
                        ref,
                        collection,
                      );
                    case _CollectionAction.sync:
                      SmartDialog.dismiss<void>();
                      await _syncRemoteCollection(
                        sidebarContext,
                        ref,
                        collection,
                      );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showRenameCollectionDialog(
    BuildContext context,
    WidgetRef ref,
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
      ToastUtil.show('歌单名称不能为空');
      return;
    }

    if (trimmedName == collection.name.trim()) {
      return;
    }

    final bool renamed = await ref
        .read(favoritesControllerProvider.notifier)
        .renameCollection(collectionId: collection.id, name: trimmedName);
    if (!context.mounted) {
      return;
    }

    ToastUtil.show(renamed ? '已重命名歌单' : '歌单名称已存在');
  }

  Future<void> _showDeleteCollectionDialog(
    BuildContext context,
    WidgetRef ref,
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
    if (!context.mounted) {
      return;
    }

    ToastUtil.show(deleted ? '已删除歌单' : '删除失败');
  }

  Future<void> _showRemoveRemoteCollectionDialog(
    BuildContext context,
    WidgetRef ref,
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
    if (!context.mounted) {
      return;
    }

    if (removed &&
        widget.currentLocation == '/profile/favorites/${collection.id}') {
      context.go('/profile/favorites/${FavoriteCollection.likedCollectionId}');
    }
    ToastUtil.show(removed ? '已解除绑定' : '解除绑定失败');
  }

  Future<void> _syncRemoteCollection(
    BuildContext context,
    WidgetRef ref,
    FavoriteCollection collection,
  ) async {
    if (!collection.isRemote) {
      return;
    }

    ToastUtil.show('正在同步…');
    try {
      final RemoteCollectionSyncResult result = await ref
          .read(favoritesControllerProvider.notifier)
          .syncRemoteCollectionIfStale(collection.id, force: true);
      if (!context.mounted) {
        return;
      }

      switch (result) {
        case RemoteCollectionSyncResult.completed:
          ToastUtil.show('同步完成');
        case RemoteCollectionSyncResult.incomplete:
          ToastUtil.show('同步未完成，已使用本地数据');
        case RemoteCollectionSyncResult.skipped:
          return;
      }
    } on Object {
      if (!context.mounted) {
        return;
      }
      ToastUtil.show('网络歌单同步失败，请稍后重试');
    }
  }
}

enum _CollectionAction { rename, delete, remove, sync, changeKind }

enum _AddAction { localCreate, remoteImport }

enum _RemoteImportMode { localCopy, bindAndSync }

class _SidebarAccountHeader extends ConsumerWidget {
  const _SidebarAccountHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final BiliSession? session = ref.watch(biliSessionControllerProvider);
    final bool isLoggedIn = session?.isLoggedIn ?? false;
    final String title = isLoggedIn
        ? (session?.uname?.isNotEmpty == true ? session!.uname! : '已登录')
        : '点击登录';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: isLoggedIn ? null : () => context.push('/auth'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Row(
            children: <Widget>[
              CommonCachedAvatar(
                imageUrl: isLoggedIn ? session?.face : null,
                size: 32,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                fallbackIcon: Icons.person_rounded,
                iconColor: colorScheme.primary,
                iconSize: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isLoggedIn)
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: '退出登录',
                    onPressed: () => _handleLogoutPressed(context, ref),
                    icon: Icon(
                      Icons.logout_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: 19,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogoutPressed(BuildContext context, WidgetRef ref) async {
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

    if (confirmed != true || !context.mounted) {
      return;
    }

    final LogoutResult result = await ref
        .read(biliAuthControllerProvider.notifier)
        .logout();
    if (!context.mounted) {
      return;
    }

    final String message = result.remoteLoggedOut
        ? '已退出登录'
        : (result.message?.isNotEmpty == true
              ? '服务端退出失败，已清除本地登录状态'
              : '已清除本地登录状态');
    ToastUtil.show(message);
  }
}

class _SidebarShortcutButton extends StatelessWidget {
  const _SidebarShortcutButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: isSelected
          ? colorScheme.surfaceContainerHighest
          : colorScheme.surfaceContainerHigh.withValues(alpha: 0.58),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Icon(
            icon,
            color: isSelected
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _SidebarListItem extends StatelessWidget {
  const _SidebarListItem({
    required this.leading,
    required this.title,
    required this.count,
    required this.isSelected,
    required this.onTap,
    this.onSecondaryTapDown,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    this.showZeroCount = true,
    this.isRemote = false,
  });

  final Widget leading;
  final String title;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final GestureTapDownCallback? onSecondaryTapDown;
  final EdgeInsetsGeometry padding;
  final bool showZeroCount;
  final bool isRemote;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color foregroundColor = isSelected
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant;
    final String label = showZeroCount || count > 0 ? '$title·$count' : title;

    return Material(
      color: isSelected
          ? colorScheme.surfaceContainerHighest
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        onSecondaryTapDown: onSecondaryTapDown,
        child: Padding(
          padding: padding,
          child: Row(
            children: <Widget>[
              leading,
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isRemote) ...<Widget>[
                const SizedBox(width: 6),
                Tooltip(
                  message: 'B站收藏夹同步',
                  child: Icon(
                    Icons.sync_rounded,
                    size: 12,
                    color: colorScheme.primary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionHeader extends StatelessWidget {
  const _CollectionHeader({required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            '歌单',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 28,
          height: 28,
          child: IconButton(
            padding: EdgeInsets.zero,
            tooltip: '添加歌单',
            onPressed: onAddPressed,
            icon: Icon(
              Icons.add_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

class _SidebarPlaylistCover extends StatelessWidget {
  const _SidebarPlaylistCover({required this.coverUrl});

  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return CommonCachedImage(
      imageUrl: coverUrl,
      width: 28,
      height: 28,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(8),
      placeholder: _SidebarPlaylistPlaceholder(primary: primary),
      errorWidget: _SidebarPlaylistPlaceholder(primary: primary),
    );
  }
}

class _SidebarPlaylistPlaceholder extends StatelessWidget {
  const _SidebarPlaylistPlaceholder({required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            primary.withValues(alpha: 0.18),
            primary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(Icons.queue_music_rounded, color: primary, size: 15),
    );
  }
}

class _EmptyCollectionHint extends StatelessWidget {
  const _EmptyCollectionHint();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
      child: Text(
        '暂无歌单，点 + 新建',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
        ),
      ),
    );
  }
}

class _CollectionNameDialog extends StatefulWidget {
  const _CollectionNameDialog({
    this.title = '新建歌单',
    this.hintText = '例如：深夜循环',
    this.confirmText = '创建',
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
