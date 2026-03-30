import 'package:bilimusic/common/components/cachedImage.dart';
import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteCollectionPage extends ConsumerWidget {
  const FavoriteCollectionPage({super.key, required this.collectionId});

  static final AppLogger _logger = AppLogger('FavoriteCollectionPage');

  final String collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FavoritesState state = ref.watch(favoritesControllerProvider);
    final Color primary = Theme.of(context).colorScheme.primary;
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
    final List<PlayableItem> queueItems = items
        .map((FavoriteEntry item) => item.toPlayableItem())
        .toList(growable: false);
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
                        color: primary,
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
          : ListView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              children: <Widget>[
                const SizedBox(height: 2),
                ...List<Widget>.generate(items.length, (int index) {
                  final FavoriteEntry item = items[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == items.length - 1 ? 0 : 0,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 0,
                      ),
                      tileColor: Colors.white,
                      leading: CommonCachedImage(
                        imageUrl: item.coverUrl,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(14),
                        fallbackIcon: Icons.music_note_rounded,
                        iconColor: primary,
                        backgroundColor: primary.withValues(alpha: 0.14),
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
                        _buildSubtitle(item),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: resolvedCollection.isLikedCollection
                          ? Icon(Icons.favorite_rounded, color: primary)
                          : const Icon(Icons.play_arrow_rounded),
                      onTap: () async {
                        _logger.d(
                          '[FavoriteDebug] tapPlay | collection=${resolvedCollection.name}, '
                          'index=$index, queueLength=${queueItems.length}, '
                          'itemStableId=${queueItems[index].stableId}, '
                          'itemTitle=${queueItems[index].title}',
                        );
                        await PlayerUtil.playQueueAndOpenPlayer(
                          context,
                          ref,
                          items: queueItems,
                          startIndex: index,
                          sourceLabel: resolvedCollection.name,
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
    );
  }

  String _buildSubtitle(FavoriteEntry item) {
    final List<String> segments = <String>[item.author];
    final int? page = item.page;
    final String pageTitle = item.pageTitle?.trim() ?? '';

    if (page != null && page > 0) {
      segments.add('P$page');
    }
    if (pageTitle.isNotEmpty) {
      segments.add(pageTitle);
    }
    if (item.durationText != null && item.durationText!.isNotEmpty) {
      segments.add(item.durationText!);
    }

    return segments.join(' · ');
  }
}
