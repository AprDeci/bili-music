import 'package:bilimusic/common/bottom_height_helper.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/searchBar.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/auth/data/bili_auth_repository.dart';
import 'package:bilimusic/feature/auth/logic/bili_auth_controller.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/profile/ui/components/user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _showAllCollections = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(biliSessionControllerProvider);
    final FavoritesState favoritesState = ref.watch(
      favoritesControllerProvider,
    );
    final double bottomSpacing = BottomHeightHelper.tabPageBottomSpacing(
      context,
    );
    final int likedCount = favoritesState.itemCountForCollection(
      FavoriteCollection.likedCollectionId,
    );
    final List<FavoriteCollection> customCollections = favoritesState
        .collections
        .where((FavoriteCollection collection) => !collection.isSystem)
        .toList(growable: false);
    final bool shouldCollapse = customCollections.length > 5;
    final List<FavoriteCollection> visibleCollections =
        shouldCollapse && !_showAllCollections
        ? customCollections.take(5).toList(growable: false)
        : customCollections;

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
            onLikedTap: () => context.push(
              '/profile/favorites/${FavoriteCollection.likedCollectionId}',
            ),
          ),
          const SizedBox(height: 16),
          _ProfileSectionHeader(
            title: '自建歌单',
            count: customCollections.length,
            onAddPressed: () => _showCreateCollectionDialog(context),
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
                count: items.length,
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
          SizedBox(height: bottomSpacing),
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
    final FavoritesState previousState = ref.read(favoritesControllerProvider);
    await controller.createCollection(result);
    if (!mounted) {
      return;
    }

    final FavoritesState nextState = ref.read(favoritesControllerProvider);
    if (nextState.collections.length == previousState.collections.length) {
      _showMessage('歌单名称已存在');
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

    final _CollectionAction? action = await showMenu<_CollectionAction>(
      context: context,
      position: position,
      items: const <PopupMenuEntry<_CollectionAction>>[
        PopupMenuItem<_CollectionAction>(
          value: _CollectionAction.rename,
          child: ListTile(
            leading: Icon(Icons.drive_file_rename_outline_rounded),
            title: Text('重命名'),
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
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(deleted ? '已删除歌单' : '删除失败')));
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _CollectionAction { rename, delete }

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
    required this.onLikedTap,
  });

  final int likedCount;
  final VoidCallback onLikedTap;

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
            Icon(icon, color: accentColor, size: 24),
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
    required this.title,
    required this.count,
    required this.onAddPressed,
  });

  final String title;
  final int count;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color primary = theme.colorScheme.primary;

    return Row(
      children: <Widget>[
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
              ),
              children: <InlineSpan>[
                TextSpan(text: title),
                TextSpan(
                  text: count == 0 ? '' : ' $count',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
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
              child: Icon(Icons.add_rounded, color: primary),
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
