import 'dart:async';

import 'package:bilimusic/common/components/queue_mode_icon.dart';
import 'package:bilimusic/core/theme/theme_colors.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_progress_provider.dart';
import 'package:bilimusic/feature/player/logic/utils/player_progress_ui_helpers.dart';
import 'package:bilimusic/feature/player/logic/utils/player_ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

class PlayerProgressHost extends ConsumerWidget {
  const PlayerProgressHost({
    super.key,
    required this.state,
    required this.onChanged,
  });

  final PlayerState state;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlayerProgressSnapshot progress = resolvePlayerProgressSnapshot(
      ref.watch(playerProgressProvider),
      state,
    );

    return PlayerProgressSection(
      position: progress.position,
      duration: progress.duration,
      isReady: progress.isReady,
      onChanged: onChanged,
    );
  }
}

class PlayerProgressSection extends StatefulWidget {
  const PlayerProgressSection({
    super.key,
    required this.position,
    required this.duration,
    required this.isReady,
    required this.onChanged,
  });

  final Duration position;
  final Duration? duration;
  final bool isReady;
  final ValueChanged<double> onChanged;

  @override
  State<PlayerProgressSection> createState() => _PlayerProgressSectionState();
}

class _PlayerProgressSectionState extends State<PlayerProgressSection> {
  bool _isDragging = false;
  double? _dragProgress;
  double? _settledProgress;
  Timer? _settleTimer;

  @override
  void didUpdateWidget(covariant PlayerProgressSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.position != widget.position ||
        oldWidget.duration != widget.duration ||
        !widget.isReady) {
      _settledProgress = null;
      _settleTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _settleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final neutralColor = neutralColorOf(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Duration total = widget.duration ?? Duration.zero;
    final double progress = total.inMilliseconds <= 0
        ? 0
        : widget.position.inMilliseconds / total.inMilliseconds;
    final double visualProgress = _isDragging || _settledProgress != null
        ? (_dragProgress ?? progress).clamp(0.0, 1.0)
        : progress.clamp(0.0, 1.0);

    final Duration visualPosition = Duration(
      milliseconds: (total.inMilliseconds * visualProgress).round(),
    );

    return Column(
      children: <Widget>[
        SizedBox(
          height: 48,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              inactiveTrackColor: neutralColor.withValues(alpha: 0.18),
              activeTrackColor: neutralColor,
              thumbColor: neutralColor,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 3),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              overlayColor: neutralColor.withValues(alpha: 0.14),
            ),
            child: Slider(
              padding: EdgeInsets.zero,
              value: visualProgress,
              onChangeStart: widget.isReady
                  ? (double value) {
                      _settleTimer?.cancel();
                      setState(() {
                        _isDragging = true;
                        _dragProgress = value;
                        _settledProgress = null;
                      });
                    }
                  : null,
              onChanged: widget.isReady
                  ? (double value) {
                      setState(() {
                        _dragProgress = value;
                      });
                    }
                  : null,
              onChangeEnd: widget.isReady
                  ? (double value) {
                      setState(() {
                        _isDragging = false;
                        _dragProgress = value;
                        _settledProgress = value;
                      });
                      _settleTimer = Timer(
                        const Duration(milliseconds: 500),
                        () {
                          setState(() => _settledProgress = null);
                        },
                      );
                      widget.onChanged(value);
                    }
                  : null,
            ),
          ),
        ),
        Row(
          children: <Widget>[
            Text(
              formatPlayerDuration(visualPosition),
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w700,
                fontSize: 8,
              ),
            ),
            const Spacer(),
            Text(
              formatPlayerDuration(total),
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: 8,
                color: colorScheme.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
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
    final Color playerControlColor = neutralColorOf(context);
    final Color disabledPlayerControlColor = playerControlColor.withValues(
      alpha: 0.32,
    );
    final bool canTogglePlayback = state.hasQueue && !state.isLoading;
    final Color iconColor = state.isReady
        ? playerControlColor
        : disabledPlayerControlColor;
    final bool canGoPrevious = state.isReady && state.hasPrevious;
    final bool canGoNext =
        state.isReady &&
        (state.queueMode == PlayerQueueMode.singleRepeat || state.hasNext);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        PlayerCircleActionButton(
          icon: queueModeIcon(state.queueMode),
          color: iconColor,
          onPressed: state.hasQueue ? onToggleQueueMode : null,
        ),
        PlayerCircleActionButton(
          icon: const Icon(Icons.skip_previous_rounded),
          color: iconColor,
          onPressed: canGoPrevious ? onBackward : null,
        ),
        OutlinedButton(
          onPressed: canTogglePlayback ? onTogglePlayback : null,
          style: OutlinedButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
            minimumSize: const Size(58, 58),
            shape: const CircleBorder(),
            foregroundColor: playerControlColor,
            disabledForegroundColor: disabledPlayerControlColor,
            side: BorderSide(
              color: canTogglePlayback
                  ? playerControlColor
                  : disabledPlayerControlColor,
              width: 2,
            ),
            padding: EdgeInsets.zero,
          ),
          child: Icon(
            state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 40,
          ),
        ),
        PlayerCircleActionButton(
          icon: const Icon(Icons.skip_next_rounded),
          color: iconColor,
          onPressed: canGoNext ? onForward : null,
        ),
        PlayerCircleActionButton(
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedListMusic),
          color: iconColor,
          onPressed: state.hasQueue ? onOpenQueue : null,
        ),
      ],
    );
  }
}

class PlayerCircleActionButton extends StatelessWidget {
  const PlayerCircleActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final Widget icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: icon,
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
    final String? label = _buildStatusLabel(state);
    if (label == null) {
      return const SizedBox.shrink();
    }

    final Color foreground = state.hasError
        ? colorScheme.error
        : colorScheme.primary.withValues(alpha: 0.88);

    return Align(
      alignment: Alignment.center,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
      ),
    );
  }

  String? _buildStatusLabel(PlayerState state) {
    return switch (state.statusHint) {
      PlayerStatusHint.resolvingAudio => '正在解析音频...',
      PlayerStatusHint.connectingStream => '正在连接播放流...',
      PlayerStatusHint.loadingCache => '正在加载缓存音频...',
      PlayerStatusHint.buffering => '缓冲中...',
      PlayerStatusHint.error => state.errorMessage ?? '播放失败，请稍后重试',
      null => null,
    };
  }
}
