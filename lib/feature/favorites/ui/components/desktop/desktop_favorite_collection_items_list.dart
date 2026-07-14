import 'package:bilimusic/common/bm_icons.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/selectable_auto_scroll_list_view.dart';
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
    required this.selectedItemIds,
    required this.selectionMode,
    required this.onSelectionModeChanged,
    required this.onSelectionChanged,
    required this.onTapItem,
    required this.onPlayItem,
    required this.onMoreItem,
  });

  final List<FavoriteEntry> items;
  final Widget footer;
  final NotificationListenerCallback<ScrollNotification> onNotification;
  final Set<String> selectedItemIds;
  final bool selectionMode;
  final ValueChanged<bool> onSelectionModeChanged;
  final ValueChanged<Set<String>> onSelectionChanged;
  final DesktopFavoriteCollectionItemCallback onTapItem;
  final DesktopFavoriteCollectionItemCallback onPlayItem;
  final DesktopFavoriteCollectionItemCallback onMoreItem;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: onNotification,
      child: SelectableAutoScrollListView<FavoriteEntry, String>(
        items: items,
        itemKeyOf: (FavoriteEntry item) => item.itemId,
        selectedKeys: selectedItemIds,
        multiSelectEnabled: selectionMode,
        onMultiSelectModeChanged: onSelectionModeChanged,
        onSelectionChanged: onSelectionChanged,
        onItemTap: (FavoriteEntry item) {
          final int index = items.indexOf(item);
          if (index < 0) {
            return;
          }
          onTapItem(index, item);
        },
        padding: EdgeInsets.zero,
        footer: footer,
        separatorBuilder: (_, _) => const SizedBox.shrink(),
        checkboxControlAffinity: ListTileControlAffinity.trailing,
        itemBuilder: _buildNormalItem,
        titleBuilder: _buildTitle,
        subtitleBuilder: _buildSubtitle,
        leadingBuilder: _buildLeading,
        trailingBuilder: _buildTrailing,
      ),
    );
  }

  Widget _buildNormalItem(
    BuildContext context,
    FavoriteEntry item,
    SelectableListItemState<FavoriteEntry, String> state,
  ) {
    final bool isEvenRow = state.index.isEven;

    return Material(
      color: isEvenRow ? Colors.transparent : null,
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        tileColor: isEvenRow
            ? Colors.transparent
            : const Color.fromARGB(255, 189, 189, 189).withValues(alpha: 0.1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        leading: _buildLeading(context, item, state),
        title: _buildTitle(context, item, state),
        subtitle: _buildSubtitle(context, item, state),
        trailing: _buildTrailing(context, item, state),
        selected: state.selected,
        onTap: state.handleTap,
        onLongPress: state.enterMultiSelectAndToggle,
      ),
    );
  }

  Widget _buildLeading(
    BuildContext context,
    FavoriteEntry item,
    SelectableListItemState<FavoriteEntry, String> state,
  ) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return CommonCachedImage(
      imageUrl: item.coverUrl,
      width: 44,
      height: 44,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(14),
      fallbackIcon: Icons.music_note_rounded,
      iconColor: primary,
      backgroundColor: primary.withValues(alpha: 0.14),
    );
  }

  Widget _buildTitle(
    BuildContext context,
    FavoriteEntry item,
    SelectableListItemState<FavoriteEntry, String> state,
  ) {
    return Text(
      item.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _buildSubtitle(
    BuildContext context,
    FavoriteEntry item,
    SelectableListItemState<FavoriteEntry, String> state,
  ) {
    final ThemeData theme = Theme.of(context);

    return Text(
      buildFavoriteEntrySubtitle(item),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.5,
      ),
    );
  }

  Widget _buildTrailing(
    BuildContext context,
    FavoriteEntry item,
    SelectableListItemState<FavoriteEntry, String> state,
  ) {
    final int index = items.indexOf(item);

    return Row(
      spacing: 0,
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          tooltip: '播放',
          onPressed: index < 0 ? null : () => onPlayItem(index, item),
          icon: const Icon(BmIcons.addPlaylist),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          tooltip: '更多',
          onPressed: index < 0 ? null : () => onMoreItem(index, item),
          icon: const Icon(Icons.more_vert_outlined),
        ),
      ],
    );
  }
}
