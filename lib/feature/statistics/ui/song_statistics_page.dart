import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/statistics/domain/song_statistics.dart';
import 'package:bilimusic/feature/statistics/logic/statistics_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SongStatisticsPage extends ConsumerWidget {
  const SongStatisticsPage({super.key, required this.item});

  final PlayableItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StatisticsTracker tracker = ref.read(statisticsTrackerProvider);
    final SongStatistics? statistics = tracker.read(item.stableId);
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('单曲统计')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            children: <Widget>[
              _SongHeader(item: item, statistics: statistics),
              const SizedBox(height: 28),
              if (statistics == null || statistics.playCount == 0)
                _EmptyStatistics(colors: colors)
              else
                _StatisticsGrid(statistics: statistics),
            ],
          ),
        ),
      ),
    );
  }
}

class _SongHeader extends StatelessWidget {
  const _SongHeader({required this.item, required this.statistics});

  final PlayableItem item;
  final SongStatistics? statistics;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        CommonCachedImage(
          imageUrl: statistics?.coverUrl.isNotEmpty == true
              ? statistics!.coverUrl
              : item.coverUrl,
          width: 88,
          height: 88,
          borderRadius: BorderRadius.circular(12),
          fallbackIcon: Icons.music_note_rounded,
          iconColor: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                statistics?.title.isNotEmpty == true
                    ? statistics!.title
                    : item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                statistics?.author.isNotEmpty == true
                    ? statistics!.author
                    : item.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatisticsGrid extends StatelessWidget {
  const _StatisticsGrid({required this.statistics});

  final SongStatistics statistics;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: MediaQuery.sizeOf(context).width >= 520 ? 2 : 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 3.1,
      children: <Widget>[
        _StatisticTile(
          icon: Icons.play_arrow_rounded,
          label: '播放次数',
          value: '${statistics.playCount} 次',
        ),
        _StatisticTile(
          icon: Icons.schedule_rounded,
          label: '累计收听时长',
          value: _formatDuration(statistics.totalPlayedMs),
        ),
        _StatisticTile(
          icon: Icons.first_page_rounded,
          label: '首次播放时间',
          value: _formatDate(statistics.firstPlayedAtEpochMs),
        ),
        _StatisticTile(
          icon: Icons.update_rounded,
          label: '最近播放时间',
          value: _formatDate(statistics.lastPlayedAtEpochMs),
        ),
      ],
    );
  }
}

class _StatisticTile extends StatelessWidget {
  const _StatisticTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.25,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: <Widget>[
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(label, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
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
}

class _EmptyStatistics extends StatelessWidget {
  const _EmptyStatistics({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48),
    child: Column(
      children: <Widget>[
        Icon(Icons.bar_chart_rounded, size: 48, color: colors.primary),
        const SizedBox(height: 14),
        const Text('还没有播放记录'),
        const SizedBox(height: 6),
        Text('播放这首歌后，统计数据会显示在这里。', style: TextStyle(color: Colors.grey)),
      ],
    ),
  );
}

String _formatDuration(int milliseconds) {
  final int totalMinutes = milliseconds ~/ Duration.millisecondsPerMinute;
  if (totalMinutes < 60) return '$totalMinutes 分钟';
  final int hours = totalMinutes ~/ 60;
  final int minutes = totalMinutes % 60;
  return minutes == 0 ? '$hours 小时' : '$hours 小时 $minutes 分钟';
}

String _formatDate(int? epochMilliseconds) {
  if (epochMilliseconds == null) return '暂无';
  final DateTime date = DateTime.fromMillisecondsSinceEpoch(
    epochMilliseconds,
  ).toLocal();
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${date.year}年${date.month}月${date.day}日 ${twoDigits(date.hour)}:${twoDigits(date.minute)}';
}
