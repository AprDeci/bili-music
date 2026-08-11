import 'package:bilimusic/common/bm_icons.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/selectable_auto_scroll_list_view.dart';
import 'package:bilimusic/common/components/tag.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorite_entry_subtitle.dart';
import 'package:bilimusic/feature/statistics/logic/statistics_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

typedef FavoriteCollectionItemCallback =
    void Function(int index, FavoriteEntry item);

class FavoriteCollectionItemsList extends ConsumerWidget {
  const FavoriteCollectionItemsList({
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
  final FavoriteCollectionItemCallback onTapItem;
  final FavoriteCollectionItemCallback onPlayItem;
  final FavoriteCollectionItemCallback onMoreItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StatisticsTracker tracker = ref.read(statisticsTrackerProvider);
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
        checkboxControlAffinity: ListTileControlAffinity.trailing,
        itemBuilder: (context, item, state) =>
            _buildNormalItem(context, item, state, tracker),
        titleBuilder: _buildTitle,
        subtitleBuilder: (context, item, state) =>
            _buildSubtitle(context, item, state, tracker),
        leadingBuilder: _buildLeading,
        trailingBuilder: _buildTrailing,
      ),
    );
  }

  Widget _buildNormalItem(
    BuildContext context,
    FavoriteEntry item,
    SelectableListItemState<FavoriteEntry, String> state,
    StatisticsTracker tracker,
  ) {
    return Material(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        leading: _buildLeading(context, item, state),
        title: _buildTitle(context, item, state),
        subtitle: _buildSubtitle(context, item, state, tracker),
        trailing: _buildTrailing(context, item, state),
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
      borderRadius: BorderRadius.circular(8),
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
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
    );
  }

  Widget _buildSubtitle(
    BuildContext context,
    FavoriteEntry item,
    SelectableListItemState<FavoriteEntry, String> state,
    StatisticsTracker tracker,
  ) {
    final ThemeData theme = Theme.of(context);
    final int playCount = tracker.read(item.itemId)?.playCount ?? 0;

    return Row(
      children: [
        Text(
          buildFavoriteEntrySubtitle(item),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(width: 8),
        playCount > 0
            ? 
          Tag(
                text: '$playCount',
                color: Colors.grey.withValues(alpha: 0.2),
                textColor: const Color.fromARGB(255, 134, 134, 134),
                size: TagSize.small,
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedHeadphones,
                  size: 12,
                ),
              )
            : const SizedBox.shrink(),
      ],
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
