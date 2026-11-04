import 'package:bilimusic/common/components/desktop/desktop_side_panel.dart';
import 'package:bilimusic/feature/player/domain/playback_chapter.dart';
import 'package:bilimusic/feature/player/logic/utils/player_ui_helpers.dart';
import 'package:bilimusic/feature/player/ui/components/player_playback_waveform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

Future<void> showPlayerChapterSelector({
  required BuildContext context,
  required List<PlaybackChapter> chapters,
  required Duration position,
  required bool isPlaying,
  required ValueChanged<Duration> onSeek,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (BuildContext context) {
      return SafeArea(
        child: _PlayerChapterSelectorContent(
          chapters: chapters,
          position: position,
          isPlaying: isPlaying,
          onSeek: onSeek,
          closeTarget: _ChapterCloseTarget.navigator,
        ),
      );
    },
  );
}

Future<void> showDesktopPlayerChapterSelectorPanel({
  required BuildContext context,
  required List<PlaybackChapter> chapters,
  required Duration position,
  required bool isPlaying,
  required ValueChanged<Duration> onSeek,
}) async {
  await showDesktopSidePanel(
    tag: 'player_chapter_selector',
    context: context,
    width: 420,
    builder: (BuildContext context) {
      return SafeArea(
        child: _PlayerChapterSelectorContent(
          chapters: chapters,
          position: position,
          isPlaying: isPlaying,
          onSeek: onSeek,
          closeTarget: _ChapterCloseTarget.sidePanel,
        ),
      );
    },
  );
}

enum _ChapterCloseTarget { navigator, sidePanel }

class _PlayerChapterSelectorContent extends StatefulWidget {
  const _PlayerChapterSelectorContent({
    required this.chapters,
    required this.position,
    required this.isPlaying,
    required this.onSeek,
    required this.closeTarget,
  });

  final List<PlaybackChapter> chapters;
  final Duration position;
  final bool isPlaying;
  final ValueChanged<Duration> onSeek;
  final _ChapterCloseTarget closeTarget;

  @override
  State<_PlayerChapterSelectorContent> createState() =>
      _PlayerChapterSelectorContentState();
}

class _PlayerChapterSelectorContentState
    extends State<_PlayerChapterSelectorContent> {
  static const double _estimatedRowExtent = 56;

  late final AutoScrollController _scrollController;
  bool _didFocusCurrentChapter = false;

  @override
  void initState() {
    super.initState();
    _scrollController = AutoScrollController(
      suggestedRowHeight: _estimatedRowExtent,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final int? currentIndex = resolveChapterIndex(
      widget.chapters,
      widget.position,
    );
    _focusCurrentChapter(currentIndex);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: <Widget>[
              Text(
                '时间轴',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.chapters.length} 首',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: widget.chapters.length,
            itemBuilder: (BuildContext context, int index) {
              final PlaybackChapter chapter = widget.chapters[index];
              final bool isSelected = index == currentIndex;

              return AutoScrollTag(
                key: ValueKey<String>(
                  'chapter-selector-${chapter.start.inMilliseconds}',
                ),
                controller: _scrollController,
                index: index,
                child: Semantics(
                  selected: isSelected,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        await _close();
                        widget.onSeek(chapter.start);
                      },
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 56),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 4,
                          ),
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 64,
                                child: Text(
                                  formatPlayerDuration(chapter.start),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontFeatures: const <FontFeature>[
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  chapter.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isSelected) ...<Widget>[
                                const SizedBox(width: 8),
                                PlayerPlaybackWaveform(
                                  isPlaying: widget.isPlaying,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _focusCurrentChapter(int? currentIndex) {
    if (_didFocusCurrentChapter || currentIndex == null || currentIndex < 0) {
      return;
    }
    _didFocusCurrentChapter = true;
    _scrollToCurrentChapter(currentIndex, 0);
  }

  void _scrollToCurrentChapter(int index, int attempt) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      if (!_scrollController.hasClients ||
          _scrollController.position.maxScrollExtent <= 0) {
        if (attempt < 12) {
          _scrollToCurrentChapter(index, attempt + 1);
        }
        return;
      }
      await _scrollController.scrollToIndex(
        index,
        preferPosition: AutoScrollPosition.middle,
      );
    });
  }

  Future<void> _close() async {
    switch (widget.closeTarget) {
      case _ChapterCloseTarget.navigator:
        if (!mounted) {
          return;
        }
        Navigator.of(context).pop();
      case _ChapterCloseTarget.sidePanel:
        await SmartDialog.dismiss<void>(tag: desktopSidePanelTag);
    }
  }
}
