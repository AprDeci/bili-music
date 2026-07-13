import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/common/components/user_avatar.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:bilimusic/feature/up/logic/favorite_up_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FavoriteUpListPage extends ConsumerWidget {
  const FavoriteUpListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<FavoriteUp> ups = ref.watch(favoriteUpControllerProvider);

    return Scaffold(
      appBar: PlatformUtil.isMobile ? AppBar(title: const Text('收藏UP主')) : null,
      body: ups.isEmpty
          ? const Center(child: Text('还没有收藏UP主'))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              itemCount: ups.length + 1,
              separatorBuilder: (BuildContext context, int index) {
                if (index >= ups.length - 1) {
                  return const SizedBox.shrink();
                }
                return const SizedBox(height: 6);
              },
              itemBuilder: (BuildContext context, int index) {
                if (index == ups.length) {
                  return const BottomPageSpacer.tab();
                }
                return _FavoriteUpTile(up: ups[index]);
              },
            ),
    );
  }
}

class _FavoriteUpTile extends ConsumerWidget {
  const _FavoriteUpTile({required this.up});

  final FavoriteUp up;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: UserAvatar(
        avatarUrl: up.avatarUrl,
        officialType: up.officialType,
        useCache: true,
      ),
      title: Text(
        up.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        'UID ${up.mid}',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: IconButton(
        tooltip: '取消收藏',
        icon: const Icon(Icons.favorite_rounded),
        color: colorScheme.primary,
        onPressed: () {
          ref.read(favoriteUpControllerProvider.notifier).remove(up.mid);
        },
      ),
      onTap: () => context.push('/up/${up.mid}'),
    );
  }
}
