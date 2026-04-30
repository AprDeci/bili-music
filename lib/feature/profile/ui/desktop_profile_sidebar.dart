import 'package:bilimusic/common/components/bar_icon_button.dart';
import 'package:bilimusic/common/components/cached_avatar.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/common_attach_menu.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/auth/data/bili_auth_repository.dart';
import 'package:bilimusic/feature/auth/logic/bili_auth_controller.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class DesktopProfileSidebar extends ConsumerWidget {
  const DesktopProfileSidebar({super.key, required this.currentLocation});

  final String currentLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final FavoritesState favoritesState = ref.watch(
      favoritesControllerProvider,
    );
    final int likedCount = favoritesState.itemCountForCollection(
      FavoriteCollection.likedCollectionId,
    );
    final bool isLikedSelected =
        currentLocation ==
        '/profile/favorites/${FavoriteCollection.likedCollectionId}';
    final List<FavoriteCollection> customCollections = favoritesState
        .collections
        .where((FavoriteCollection collection) => !collection.isSystem)
        .toList(growable: false);

    return Container(
      width: 240,
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
                  isSelected: currentLocation == '/home',
                  onTap: () => context.go('/home'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SidebarShortcutButton(
                  icon: Icons.explore_outlined,
                  isSelected: currentLocation == '/search',
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
            title: '喜欢',
            count: likedCount,
            isSelected: isLikedSelected,
            onTap: () => context.go(
              '/profile/favorites/${FavoriteCollection.likedCollectionId}',
            ),
          ),
          const SizedBox(height: 22),
          _CollectionHeader(
            onAddPressed: () => _showCreateCollectionDialog(context, ref),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: customCollections.isEmpty
                ? const _EmptyCollectionHint()
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: customCollections.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 4),
                    itemBuilder: (BuildContext context, int index) {
                      final FavoriteCollection collection =
                          customCollections[index];
                      final List<FavoriteEntry> items = favoritesState
                          .itemsForCollection(collection.id);
                      final FavoriteEntry? latestItem = items.isEmpty
                          ? null
                          : items.first;

                      return _SidebarListItem(
                        leading: _SidebarPlaylistCover(
                          coverUrl: latestItem?.coverUrl,
                        ),
                        title: collection.name,
                        count: items.length,
                        isSelected:
                            currentLocation ==
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
                  isActive: currentLocation.startsWith('/settings'),
                  onPressed: () => context.go('/settings'),
                ),
                const SizedBox(width: 12),
                // 外观
                BarIconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedShirt01,
                    size: 20,
                  ),
                  isActive: currentLocation.startsWith('/settings/theme'),
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

    final FavoritesState previousState = ref.read(favoritesControllerProvider);
    await ref
        .read(favoritesControllerProvider.notifier)
        .createCollection(trimmedName);
    final FavoritesState nextState = ref.read(favoritesControllerProvider);
    if (nextState.collections.length == previousState.collections.length) {
      ToastUtil.show('歌单名称已存在');
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
                items: const <CommonAttachMenuItem<_CollectionAction>>[
                  CommonAttachMenuItem<_CollectionAction>(
                    value: _CollectionAction.delete,
                    label: '删除',
                    icon: Icons.delete_outline_rounded,
                  ),
                  CommonAttachMenuItem<_CollectionAction>(
                    value: _CollectionAction.rename,
                    label: '重命名',
                    icon: SizedBox.shrink(),
                  ),
                ],
                onSelected: (_CollectionAction action) async {
                  switch (action) {
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
    if (!context.mounted) {
      return;
    }

    ToastUtil.show(deleted ? '已删除歌单' : '删除失败');
  }
}

enum _CollectionAction { rename, delete }

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

class _CreateCollectionButton extends StatelessWidget {
  const _CreateCollectionButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          strokeAlign: BorderSide.strokeAlignInside,
          style: BorderStyle.solid,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          height: 28,
          child: Icon(
            Icons.add_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 20,
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
  });

  final Widget leading;
  final String title;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final GestureTapDownCallback? onSecondaryTapDown;
  final EdgeInsetsGeometry padding;
  final bool showZeroCount;

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
            '自建歌单',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          width: 28,
          height: 28,
          child: IconButton(
            padding: EdgeInsets.zero,
            tooltip: '新建歌单',
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
      borderRadius: BorderRadius.circular(5),
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
        '暂无自建歌单',
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
