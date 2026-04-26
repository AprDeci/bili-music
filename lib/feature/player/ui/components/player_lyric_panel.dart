import 'package:bilimusic/common/util/color_util.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_lyrics_state.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_lyrics_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/flutter_lyric.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PlayerLyricPanelVariant { mobile, desktop }

class PlayerLyricPanel extends ConsumerStatefulWidget {
  const PlayerLyricPanel({
    super.key,
    required this.state,
    required this.item,
    required this.onSeek,
    this.variant = PlayerLyricPanelVariant.mobile,
  });

  final PlayerState state;
  final PlayableItem? item;
  final ValueChanged<Duration> onSeek;
  final PlayerLyricPanelVariant variant;

  @override
  ConsumerState<PlayerLyricPanel> createState() => _PlayerLyricPanelState();
}

class _PlayerLyricPanelState extends ConsumerState<PlayerLyricPanel> {
  late final LyricController _lyricController;

  String? _loadedStableId;
  String? _loadedRenderableLyrics;

  bool get _isDesktop => widget.variant == PlayerLyricPanelVariant.desktop;

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
  void didUpdateWidget(covariant PlayerLyricPanel oldWidget) {
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
    if (!_isDesktop) {
      return content;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      child: content,
    );
  }

  Widget _buildContent(BuildContext context, PlayerLyricsState lyricsState) {
    final PlayableItem? item = widget.item;
    if (item == null) {
      return _PlayerLyricPanelStatus(
        key: const ValueKey<String>('empty'),
        variant: widget.variant,
        title: _isDesktop ? '还没有播放内容' : '还没有选择播放内容',
        message: _isDesktop
            ? '从搜索或收藏中选择一首音乐后，这里会显示歌词。'
            : '从搜索页选一条视频或音频后，这里会显示歌词。',
        icon: _isDesktop ? Icons.lyrics_outlined : Icons.music_note_outlined,
      );
    }

    if (lyricsState.stableId != item.stableId) {
      return _PlayerLyricPanelStatus(
        key: const ValueKey<String>('preparing'),
        variant: widget.variant,
        title: '正在准备歌词',
        message: _isDesktop ? '歌词会在当前歌曲匹配完成后显示。' : '歌词会在当前分 P 匹配完成后显示。',
        icon: _isDesktop ? Icons.graphic_eq_rounded : Icons.lyrics_outlined,
      );
    }

    if (lyricsState.isLoading) {
      return _PlayerLyricPanelStatus(
        key: const ValueKey<String>('loading'),
        variant: widget.variant,
        title: '正在查找歌词',
        message: _isDesktop ? '正在从 Meting 匹配当前歌曲。' : '已开始从 Meting 查询当前分 P 的歌词。',
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
      return _PlayerLyricPanelStatus(
        key: const ValueKey<String>('error'),
        variant: widget.variant,
        title: '歌词查询失败',
        message: lyricsState.errorMessage!,
        icon: Icons.error_outline_rounded,
        actionLabel: '重试',
        onAction: () =>
            ref.read(playerLyricsControllerProvider.notifier).retryCurrent(),
      );
    }

    return _PlayerLyricPanelStatus(
      key: const ValueKey<String>('no-lyrics'),
      variant: widget.variant,
      title: '暂无歌词',
      message: _isDesktop ? '没有匹配到当前歌曲的歌词。' : '没有匹配到当前分 P 的歌词。',
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

class _PlayerLyricPanelStatus extends StatelessWidget {
  const _PlayerLyricPanelStatus({
    super.key,
    required this.variant,
    required this.title,
    required this.message,
    required this.icon,
    this.isLoading = false,
    this.actionLabel,
    this.onAction,
  });

  final PlayerLyricPanelVariant variant;
  final String title;
  final String message;
  final IconData icon;
  final bool isLoading;
  final String? actionLabel;
  final VoidCallback? onAction;

  bool get _isDesktop => variant == PlayerLyricPanelVariant.desktop;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (isLoading)
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: _isDesktop ? 2.4 : 2.5,
              color: colorScheme.primary,
            ),
          )
        else
          Icon(
            icon,
            size: _isDesktop ? 38 : 34,
            color: _isDesktop
                ? colorScheme.primary.withValues(alpha: 0.62)
                : colorScheme.primary,
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
            color: _isDesktop
                ? colorScheme.onSurface.withValues(alpha: 0.58)
                : colorScheme.onSurfaceVariant,
            height: _isDesktop ? 1.45 : 1.35,
          ),
        ),
        if (actionLabel != null && onAction != null) ...<Widget>[
          SizedBox(height: _isDesktop ? 18 : 20),
          if (_isDesktop)
            TextButton(onPressed: onAction, child: Text(actionLabel!))
          else
            FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ],
    );

    return Center(
      child: _isDesktop
          ? ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: content,
            )
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: content,
            ),
    );
  }
}
