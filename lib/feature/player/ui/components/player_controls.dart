import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/ui/components/player_ui_helpers.dart';
import 'package:flutter/material.dart';

class PlayerProgressSection extends StatelessWidget {
  const PlayerProgressSection({
    super.key,
    required this.state,
    required this.onChanged,
  });

  final PlayerState state;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Duration total = state.duration ?? Duration.zero;
    final double progress = total.inMilliseconds <= 0
        ? 0
        : state.position.inMilliseconds / total.inMilliseconds;

    return Column(
      children: <Widget>[
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 5,
            inactiveTrackColor: colorScheme.primary.withValues(alpha: 0.18),
            activeTrackColor: colorScheme.primary,
            thumbColor: colorScheme.surface,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            overlayColor: colorScheme.primary.withValues(alpha: 0.14),
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: state.isReady ? onChanged : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            children: <Widget>[
              Text(
                formatPlayerDuration(state.position),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                formatPlayerDuration(total),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PlayerTransportControls extends StatelessWidget {
  const PlayerTransportControls({
    super.key,
    required this.state,
    required this.onToggleQueueMode,
    required this.onBackward,
    required this.onTogglePlayback,
    required this.onForward,
    required this.onOpenQueue,
  });

  final PlayerState state;
  final VoidCallback onToggleQueueMode;
  final VoidCallback onBackward;
  final VoidCallback onTogglePlayback;
  final VoidCallback onForward;
  final VoidCallback onOpenQueue;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color iconColor = state.isReady
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.3);
    final Color activeModeColor = state.isReady
        ? colorScheme.primary
        : colorScheme.primary.withValues(alpha: 0.4);
    final bool canGoPrevious =
        state.isReady &&
        (state.hasPrevious || state.position > const Duration(seconds: 3));
    final bool canGoNext =
        state.isReady &&
        (state.queueMode == PlayerQueueMode.singleRepeat || state.hasNext);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        PlayerCircleActionButton(
          icon: _buildQueueModeIcon(state.queueMode),
          color: state.isReady ? activeModeColor : iconColor,
          onPressed: state.hasQueue ? onToggleQueueMode : null,
        ),
        PlayerCircleActionButton(
          icon: Icons.skip_previous_rounded,
          color: iconColor,
          onPressed: canGoPrevious ? onBackward : null,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: FilledButton(
            onPressed: state.isReady ? onTogglePlayback : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size(54, 54),
              shape: const CircleBorder(),
              backgroundColor: colorScheme.primary,
              disabledBackgroundColor: colorScheme.primary.withValues(
                alpha: 0.3,
              ),
              foregroundColor: Colors.white,
            ),
            child: Icon(
              state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 40,
            ),
          ),
        ),
        PlayerCircleActionButton(
          icon: Icons.skip_next_rounded,
          color: iconColor,
          onPressed: canGoNext ? onForward : null,
        ),
        PlayerCircleActionButton(
          icon: Icons.list,
          color: iconColor,
          onPressed: state.hasQueue ? onOpenQueue : null,
        ),
      ],
    );
  }

  IconData _buildQueueModeIcon(PlayerQueueMode mode) {
    return switch (mode) {
      PlayerQueueMode.sequence => Icons.repeat_rounded,
      PlayerQueueMode.singleRepeat => Icons.repeat_one_rounded,
      PlayerQueueMode.shuffle => Icons.shuffle_rounded,
    };
  }
}

class PlayerCircleActionButton extends StatelessWidget {
  const PlayerCircleActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: 34,
      color: color,
      style: IconButton.styleFrom(
        minimumSize: const Size(56, 56),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class PlayerPlaybackStatusChip extends StatelessWidget {
  const PlayerPlaybackStatusChip({super.key, required this.state});

  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    String label = '等待选择内容';
    Color background = colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.75,
    );
    Color foreground = colorScheme.onSurface.withValues(alpha: 0.7);
    IconData icon = Icons.music_note_rounded;

    if (state.isLoading) {
      label = '正在解析音频流';
      background = colorScheme.primaryContainer.withValues(alpha: 0.72);
      foreground = colorScheme.primary;
      icon = Icons.radio_button_checked_rounded;
    } else if (state.hasError) {
      label = state.errorMessage ?? '播放失败';
      background = colorScheme.errorContainer.withValues(alpha: 0.8);
      foreground = colorScheme.error;
      icon = Icons.error_outline_rounded;
    } else if (state.isBuffering) {
      label = '缓冲中';
      background = colorScheme.secondaryContainer.withValues(alpha: 0.75);
      foreground = colorScheme.secondary;
      icon = Icons.hourglass_top_rounded;
    } else if (state.isPlaying) {
      label = '正在播放';
      background = colorScheme.primaryContainer.withValues(alpha: 0.72);
      foreground = colorScheme.primary;
      icon = Icons.graphic_eq_rounded;
    } else if (state.isReady) {
      label = '已暂停，可继续播放';
      background = colorScheme.surfaceContainerHighest.withValues(alpha: 0.8);
      foreground = colorScheme.onSurface.withValues(alpha: 0.72);
      icon = Icons.pause_circle_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: foreground, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
