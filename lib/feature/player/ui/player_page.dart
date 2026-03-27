import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerPage extends ConsumerStatefulWidget {
  const PlayerPage({super.key, this.initialItem});

  final PlayableItem? initialItem;

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialItem();
    });
  }

  @override
  void didUpdateWidget(covariant PlayerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialItem != widget.initialItem) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadInitialItem();
      });
    }
  }

  void _loadInitialItem() {
    final PlayableItem? item = widget.initialItem;
    if (item == null) {
      return;
    }
    ref.read(playerControllerProvider.notifier).loadFromItem(item);
  }

  @override
  Widget build(BuildContext context) {
    final PlayerState state = ref.watch(playerControllerProvider);
    final PlayerController playerController = ref.read(
      playerControllerProvider.notifier,
    );
    final PlayableItem? item = state.currentItem ?? widget.initialItem;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              colorScheme.surface,
              colorScheme.primary.withValues(alpha: 0.08),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: <Widget>[
            const Positioned(top: -120, left: -90, child: _BackdropOrb()),
            const Positioned(
              right: -70,
              top: 180,
              child: _BackdropOrb(size: 220, opacity: 0.35),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    children: <Widget>[
                      _TopBar(
                        title: _buildHeaderTitle(state, item),
                        onBack: () => Navigator.of(context).maybePop(),
                        onMore: item == null
                            ? null
                            : () => playerController.loadFromItem(item),
                      ),
                      const SizedBox(height: 22),
                      _ArtworkFrame(coverUrl: item?.coverUrl ?? ''),
                      const SizedBox(height: 28),
                      _TrackHeader(
                        title: item?.title ?? '还没有选择播放内容',
                        subtitle: item == null
                            ? '从搜索页选一条视频或音频后，这里会显示当前播放信息。'
                            : _buildSubtitle(item.author, state),
                        isFavoriteEnabled: item != null,
                      ),
                      const SizedBox(height: 26),
                      _ProgressSection(
                        state: state,
                        onChanged: (double value) {
                          final int totalMs =
                              (state.duration ?? Duration.zero).inMilliseconds;
                          final Duration position = Duration(
                            milliseconds: (totalMs * value).round(),
                          );
                          playerController.seek(position);
                        },
                      ),
                      const SizedBox(height: 30),
                      _TransportControls(
                        state: state,
                        onBackward: () => playerController.seekBy(
                          const Duration(seconds: -10),
                        ),
                        onTogglePlayback: playerController.togglePlayback,
                        onForward: () => playerController.seekBy(
                          const Duration(seconds: 10),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _UtilityActions(
                        state: state,
                        onStop: state.isReady ? playerController.stop : null,
                      ),
                      const SizedBox(height: 28),
                      _PlaybackStatusChip(state: state),
                      const SizedBox(height: 18),
                      _MetaSheet(state: state, item: item),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.onBack,
    required this.onMore,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color iconColor = theme.colorScheme.primary;

    return SizedBox(
      height: 48,
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            color: iconColor,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: iconColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: onMore,
            icon: const Icon(Icons.more_vert_rounded),
            color: iconColor,
          ),
        ],
      ),
    );
  }
}

class _ArtworkFrame extends StatelessWidget {
  const _ArtworkFrame({required this.coverUrl});

  final String coverUrl;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.16),
              blurRadius: 32,
              offset: Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (coverUrl.isNotEmpty)
                Image.network(
                  coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const _ArtworkFallback();
                  },
                )
              else
                const _ArtworkFallback(),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      colorScheme.primary.withValues(alpha: 0.78),
                      const Color(0x00000000),
                      colorScheme.primaryContainer.withValues(alpha: 0.44),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const <double>[0, 0.55, 1],
                  ),
                ),
              ),
              const _ArtworkLiquidPattern(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArtworkFallback extends StatelessWidget {
  const _ArtworkFallback();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            colorScheme.primary,
            colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.music_note_rounded, size: 84, color: Colors.white),
      ),
    );
  }
}

class _ArtworkLiquidPattern extends StatelessWidget {
  const _ArtworkLiquidPattern();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return CustomPaint(
      painter: _LiquidArtworkPainter(
        darkColor: colorScheme.primary.withValues(alpha: 0.58),
        lightColor: colorScheme.primaryContainer.withValues(alpha: 0.68),
      ),
    );
  }
}

class _TrackHeader extends StatelessWidget {
  const _TrackHeader({
    required this.title,
    required this.subtitle,
    required this.isFavoriteEnabled,
  });

  final String title;
  final String subtitle;
  final bool isFavoriteEnabled;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: isFavoriteEnabled ? () {} : null,
          icon: const Icon(Icons.favorite_border_rounded),
          color: colorScheme.primary.withValues(alpha: 0.55),
          iconSize: 28,
        ),
      ],
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.state, required this.onChanged});

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
                _formatDuration(state.position),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                _formatDuration(total),
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

class _TransportControls extends StatelessWidget {
  const _TransportControls({
    required this.state,
    required this.onBackward,
    required this.onTogglePlayback,
    required this.onForward,
  });

  final PlayerState state;
  final VoidCallback onBackward;
  final VoidCallback onTogglePlayback;
  final VoidCallback onForward;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color iconColor = state.isReady
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.3);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _CircleActionButton(
          icon: Icons.skip_previous_rounded,
          color: iconColor,
          onPressed: state.isReady ? onBackward : null,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: FilledButton(
            onPressed: state.isReady ? onTogglePlayback : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size(88, 88),
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
        _CircleActionButton(
          icon: Icons.skip_next_rounded,
          color: iconColor,
          onPressed: state.isReady ? onForward : null,
        ),
      ],
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
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

class _UtilityActions extends StatelessWidget {
  const _UtilityActions({required this.state, required this.onStop});

  final PlayerState state;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color activeColor = colorScheme.onSurface.withValues(alpha: 0.58);
    final Color disabledColor = colorScheme.onSurface.withValues(alpha: 0.22);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _UtilityIcon(
          icon: Icons.open_in_full_rounded,
          color: state.isReady ? activeColor : disabledColor,
        ),
        _UtilityIcon(
          icon: Icons.repeat_rounded,
          color: state.isReady ? activeColor : disabledColor,
        ),
        _UtilityIcon(
          icon: Icons.stop_rounded,
          color: onStop == null ? disabledColor : activeColor,
          onTap: onStop,
        ),
      ],
    );
  }
}

class _UtilityIcon extends StatelessWidget {
  const _UtilityIcon({required this.icon, required this.color, this.onTap});

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: Icon(icon, color: color, size: 24),
    );
  }
}

class _PlaybackStatusChip extends StatelessWidget {
  const _PlaybackStatusChip({required this.state});

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
      background = colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.8,
      );
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

class _MetaSheet extends StatelessWidget {
  const _MetaSheet({required this.state, required this.item});

  final PlayerState state;
  final PlayableItem? item;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '播放信息',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          _MetaRow(label: 'BV', value: item?.bvid ?? '--'),
          _MetaRow(
            label: 'AID',
            value: item == null ? '--' : item!.aid.toString(),
          ),
          _MetaRow(
            label: 'CID',
            value: state.audioStream == null
                ? '--'
                : state.audioStream!.cid.toString(),
          ),
          _MetaRow(label: '音质', value: state.audioStream?.qualityLabel ?? '--'),
          _MetaRow(
            label: '分P',
            value: state.audioStream?.pageTitle ?? '--',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 56,
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.58),
                  fontWeight: FontWeight.w700,
                ),
              ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackdropOrb extends StatelessWidget {
  const _BackdropOrb({this.size = 260, this.opacity = 0.45});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              primary.withValues(alpha: opacity * 0.45),
              primary.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiquidArtworkPainter extends CustomPainter {
  _LiquidArtworkPainter({required this.darkColor, required this.lightColor});

  final Color darkColor;
  final Color lightColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint darkPaint = Paint()
      ..color = darkColor
      ..style = PaintingStyle.fill;

    final Paint lightPaint = Paint()
      ..color = lightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.11
      ..strokeCap = StrokeCap.round;

    final Path topWave = Path()
      ..moveTo(-size.width * 0.1, size.height * 0.2)
      ..cubicTo(
        size.width * 0.18,
        -size.height * 0.05,
        size.width * 0.52,
        size.height * 0.28,
        size.width * 0.92,
        size.height * 0.02,
      )
      ..cubicTo(
        size.width * 1.1,
        size.height * 0.16,
        size.width * 1.08,
        size.height * 0.44,
        size.width * 0.86,
        size.height * 0.5,
      )
      ..cubicTo(
        size.width * 0.56,
        size.height * 0.62,
        size.width * 0.24,
        size.height * 0.34,
        -size.width * 0.08,
        size.height * 0.48,
      )
      ..lineTo(-size.width * 0.12, -size.height * 0.08)
      ..close();

    final Path bottomWave = Path()
      ..moveTo(-size.width * 0.1, size.height * 0.82)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.56,
        size.width * 0.46,
        size.height * 1.04,
        size.width * 0.8,
        size.height * 0.78,
      )
      ..cubicTo(
        size.width * 0.98,
        size.height * 0.64,
        size.width * 1.06,
        size.height * 0.88,
        size.width * 1.08,
        size.height * 1.08,
      )
      ..lineTo(-size.width * 0.12, size.height * 1.08)
      ..close();

    canvas.drawPath(topWave, darkPaint);
    canvas.drawPath(bottomWave, darkPaint);

    final Path ribbon = Path()
      ..moveTo(-size.width * 0.02, size.height * 0.62)
      ..cubicTo(
        size.width * 0.16,
        size.height * 0.48,
        size.width * 0.42,
        size.height * 0.7,
        size.width * 0.58,
        size.height * 0.52,
      )
      ..cubicTo(
        size.width * 0.78,
        size.height * 0.28,
        size.width * 0.92,
        size.height * 0.38,
        size.width * 1.04,
        size.height * 0.22,
      );

    canvas.drawPath(ribbon, lightPaint);

    final Paint glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: <Color>[
              const Color(0xFFFFFFFF).withValues(alpha: 0.32),
              const Color(0x00FFFFFF),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.72, size.height * 0.56),
              radius: size.width * 0.34,
            ),
          );

    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.56),
      size.width * 0.34,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _formatDuration(Duration value) {
  if (value <= Duration.zero) {
    return '00:00';
  }

  final int totalSeconds = value.inSeconds;
  final int hours = totalSeconds ~/ 3600;
  final int minutes = (totalSeconds % 3600) ~/ 60;
  final int seconds = totalSeconds % 60;

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

String _buildSubtitle(String author, PlayerState state) {
  final String? pageTitle = state.audioStream?.pageTitle;
  if (pageTitle == null || pageTitle.isEmpty) {
    return author;
  }
  return '$author · $pageTitle';
}

String _buildHeaderTitle(PlayerState state, PlayableItem? item) {
  if (state.isPlaying) {
    return 'Now Playing';
  }
  if (item != null) {
    return 'Player';
  }
  return 'Ready to Play';
}
