import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:flutter/material.dart';

class RemoteCollectionImportDialog extends StatelessWidget {
  const RemoteCollectionImportDialog({
    super.key,
    required this.collectionsFuture,
  });

  final Future<List<FavoriteCollection>> collectionsFuture;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('导入已有收藏夹'),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      content: SizedBox(
        width: 360,
        child: FutureBuilder<List<FavoriteCollection>>(
          future: collectionsFuture,
          builder:
              (
                BuildContext context,
                AsyncSnapshot<List<FavoriteCollection>> snapshot,
              ) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return _DialogMessage(
                    icon: Icons.error_outline_rounded,
                    text: snapshot.error?.toString() ?? '拉取收藏夹失败',
                  );
                }

                final List<FavoriteCollection> collections =
                    snapshot.data ?? <FavoriteCollection>[];
                if (collections.isEmpty) {
                  return const _DialogMessage(
                    icon: Icons.library_music_outlined,
                    text: '没有可导入的收藏夹',
                  );
                }

                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 420),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: collections.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(height: 1),
                    itemBuilder: (BuildContext context, int index) {
                      final FavoriteCollection collection = collections[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.folder_open_rounded),
                        title: Text(
                          collection.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text('${collection.itemCount} 个内容'),
                        onTap: () => Navigator.of(context).pop(collection),
                      );
                    },
                  ),
                );
              },
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
      ],
    );
  }
}

class _DialogMessage extends StatelessWidget {
  const _DialogMessage({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 140,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: colorScheme.onSurfaceVariant, size: 32),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
