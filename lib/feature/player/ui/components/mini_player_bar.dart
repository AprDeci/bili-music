import 'dart:math';

import 'package:bilimusic/common/bottom_height_helper.dart';
import 'package:bilimusic/common/components/cachedImage.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:flutter/material.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({
    super.key,
    required this.state,
    required this.onTap,
    required this.onTogglePlayback,
    this.bottomPadding = BottomHeightHelper.miniPlayerCollapsedBottomPadding,
  });

  final PlayerState state;
  final VoidCallback onTap;
  final VoidCallback onTogglePlayback;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String subtitle = _buildSubtitle(state);
    final double progress = _buildProgress(state);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.10),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: <Widget>[
                  _Artwork(
                    coverUrl: state.currentItem?.coverUrl ?? '',
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          state.currentItem?.title ?? '未选择播放内容',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _PlaybackButton(
                    progress: progress,
                    isPlaying: state.isPlaying,
                    onPressed: onTogglePlayback,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _buildSubtitle(PlayerState state) {
    return switch (state.statusHint) {
      PlayerStatusHint.resolvingAudio => '正在解析音频...',
      PlayerStatusHint.connectingStream => '正在连接播放流...',
      PlayerStatusHint.loadingCache => '正在加载缓存音频...',
      PlayerStatusHint.buffering => '缓冲中...',
      PlayerStatusHint.error => state.errorMessage ?? '播放失败，请稍后重试',
      null =>
        state.audioStream?.qualityLabel ?? state.currentItem?.author ?? '',
    };
  }

  double _buildProgress(PlayerState state) {
    final Duration? duration = state.duration;

    if (duration == null || duration <= Duration.zero) {
      return 0;
    }

    return (state.position.inMilliseconds / duration.inMilliseconds).clamp(
      0.0,
      1.0,
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.coverUrl});

  static const double _outerSize = 52;
  static const double _imageSize = 48;

  final String coverUrl;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: _outerSize,
      height: _outerSize,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: _imageSize,
            height: _imageSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: colorScheme.surfaceContainerHigh,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CommonCachedImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
                fallbackIcon: Icons.music_note_rounded,
                iconColor: colorScheme.onSurfaceVariant,
                backgroundColor: colorScheme.surfaceContainerHigh,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaybackButton extends StatelessWidget {
  const _PlaybackButton({
    required this.progress,
    required this.isPlaying,
    required this.onPressed,
  });

  final double progress;
  final bool isPlaying;
  final VoidCallback onPressed;

  static const double _size = 44;
  static const double _iconSize = 22;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CustomPaint(
            size: const Size(_size - 8, _size - 8),
            painter: _PlaybackProgressPainter(
              progress: progress,
              trackColor: colorScheme.primary.withValues(alpha: 0.14),
              progressColor: colorScheme.primary,
            ),
          ),
          IconButton(
            onPressed: onPressed,
            style: IconButton.styleFrom(
              minimumSize: const Size(_size - 8, _size - 8),
              // backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
              foregroundColor: colorScheme.primary,
              padding: EdgeInsets.zero,
            ),
            iconSize: _iconSize,
            icon: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaybackProgressPainter extends CustomPainter {
  const _PlaybackProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;

  static const double _strokeWidth = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final double clampedProgress = progress.clamp(0.0, 1.0);
    final Offset center = size.center(Offset.zero);
    final double radius = (size.shortestSide - _strokeWidth) / 2;
    final Rect arcRect = Rect.fromCircle(center: center, radius: radius);

    final Paint trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;

    final Paint progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (clampedProgress <= 0) {
      return;
    }

    canvas.drawArc(
      arcRect,
      -pi / 2,
      2 * pi * clampedProgress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PlaybackProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
