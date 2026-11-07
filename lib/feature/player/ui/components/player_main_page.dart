import 'package:bilimusic/common/bm_icons.dart';
import 'package:bilimusic/common/components/badged_icon_button.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/domain/player_online_audience.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/player_online_audience_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_artwork.dart';
import 'package:bilimusic/feature/player/ui/components/player_controls.dart';
import 'package:bilimusic/feature/player/ui/components/player_quality_badge.dart';
import 'package:bilimusic/feature/player/ui/components/player_shared.dart';
import 'package:bilimusic/feature/player/logic/utils/player_ui_helpers.dart';
import 'package:bilimusic/router/util/player_page_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class PlayerMainPage extends ConsumerStatefulWidget {
  const PlayerMainPage({
    super.key,
    required this.state,
    required this.item,
    required this.display,
    required this.commentCount,
    required this.canOpenJumpPanel,
    required this.onPartTap,
    required this.onOpenCollectionSheet,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onToggleSource,
    required this.onSeek,
    required this.onToggleQueueMode,
    required this.onBackward,
    required this.onTogglePlayback,
    required this.onForward,
    required this.onOpenQueue,
    required this.onOpenComments,
  });

  final PlayerState state;
  final PlayableItem? item;
  final PlayerDisplayInfo display;
  final int? commentCount;
  final bool canOpenJumpPanel;
  final VoidCallback? onPartTap;
  final VoidCallback? onOpenCollectionSheet;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback onToggleSource;
  final ValueChanged<double> onSeek;
  final VoidCallback onToggleQueueMode;
  final VoidCallback onBackward;
  final VoidCallback onTogglePlayback;
  final VoidCallback onForward;
  final VoidCallback onOpenQueue;
  final VoidCallback? onOpenComments;

  @override
  ConsumerState<PlayerMainPage> createState() => _PlayerMainPageState();
}

class _PlayerMainPageState extends ConsumerState<PlayerMainPage> {
  final ScrollController _scrollController = ScrollController();
  int? _pointer;
  Offset? _dragStart;
  VelocityTracker? _velocityTracker;
  PlayerPageRoute? _dragRoute;

  @override
  void dispose() {
    _resetDrag();
    _scrollController.dispose();
    super.dispose();
  }

  void _resetDrag() {
    _dragRoute?.endDrag();
    _dragRoute = null;
    _pointer = null;
    _dragStart = null;
    _velocityTracker = null;
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_pointer != null) {
      _resetDrag();
      return;
    }
    final ModalRoute<Object?>? route = ModalRoute.of(context);
    if (route is! PlayerPageRoute ||
        !route.canStartDrag ||
        (_scrollController.hasClients &&
            _scrollController.offset >
                _scrollController.position.minScrollExtent + 1)) {
      return;
    }
    _pointer = event.pointer;
    _dragStart = event.position;
    _velocityTracker = VelocityTracker.withKind(event.kind)
      ..addPosition(event.timeStamp, event.position);
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (event.pointer != _pointer || _dragStart == null) {
      return;
    }
    final Offset delta = event.position - _dragStart!;
    if (_dragRoute == null &&
        (delta.dy < -18 || delta.dx.abs() > 18 && delta.dx.abs() > delta.dy)) {
      _resetDrag();
      return;
    }
    _velocityTracker?.addPosition(event.timeStamp, event.position);
    if (_dragRoute == null && delta.dy > 18 && delta.dy > delta.dx.abs()) {
      final ModalRoute<Object?>? route = ModalRoute.of(context);
      if (route is! PlayerPageRoute || !route.startDrag()) {
        _resetDrag();
        return;
      }
      _dragRoute = route;
    }
    _dragRoute?.updateDrag(delta.dy / MediaQuery.sizeOf(context).height);
  }

  void _onPointerUp(PointerUpEvent event) {
    if (event.pointer != _pointer) {
      return;
    }
    final Offset delta = event.position - (_dragStart ?? event.position);
    _velocityTracker?.addPosition(event.timeStamp, event.position);
    final double velocity =
        _velocityTracker?.getVelocity().pixelsPerSecond.dy ?? 0;
    final bool shouldClose =
        _dragStart != null &&
        delta.dy > delta.dx.abs() &&
        velocity >= 0 &&
        (delta.dy >= 80 || (delta.dy >= 24 && velocity >= 700));
    _dragRoute?.endDrag(dismiss: shouldClose);
    _dragRoute = null;
    _resetDrag();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size screenSize = mediaQuery.size;
    final bool isCompact = screenSize.height < 600;
    final double artworkSize = playerArtworkSize(screenSize);
    final AsyncValue<PlayerOnlineAudience?> onlineAudienceAsync = ref.watch(
      playerOnlineAudienceControllerProvider,
    );
    final PlayerOnlineAudience? onlineAudience = switch (onlineAudienceAsync) {
      AsyncData<PlayerOnlineAudience?>(:final value) => value,
      _ => null,
    };
    final String? onlineAudienceLabel = onlineAudience == null
        ? null
        : _buildAudienceLabel(onlineAudience);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          onPointerCancel: (_) => _resetDrag(),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _RepaintSection(
                      child: _PlayerHeroAndTitle(
                        artworkSize: artworkSize,
                        isCompact: isCompact,
                        item: widget.item,
                        display: widget.display,
                        isFavorite: widget.isFavorite,
                        onlineAudienceLabel: onlineAudienceLabel,
                        onFavoriteToggle: widget.onFavoriteToggle,
                        onToggleSource: widget.onToggleSource,
                      ),
                    ),
                    const Spacer(),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _RepaintSection(
                          child: _PlayerStatusAndTools(
                            state: widget.state,
                            item: widget.item,
                            commentCount: widget.commentCount,
                            canOpenJumpPanel: widget.canOpenJumpPanel,
                            onPartTap: widget.onPartTap,
                            onOpenCollectionSheet: widget.onOpenCollectionSheet,
                            onOpenComments: widget.onOpenComments,
                          ),
                        ),
                        SizedBox(height: isCompact ? 6 : 10),
                        _RepaintSection(
                          child: PlayerProgressHost(
                            state: widget.state,
                            onChanged: widget.onSeek,
                          ),
                        ),
                        SizedBox(height: isCompact ? 6 : 10),
                        _RepaintSection(
                          child: PlayerTransportControls(
                            state: widget.state,
                            onToggleQueueMode: widget.onToggleQueueMode,
                            onBackward: widget.onBackward,
                            onTogglePlayback: widget.onTogglePlayback,
                            onForward: widget.onForward,
                            onOpenQueue: widget.onOpenQueue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: isCompact || mediaQuery.padding.bottom > 0
                          ? 40
                          : 50,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RepaintSection extends StatelessWidget {
  const _RepaintSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: child);
  }
}

class _PlayerHeroAndTitle extends StatelessWidget {
  const _PlayerHeroAndTitle({
    required this.artworkSize,
    required this.isCompact,
    required this.item,
    required this.display,
    required this.isFavorite,
    required this.onlineAudienceLabel,
    required this.onFavoriteToggle,
    required this.onToggleSource,
  });

  final double artworkSize;
  final bool isCompact;
  final PlayableItem? item;
  final PlayerDisplayInfo display;
  final bool isFavorite;
  final String? onlineAudienceLabel;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback onToggleSource;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: isCompact ? 8 : 12),
        Center(
          child: SizedBox(
            width: artworkSize,
            height: artworkSize,
            child: Stack(
              children: <Widget>[
                GestureDetector(
                  onDoubleTap: display.canToggleSource ? onToggleSource : null,
                  child: Hero(
                    tag: 'artwork',
                    child: PlayerArtworkFrame(coverUrl: display.coverUrl ?? ''),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: isCompact ? 16 : 28),
        PlayerTrackHeader(
          title: display.title ?? '还没有选择播放内容',
          subtitle: display.stableId == null
              ? '从搜索页选一条视频或音频后，这里会显示当前播放信息。'
              : display.artist ?? '',
          isFavoriteEnabled: item != null,
          isFavorite: isFavorite,
          onFavoriteToggle: onFavoriteToggle,
          onSubtitleTap: _buildUpTapHandler(context, display.artistUpMid),
        ),
        if (onlineAudienceLabel != null) ...<Widget>[
          const SizedBox(height: 12),
          Row(children: <Widget>[PlayerBadge(label: onlineAudienceLabel!)]),
        ],
      ],
    );
  }

  VoidCallback? _buildUpTapHandler(BuildContext context, int? ownerMid) {
    if (ownerMid == null || ownerMid <= 0) {
      return null;
    }
    return () {
      final GoRouter router = GoRouter.of(context);
      Navigator.of(context).pop();
      router.push('/up/$ownerMid');
    };
  }
}

class _PlayerStatusAndTools extends StatelessWidget {
  const _PlayerStatusAndTools({
    required this.state,
    required this.item,
    required this.commentCount,
    required this.canOpenJumpPanel,
    required this.onPartTap,
    required this.onOpenCollectionSheet,
    required this.onOpenComments,
  });

  final PlayerState state;
  final PlayableItem? item;
  final int? commentCount;
  final bool canOpenJumpPanel;
  final VoidCallback? onPartTap;
  final VoidCallback? onOpenCollectionSheet;
  final VoidCallback? onOpenComments;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PlayerPlaybackStatusChip(state: state),
        if (state.statusHint != null) const SizedBox(height: 12),
        _PlayerToolBar(
          state: state,
          hasItem: item != null,
          item: item,
          commentCount: commentCount,
          canOpenJumpPanel: canOpenJumpPanel,
          onPartTap: onPartTap,
          onOpenCollectionSheet: onOpenCollectionSheet,
          onOpenComments: onOpenComments,
        ),
      ],
    );
  }
}

String? _buildAudienceLabel(PlayerOnlineAudience audience) {
  final String? preferredText = switch ((
    audience.showTotal,
    audience.showCount,
  )) {
    (true, _) when audience.totalText?.isNotEmpty ?? false =>
      audience.totalText,
    (_, true) when audience.countText?.isNotEmpty ?? false =>
      audience.countText,
    _ when audience.totalText?.isNotEmpty ?? false => audience.totalText,
    _ when audience.countText?.isNotEmpty ?? false => audience.countText,
    _ => null,
  };

  if (preferredText == null) {
    return null;
  }
  if (preferredText.contains('人')) {
    return preferredText;
  }
  return '$preferredText人在听';
}

class _PlayerToolBar extends StatelessWidget {
  const _PlayerToolBar({
    required this.state,
    required this.hasItem,
    required this.item,
    required this.commentCount,
    required this.canOpenJumpPanel,
    required this.onPartTap,
    required this.onOpenCollectionSheet,
    required this.onOpenComments,
  });

  final PlayerState state;
  final bool hasItem;
  final PlayableItem? item;
  final int? commentCount;
  final bool canOpenJumpPanel;
  final VoidCallback? onPartTap;
  final VoidCallback? onOpenCollectionSheet;
  final VoidCallback? onOpenComments;

  @override
  Widget build(BuildContext context) {
    final List<AudioQualityOption> availableQualities =
        state.audioStream?.availableQualities ?? const <AudioQualityOption>[];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _PlayerPartToolButton(
          item: item,
          isEnabled: canOpenJumpPanel,
          onTap: onPartTap,
        ),
        _PlayerToolButton(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedFolderAdd),
          isEnabled: hasItem,
          onTap: onOpenCollectionSheet,
        ),
        _PlayerQualityToolButton(
          qualities: availableQualities,
          isEnabled: hasItem && availableQualities.isNotEmpty,
        ),
        _PlayerCommentToolButton(
          commentCount: commentCount,
          isEnabled: hasItem,
          onTap: onOpenComments,
        ),
      ],
    );
  }
}

class _PlayerCommentToolButton extends StatelessWidget {
  const _PlayerCommentToolButton({
    required this.commentCount,
    required this.isEnabled,
    this.onTap,
  });

  final int? commentCount;
  final bool isEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String? badgeLabel = formatCommentBadgeCount(commentCount);

    return BadgedIconButton(
      noBadgeIcon: HugeIcon(icon: HugeIcons.strokeRoundedComment01),
      badgeIcon: const Icon(BmIcons.commentWithBadge, size: 26),
      badge: badgeLabel,
      onPressed: isEnabled ? onTap : null,
    );
  }
}

class _PlayerQualityToolButton extends ConsumerWidget {
  const _PlayerQualityToolButton({
    required this.qualities,
    required this.isEnabled,
  });

  final List<AudioQualityOption> qualities;
  final bool isEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String badgeLabel = qualityBadgeLabel(qualities: qualities);
    return IconButton(
      onPressed: !isEnabled
          ? null
          : () => _showPlayerQualitySheet(
              context: context,
              ref: ref,
              qualities: qualities,
            ),
      icon: PlayerQualityBadge(label: badgeLabel),
    );
  }
}

Future<void> _showPlayerQualitySheet({
  required BuildContext context,
  required WidgetRef ref,
  required List<AudioQualityOption> qualities,
}) async {
  final ThemeData theme = Theme.of(context);
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: theme.colorScheme.surface,
    builder: (BuildContext context) {
      return SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          itemCount: qualities.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (BuildContext context, int index) {
            final AudioQualityOption option = qualities[index];
            final bool isSelected = option.isSelected;
            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              tileColor: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : null,
              title: Text(
                option.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
                  : const Icon(Icons.play_arrow_rounded),
              onTap: () async {
                Navigator.of(context).pop();
                await ref
                    .read(playerControllerProvider.notifier)
                    .switchCurrentAudioQuality(option.qualityId);
              },
            );
          },
        ),
      );
    },
  );
}

class _PlayerPartToolButton extends ConsumerWidget {
  const _PlayerPartToolButton({
    required this.item,
    required this.isEnabled,
    this.onTap,
  });

  final PlayableItem? item;
  final bool isEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? badge = ref.watch(
      playerControllerProvider.select(
        (PlayerState state) => formatJumpBadge(
          item: state.currentItem ?? item,
          chapters: state.chapters,
          position: state.position,
        ),
      ),
    );

    return BadgedIconButton(
      noBadgeIcon: const HugeIcon(icon: HugeIcons.strokeRoundedListVideo),
      badgeIcon: const Icon(BmIcons.partListWithBadge, size: 26),
      badge: badge,
      onPressed: isEnabled ? onTap : null,
    );
  }
}

class _PlayerToolButton extends StatelessWidget {
  const _PlayerToolButton({
    required this.icon,
    required this.isEnabled,
    this.onTap,
  });

  final Widget icon;
  final bool isEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color foregroundColor = isEnabled
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.38);
    return SizedBox(
      width: 40,
      height: 40,
      child: InkResponse(
        onTap: isEnabled ? onTap : null,
        radius: 24,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: IconTheme.merge(
              data: IconThemeData(size: 24, color: foregroundColor),
              child: icon,
            ),
          ),
        ),
      ),
    );
  }
}
