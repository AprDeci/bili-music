import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class PlayerLandscapeControls extends StatelessWidget {
  const PlayerLandscapeControls({
    super.key,
    required this.state,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onBackward,
    required this.onTogglePlayback,
    required this.onForward,
    required this.onOpenQueue,
  });

  final PlayerState state;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback onBackward;
  final VoidCallback onTogglePlayback;
  final VoidCallback onForward;
  final VoidCallback onOpenQueue;

  @override
  Widget build(BuildContext context) {
    final bool canGoNext =
        state.isReady &&
        (state.queueMode == PlayerQueueMode.singleRepeat || state.hasNext);

    return IconButtonTheme(
      data: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: neutralColorOf(context),
          minimumSize: const Size.square(48),
          iconSize: 28,
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: IconButton(
              tooltip: isFavorite ? '取消喜欢' : '喜欢',
              onPressed: onFavoriteToggle,
              icon: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
              ),
            ),
          ),
          Expanded(
            child: IconButton(
              tooltip: '上一首',
              onPressed: state.isReady && state.hasPrevious ? onBackward : null,
              icon: const Icon(Icons.skip_previous_rounded, size: 36),
            ),
          ),
          Expanded(
            child: IconButton(
              tooltip: state.isPlaying ? '暂停' : '播放',
              onPressed: state.hasQueue && !state.isLoading
                  ? onTogglePlayback
                  : null,
              icon: Icon(
                state.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                size: 48,
              ),
            ),
          ),
          Expanded(
            child: IconButton(
              tooltip: '下一首',
              onPressed: canGoNext ? onForward : null,
              icon: const Icon(Icons.skip_next_rounded, size: 36),
            ),
          ),
          Expanded(
            child: IconButton(
              tooltip: '播放队列',
              onPressed: state.hasQueue ? onOpenQueue : null,
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedListMusic),
            ),
          ),
        ],
      ),
    );
  }
}
