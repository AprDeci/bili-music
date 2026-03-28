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
        title: CommonSearchBar(onTap: () => context.push('/search')),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        children: <Widget>[
          UserCard(onLogoutPressed: _handleLogoutPressed),
          const SizedBox(height: 18),
          _ProfileQuickActions(
            likedCount: likedCount,
            onLikedTap: () => context.push(
              '/favorites/${FavoriteCollection.likedCollectionId}',
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
                onTap: () => context.push('/favorites/${collection.id}'),
                onLongPress: () => _showDeleteCollectionDialog(collection),
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
        ],
      ),
    );
  }

  Future<void> _showCreateCollectionDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('新建歌单'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 24,
            decoration: const InputDecoration(hintText: '例如：深夜循环'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('创建'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (result == null || result.trim().isEmpty) {
      return;
    }

    await ref
        .read(favoritesControllerProvider.notifier)
        .createCollection(result);
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
                color: enabled
                    ? const Color(0xFF172033)
                    : const Color(0xFF8B95A7),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$count',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: enabled
                    ? const Color(0xFF737B8C)
                    : const Color(0xFFB3BAC6),
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
    final Color primary = theme.colorScheme.primary;

    return Row(
      children: <Widget>[
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF111A2D),
              ),
              children: <InlineSpan>[
                TextSpan(text: title),
                TextSpan(
                  text: count == 0 ? '' : ' $count',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF8A93A3),
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
    required this.onLongPress,
  });

  final String title;
  final int count;
  final String? coverUrl;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        onLongPress: onLongPress,
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
                        color: const Color(0xFF152033),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$count 首',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6E7787),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF98A2B3)),
            ],
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

    if (coverUrl != null && coverUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          coverUrl!,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _PlaylistPlaceholder(primary: primary);
          },
        ),
      );
    }

    return _PlaylistPlaceholder(primary: primary);
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
