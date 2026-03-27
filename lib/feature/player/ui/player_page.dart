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
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialItem();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      children: <Widget>[
                        _TopBar(
                          currentPage: _currentPage,
                          onBack: () => Navigator.of(context).maybePop(),
                          onMore: item == null
                              ? null
                              : () => playerController.loadFromItem(item),
                        ),
                        const SizedBox(height: 18),
                        Expanded(
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: (int index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            children: <Widget>[
                              _PlayerMainPage(
                                state: state,
                                item: item,
                                onSeek: (double value) {
                                  final int totalMs =
                                      (state.duration ?? Duration.zero)
                                          .inMilliseconds;
                                  final Duration position = Duration(
                                    milliseconds: (totalMs * value).round(),
                                  );
                                  playerController.seek(position);
                                },
                                onBackward: () => playerController.seekBy(
                                  const Duration(seconds: -10),
                                ),
                                onTogglePlayback:
                                    playerController.togglePlayback,
                                onForward: () => playerController.seekBy(
                                  const Duration(seconds: 10),
                                ),
                              ),
                              _PlayerMetaPage(state: state, item: item),
                            ],
                          ),
                        ),
                      ],
                    ),
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
    required this.currentPage,
    required this.onBack,
    required this.onMore,
  });

  final int currentPage;
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
            child: Center(child: _PageIndicator(currentPage: currentPage)),
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

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.currentPage});

  final int currentPage;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(2, (int index) {
        final bool isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: isActive ? 18 : 6,
          height: 6,
          margin: EdgeInsets.only(right: index == 0 ? 8 : 0),
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.primary
                : colorScheme.primary.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _PlayerMainPage extends StatelessWidget {
  const _PlayerMainPage({
    required this.state,
    required this.item,
    required this.onSeek,
    required this.onBackward,
    required this.onTogglePlayback,
    required this.onForward,
  });

  final PlayerState state;
  final PlayableItem? item;
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
        SizedBox(
          width: 200,
          height: 200,
          child: _ArtworkFrame(coverUrl: item?.coverUrl ?? ''),
        ),
        const SizedBox(height: 28),
        _TrackHeader(
          title: item?.title ?? '还没有选择播放内容',
          subtitle: item == null
              ? '从搜索页选一条视频或音频后，这里会显示当前播放信息。'
              : _buildSubtitle(item!.author, state),
          isFavoriteEnabled: item != null,
        ),
        const SizedBox(height: 8),
        _SwipeHint(label: state.currentItem == null ? '左右滑动切换页面' : '左滑查看音频信息'),
        const SizedBox(height: 18),
        _ProgressSection(state: state, onChanged: onSeek),
        const SizedBox(height: 30),
        _TransportControls(
          state: state,
          onBackward: onBackward,
          onTogglePlayback: onTogglePlayback,
          onForward: onForward,
        ),
        const SizedBox(height: 30),
        _PlaybackStatusChip(state: state),
        const SizedBox(height: 18),
      ],
    );
  }
}

class _PlayerMetaPage extends StatelessWidget {
  const _PlayerMetaPage({required this.state, required this.item});

  final PlayerState state;
  final PlayableItem? item;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: <Widget>[
        _MetaHero(item: item, state: state),
        const SizedBox(height: 18),
        _StatsGrid(item: item),
        const SizedBox(height: 18),
        _MetaSheet(state: state, item: item),
        const SizedBox(height: 18),
        if ((item?.description ?? '').trim().isNotEmpty)
          _DescriptionCard(description: item!.description!),
      ],
    );
  }
}

class _MetaHero extends StatelessWidget {
  const _MetaHero({required this.item, required this.state});

  final PlayableItem? item;
  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: <Color>[
            colorScheme.primaryContainer.withValues(alpha: 0.82),
            colorScheme.surface.withValues(alpha: 0.92),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.queue_music_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '音频信息',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item?.publishTimeText ?? '当前播放内容详情',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.62),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            item?.title ?? '还没有选择播放内容',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w900,
              height: 1.16,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _InfoPill(
                icon: Icons.account_circle_rounded,
                label: item?.author ?? '--',
              ),
              _InfoPill(
                icon: Icons.schedule_rounded,
                label: _resolveDurationLabel(state, item),
              ),
              _InfoPill(
                icon: Icons.graphic_eq_rounded,
                label: state.audioStream?.qualityLabel ?? '音质待解析',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.item});

  final PlayableItem? item;

  @override
  Widget build(BuildContext context) {
    final List<_StatEntry> stats = <_StatEntry>[
      _StatEntry(
        icon: Icons.play_circle_outline_rounded,
        label: '播放',
        value: item?.playCountText ?? '--',
      ),
      _StatEntry(
        icon: Icons.subtitles_outlined,
        label: '弹幕',
        value: item?.danmakuCountText ?? '--',
      ),
      _StatEntry(
        icon: Icons.thumb_up_alt_outlined,
        label: '点赞',
        value: item?.likeCountText ?? '--',
      ),
      _StatEntry(
        icon: Icons.monetization_on_outlined,
        label: '投币',
        value: item?.coinCountText ?? '--',
      ),
      _StatEntry(
        icon: Icons.star_border_rounded,
        label: '收藏',
        value: item?.favoriteCountText ?? '--',
      ),
      _StatEntry(
        icon: Icons.reply_all_rounded,
        label: '分享',
        value: item?.shareCountText ?? '--',
      ),
      _StatEntry(
        icon: Icons.chat_bubble_outline_rounded,
        label: '评论',
        value: item?.replyCountText ?? '--',
      ),
      _StatEntry(
        icon: Icons.timelapse_rounded,
        label: '时长',
        value: item?.durationText ?? '--:--',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.85,
      ),
      itemBuilder: (BuildContext context, int index) {
        return _StatCard(entry: stats[index]);
      },
    );
  }
}

class _StatEntry {
  const _StatEntry({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.entry});

  final _StatEntry entry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
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
            child: Icon(entry.icon, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  entry.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.58),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '简介',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.78),
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Row(
      children: <Widget>[
        Icon(
          Icons.swipe_left_alt_rounded,
          size: 18,
          color: colorScheme.primary.withValues(alpha: 0.72),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.55),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
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
              offset: const Offset(0, 20),
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
          colors: <Color>[colorScheme.primary, colorScheme.primaryContainer],
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
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.62),
                  fontWeight: FontWeight.w600,
                  height: 1.35,
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
          icon: Icons.repeat_rounded,
          color: iconColor,
          onPressed: null,
        ),
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
        _CircleActionButton(
          icon: Icons.skip_next_rounded,
          color: iconColor,
          onPressed: state.isReady ? onForward : null,
        ),
        _CircleActionButton(
          icon: Icons.list,
          color: iconColor,
          onPressed: null,
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
          _MetaRow(label: '标题', value: item?.title ?? '--'),
          _MetaRow(label: 'UP主', value: item?.author ?? '--'),
          _MetaRow(label: '发布时间', value: item?.publishTimeText ?? '--'),
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
          _MetaRow(label: '时长', value: _resolveDurationLabel(state, item)),
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
            width: 64,
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

String _resolveDurationLabel(PlayerState state, PlayableItem? item) {
  final Duration? duration = state.duration ?? state.audioStream?.duration;
  if (duration != null && duration > Duration.zero) {
    return _formatDuration(duration);
  }
  return item?.durationText ?? '--:--';
}
