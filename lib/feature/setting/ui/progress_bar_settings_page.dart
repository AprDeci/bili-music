import 'package:bilimusic/feature/player/domain/playback_chapter.dart';
import 'package:bilimusic/feature/player/domain/player_chapter_marker_style.dart';
import 'package:bilimusic/feature/player/logic/display/player_chapter_marker_style_logic.dart';
import 'package:bilimusic/feature/player/ui/components/player_chapter_markers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressBarSettingsPage extends ConsumerWidget {
  const ProgressBarSettingsPage({super.key});

  static const List<PlaybackChapter> _previewChapters = <PlaybackChapter>[
    PlaybackChapter(start: Duration.zero, title: ''),
    PlaybackChapter(start: Duration(seconds: 25), title: ''),
    PlaybackChapter(start: Duration(seconds: 50), title: ''),
    PlaybackChapter(start: Duration(seconds: 75), title: ''),
  ];
  static const Duration _previewTotal = Duration(seconds: 100);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final PlayerChapterMarkerStyle style = ref.watch(
      playerChapterMarkerStyleLogicProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('进度条设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          Text('章节分隔样式', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            '单P歌曲合集按时间轴拆分后，进度条上标记每首歌起点的方式',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: RadioGroup<PlayerChapterMarkerStyle>(
              groupValue: style,
              onChanged: (PlayerChapterMarkerStyle? value) {
                if (value == null) {
                  return;
                }
                ref
                    .read(playerChapterMarkerStyleLogicProvider.notifier)
                    .setStyle(value);
              },
              child: Column(
                children: PlayerChapterMarkerStyle.values
                    .map(
                      (PlayerChapterMarkerStyle option) =>
                          RadioListTile<PlayerChapterMarkerStyle>(
                            value: option,
                            title: Text(option.label),
                            subtitle: Text(option.description),
                            secondary: _StylePreview(style: option),
                          ),
                    )
                    .toList(growable: false),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('预览', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _PreviewBar(
              style: style,
              chapters: _previewChapters,
              total: _previewTotal,
            ),
          ),
        ],
      ),
    );
  }
}

class _StylePreview extends StatelessWidget {
  const _StylePreview({required this.style});

  final PlayerChapterMarkerStyle style;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 24,
      child: _PreviewBar(
        style: style,
        chapters: ProgressBarSettingsPage._previewChapters,
        total: ProgressBarSettingsPage._previewTotal,
      ),
    );
  }
}

class _PreviewBar extends StatelessWidget {
  const _PreviewBar({
    required this.style,
    required this.chapters,
    required this.total,
  });

  final PlayerChapterMarkerStyle style;
  final List<PlaybackChapter> chapters;
  final Duration total;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: ChapterMarkers(
                chapters: chapters,
                total: total,
                style: style,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
