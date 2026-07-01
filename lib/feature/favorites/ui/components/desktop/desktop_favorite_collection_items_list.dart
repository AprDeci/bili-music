import 'package:bilimusic/common/bm_icons.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorite_entry_subtitle.dart';
import 'package:flutter/material.dart';

typedef DesktopFavoriteCollectionItemCallback =
    void Function(int index, FavoriteEntry item);

class DesktopFavoriteCollectionItemsList extends StatelessWidget {
  const DesktopFavoriteCollectionItemsList({
    super.key,
    required this.items,
    required this.footer,
    required this.onNotification,
    required this.onTapItem,
    required this.onPlayItem,
    required this.onMoreItem,
  });

  final List<FavoriteEntry> items;
  final Widget footer;
  final NotificationListenerCallback<ScrollNotification> onNotification;
  final DesktopFavoriteCollectionItemCallback onTapItem;
  final DesktopFavoriteCollectionItemCallback onPlayItem;
  final DesktopFavoriteCollectionItemCallback onMoreItem;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: onNotification,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: items.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == items.length) {
            return footer;
          }

          final FavoriteEntry item = items[index];
          return _DesktopFavoriteCollectionItemTile(
            index: index,
            item: item,
            onTap: () => onTapItem(index, item),
            onPlayTap: () => onPlayItem(index, item),
            onMoreTap: () => onMoreItem(index, item),
          );
        },
      ),
    );
  }
}

class _DesktopFavoriteCollectionItemTile extends StatelessWidget {
  const _DesktopFavoriteCollectionItemTile({
    required this.index,
    required this.item,
    required this.onTap,
    required this.onPlayTap,
    required this.onMoreTap,
  });

  final int index;
  final FavoriteEntry item;
  final VoidCallback onTap;
  final VoidCallback onPlayTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color primary = colorScheme.primary;
    final bool isEvenRow = index.isEven;

    return Material(
      color: isEvenRow ? Colors.transparent : null,
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        tileColor: isEvenRow
            ? Colors.transparent
            : const Color.fromARGB(255, 189, 189, 189).withValues(alpha: 0.1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
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
          buildFavoriteEntryTitle(item),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
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
