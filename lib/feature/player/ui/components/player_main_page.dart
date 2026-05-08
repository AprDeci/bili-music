import 'dart:async';

import 'package:bilimusic/common/bm_icons.dart';
import 'package:bilimusic/common/components/badged_icon_button.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_online_audience.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/player_online_audience_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_artwork.dart';
import 'package:bilimusic/feature/player/ui/components/player_controls.dart';
import 'package:bilimusic/feature/player/ui/components/player_shared.dart';
import 'package:bilimusic/feature/player/ui/components/player_ui_helpers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

class PlayerMainPage extends ConsumerWidget {
  const PlayerMainPage({
    super.key,
    required this.state,
    required this.item,
    required this.commentCount,
    required this.availableParts,
    required this.onPartTap,
    required this.onOpenCollectionSheet,
    required this.isFavorite,
    required this.onFavoriteToggle,
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
  final int? commentCount;
  final List<PlayableItem> availableParts;
  final VoidCallback? onPartTap;
  final VoidCallback? onOpenCollectionSheet;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final ValueChanged<double> onSeek;
  final VoidCallback onToggleQueueMode;
  final VoidCallback onBackward;
  final VoidCallback onTogglePlayback;
  final VoidCallback onForward;
  final VoidCallback onOpenQueue;
  final VoidCallback? onOpenComments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size screenSize = mediaQuery.size;
    final bool canOpenPartSelector = item != null && availableParts.length > 1;
    final double artworkSize = (screenSize.height * 0.31).clamp(190.0, 320.0);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _RepaintSection(
          child: _PlayerHeroAndTitle(
            artworkSize: artworkSize,
            item: item,
            state: state,
            isFavorite: isFavorite,
            onlineAudienceLabel: onlineAudienceLabel,
            onFavoriteToggle: onFavoriteToggle,
          ),
        ),
        const Spacer(),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _RepaintSection(
              child: _PlayerStatusAndTools(
                state: state,
                item: item,
                commentCount: commentCount,
                canOpenPartSelector: canOpenPartSelector,
                onPartTap: onPartTap,
                onOpenCollectionSheet: onOpenCollectionSheet,
                onOpenComments: onOpenComments,
              ),
            ),
            const SizedBox(height: 10),
            _RepaintSection(child: _PlayerProgressHost(onChanged: onSeek)),
            const SizedBox(height: 10),
            _RepaintSection(
              child: PlayerTransportControls(
                state: state,
                onToggleQueueMode: onToggleQueueMode,
                onBackward: onBackward,
                onTogglePlayback: onTogglePlayback,
                onForward: onForward,
                onOpenQueue: onOpenQueue,
              ),
            ),
          ],
        ),
        SizedBox(height: mediaQuery.padding.bottom > 0 ? 8 : 18),
      ],
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
    required this.item,
    required this.state,
    required this.isFavorite,
    required this.onlineAudienceLabel,
    required this.onFavoriteToggle,
  });

  final double artworkSize;
  final PlayableItem? item;
  final PlayerState state;
  final bool isFavorite;
  final String? onlineAudienceLabel;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 12),
        Hero(
          tag: "artwork",
          child: Center(
            child: SizedBox(
              width: artworkSize,
              height: artworkSize,
              child: PlayerArtworkFrame(coverUrl: item?.coverUrl ?? ''),
            ),
          ),
        ),
        const SizedBox(height: 28),
        PlayerTrackHeader(
          title: item?.title ?? '还没有选择播放内容',
          subtitle: item == null
              ? '从搜索页选一条视频或音频后，这里会显示当前播放信息。'
              : buildPlayerSubtitle(item!.author, state),
          isFavoriteEnabled: item != null,
          isFavorite: isFavorite,
          onFavoriteToggle: onFavoriteToggle,
        ),
        if (onlineAudienceLabel != null) ...<Widget>[
          const SizedBox(height: 12),
          Row(children: <Widget>[PlayerBadge(label: onlineAudienceLabel!)]),
        ],
      ],
    );
  }
}

class _PlayerStatusAndTools extends StatelessWidget {
  const _PlayerStatusAndTools({
    required this.state,
    required this.item,
    required this.commentCount,
    required this.canOpenPartSelector,
    required this.onPartTap,
    required this.onOpenCollectionSheet,
    required this.onOpenComments,
  });

  final PlayerState state;
  final PlayableItem? item;
  final int? commentCount;
  final bool canOpenPartSelector;
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
          canOpenPartSelector: canOpenPartSelector,
          onPartTap: onPartTap,
          onOpenCollectionSheet: onOpenCollectionSheet,
          onOpenComments: onOpenComments,
        ),
      ],
    );
  }
}

class _PlayerProgressHost extends ConsumerStatefulWidget {
  const _PlayerProgressHost({required this.onChanged});

  final ValueChanged<double> onChanged;

  @override
  ConsumerState<_PlayerProgressHost> createState() =>
      _PlayerProgressHostState();
}

class _PlayerProgressHostState extends ConsumerState<_PlayerProgressHost> {
  static const Duration _progressUpdateInterval = Duration(milliseconds: 250);

  Timer? _progressUpdateTimer;
  Duration _displayPosition = Duration.zero;
  Duration? _displayDuration;
  bool _displayIsReady = false;
  ({Duration position, Duration? duration, bool isReady})? _pendingProgress;

  @override
  void initState() {
    super.initState();
    final (:position, :duration, :isReady) = ref.read(
      playerControllerProvider.select(
        (PlayerState state) => (
          position: state.position,
          duration: state.duration,
          isReady: state.isReady,
        ),
      ),
    );
    _displayPosition = position;
    _displayDuration = duration;
    _displayIsReady = isReady;

    ref.listenManual(
      playerControllerProvider.select(
        (PlayerState state) => (
          position: state.position,
          duration: state.duration,
          isReady: state.isReady,
        ),
      ),
      (_, ({Duration position, Duration? duration, bool isReady}) next) {
        _pendingProgress = next;
        _progressUpdateTimer ??= Timer(
          _progressUpdateInterval,
          _flushPendingProgress,
        );
      },
    );
  }

  @override
  void dispose() {
    _progressUpdateTimer?.cancel();
    super.dispose();
  }

  void _flushPendingProgress() {
    _progressUpdateTimer = null;
    final ({Duration position, Duration? duration, bool isReady})? next =
        _pendingProgress;
    if (next == null || !mounted) {
      return;
    }
    _pendingProgress = null;
    setState(() {
      _displayPosition = next.position;
      _displayDuration = next.duration;
      _displayIsReady = next.isReady;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build PlayerProgressSection');
    return PlayerProgressSection(
      position: _displayPosition,
      duration: _displayDuration,
      isReady: _displayIsReady,
      onChanged: widget.onChanged,
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
    required this.canOpenPartSelector,
    required this.onPartTap,
    required this.onOpenCollectionSheet,
    required this.onOpenComments,
  });

  final PlayerState state;
  final bool hasItem;
  final PlayableItem? item;
  final int? commentCount;
  final bool canOpenPartSelector;
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
          isEnabled: canOpenPartSelector,
          onTap: onPartTap,
        ),
        _PlayerToolButton(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedFolder01),
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
    final AudioQualityOption? selected = qualities
        .where((AudioQualityOption option) => option.isSelected)
        .firstOrNull;

    return BadgedIconButton(
      noBadgeIcon: const Icon(Icons.graphic_eq_rounded),
      badgeIcon: const Icon(Icons.graphic_eq_rounded),
      badge: selected?.label,
      badgeOffset: const Offset(-12, -2),
      onPressed: !isEnabled
          ? null
          : () => _showPlayerQualitySheet(
              context: context,
              ref: ref,
              qualities: qualities,
            ),
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

class _PlayerPartToolButton extends StatelessWidget {
  const _PlayerPartToolButton({
    required this.item,
    required this.isEnabled,
    this.onTap,
  });

  final PlayableItem? item;
  final bool isEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String? badge = formatPartBadge(item);
    final int digitCount = (item?.page ?? 1).toString().length;
    final Offset badgeOffset = switch (digitCount) {
      1 => const Offset(2, 4),
      2 => const Offset(-2, 4),
      _ => const Offset(-6, 4),
    };

    return BadgedIconButton(
      noBadgeIcon: const HugeIcon(icon: HugeIcons.strokeRoundedListVideo),
      badgeIcon: const Icon(BmIcons.partListWithBadge, size: 26),
      badge: badge,
      onPressed: isEnabled ? onTap : null,
      badgeOffset: badgeOffset,
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
