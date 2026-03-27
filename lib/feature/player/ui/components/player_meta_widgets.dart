import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/ui/components/player_ui_helpers.dart';
import 'package:flutter/material.dart';

class PlayerMetaSheet extends StatelessWidget {
  const PlayerMetaSheet({super.key, required this.state, required this.item});

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
          PlayerMetaRow(label: '标题', value: item?.title ?? '--'),
          PlayerMetaRow(label: 'UP主', value: item?.author ?? '--'),
          PlayerMetaRow(label: '发布时间', value: item?.publishTimeText ?? '--'),
          PlayerMetaRow(label: 'BV', value: item?.bvid ?? '--'),
          PlayerMetaRow(
            label: '时长',
            value: resolvePlayerDurationLabel(state, item),
          ),
          PlayerMetaRow(
            label: '音质',
            value: state.audioStream?.qualityLabel ?? '--',
          ),
          PlayerMetaRow(
            label: '分P',
            value: state.audioStream?.pageTitle ?? '--',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class PlayerMetaRow extends StatelessWidget {
  const PlayerMetaRow({
    super.key,
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

class PlayerStatsGrid extends StatelessWidget {
  const PlayerStatsGrid({super.key, required this.item});

  final PlayableItem? item;

  @override
  Widget build(BuildContext context) {
    final List<PlayerStatEntry> stats = <PlayerStatEntry>[
      PlayerStatEntry(
        icon: Icons.play_circle_outline_rounded,
        label: '播放',
        value: item?.playCountText ?? '--',
      ),
      PlayerStatEntry(
        icon: Icons.subtitles_outlined,
        label: '弹幕',
        value: item?.danmakuCountText ?? '--',
      ),
      PlayerStatEntry(
        icon: Icons.thumb_up_alt_outlined,
        label: '点赞',
        value: item?.likeCountText ?? '--',
      ),
      PlayerStatEntry(
        icon: Icons.monetization_on_outlined,
        label: '投币',
        value: item?.coinCountText ?? '--',
      ),
      PlayerStatEntry(
        icon: Icons.star_border_rounded,
        label: '收藏',
        value: item?.favoriteCountText ?? '--',
      ),
      PlayerStatEntry(
        icon: Icons.reply_all_rounded,
        label: '分享',
        value: item?.shareCountText ?? '--',
      ),
      PlayerStatEntry(
        icon: Icons.chat_bubble_outline_rounded,
        label: '评论',
        value: item?.replyCountText ?? '--',
      ),
      PlayerStatEntry(
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
        return PlayerStatCard(entry: stats[index]);
      },
    );
  }
}

class PlayerStatEntry {
  const PlayerStatEntry({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class PlayerStatCard extends StatelessWidget {
  const PlayerStatCard({super.key, required this.entry});

  final PlayerStatEntry entry;

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

class PlayerDescriptionCard extends StatelessWidget {
  const PlayerDescriptionCard({super.key, required this.description});

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

class InfoPill extends StatelessWidget {
  const InfoPill({super.key, required this.icon, required this.label});

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
