import 'package:bilimusic/common/bm_icons.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry_group.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorite_entry_subtitle.dart';
import 'package:flutter/material.dart';

typedef FavoriteCollectionItemCallback =
    void Function(int index, FavoriteEntry item);

class FavoriteCollectionItemsList extends StatelessWidget {
  const FavoriteCollectionItemsList({
    super.key,
    required this.items,
    required this.header,
    required this.footer,
    required this.onNotification,
    required this.onTapItem,
    required this.onPlayItem,
    required this.onMoreItem,
  });

  final List<FavoriteEntry> items;
  final Widget header;
  final Widget footer;
  final NotificationListenerCallback<ScrollNotification> onNotification;
  final FavoriteCollectionItemCallback onTapItem;
  final FavoriteCollectionItemCallback onPlayItem;
  final FavoriteCollectionItemCallback onMoreItem;

  @override
  Widget build(BuildContext context) {
    final List<_FavoriteCollectionRow> rows = _buildRows(items);
    final Map<String, int> itemIndexes = <String, int>{
      for (int index = 0; index < items.length; index++)
        items[index].itemId: index,
    };
    return NotificationListener<ScrollNotification>(
      onNotification: onNotification,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: rows.length + 2,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return header;
          }

          if (index == rows.length + 1) {
            return footer;
          }

          final _FavoriteCollectionRow row = rows[index - 1];
          final FavoriteEntry? item = row.item;
          final FavoriteEntryGroup? group = row.group;
          if (group != null) {
            final FavoriteEntry firstItem = group.items.first;
            final int itemIndex = itemIndexes[firstItem.itemId] ?? 0;
            return _FavoriteCollectionGroupTile(
              group: group,
              onTap: () => onTapItem(itemIndex, firstItem),
              onPlayTap: () => onPlayItem(itemIndex, firstItem),
            );
          }

          final FavoriteEntry resolvedItem = item!;
          final int itemIndex = itemIndexes[resolvedItem.itemId] ?? 0;
          return _FavoriteCollectionItemTile(
            item: resolvedItem,
            isChild: row.isChild,
            onTap: () => onTapItem(itemIndex, resolvedItem),
            onPlayTap: () => onPlayItem(itemIndex, resolvedItem),
            onMoreTap: () => onMoreItem(itemIndex, resolvedItem),
          );
        },
      ),
    );
  }

  List<_FavoriteCollectionRow> _buildRows(List<FavoriteEntry> items) {
    final List<_FavoriteCollectionRow> rows = <_FavoriteCollectionRow>[];
    for (final FavoriteEntryGroup group in groupFavoriteEntriesByVideo(items)) {
      if (!group.isMultiPart) {
        rows.add(_FavoriteCollectionRow.item(group.items.first));
        continue;
      }
      rows.add(_FavoriteCollectionRow.group(group));
      for (final FavoriteEntry item in group.items) {
        rows.add(_FavoriteCollectionRow.item(item, isChild: true));
      }
    }
    return rows;
  }
}

class _FavoriteCollectionRow {
  const _FavoriteCollectionRow._({this.group, this.item, this.isChild = false});

  factory _FavoriteCollectionRow.group(FavoriteEntryGroup group) {
    return _FavoriteCollectionRow._(group: group);
  }

  factory _FavoriteCollectionRow.item(
    FavoriteEntry item, {
    bool isChild = false,
  }) {
    return _FavoriteCollectionRow._(item: item, isChild: isChild);
  }

  final FavoriteEntryGroup? group;
  final FavoriteEntry? item;
  final bool isChild;
}

class _FavoriteCollectionGroupTile extends StatelessWidget {
  const _FavoriteCollectionGroupTile({
    required this.group,
    required this.onTap,
    required this.onPlayTap,
  });

  final FavoriteEntryGroup group;
  final VoidCallback onTap;
  final VoidCallback onPlayTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color primary = colorScheme.primary;
    final FavoriteEntry parent = group.parent;

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.32),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CommonCachedImage(
          imageUrl: parent.coverUrl,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(8),
          fallbackIcon: Icons.video_library_rounded,
          iconColor: primary,
          backgroundColor: primary.withValues(alpha: 0.14),
        ),
        title: Text(
          parent.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          '${parent.author} · ${group.items.length} 个分段',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        trailing: IconButton(
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          tooltip: '播放',
          onPressed: onPlayTap,
          icon: const Icon(BmIcons.addPlaylist),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _FavoriteCollectionItemTile extends StatelessWidget {
  const _FavoriteCollectionItemTile({
    required this.item,
    this.isChild = false,
    required this.onTap,
    required this.onPlayTap,
    required this.onMoreTap,
  });

  final FavoriteEntry item;
  final bool isChild;
  final VoidCallback onTap;
  final VoidCallback onPlayTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color primary = colorScheme.primary;

    return Material(
      child: ListTile(
        contentPadding: EdgeInsets.fromLTRB(isChild ? 34 : 14, 0, 14, 0),
        leading: isChild
            ? _FavoritePartLeading(item: item)
            : CommonCachedImage(
                imageUrl: item.coverUrl,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(8),
                fallbackIcon: Icons.music_note_rounded,
                iconColor: primary,
                backgroundColor: primary.withValues(alpha: 0.14),
              ),
        title: Text(
          buildFavoriteEntryTitle(item),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          buildFavoriteEntrySubtitle(item),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        trailing: Row(
          spacing: 0,
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              tooltip: '播放',
              onPressed: onPlayTap,
              icon: const Icon(BmIcons.addPlaylist),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              tooltip: '更多',
              onPressed: onMoreTap,
              icon: const Icon(Icons.more_vert_outlined),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _FavoritePartLeading extends StatelessWidget {
  const _FavoritePartLeading({required this.item});

  final FavoriteEntry item;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final int? page = item.page;
    return SizedBox(
      width: 44,
      height: 44,
      child: Center(
        child: CircleAvatar(
          radius: 16,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
          foregroundColor: colorScheme.primary,
          child: Text(
            page != null && page > 0 ? '$page' : '#',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
