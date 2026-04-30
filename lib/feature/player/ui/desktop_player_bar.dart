import 'package:bilimusic/common/components/bar_icon_button.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/desktop/volumn_attach.dart';
import 'package:bilimusic/common/util/color_util.dart';
import 'package:bilimusic/feature/comment/domain/comment_target.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/desktop/quality_attach.dart';
import 'package:bilimusic/feature/player/ui/components/desktop/queue_mode_attach.dart';
import 'package:bilimusic/feature/player/ui/components/player_part_selector.dart';
import 'package:bilimusic/feature/player/ui/components/player_queue_sheet.dart';
import 'package:bilimusic/feature/player/ui/components/player_ui_helpers.dart';
import 'package:bilimusic/router/player_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class DesktopPlayerBar extends ConsumerWidget {
  const DesktopPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final PlayerState state = ref.watch(playerControllerProvider);
    final PlayerController controller = ref.read(
      playerControllerProvider.notifier,
    );
    final PlayableItem? item = state.currentItem;
    final bool isFavorite = item != null
        ? ref.watch(favoritesControllerProvider).isLiked(item)
        : false;
    final Duration total =
        state.duration ?? state.audioStream?.duration ?? Duration.zero;
    final double progress = total.inMilliseconds <= 0
        ? 0
        : (state.position.inMilliseconds / total.inMilliseconds).clamp(
            0.0,
            1.0,
          );
    final bool canTogglePlayback = state.hasQueue && !state.isLoading;
    final bool canGoPrevious =
        state.isReady &&
        (state.hasPrevious || state.position > const Duration(seconds: 3));
    final bool canGoNext =
        state.isReady &&
        (state.queueMode == PlayerQueueMode.singleRepeat || state.hasNext);

    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 220,
              child: _TrackSection(
                item: item,
                state: state,
                isFavorite: isFavorite,
                onFavoritePressed: item == null
                    ? null
                    : () {
                        ref
                            .read(favoritesControllerProvider.notifier)
                            .toggleLiked(item);
                      },
                onCommentPressed: item == null || item.aid <= 0
                    ? null
                    : () {
                        context.push(
                          '/comments',
                          extra: CommentTarget.video(
                            aid: item.aid,
                            bvid: item.bvid,
                            title: item.title,
                            coverUrl: item.coverUrl,
                          ),
                        );
                      },
              ),
            ),

            const SizedBox(width: 30),
            Expanded(
              flex: 4,
              child: _PlaybackSection(
                state: state,
                progress: progress,
                canGoPrevious: canGoPrevious,
                canGoNext: canGoNext,
                canTogglePlayback: canTogglePlayback,
                onSeek: (double value) {
                  final Duration target = Duration(
                    milliseconds: (total.inMilliseconds * value).round(),
                  );
                  controller.seek(target);
                },
                onSelectQueueMode: controller.setQueueMode,
                onPrevious: controller.skipToPrevious,
                onTogglePlayback: controller.togglePlayback,
                onNext: controller.skipToNext,
                onVolumeChanged: controller.setVolume,
                onToggleMute: controller.toggleMute,
              ),
            ),
            Expanded(
              flex: 2,
              child: _ActionSection(
                state: state,
                onOpenParts: item == null || state.availableParts.length < 2
                    ? null
                    : () => showDesktopPlayerPartSelectorPanel(
                        context: context,
                        parts: state.availableParts,
                        currentItem: item,
                        state: state,
                        controller: controller,
                      ),
                onOpenQueue: () =>
                    showDesktopPlayerQueuePanel(context: context, state: state),
                onSelectQuality: (int? qualityId) {
                  controller.switchCurrentAudioQuality(qualityId);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackSection extends StatelessWidget {
  const _TrackSection({
    required this.item,
    required this.state,
    required this.isFavorite,
    required this.onFavoritePressed,
    required this.onCommentPressed,
  });

  final PlayableItem? item;
  final PlayerState state;
  final bool isFavorite;
  final VoidCallback? onFavoritePressed;
  final VoidCallback? onCommentPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      children: <Widget>[
        _ArtworkHoverButton(item: item),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item?.title ?? '未选择播放内容',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: <Widget>[
                  BarIconButton(
                    onPressed: onFavoritePressed,
                    icon: isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    activeColor: const Color(0xFFFF5C73),
                    isActive: isFavorite,
                  ),
                  const SizedBox(width: 10),
                  BarIconButton(
                    onPressed: onCommentPressed,
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedComment01,
                      size: 20,
                      strokeWidth: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArtworkHoverButton extends StatefulWidget {
  const _ArtworkHoverButton({required this.item});

  final PlayableItem? item;

  @override
  State<_ArtworkHoverButton> createState() => _ArtworkHoverButtonState();
}

class _ArtworkHoverButtonState extends State<_ArtworkHoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isEnabled = widget.item != null;

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: isEnabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: isEnabled ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTap: isEnabled
            ? () => openPlayerPage(context, item: widget.item)
            : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: colorScheme.surfaceContainerHigh,
          ),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CommonCachedImage(
                    imageUrl: widget.item?.coverUrl,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.music_note_rounded,
                    iconColor: colorScheme.onSurfaceVariant,
                    backgroundColor: colorScheme.surfaceContainerHigh,
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isHovered ? 1 : 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.open_in_full_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaybackSection extends StatelessWidget {
  const _PlaybackSection({
    required this.state,
    required this.progress,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.canTogglePlayback,
    required this.onSeek,
    required this.onSelectQueueMode,
    required this.onPrevious,
    required this.onTogglePlayback,
    required this.onNext,
    required this.onVolumeChanged,
    required this.onToggleMute,
  });

  final PlayerState state;
  final double progress;
  final bool canGoPrevious;
  final bool canGoNext;
  final bool canTogglePlayback;
  final ValueChanged<double> onSeek;
  final ValueChanged<PlayerQueueMode> onSelectQueueMode;
  final VoidCallback onPrevious;
  final VoidCallback onTogglePlayback;
  final VoidCallback onNext;
  final ValueChanged<double> onVolumeChanged;
  final Future<double> Function() onToggleMute;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Duration total =
        state.duration ?? state.audioStream?.duration ?? Duration.zero;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DesktopQueueModeAttach(
              enabled: state.hasQueue,
              mode: state.queueMode,
              onSelected: onSelectQueueMode,
            ),
            const SizedBox(width: 8),
            BarIconButton(
              onPressed: canGoPrevious ? onPrevious : null,
              icon: Icons.skip_previous_rounded,
              iconSize: 24,
            ),
            const SizedBox(width: 8),
            _PlayPauseButton(
              isPlaying: state.isPlaying,
              onPressed: canTogglePlayback ? onTogglePlayback : null,
            ),
            const SizedBox(width: 8),
            BarIconButton(
              onPressed: canGoNext ? onNext : null,
              icon: Icons.skip_next_rounded,
              iconSize: 24,
            ),
            const SizedBox(width: 8),
            DesktopVolumnAttach(
              enabled: state.hasQueue,
              volume: state.volume,
              onVolumeChanged: onVolumeChanged,
              onToggleMute: onToggleMute,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: <Widget>[
            SizedBox(
              width: 38,
              child: Text(
                formatPlayerDuration(state.position),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2.5,
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 10,
                  ),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 3,
                  ),
                  inactiveTrackColor: colorScheme.outlineVariant,
                  activeTrackColor: colorScheme.onSurface,
                  thumbColor: colorScheme.onSurface,
                  overlayColor: colorScheme.onSurface.withValues(alpha: 0.08),
                ),
                child: Slider(
                  value: progress,
                  onChanged: total > Duration.zero && state.isReady
                      ? onSeek
                      : null,
                ),
              ),
            ),
            SizedBox(
              width: 38,
              child: Text(
                formatPlayerDuration(total),
                textAlign: TextAlign.right,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionSection extends StatelessWidget {
  const _ActionSection({
    required this.state,
    required this.onOpenParts,
    required this.onOpenQueue,
    required this.onSelectQuality,
  });

  final PlayerState state;
  final VoidCallback? onOpenParts;
  final VoidCallback onOpenQueue;
  final ValueChanged<int?> onSelectQuality;

  @override
  Widget build(BuildContext context) {
    final List<AudioQualityOption> qualities =
        state.audioStream?.availableQualities ?? const <AudioQualityOption>[];

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        DesktopQualityAttach(qualities: qualities, onSelected: onSelectQuality),
        const SizedBox(width: 10),
        BarIconButton(
          onPressed: onOpenParts,
          icon: HugeIcon(icon: HugeIcons.strokeRoundedListVideo, size: 22),
          tooltip: '选择分 P',
        ),
        const SizedBox(width: 10),
        BarIconButton(
          onPressed: state.hasQueue ? onOpenQueue : null,
          icon: HugeIcon(icon: HugeIcons.strokeRoundedListMusic, size: 22),
        ),
      ],
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.isPlaying, required this.onPressed});

  final bool isPlaying;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: isPlaying ? '暂停' : '播放',
      icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
      iconSize: 22,
      style: IconButton.styleFrom(
        minimumSize: const Size(40, 30), // 宽度 > 高度，呈椭圆形
        maximumSize: const Size(40, 30),
        padding: EdgeInsets.zero,
        backgroundColor: ColorUtil.getShade(
          Theme.of(context).colorScheme.primary,
          400,
        ),
        disabledBackgroundColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // 大圆角形成椭圆
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
