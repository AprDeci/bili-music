import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FavoriteCollectionPage extends ConsumerWidget {
  const FavoriteCollectionPage({super.key, required this.collectionId});

  final String collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FavoritesState state = ref.watch(favoritesControllerProvider);
    FavoriteCollection? collection;
    for (final FavoriteCollection item in state.collections) {
      if (item.id == collectionId) {
        collection = item;
        break;
      }
    }

    if (collection == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('收藏夹')),
        body: const Center(child: Text('收藏夹不存在')),
      );
    }

    final FavoriteCollection resolvedCollection = collection;

    final List<FavoriteEntry> items = state.itemsForCollection(
      resolvedCollection.id,
    );
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(title: Text(resolvedCollection.name)),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF0FF),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        resolvedCollection.isLikedCollection
                            ? Icons.favorite_border_rounded
                            : Icons.folder_open_rounded,
                        color: const Color(0xFF3B82F6),
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '这个收藏夹还是空的',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '先去搜索页或者播放器点亮爱心，喜欢的内容会出现在这里。',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF667085),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemBuilder: (BuildContext context, int index) {
                final FavoriteEntry item = items[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  tileColor: Colors.white,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: item.coverUrl.isEmpty
                        ? Container(
                            width: 56,
                            height: 56,
                            color: const Color(0xFFEFF4FF),
                            child: const Icon(
                              Icons.music_note_rounded,
                              color: Color(0xFF2563EB),
                            ),
                          )
                        : Image.network(
                            item.coverUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 56,
                                height: 56,
                                color: const Color(0xFFEFF4FF),
                                child: const Icon(
                                  Icons.music_note_rounded,
                                  color: Color(0xFF2563EB),
                                ),
                              );
                            },
                          ),
                  ),
                  title: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    item.durationText == null || item.durationText!.isEmpty
                        ? item.author
                        : '${item.author} · ${item.durationText}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: resolvedCollection.isLikedCollection
                      ? const Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFFF97316),
                        )
                      : const Icon(Icons.play_arrow_rounded),
                  onTap: () =>
                      context.push('/player', extra: item.toPlayableItem()),
                );
              },
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemCount: items.length,
            ),
    );
  }
}
