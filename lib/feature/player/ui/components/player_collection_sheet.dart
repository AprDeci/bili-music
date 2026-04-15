import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showPlayerCollectionSheet({
  required BuildContext context,
  required PlayableItem item,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (BuildContext context) {
      return SafeArea(child: _PlayerCollectionSheet(item: item));
    },
  );
}

class _PlayerCollectionSheet extends ConsumerWidget {
  const _PlayerCollectionSheet({required this.item});

  final PlayableItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FavoritesState favoritesState = ref.watch(
      favoritesControllerProvider,
    );
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final List<FavoriteCollection> collections =
        favoritesState.collections
            .where(
              (FavoriteCollection collection) => !collection.isLikedCollection,
            )
            .toList(growable: false)
          ..sort(
            (FavoriteCollection a, FavoriteCollection b) =>
                b.updatedAt.compareTo(a.updatedAt),
          );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.68,
      minChildSize: 0.34,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '加到歌单',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: collections.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (BuildContext context, int index) {
                  final FavoriteCollection collection = collections[index];
                  final bool alreadyAdded = favoritesState
                      .containsItemInCollection(
                        collectionId: collection.id,
                        item: item,
                      );
                  final int count = favoritesState.itemCountForCollection(
                    collection.id,
                  );

                  return Material(
                    color: alreadyAdded
                        ? colorScheme.primary.withValues(alpha: 0.1)
                        : colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.45,
                          ),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        Navigator.of(context).pop();

                        final String message;
                        if (alreadyAdded) {
                          message = '已在“${collection.name}”歌单中';
                        } else {
                          final bool added = await ref
                              .read(favoritesControllerProvider.notifier)
                              .addToCollection(
                                collectionId: collection.id,
                                item: item,
                              );
                          message = added
                              ? '已添加到“${collection.name}”歌单'
                              : '添加失败';
                        }

                        if (!context.mounted) {
                          return;
                        }
                        ToastUtil.show(message);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: alreadyAdded
                                  ? colorScheme.primary
                                  : colorScheme.primary.withValues(alpha: 0.12),
                              foregroundColor: alreadyAdded
                                  ? colorScheme.onPrimary
                                  : colorScheme.primary,
                              child: Icon(
                                collection.isLikedCollection
                                    ? Icons.favorite_rounded
                                    : Icons.folder_open_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    collection.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    alreadyAdded
                                        ? '$count 首 · 已收藏'
                                        : '$count 首',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.64,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              alreadyAdded
                                  ? Icons.check_circle_rounded
                                  : Icons.add_circle_outline_rounded,
                              color: alreadyAdded
                                  ? colorScheme.primary
                                  : colorScheme.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
