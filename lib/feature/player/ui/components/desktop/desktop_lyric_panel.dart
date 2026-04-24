import 'package:bilimusic/common/util/color_util.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_lyrics_state.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_lyrics_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/flutter_lyric.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopLyricPanel extends ConsumerStatefulWidget {
  const DesktopLyricPanel({
    super.key,
    required this.state,
    required this.item,
    required this.onSeek,
  });

  final PlayerState state;
  final PlayableItem? item;
  final ValueChanged<Duration> onSeek;

  @override
  ConsumerState<DesktopLyricPanel> createState() => _DesktopLyricPanelState();
}

class _DesktopLyricPanelState extends ConsumerState<DesktopLyricPanel> {
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
  void didUpdateWidget(covariant DesktopLyricPanel oldWidget) {
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

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      child: _buildContent(context, lyricsState),
    );
  }

  Widget _buildContent(BuildContext context, PlayerLyricsState lyricsState) {
    final PlayableItem? item = widget.item;
    if (item == null) {
      return const _DesktopLyricStatus(
        key: ValueKey<String>('empty'),
        title: '还没有播放内容',
        message: '从搜索或收藏中选择一首音乐后，这里会显示歌词。',
        icon: Icons.lyrics_outlined,
      );
    }

    if (lyricsState.stableId != item.stableId) {
      return const _DesktopLyricStatus(
        key: ValueKey<String>('preparing'),
        title: '正在准备歌词',
        message: '歌词会在当前歌曲匹配完成后显示。',
        icon: Icons.graphic_eq_rounded,
      );
    }

    if (lyricsState.isLoading) {
      return const _DesktopLyricStatus(
        key: ValueKey<String>('loading'),
        title: '正在查找歌词',
        message: '正在从 Meting 匹配当前歌曲。',
        icon: Icons.lyrics_outlined,
        isLoading: true,
      );
    }

    if (lyricsState.hasLyrics) {
      return LayoutBuilder(
        key: const ValueKey<String>('lyrics'),
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
      return _DesktopLyricStatus(
        key: const ValueKey<String>('error'),
        title: '歌词查询失败',
        message: lyricsState.errorMessage!,
        icon: Icons.error_outline_rounded,
        actionLabel: '重试',
        onAction: () =>
            ref.read(playerLyricsControllerProvider.notifier).retryCurrent(),
      );
    }

    return const _DesktopLyricStatus(
      key: ValueKey<String>('no-lyrics'),
      title: '暂无歌词',
      message: '没有匹配到当前歌曲的歌词。',
      icon: Icons.lyrics_outlined,
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
}

class _DesktopLyricStatus extends StatelessWidget {
  const _DesktopLyricStatus({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.isLoading = false,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final bool isLoading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (isLoading)
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: colorScheme.primary,
                ),
              )
            else
              Icon(
                icon,
                size: 38,
                color: colorScheme.primary.withValues(alpha: 0.62),
              ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.58),
                height: 1.45,
              ),
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 18),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
