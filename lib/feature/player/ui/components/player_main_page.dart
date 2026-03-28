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
    required this.availableParts,
    required this.onPartTap,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onSeek,
    required this.onBackward,
    required this.onTogglePlayback,
    required this.onForward,
  });

  final PlayerState state;
  final PlayableItem? item;
  final List<PlayableItem> availableParts;
  final VoidCallback? onPartTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final ValueChanged<double> onSeek;
  final VoidCallback onBackward;
  final VoidCallback onTogglePlayback;
  final VoidCallback onForward;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: <Widget>[
        const SizedBox(height: 4),
        if (availableParts.length > 1) ...<Widget>[
          _PlayerPartSelector(
            item: item,
            availableParts: availableParts,
            onTap: onPartTap,
          ),
          const SizedBox(height: 18),
        ],
        SizedBox(
          width: 200,
          height: 200,
          child: PlayerArtworkFrame(coverUrl: item?.coverUrl ?? ''),
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
        const SizedBox(height: 18),
        PlayerProgressSection(state: state, onChanged: onSeek),
        const SizedBox(height: 18),
        PlayerTransportControls(
          state: state,
          onBackward: onBackward,
          onTogglePlayback: onTogglePlayback,
          onForward: onForward,
        ),
        const SizedBox(height: 30),
        PlayerPlaybackStatusChip(state: state),
        const SizedBox(height: 18),
      ],
    );
  }
}

class _PlayerPartSelector extends StatelessWidget {
  const _PlayerPartSelector({
    required this.item,
    required this.availableParts,
    required this.onTap,
  });

  final PlayableItem? item;
  final List<PlayableItem> availableParts;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final PlayableItem? currentItem = item;
    final int currentPage = currentItem?.page ?? 1;
    final String title = currentItem?.pageTitle?.trim() ?? '';
    final String label = title.isEmpty
        ? 'P$currentPage'
        : 'P$currentPage · $title';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.14),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.playlist_play_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '分P选择',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${availableParts.length}P',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
