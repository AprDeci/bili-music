import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/ui/components/player_artwork.dart';
import 'package:bilimusic/feature/player/ui/components/player_controls.dart';
import 'package:bilimusic/feature/player/ui/components/player_shared.dart';
import 'package:bilimusic/feature/player/ui/components/player_ui_helpers.dart';
import 'package:flutter/material.dart';

class PlayerMainPage extends StatelessWidget {
  const PlayerMainPage({
    super.key,
    required this.state,
    required this.item,
    required this.commentCount,
    required this.availableParts,
    required this.onPartTap,
    required this.onOpenCollectionSheet,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onSeek,
    required this.onToggleQueueMode,
    required this.onBackward,
    required this.onTogglePlayback,
    required this.onForward,
    required this.onOpenQueue,
    required this.onOpenComments,
  });

  final PlayerState state;
  final PlayableItem? item;
  final int? commentCount;
  final List<PlayableItem> availableParts;
  final VoidCallback? onPartTap;
  final VoidCallback? onOpenCollectionSheet;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final ValueChanged<double> onSeek;
  final VoidCallback onToggleQueueMode;
  final VoidCallback onBackward;
  final VoidCallback onTogglePlayback;
  final VoidCallback onForward;
  final VoidCallback onOpenQueue;
  final VoidCallback? onOpenComments;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size screenSize = mediaQuery.size;
    final bool canOpenPartSelector = item != null && availableParts.length > 1;
    final bool showStatusHint = state.statusHint != null;
    final double artworkSize = (screenSize.height * 0.31).clamp(190.0, 320.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 12),
        Center(
          child: SizedBox(
            width: artworkSize,
            height: artworkSize,
            child: PlayerArtworkFrame(coverUrl: item?.coverUrl ?? ''),
          ),
        ),
        const SizedBox(height: 28),
        PlayerTrackHeader(
          title: item?.title ?? '还没有选择播放内容',
          subtitle: item == null
              ? '从搜索页选一条视频或音频后，这里会显示当前播放信息。'
              : buildPlayerSubtitle(item!.author, state),
          isFavoriteEnabled: item != null,
          isFavorite: isFavorite,
          onFavoriteToggle: onFavoriteToggle,
        ),
        const Spacer(),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (showStatusHint || true) PlayerPlaybackStatusChip(state: state),
            if (showStatusHint) const SizedBox(height: 12),
            _PlayerToolBar(
              hasItem: item != null,
              item: item,
              commentCount: commentCount,
              canOpenPartSelector: canOpenPartSelector,
              onPartTap: onPartTap,
              onOpenCollectionSheet: onOpenCollectionSheet,
              onOpenComments: onOpenComments,
            ),
            const SizedBox(height: 10),
            PlayerProgressSection(state: state, onChanged: onSeek),
            const SizedBox(height: 10),
            PlayerTransportControls(
              state: state,
              onToggleQueueMode: onToggleQueueMode,
              onBackward: onBackward,
              onTogglePlayback: onTogglePlayback,
              onForward: onForward,
              onOpenQueue: onOpenQueue,
            ),
          ],
        ),
        SizedBox(height: mediaQuery.padding.bottom > 0 ? 8 : 18),
      ],
    );
  }
}

class _PlayerToolBar extends StatelessWidget {
  const _PlayerToolBar({
    required this.hasItem,
    required this.item,
    required this.commentCount,
    required this.canOpenPartSelector,
    required this.onPartTap,
    required this.onOpenCollectionSheet,
    required this.onOpenComments,
  });

  final bool hasItem;
  final PlayableItem? item;
  final int? commentCount;
  final bool canOpenPartSelector;
  final VoidCallback? onPartTap;
  final VoidCallback? onOpenCollectionSheet;
  final VoidCallback? onOpenComments;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _PlayerPartToolButton(
          item: item,
          isEnabled: canOpenPartSelector,
          onTap: onPartTap,
        ),
        _PlayerToolButton(
          icon: Icons.folder_open_outlined,
          isEnabled: hasItem,
          onTap: onOpenCollectionSheet,
        ),
        _PlayerCommentToolButton(
          commentCount: commentCount,
          isEnabled: hasItem,
          onTap: onOpenComments,
        ),
      ],
    );
  }
}

class _PlayerCommentToolButton extends StatelessWidget {
  const _PlayerCommentToolButton({
    required this.commentCount,
    required this.isEnabled,
    this.onTap,
  });

  final int? commentCount;
  final bool isEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String? badgeLabel = _formatCommentBadgeCount(commentCount);

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        _PlayerToolButton(
          icon: Icons.comment_outlined,
          isEnabled: isEnabled,
          onTap: onTap,
        ),
        if (isEnabled && badgeLabel != null)
          Positioned(
            top: -2,
            right: -8,
            child: IgnorePointer(
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  badgeLabel,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

String? _formatCommentBadgeCount(int? count) {
  if (count == null || count <= 0) {
    return null;
  }
  if (count <= 99) {
    return count.toString();
  }
  if (count <= 999) {
    return '99+';
  }
  return '999+';
}

class _PlayerPartToolButton extends StatelessWidget {
  const _PlayerPartToolButton({
    required this.item,
    required this.isEnabled,
    this.onTap,
  });

  final PlayableItem? item;
  final bool isEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final int currentPage = item?.page ?? 1;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        _PlayerToolButton(
          icon: Icons.playlist_play_rounded,
          isEnabled: isEnabled,
          onTap: onTap,
        ),
        if (isEnabled)
          Positioned(
            top: -2,
            right: -8,
            child: IgnorePointer(
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  'P$currentPage',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PlayerToolButton extends StatelessWidget {
  const _PlayerToolButton({
    required this.icon,
    required this.isEnabled,
    this.onTap,
  });

  final IconData icon;
  final bool isEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color foregroundColor = isEnabled
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.38);
    return SizedBox(
      width: 40,
      height: 40,
      child: InkResponse(
        onTap: isEnabled ? onTap : null,
        radius: 24,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: Icon(icon, size: 24, color: foregroundColor),
          ),
        ),
      ),
    );
  }
}
