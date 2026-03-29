import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/ui/components/player_artwork.dart';
import 'package:bilimusic/feature/player/ui/components/player_controls.dart';
import 'package:bilimusic/feature/player/ui/components/player_shared.dart';
import 'package:bilimusic/feature/player/ui/components/player_ui_helpers.dart';
import 'package:flutter/foundation.dart';
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
    required this.onToggleQueueMode,
    required this.onBackward,
    required this.onTogglePlayback,
    required this.onForward,
    required this.onOpenQueue,
  });

  final PlayerState state;
  final PlayableItem? item;
  final List<PlayableItem> availableParts;
  final VoidCallback? onPartTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final ValueChanged<double> onSeek;
  final VoidCallback onToggleQueueMode;
  final VoidCallback onBackward;
  final VoidCallback onTogglePlayback;
  final VoidCallback onForward;
  final VoidCallback onOpenQueue;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size screenSize = mediaQuery.size;
    final bool hasPartSelector = availableParts.length > 1;
    final bool showDebugQueue = kDebugMode && state.hasQueue;
    final bool showDebugStatus = kDebugMode;
    final double artworkSize = (screenSize.height * 0.31).clamp(190.0, 320.0);
    final double topSpacing = hasPartSelector ? 4 : 12;
    final double artworkBottomSpacing = hasPartSelector ? 20 : 28;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: topSpacing),
        if (hasPartSelector) ...<Widget>[
          _PlayerPartSelector(
            item: item,
            availableParts: availableParts,
            onTap: onPartTap,
          ),
          const SizedBox(height: 16),
        ],
        Center(
          child: SizedBox(
            width: artworkSize,
            height: artworkSize,
            child: PlayerArtworkFrame(coverUrl: item?.coverUrl ?? ''),
          ),
        ),
        SizedBox(height: artworkBottomSpacing),
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
            PlayerProgressSection(state: state, onChanged: onSeek),
            const SizedBox(height: 18),
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
        if (showDebugQueue || showDebugStatus) const SizedBox(height: 18),
        if (showDebugQueue) ...<Widget>[
          _PlayerQueueSummary(state: state),
          if (showDebugStatus) const SizedBox(height: 12),
        ],
        if (showDebugStatus) PlayerPlaybackStatusChip(state: state),
        SizedBox(height: mediaQuery.padding.bottom > 0 ? 8 : 18),
      ],
    );
  }
}

class _PlayerQueueSummary extends StatelessWidget {
  const _PlayerQueueSummary({required this.state});

  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final int current = (state.currentQueueIndex ?? 0) + 1;
    final String modeLabel = switch (state.queueMode) {
      PlayerQueueMode.sequence => '列表循环',
      PlayerQueueMode.singleRepeat => '单曲循环',
      PlayerQueueMode.shuffle => '随机播放',
    };
    final String source = state.queueSourceLabel?.trim() ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.queue_music_rounded, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              source.isEmpty
                  ? '队列 $current/${state.queue.length} · $modeLabel'
                  : '$source · $current/${state.queue.length} · $modeLabel',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
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
