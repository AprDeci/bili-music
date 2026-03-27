import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FavoritesState state = ref.watch(favoritesControllerProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(title: const Text('我的收藏')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateCollectionDialog(context, ref),
        icon: const Icon(Icons.create_new_folder_rounded),
        label: const Text('新建收藏夹'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF0F2742), Color(0xFF256C66)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '收藏夹',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.76),
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${state.collections.length} 个收藏夹',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '点爱心默认加入“我喜欢”，后面也可以继续整理到更多收藏夹。',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFD8EDF2),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...state.collections.map((FavoriteCollection collection) {
            final int itemCount = state.itemCountForCollection(collection.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CollectionCard(
                collection: collection,
                itemCount: itemCount,
                onTap: () => context.push('/favorites/${collection.id}'),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _showCreateCollectionDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final TextEditingController controller = TextEditingController();
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('新建收藏夹'),
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
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.collection,
    required this.itemCount,
    required this.onTap,
  });

  final FavoriteCollection collection;
  final int itemCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5E9F2)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x100F172A),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: collection.isLikedCollection
                      ? const LinearGradient(
                          colors: <Color>[Color(0xFFFFC658), Color(0xFFF97316)],
                        )
                      : const LinearGradient(
                          colors: <Color>[Color(0xFFB8D5FF), Color(0xFF7AA2F7)],
                        ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  collection.isLikedCollection
                      ? Icons.favorite_rounded
                      : Icons.folder_copy_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      collection.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF122033),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      itemCount == 0 ? '还没有内容' : '$itemCount 条内容',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6A7384),
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
