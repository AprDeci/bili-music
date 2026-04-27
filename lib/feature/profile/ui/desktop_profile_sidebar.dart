import 'package:bilimusic/common/components/bar_icon_button.dart';
import 'package:bilimusic/common/components/cached_avatar.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
          const SizedBox(height: 10),
          _CreateCollectionButton(
            onTap: () => _showCreateCollectionDialog(context, ref),
          ),
          const SizedBox(height: 24),
          _SidebarMenuItem(
            icon: Icons.favorite_rounded,
            title: '喜欢',
            count: likedCount,
            isSelected:
                currentLocation ==
                '/profile/favorites/${FavoriteCollection.likedCollectionId}',
            selectedIconColor: Colors.black,
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
                      return _SidebarPlaylistTile(
                        title: collection.name,
                        count: items.length,
                        isSelected:
                            currentLocation ==
                            '/profile/favorites/${collection.id}',
                        onTap: () =>
                            context.go('/profile/favorites/${collection.id}'),
                      );
                    },
                  ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: BarIconButton(
              icon: Icons.settings_outlined,
              iconSize: 20,
              isActive: currentLocation.startsWith('/settings'),
              onPressed: () => context.go('/settings'),
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
}

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
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
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

class _SidebarMenuItem extends StatelessWidget {
  const _SidebarMenuItem({
    required this.icon,
    required this.title,
    required this.count,
    required this.isSelected,
    required this.onTap,
    this.selectedIconColor,
  });

  final IconData icon;
  final String title;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedIconColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color foregroundColor = isSelected
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant;

    return Material(
      color: isSelected
          ? colorScheme.surfaceContainerHighest
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: <Widget>[
              Icon(
                icon,
                size: 22,
                color: isSelected
                    ? selectedIconColor ?? foregroundColor
                    : foregroundColor,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  '$title:$count',
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

class _SidebarPlaylistTile extends StatelessWidget {
  const _SidebarPlaylistTile({
    required this.title,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color foregroundColor = isSelected
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant;

    return Material(
      color: isSelected
          ? colorScheme.surfaceContainerHighest
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: Row(
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: isSelected ? 1 : 0.62,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  Icons.music_note_rounded,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.44),
                  size: 17,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  count > 0 ? '$title:$count' : title,
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
  const _CollectionNameDialog();

  @override
  State<_CollectionNameDialog> createState() => _CollectionNameDialogState();
}

class _CollectionNameDialogState extends State<_CollectionNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新建歌单'),
      content: TextField(
        controller: _controller,
        maxLength: 24,
        autofocus: true,
        decoration: const InputDecoration(hintText: '例如：深夜循环'),
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
          child: const Text('创建'),
        ),
      ],
    );
  }
}
