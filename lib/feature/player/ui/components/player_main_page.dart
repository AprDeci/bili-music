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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final bool showStatusHint = state.statusHint != null;
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
          Row(children: <Widget>[PlayerBadge(label: onlineAudienceLabel)]),
        ],
        const Spacer(),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (showStatusHint || true) PlayerPlaybackStatusChip(state: state),
            if (showStatusHint) const SizedBox(height: 12),
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
            const SizedBox(height: 10),
            PlayerProgressSection(state: state, onChanged: onSeek),
            const SizedBox(height: 10),
            PlayerTransportControls(
              state: state,
              onToggleQueueMode: onToggleQueueMode,
              onBackward: onBackward,
              onTogglePlayback: onTogglePlayback,
              onForward: onForward,
              onOpenQueue: onOpenQueue,
            ),
          ],
        ),
        SizedBox(height: mediaQuery.padding.bottom > 0 ? 8 : 18),
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
          icon: Icons.folder_open_outlined,
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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String? badgeLabel = _formatCommentBadgeCount(commentCount);

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        _PlayerToolButton(
          icon: Icons.comment_outlined,
          isEnabled: isEnabled,
          onTap: onTap,
        ),
        if (isEnabled && badgeLabel != null)
          Positioned(
            top: -2,
            right: -8,
            child: IgnorePointer(
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  badgeLabel,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
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

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        _PlayerToolButton(
          icon: Icons.graphic_eq_rounded,
          isEnabled: isEnabled,
          onTap: !isEnabled
              ? null
              : () => _showPlayerQualitySheet(
                  context: context,
                  ref: ref,
                  qualities: qualities,
                ),
        ),
        if (isEnabled && selected != null)
          Positioned(
            top: -2,
            right: -12,
            child: IgnorePointer(
              child: _ToolButtonBadge(label: selected.label),
            ),
          ),
      ],
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

String? _formatCommentBadgeCount(int? count) {
  if (count == null || count <= 0) {
    return null;
  }
  if (count <= 99) {
    return count.toString();
  }
  if (count <= 999) {
    return '99+';
  }
  return '999+';
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
    final ThemeData theme = Theme.of(context);
    final int currentPage = item?.page ?? 1;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        _PlayerToolButton(
          icon: Icons.playlist_play_rounded,
          isEnabled: isEnabled,
          onTap: onTap,
        ),
        if (isEnabled)
          Positioned(
            top: -2,
            right: -8,
            child: IgnorePointer(
              child: _ToolButtonBadge(label: 'P$currentPage'),
            ),
          ),
      ],
    );
  }
}

class _ToolButtonBadge extends StatelessWidget {
  const _ToolButtonBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _PlayerToolButton extends StatelessWidget {
  const _PlayerToolButton({
    required this.icon,
    required this.isEnabled,
    this.onTap,
  });

  final IconData icon;
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
            child: Icon(icon, size: 24, color: foregroundColor),
          ),
        ),
      ),
    );
  }
}
