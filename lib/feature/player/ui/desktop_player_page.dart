import 'package:bilimusic/common/components/bar_icon_button.dart';
import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/comment/domain/comment_target.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/desktop/desktop_lyric_panel.dart';
import 'package:bilimusic/feature/player/ui/components/player_collection_sheet.dart';
import 'package:bilimusic/feature/player/ui/components/player_part_selector.dart';
import 'package:bilimusic/feature/player/ui/components/player_queue_sheet.dart';
import 'package:bilimusic/feature/player/ui/components/player_ui_helpers.dart';
import 'package:bilimusic/router/player_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

class DesktopPlayerPage extends ConsumerStatefulWidget {
  const DesktopPlayerPage({super.key, this.initialItem});

  final PlayableItem? initialItem;

  @override
  ConsumerState<DesktopPlayerPage> createState() => _DesktopPlayerPageState();
}

class _DesktopPlayerPageState extends ConsumerState<DesktopPlayerPage> {
  @override
  void initState() {
    super.initState();
    markPlayerPageVisible();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialItem();
    });
  }

  @override
  void dispose() {
    markPlayerPageHidden();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DesktopPlayerPage oldWidget) {
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
    final PlayerState state = ref.read(playerControllerProvider);
    if (state.currentItem?.stableId == item.stableId && state.isReady) {
      return;
    }
    ref
        .read(playerControllerProvider.notifier)
        .setQueue(<PlayableItem>[item], startIndex: 0, sourceLabel: '当前播放');
  }

  @override
  Widget build(BuildContext context) {
    final PlayerState state = ref.watch(playerControllerProvider);
    final PlayerController controller = ref.read(
      playerControllerProvider.notifier,
    );
    final PlayableItem? item = state.currentItem ?? widget.initialItem;
    final bool isFavorite = item != null
        ? ref.watch(favoritesControllerProvider).isLiked(item)
        : false;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              colorScheme.primaryContainer.withValues(alpha: 0.54),
              colorScheme.surfaceContainerLowest,
              colorScheme.primary.withValues(alpha: 0.12),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              Positioned(
                left: -120,
                bottom: 90,
                child: _DesktopGlowOrb(
                  size: 360,
                  color: colorScheme.primary.withValues(alpha: 0.16),
                ),
              ),
              Positioned(
                right: -90,
                top: 110,
                child: _DesktopGlowOrb(
                  size: 300,
                  color: colorScheme.secondary.withValues(alpha: 0.13),
                ),
              ),
              Column(
                children: <Widget>[
                  _DesktopPlayerTopBar(
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: _DesktopPlayerHeroSection(
                      state: state,
                      item: item,
                      onSeek: controller.seek,
                    ),
                  ),
                  _DesktopPlayerControlDeck(
                    state: state,
                    item: item,
                    isFavorite: isFavorite,
                    onFavoriteToggle: item == null
                        ? null
                        : () => _toggleFavorite(item),
                    onOpenComments: item == null || item.aid <= 0
                        ? null
                        : () => _openComments(item),
                    onOpenCollectionSheet: item == null
                        ? null
                        : () => showPlayerCollectionSheet(
                            context: context,
                            item: item,
                          ),
                    onPartTap: item == null || state.availableParts.length < 2
                        ? null
                        : () => showPlayerPartSelector(
                            context: context,
                            parts: state.availableParts,
                            currentItem: item,
                            state: state,
                            controller: controller,
                          ),
                    onOpenQueue: () =>
                        showPlayerQueueSheet(context: context, state: state),
                    onSelectQuality: controller.switchCurrentAudioQuality,
                    onToggleQueueMode: controller.toggleQueueMode,
                    onPrevious: controller.skipToPrevious,
                    onTogglePlayback: controller.togglePlayback,
                    onNext: controller.skipToNext,
                    onSeek: (double value) {
                      final Duration total = _resolveTotalDuration(state);
                      controller.seek(
                        Duration(
                          milliseconds: (total.inMilliseconds * value).round(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(PlayableItem item) async {
    final bool isLiked = await ref
        .read(favoritesControllerProvider.notifier)
        .toggleLiked(item);
    if (!mounted) {
      return;
    }
    ToastUtil.show(isLiked ? '已加入“我喜欢”' : '已从“我喜欢”移除');
  }

  Future<void> _openComments(PlayableItem item) async {
    await context.push(
      '/comments',
      extra: CommentTarget.video(
        aid: item.aid,
        bvid: item.bvid,
        title: item.title,
        coverUrl: item.coverUrl,
      ),
    );
  }
}

class _DesktopPlayerTopBar extends StatefulWidget {
  const _DesktopPlayerTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  State<_DesktopPlayerTopBar> createState() => _DesktopPlayerTopBarState();
}

class _DesktopPlayerTopBarState extends State<_DesktopPlayerTopBar>
    with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _syncWindowState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    _syncWindowState();
  }

  @override
  void onWindowUnmaximize() {
    _syncWindowState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: DragToMoveArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: _toggleMaximize,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: <Widget>[
                Tooltip(
                  waitDuration: const Duration(seconds: 1),
                  message: '收起播放页',
                  child: BarIconButton(
                    icon: Icons.keyboard_arrow_down_rounded,
                    iconSize: 24,
                    onPressed: widget.onBack,
                  ),
                ),
                const Spacer(),
                Tooltip(
                  waitDuration: const Duration(seconds: 1),
                  message: '最小化',
                  child: BarIconButton(
                    icon: Icons.remove_rounded,
                    iconSize: 18,
                    onPressed: () => windowManager.minimize(),
                  ),
                ),
                Tooltip(
                  waitDuration: const Duration(seconds: 1),
                  message: _isMaximized ? '还原' : '最大化',
                  child: BarIconButton(
                    icon: _isMaximized
                        ? Icons.filter_none_rounded
                        : Icons.crop_square_rounded,
                    iconSize: 16,
                    onPressed: _toggleMaximize,
                  ),
                ),
                Tooltip(
                  waitDuration: const Duration(seconds: 1),
                  message: '关闭',
                  child: BarIconButton(
                    icon: Icons.close_rounded,
                    iconSize: 18,
                    onPressed: () => windowManager.close(),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _syncWindowState() async {
    final bool isMaximized = await windowManager.isMaximized();
    if (!mounted || isMaximized == _isMaximized) {
      return;
    }

    setState(() {
      _isMaximized = isMaximized;
    });
  }

  Future<void> _toggleMaximize() async {
    if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
    await _syncWindowState();
  }
}

class _DesktopPlayerHeroSection extends StatelessWidget {
  const _DesktopPlayerHeroSection({
    required this.state,
    required this.item,
    required this.onSeek,
  });

  final PlayerState state;
  final PlayableItem? item;
  final ValueChanged<Duration> onSeek;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 820;
        final double artworkSize = (constraints.maxHeight * 0.58).clamp(
          compact ? 188.0 : 250.0,
          compact ? 260.0 : 360.0,
        );

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? 24 : 54,
                8,
                compact ? 24 : 54,
                12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: artworkSize,
                    height: artworkSize,
                    child: _DesktopArtwork(coverUrl: item?.coverUrl),
                  ),
                  SizedBox(width: compact ? 34 : 86),
                  Expanded(
                    child: DesktopLyricPanel(
                      state: state,
                      item: item,
                      onSeek: onSeek,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DesktopArtwork extends StatelessWidget {
  const _DesktopArtwork({required this.coverUrl});

  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(26),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.10),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: CommonCachedImage(
          imageUrl: coverUrl,
          fit: BoxFit.cover,
          fallbackIcon: Icons.music_note_rounded,
          iconSize: 72,
          iconColor: colorScheme.primary.withValues(alpha: 0.58),
          backgroundGradient: LinearGradient(
            colors: <Color>[
              colorScheme.primary.withValues(alpha: 0.16),
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.52),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}

class _DesktopPlayerControlDeck extends StatelessWidget {
  const _DesktopPlayerControlDeck({
    required this.state,
    required this.item,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onOpenComments,
    required this.onOpenCollectionSheet,
    required this.onPartTap,
    required this.onOpenQueue,
    required this.onSelectQuality,
    required this.onToggleQueueMode,
    required this.onPrevious,
    required this.onTogglePlayback,
    required this.onNext,
    required this.onSeek,
  });

  final PlayerState state;
  final PlayableItem? item;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onOpenComments;
  final VoidCallback? onOpenCollectionSheet;
  final VoidCallback? onPartTap;
  final VoidCallback onOpenQueue;
  final ValueChanged<int?> onSelectQuality;
  final VoidCallback onToggleQueueMode;
  final VoidCallback onPrevious;
  final VoidCallback onTogglePlayback;
  final VoidCallback onNext;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Duration total = _resolveTotalDuration(state);
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
    final List<AudioQualityOption> qualities =
        state.audioStream?.availableQualities ?? const <AudioQualityOption>[];

    return SizedBox(
      height: 84,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 0, 26, 10),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 190,
                    child: Row(
                      children: <Widget>[
                        _DesktopIconButton(
                          icon: Icons.fullscreen_exit_rounded,
                          tooltip: '收起播放页',
                          onPressed: null,
                        ),
                        const SizedBox(width: 8),
                        _DesktopIconButton(
                          icon: isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border,
                          tooltip: '我喜欢',
                          isActive: isFavorite,
                          activeColor: const Color(0xFFFF6A7A),
                          onPressed: onFavoriteToggle,
                        ),
                        const SizedBox(width: 8),
                        _DesktopIconButton(
                          icon: Icons.mode_comment_outlined,
                          tooltip: '评论',
                          onPressed: onOpenComments,
                        ),
                        const SizedBox(width: 8),
                        _DesktopIconButton(
                          icon: Icons.more_horiz_rounded,
                          tooltip: '更多',
                          onPressed: item == null ? null : () {},
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _DesktopIconButton(
                              icon: _queueModeIcon(state.queueMode),
                              tooltip: '播放模式',
                              isActive: state.isReady,
                              onPressed: state.hasQueue
                                  ? onToggleQueueMode
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            _DesktopIconButton(
                              icon: Icons.skip_previous_rounded,
                              tooltip: '上一首',
                              iconSize: 26,
                              onPressed: canGoPrevious ? onPrevious : null,
                            ),
                            const SizedBox(width: 14),
                            _DesktopPlayButton(
                              isPlaying: state.isPlaying,
                              onPressed: canTogglePlayback
                                  ? onTogglePlayback
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            _DesktopIconButton(
                              icon: Icons.skip_next_rounded,
                              tooltip: '下一首',
                              iconSize: 26,
                              onPressed: canGoNext ? onNext : null,
                            ),
                            const SizedBox(width: 14),
                            _DesktopIconButton(
                              icon: Icons.volume_up_outlined,
                              tooltip: '音量',
                              onPressed: state.hasQueue ? () {} : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: 44,
                              child: Text(
                                formatPlayerDuration(state.position),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.62,
                                  ),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 3,
                                  inactiveTrackColor: colorScheme.onSurface
                                      .withValues(alpha: 0.14),
                                  activeTrackColor: colorScheme.onSurface
                                      .withValues(alpha: 0.82),
                                  thumbColor: colorScheme.onSurface,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 3.5,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 10,
                                  ),
                                  overlayColor: colorScheme.onSurface
                                      .withValues(alpha: 0.08),
                                ),
                                child: Slider(
                                  value: progress,
                                  onChanged:
                                      total > Duration.zero && state.isReady
                                      ? onSeek
                                      : null,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 44,
                              child: Text(
                                formatPlayerDuration(total),
                                textAlign: TextAlign.right,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.62,
                                  ),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 190,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        _DesktopIconButton(
                          icon: Icons.checkroom_outlined,
                          tooltip: '收藏到歌单',
                          onPressed: onOpenCollectionSheet,
                        ),
                        const SizedBox(width: 8),
                        _DesktopIconButton(
                          icon: Icons.lyrics_outlined,
                          tooltip: '选择分 P',
                          onPressed: onPartTap,
                        ),
                        const SizedBox(width: 8),
                        _DesktopQualityButton(
                          qualities: qualities,
                          onSelected: onSelectQuality,
                        ),
                        const SizedBox(width: 8),
                        _DesktopIconButton(
                          icon: Icons.playlist_play_rounded,
                          tooltip: '播放队列',
                          onPressed: state.hasQueue ? onOpenQueue : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _queueModeIcon(PlayerQueueMode mode) {
    return switch (mode) {
      PlayerQueueMode.sequence => Icons.repeat_rounded,
      PlayerQueueMode.singleRepeat => Icons.repeat_one_rounded,
      PlayerQueueMode.shuffle => Icons.shuffle_rounded,
    };
  }
}

class _DesktopQualityButton extends StatelessWidget {
  const _DesktopQualityButton({
    required this.qualities,
    required this.onSelected,
  });

  final List<AudioQualityOption> qualities;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int?>(
      enabled: qualities.isNotEmpty,
      tooltip: '音质',
      padding: EdgeInsets.zero,
      splashRadius: 16,
      constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        return qualities.map((AudioQualityOption option) {
          return PopupMenuItem<int?>(
            value: option.qualityId,
            child: Row(
              children: <Widget>[
                Expanded(child: Text(option.label)),
                if (option.isSelected)
                  Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          );
        }).toList();
      },
      child: IgnorePointer(
        child: Tooltip(
          waitDuration: const Duration(milliseconds: 600),
          message: '音质',
          child: _DesktopQualityBadge(isEnabled: qualities.isNotEmpty),
        ),
      ),
    );
  }
}

class _DesktopQualityBadge extends StatelessWidget {
  const _DesktopQualityBadge({required this.isEnabled});

  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color color = isEnabled
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: 0.28);

    return SizedBox(
      width: 30,
      height: 30,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 1.4),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'SQ',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopIconButton extends StatelessWidget {
  const _DesktopIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.iconSize = 22,
    this.isActive = false,
    this.activeColor,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double iconSize;
  final bool isActive;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      waitDuration: const Duration(milliseconds: 600),
      message: tooltip,
      child: BarIconButton(
        onPressed: onPressed,
        icon: icon,
        iconSize: iconSize,
        isActive: isActive,
        activeColor: activeColor,
      ),
    );
  }
}

class _DesktopPlayButton extends StatelessWidget {
  const _DesktopPlayButton({required this.isPlaying, required this.onPressed});

  final bool isPlaying;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 36),
        maximumSize: const Size(48, 36),
        padding: EdgeInsets.zero,
        backgroundColor: colorScheme.primary,
        disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.32),
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      child: Icon(
        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
        size: 30,
      ),
    );
  }
}

class _DesktopGlowOrb extends StatelessWidget {
  const _DesktopGlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

Duration _resolveTotalDuration(PlayerState state) {
  return state.duration ?? state.audioStream?.duration ?? Duration.zero;
}
