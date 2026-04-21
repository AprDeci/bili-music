import 'package:bilimusic/common/util/color_util.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_lyrics_state.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_lyrics_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/flutter_lyric.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerLyricPage extends ConsumerStatefulWidget {
  const PlayerLyricPage({
    super.key,
    required this.state,
    required this.item,
    required this.onSeek,
  });

  final PlayerState state;
  final PlayableItem? item;
  final ValueChanged<Duration> onSeek;

  @override
  ConsumerState<PlayerLyricPage> createState() => _PlayerLyricPageState();
}

class _PlayerLyricPageState extends ConsumerState<PlayerLyricPage> {
  late final LyricController _lyricController;

  String? _loadedStableId;
  String? _loadedRenderableLyrics;

  @override
  void initState() {
    super.initState();
    _lyricController = LyricController()
      ..setOnTapLineCallback((Duration position) {
        if (_loadedStableId != widget.item?.stableId) {
          return;
        }
        widget.onSeek(position);
      });
  }

  @override
  void didUpdateWidget(covariant PlayerLyricPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncProgress();
  }

  @override
  void dispose() {
    _lyricController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PlayerLyricsState lyricsState = ref.watch(
      playerLyricsControllerProvider,
    );
    _syncLyrics(lyricsState);

    final Widget content = _buildContent(context, lyricsState);
    if (widget.item == null) {
      return content;
    }

    return Column(
      children: <Widget>[
        Expanded(child: content),
        _PlayerLyricToolbar(
          onSearch: null,
          onOffset: () => _showLyricOffsetSheet(context),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, PlayerLyricsState lyricsState) {
    if (widget.item == null) {
      return const _PlayerLyricStatusView(
        icon: Icons.music_note_outlined,
        title: '还没有选择播放内容',
        message: '从搜索页选一条视频或音频后，这里会显示歌词。',
      );
    }

    if (lyricsState.stableId != widget.item!.stableId) {
      return const _PlayerLyricStatusView(
        icon: Icons.lyrics_outlined,
        title: '正在准备歌词',
        message: '歌词会在当前分 P 匹配完成后显示。',
      );
    }

    if (lyricsState.isLoading) {
      return const _PlayerLyricStatusView(
        icon: Icons.lyrics_outlined,
        title: '正在查找歌词',
        message: '已开始从 Meting 查询当前分 P 的歌词。',
        isLoading: true,
      );
    }

    if (lyricsState.hasLyrics) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return LyricView(
            controller: _lyricController,
            style: _buildLyricStyle(context),
            width: constraints.maxWidth,
            height: constraints.maxHeight,
          );
        },
      );
    }

    if (lyricsState.hasError) {
      return _PlayerLyricStatusView(
        icon: Icons.error_outline_rounded,
        title: '歌词查询失败',
        message: lyricsState.errorMessage!,
        actionLabel: '重试',
        onAction: () =>
            ref.read(playerLyricsControllerProvider.notifier).retryCurrent(),
      );
    }

    return const _PlayerLyricStatusView(
      icon: Icons.lyrics_outlined,
      title: '暂无歌词',
      message: '没有匹配到当前分 P 的歌词。',
    );
  }

  void _syncLyrics(PlayerLyricsState lyricsState) {
    _lyricController.lyricOffset = lyricsState.lyricOffsetMs;

    final String? rawLyrics = lyricsState.rawLyrics;
    final String? stableId = lyricsState.stableId;
    final String? renderableLyrics = PlayerUtil.buildRenderableLyrics(
      rawLyrics,
      widget.state.duration,
    );
    if (renderableLyrics == null || stableId == null) {
      if (_loadedStableId != null || _loadedRenderableLyrics != null) {
        _loadedStableId = null;
        _loadedRenderableLyrics = null;
        _lyricController.loadLyric('');
      }
      return;
    }

    if (_loadedStableId == stableId &&
        _loadedRenderableLyrics == renderableLyrics) {
      _syncProgress();
      return;
    }

    _loadedStableId = stableId;
    _loadedRenderableLyrics = renderableLyrics;
    _lyricController.loadLyric(renderableLyrics);
    _syncProgress();
  }

  void _syncProgress() {
    if (_loadedStableId != widget.item?.stableId) {
      return;
    }
    _lyricController.setProgress(widget.state.position);
  }

  LyricStyle _buildLyricStyle(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final Color activeColor = ColorUtil.getAllShades(colorScheme.primary)[700]!;
    final Color normalColor = colorScheme.onSurface;
    return LyricStyles.default1.copyWith(
      textStyle: (textTheme.bodyLarge ?? const TextStyle()).copyWith(
        color: normalColor.withValues(alpha: 0.8),
        fontSize: 22,
        height: 1.25,
        fontWeight: FontWeight.w500,
      ),
      activeStyle: (textTheme.titleLarge ?? const TextStyle()).copyWith(
        color: const Color.fromARGB(255, 168, 168, 168),
        fontSize: 30,
        height: 1.2,
        fontWeight: FontWeight.w800,
      ),
      translationStyle: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.62),
        fontSize: 14,
        height: 1.2,
      ),
      textAlign: TextAlign.left,
      contentAlignment: CrossAxisAlignment.start,
      contentPadding: const EdgeInsets.fromLTRB(8, 24, 8, 36),
      lineGap: 36,
      translationLineGap: 8,
      activeHighlightColor: activeColor,
      selectedColor: colorScheme.primary,
      selectedTranslationColor: colorScheme.primary.withValues(alpha: 0.72),
      highlightAlign: MainAxisAlignment.start,
      activeAlignment: MainAxisAlignment.start,
      anchorPosition: 0.42,
      activeAnchorPosition: 0.42,
      fadeRange: FadeRange(top: 0.42, bottom: 0.8),
    );
  }

  Future<void> _showLyricOffsetSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (BuildContext context) {
        return const _LyricOffsetSheet();
      },
    );
  }
}

class _PlayerLyricToolbar extends StatelessWidget {
  const _PlayerLyricToolbar({required this.onOffset, this.onSearch});

  final VoidCallback? onSearch;
  final VoidCallback onOffset;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color iconColor = colorScheme.primary.withValues(alpha: 0.72);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              tooltip: '手动匹配歌词',
              onPressed: onSearch,
              color: iconColor,
              icon: const Icon(Icons.search_rounded),
            ),
            const SizedBox(width: 20),
            IconButton(
              tooltip: '歌词偏移',
              onPressed: onOffset,
              color: iconColor,
              icon: const Icon(Icons.hourglass_empty_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _LyricOffsetSheet extends ConsumerWidget {
  const _LyricOffsetSheet();

  static const int _stepMs = 500;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlayerLyricsState lyricsState = ref.watch(
      playerLyricsControllerProvider,
    );
    final PlayerLyricsController controller = ref.read(
      playerLyricsControllerProvider.notifier,
    );
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                tooltip: '歌词提前 0.5 秒',
                onPressed: () => controller.adjustOffset(-_stepMs),
                icon: const Icon(Icons.remove_rounded),
              ),
              SizedBox(
                width: 96,
                child: Center(
                  child: Text(
                    _formatOffset(lyricsState.lyricOffsetMs),
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: '歌词延后 0.5 秒',
                onPressed: () => controller.adjustOffset(_stepMs),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatOffset(int offsetMs) {
    final double seconds = offsetMs / Duration.millisecondsPerSecond;
    if (offsetMs > 0) {
      return '+${seconds.toStringAsFixed(1)}s';
    }
    return '${seconds.toStringAsFixed(1)}s';
  }
}

class _PlayerLyricStatusView extends StatelessWidget {
  const _PlayerLyricStatusView({
    required this.icon,
    required this.title,
    required this.message,
    this.isLoading = false,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool isLoading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (isLoading)
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colorScheme.primary,
                ),
              )
            else
              Icon(icon, size: 34, color: colorScheme.primary),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 20),
              FilledButton.tonal(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
