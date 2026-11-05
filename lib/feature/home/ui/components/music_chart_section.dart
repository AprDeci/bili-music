import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/status_view.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/home/domain/music_chart_platform.dart';
import 'package:bilimusic/feature/home/domain/music_chart_state.dart';
import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/home/logic/music_chart_controller.dart';
import 'package:bilimusic/feature/home/logic/music_chart_resolver.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicChartSection extends ConsumerStatefulWidget {
  const MusicChartSection({super.key});

  @override
  ConsumerState<MusicChartSection> createState() => _MusicChartSectionState();
}

class _MusicChartSectionState extends ConsumerState<MusicChartSection> {
  String? _resolvingTrackKey;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final MusicChartState state = ref.watch(musicChartControllerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '音乐热榜',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
              fontSize: 18,
              letterSpacing: -1.3,
              height: 1,
            ),
          ),
          const SizedBox(height: 12),
          _ChartPlatformBar(
            selected: state.platform,
            onSelected: (MusicChartPlatform platform) {
              ref
                  .read(musicChartControllerProvider.notifier)
                  .selectPlatform(platform);
            },
          ),
          const SizedBox(height: 16),
          if (state.isLoading)
            const _MusicChartLoading()
          else if (state.hasError)
            StatusView(
              icon: Icons.signal_wifi_statusbar_connected_no_internet_4_rounded,
              iconColor: colorScheme.error,
              title: '热榜加载失败',
              description: state.errorMessage,
            )
          else if (state.isEmpty)
            const StatusView(icon: Icons.leaderboard_outlined, title: '暂无热榜内容')
          else
            _MusicChartTracks(
              tracks: state.tracks,
              resolvingTrackKey: _resolvingTrackKey,
              onTrackTap: (MusicChartTrack track) => _playTrack(track),
            ),
        ],
      ),
    );
  }

  Future<void> _playTrack(MusicChartTrack track) async {
    if (_resolvingTrackKey != null) {
      return;
    }
    setState(() => _resolvingTrackKey = track.key);
    try {
      final PlayableItem? item = await ref
          .read(musicChartResolverProvider)
          .resolve(track);
      if (!mounted) {
        return;
      }
      if (item == null) {
        ToastUtil.show('没找到匹配的 B 站视频');
        return;
      }
      await PlayerUtil.playItemAndOpenPlayer(
        context,
        ref,
        item: item,
        sourceLabel: track.platform.title,
      );
    } on Object {
      if (mounted) {
        ToastUtil.show('匹配失败，请稍后再试');
      }
    } finally {
      if (mounted) {
        setState(() => _resolvingTrackKey = null);
      }
    }
  }
}

class _ChartPlatformBar extends StatelessWidget {
  const _ChartPlatformBar({required this.selected, required this.onSelected});

  final MusicChartPlatform selected;
  final ValueChanged<MusicChartPlatform> onSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final MusicChartPlatform platform in MusicChartPlatform.values)
          _ChartPlatformChip(
            label: platform.label,
            selected: platform == selected,
            colorScheme: colorScheme,
            onTap: () => onSelected(platform),
          ),
      ],
    );
  }
}

class _ChartPlatformChip extends StatelessWidget {
  const _ChartPlatformChip({
    required this.label,
    required this.selected,
    required this.colorScheme,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? colorScheme.primary.withValues(alpha: 0.12)
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}

class _MusicChartTracks extends StatelessWidget {
  const _MusicChartTracks({
    required this.tracks,
    required this.resolvingTrackKey,
    required this.onTrackTap,
  });

  final List<MusicChartTrack> tracks;
  final String? resolvingTrackKey;
  final ValueChanged<MusicChartTrack> onTrackTap;

  @override
  Widget build(BuildContext context) {
    if (!PlatformUtil.isDesktop) {
      return Column(
        children: <Widget>[
          for (final MusicChartTrack track in tracks)
            _MusicChartTrackTile(
              track: track,
              isResolving: resolvingTrackKey == track.key,
              onTap: () => onTrackTap(track),
            ),
        ],
      );
    }

    final List<MusicChartTrack> left = <MusicChartTrack>[];
    final List<MusicChartTrack> right = <MusicChartTrack>[];
    for (int index = 0; index < tracks.length; index += 1) {
      (index.isEven ? left : right).add(tracks[index]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              for (final MusicChartTrack track in left)
                _MusicChartTrackTile(
                  track: track,
                  isResolving: resolvingTrackKey == track.key,
                  onTap: () => onTrackTap(track),
                ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: <Widget>[
              for (final MusicChartTrack track in right)
                _MusicChartTrackTile(
                  track: track,
                  isResolving: resolvingTrackKey == track.key,
                  onTap: () => onTrackTap(track),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MusicChartTrackTile extends StatelessWidget {
  const _MusicChartTrackTile({
    required this.track,
    required this.isResolving,
    required this.onTap,
  });

  final MusicChartTrack track;
  final bool isResolving;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool topThree = track.rank <= 3;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isResolving ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 54,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 26,
                  child: Text(
                    '${track.rank}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: topThree
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CommonCachedImage(
                    imageUrl: track.coverUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.music_note_rounded,
                    iconColor: colorScheme.onSurfaceVariant,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                          fontSize: 14,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        track.artist.isEmpty
                            ? track.platform.label
                            : track.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isResolving)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    track.durationText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.75,
                      ),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MusicChartLoading extends StatelessWidget {
  const _MusicChartLoading();

  static const Color _placeholderColor = Color(0xFFDDE6F2);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(6, (int index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: SizedBox(
            height: 54,
            child: Row(
              children: <Widget>[
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _placeholderColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 13,
                        decoration: BoxDecoration(
                          color: _placeholderColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 120,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _placeholderColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
