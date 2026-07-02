import 'package:bilimusic/common/util/color_util.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_lyric_font_preference.dart';
import 'package:bilimusic/feature/player/domain/player_lyric_font_size_preference.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_lyric_font_preference_logic.dart';
import 'package:bilimusic/feature/player/logic/player_lyric_font_size_preference_logic.dart';
import 'package:bilimusic/feature/player/ui/components/player_display_metadata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/flutter_lyric.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum PlayerLyricPanelVariant { mobile, desktop }

class PlayerLyricPanel extends ConsumerStatefulWidget {
  const PlayerLyricPanel({
    super.key,
    required this.state,
    required this.item,
    required this.isActive,
    required this.onSeek,
    this.activeColor,
    this.variant = PlayerLyricPanelVariant.mobile,
  });

  final PlayerState state;
  final PlayableItem? item;
  final bool isActive;
  final ValueChanged<Duration> onSeek;
  final Color? activeColor;
  final PlayerLyricPanelVariant variant;

  @override
  ConsumerState<PlayerLyricPanel> createState() => _PlayerLyricPanelState();
}

class _PlayerLyricPanelState extends ConsumerState<PlayerLyricPanel> {
  static const Duration _inactiveSyncInterval = Duration(seconds: 1);

  late final LyricController _lyricController;

  String? _loadedStableId;
  String? _loadedRenderableLyrics;
  String? _loadedTranslationLyrics;
  String? _loadedLyricStyleKey;
  Duration? _lastInactiveSyncedPosition;

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
    _syncProgressIfNeeded();
  }

  void _syncProgressIfNeeded() {
    if (widget.isActive) {
      _lastInactiveSyncedPosition = null;
      _syncProgress();
      return;
    }

    final Duration position = widget.state.position;
    final Duration? lastPosition = _lastInactiveSyncedPosition;
    if (lastPosition != null &&
        (position - lastPosition).abs() < _inactiveSyncInterval) {
      return;
    }

    _lastInactiveSyncedPosition = position;
    _syncProgress();
  }

  @override
  void dispose() {
    _lyricController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MetadataState metadataState = ref.watch(metadataControllerProvider);
    final PlayerLyricFontPreference lyricFontPreference = ref.watch(
      playerLyricFontPreferenceLogicProvider,
    );
    final PlayerLyricFontSizePreference lyricFontSizePreference = ref.watch(
      playerLyricFontSizePreferenceLogicProvider,
    );
    final String lyricStyleKey = _buildLyricStyleKey(
      lyricFontPreference,
      lyricFontSizePreference,
    );
    _syncLyrics(metadataState, lyricStyleKey);

    final Widget content = _buildContent(
      context,
      metadataState,
      lyricFontPreference,
      lyricFontSizePreference,
    );
    if (!_isDesktop) {
      return content;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      child: content,
    );
  }

  Widget _buildContent(
    BuildContext context,
    MetadataState metadataState,
    PlayerLyricFontPreference lyricFontPreference,
    PlayerLyricFontSizePreference lyricFontSizePreference,
  ) {
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

    final String itemKey = item.stableId;

    if (metadataState.stableId != item.stableId) {
      return _PlayerLyricPanelStatus(
        key: ValueKey<String>('preparing-$itemKey'),
        variant: widget.variant,
        title: '正在准备歌词',
        message: _isDesktop ? '歌词会在当前歌曲匹配完成后显示。' : '歌词会在当前分 P 匹配完成后显示。',
        icon: _isDesktop ? Icons.graphic_eq_rounded : Icons.lyrics_outlined,
      );
    }

    if (metadataState.isLoading) {
      return _PlayerLyricPanelStatus(
        key: ValueKey<String>('loading-$itemKey'),
        variant: widget.variant,
        title: '正在查找歌词',
        message: _isDesktop ? '正在从 Meting 匹配当前歌曲。' : '已开始从 Meting 查询当前分 P 的歌词。',
        icon: Icons.lyrics_outlined,
        isLoading: true,
      );
    }

    if (metadataState.hasLyrics) {
      return LayoutBuilder(
        key: ValueKey<String>('lyrics-$itemKey'),
        builder: (BuildContext context, BoxConstraints constraints) {
          final LyricStyle style = _buildLyricStyle(
            context,
            lyricFontPreference,
            lyricFontSizePreference,
          );
          final EdgeInsets lyricPadding = _isDesktop
              ? const EdgeInsets.symmetric(horizontal: 30)
              : EdgeInsets.zero;
          return Stack(
            children: <Widget>[
              Padding(
                padding: lyricPadding,
                child: LyricView(
                  key: ValueKey<String>(
                    'lyric-${lyricFontPreference.storageValue}-${lyricFontSizePreference.storageValue}',
                  ),
                  controller: _lyricController,
                  style: style,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                ),
              ),
              _PlayerLyricSelectionProgress(
                controller: _lyricController,
                variant: widget.variant,
                onPlay: (SelectionState state) {
                  _lyricController.stopSelection();
                  widget.onSeek(state.duration);
                },
              ),
            ],
          );
        },
      );
    }

    if (metadataState.hasError) {
      return _PlayerLyricPanelStatus(
        key: ValueKey<String>('error-$itemKey'),
        variant: widget.variant,
        title: '歌词查询失败',
        message: metadataState.errorMessage!,
        icon: Icons.error_outline_rounded,
        actionLabel: '重试',
        goSetting: true,
        onAction: () =>
            ref.read(metadataControllerProvider.notifier).retryCurrent(),
      );
    }

    return _PlayerLyricPanelStatus(
      key: ValueKey<String>('no-lyrics-$itemKey'),
      variant: widget.variant,
      title: '暂无歌词',
      message: _isDesktop ? '没有匹配到当前歌曲的歌词。' : '没有匹配到当前分 P 的歌词。',
      icon: Icons.lyrics_outlined,
    );
  }

  void _syncLyrics(MetadataState metadataState, String lyricStyleKey) {
    _lyricController.lyricOffset = resolveDisplayLyricOffsetMs(
      metadataState.metadata,
    );

    final String? rawLyrics = resolveDisplayLyrics(metadataState.metadata);
    final String? translationLyrics = resolveDisplayTranslationLyrics(
      metadataState.metadata,
    );
    final String? stableId = metadataState.stableId;
    final String? renderableLyrics = PlayerUtil.buildRenderableLyrics(
      rawLyrics,
      widget.state.duration,
    );
    if (renderableLyrics == null || stableId == null) {
      if (_loadedStableId != null ||
          _loadedRenderableLyrics != null ||
          _loadedTranslationLyrics != null ||
          _loadedLyricStyleKey != null) {
        _loadedStableId = null;
        _loadedRenderableLyrics = null;
        _loadedTranslationLyrics = null;
        _loadedLyricStyleKey = null;
        _lyricController.loadLyric('');
      }
      return;
    }

    if (_loadedStableId == stableId &&
        _loadedRenderableLyrics == renderableLyrics &&
        _loadedTranslationLyrics == translationLyrics &&
        _loadedLyricStyleKey == lyricStyleKey) {
      _syncProgressIfNeeded();
      return;
    }

    _loadedStableId = stableId;
    _loadedRenderableLyrics = renderableLyrics;
    _loadedTranslationLyrics = translationLyrics;
    _loadedLyricStyleKey = lyricStyleKey;
    _lyricController.loadLyric(
      renderableLyrics,
      translationLyric: translationLyrics,
    );
    _syncProgressIfNeeded();
  }

  String _buildLyricStyleKey(
    PlayerLyricFontPreference lyricFontPreference,
    PlayerLyricFontSizePreference lyricFontSizePreference,
  ) {
    return '${lyricFontPreference.storageValue}-'
        '${lyricFontSizePreference.storageValue}';
  }

  void _syncProgress() {
    if (_loadedStableId != widget.item?.stableId) {
      return;
    }
    _lyricController.setProgress(widget.state.position);
  }

  LyricStyle _buildLyricStyle(
    BuildContext context,
    PlayerLyricFontPreference lyricFontPreference,
    PlayerLyricFontSizePreference lyricFontSizePreference,
  ) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final Color accentColor = _resolveAccentColor(context);
    final Color activeColor = ColorUtil.getAllShades(
      accentColor,
    )[600]!.withValues(alpha: 0.8);
    final Color normalColor = colorScheme.onSurface;
    final bool isDesktop = PlatformUtil.isDesktop;
    final String? fontFamily = lyricFontPreference.fontFamily;
    final List<String>? fontFamilyFallback =
        lyricFontPreference.fontFamilyFallback;
    final double fontScale = lyricFontSizePreference.scale;
    return LyricStyles.default1.copyWith(
      textStyle: (textTheme.bodyLarge ?? const TextStyle()).copyWith(
        color: normalColor.withValues(alpha: 0.7),
        fontSize: (isDesktop ? 20 : 24) * fontScale,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        height: 1.25,
        fontWeight: FontWeight.w500,
      ),
      activeStyle: (textTheme.titleLarge ?? const TextStyle()).copyWith(
        color: const Color.fromARGB(255, 168, 168, 168),
        fontSize: (isDesktop ? 20 : 30) * fontScale,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        height: 1.2,
        fontWeight: FontWeight.w800,
      ),
      translationStyle: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.62),
        fontSize: 14 * fontScale,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        height: 1.2,
      ),
      textAlign: isDesktop ? TextAlign.center : TextAlign.left,
      contentAlignment: isDesktop
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      contentPadding: const EdgeInsets.fromLTRB(8, 24, 8, 36),
      lineGap: isDesktop ? 20 : 36,
      translationLineGap: 8,
      activeHighlightColor: activeColor,
      selectedColor: const Color.fromARGB(255, 168, 168, 168),
      selectedTranslationColor: const Color.fromARGB(255, 168, 168, 168),
      highlightAlign: MainAxisAlignment.start,
      activeAlignment: MainAxisAlignment.start,
      anchorPosition: 0.42,
      activeAnchorPosition: 0.42,
      fadeRange: FadeRange(top: 0.42, bottom: 0.8),
    );
  }

  Color _resolveAccentColor(BuildContext context) {
    return widget.activeColor ?? Theme.of(context).colorScheme.primary;
  }
}

class _PlayerLyricPanelStatus extends StatelessWidget {
  const _PlayerLyricPanelStatus({
    super.key,
    required this.variant,
    required this.title,
    required this.message,
    required this.icon,
    this.goSetting = false,
    this.isLoading = false,
    this.actionLabel,
    this.onAction,
  });

  final PlayerLyricPanelVariant variant;
  final String title;
  final String message;
  final IconData icon;
  final bool goSetting;
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
        if (goSetting) ...<Widget>[
          if (_isDesktop)
            TextButton(
              onPressed: () => context.go('/settings/player'),
              child: Text('设置'),
            )
          else
            FilledButton.tonal(
              onPressed: () => context.push('/settings/player'),
              child: Text('设置'),
            ),
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

class _PlayerLyricSelectionProgress extends StatelessWidget {
  const _PlayerLyricSelectionProgress({
    required this.controller,
    required this.variant,
    required this.onPlay,
  });

  final LyricController controller;
  final PlayerLyricPanelVariant variant;
  final ValueChanged<SelectionState> onPlay;

  bool get _isDesktop => variant == PlayerLyricPanelVariant.desktop;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color labelColor = colorScheme.onSurfaceVariant;
    final Color labelBackground = colorScheme.surfaceContainerHighest
        .withValues(alpha: 0.52);

    return SelectListenableBuilder(
      controller: controller,
      builder: (SelectionState state, Widget? child) {
        return Positioned(
          top: state.centerY,
          right: 0,
          left: 0,
          child: FractionalTranslation(
            translation: const Offset(0, -0.5),
            transformHitTests: true,
            child: SizedBox(
              height: 200,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: _isDesktop
                    ? _buildDesktopSelection(context, state, labelColor)
                    : _buildMobileSelection(state, labelColor, labelBackground),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildDesktopSelection(
    BuildContext context,
    SelectionState state,
    Color labelColor,
  ) {
    final Color dividerColor = Theme.of(
      context,
    ).colorScheme.outlineVariant.withValues(alpha: 0.72);

    return <Widget>[
      Positioned(
        left: 0,
        child: Text(
          _formatDuration(state.duration),
          style: TextStyle(
            color: labelColor,
            fontSize: 12,
            height: 1,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      Positioned(
        left: 40,
        right: 40,
        child: Container(height: 1, color: dividerColor),
      ),
      Positioned(
        right: 0,
        child: IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: () => onPlay(state),
          icon: Icon(Icons.play_arrow_rounded, size: 24, color: labelColor),
        ),
      ),
    ];
  }

  List<Widget> _buildMobileSelection(
    SelectionState state,
    Color labelColor,
    Color labelBackground,
  ) {
    return <Widget>[
      Positioned(
        right: 0,
        child: GestureDetector(
          onTap: () => onPlay(state),
          child: DecoratedBox(
            decoration: _PlayerLyricSelectionDecoration(color: labelBackground),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 3,
                vertical: 2,
              ).copyWith(left: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.play_arrow_rounded, size: 13, color: labelColor),
                  const SizedBox(width: 1),
                  Text(
                    _formatDuration(state.duration),
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 11,
                      height: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ];
  }

  static String _formatDuration(Duration duration) {
    final int minutes = duration.inMinutes;
    final int seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}

class _PlayerLyricSelectionDecoration extends Decoration {
  const _PlayerLyricSelectionDecoration({required this.color});

  final Color color;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _PlayerLyricSelectionBoxPainter(color, onChanged);
  }
}

class _PlayerLyricSelectionBoxPainter extends BoxPainter {
  _PlayerLyricSelectionBoxPainter(this.color, VoidCallback? onChanged)
    : super(onChanged);

  final Color color;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Size? size = configuration.size;
    if (size == null) {
      return;
    }

    const double radius = 4;
    const double triangleWidth = 3;

    final Paint paint = Paint()..color = color;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
        const Radius.circular(radius),
      ),
      paint,
    );

    final Path path = Path()
      ..moveTo(offset.dx - triangleWidth, offset.dy + size.height / 2)
      ..lineTo(offset.dx, offset.dy + radius)
      ..lineTo(offset.dx, offset.dy + size.height - radius)
      ..close();

    canvas.drawPath(path, paint);
  }
}
