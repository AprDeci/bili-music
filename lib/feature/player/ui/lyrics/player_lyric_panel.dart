import 'dart:async';

import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/player/domain/bili_subtitle.dart';
import 'package:bilimusic/feature/player/domain/player_subtitle_state.dart';
import 'package:bilimusic/feature/player/logic/lyrics/player_subtitle_controller.dart';
import 'package:bilimusic/feature/player/ui/lyrics/player_subtitle_document.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/lyrics/player_lyric_settings_logic.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_metadata.dart';
import 'package:bilimusic/feature/player/ui/lyrics/player_lyric_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
    this.showTranslation = true,
  });

  final PlayerState state;
  final PlayableItem? item;
  final bool isActive;
  final ValueChanged<Duration> onSeek;
  final Color? activeColor;
  final PlayerLyricPanelVariant variant;
  final bool showTranslation;

  @override
  ConsumerState<PlayerLyricPanel> createState() => _PlayerLyricPanelState();
}

class _PlayerLyricPanelState extends ConsumerState<PlayerLyricPanel> {
  late final _PlayerLyricProgressSource _progressSource;
  late final LyricController _lyricController;

  String? _loadedStableId;
  String? _loadedRenderableLyrics;
  String? _loadedTranslationLyrics;
  List<BiliSubtitleLine>? _loadedSubtitleLines;

  bool get _isDesktop => widget.variant == PlayerLyricPanelVariant.desktop;

  @override
  void initState() {
    super.initState();
    _progressSource = _PlayerLyricProgressSource(
      widget.state,
      widget.isActive,
      widget.item?.stableId,
    );
    _lyricController = LyricController(progressSource: _progressSource);
  }

  @override
  void didUpdateWidget(covariant PlayerLyricPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _progressSource.update(
      widget.state,
      enabled: widget.isActive,
      stableId: widget.item?.stableId,
    );
  }

  @override
  void dispose() {
    _lyricController.dispose();
    _progressSource.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MetadataState metadataState = widget.item?.isSpoken == true
        ? const MetadataState()
        : ref.watch(metadataControllerProvider);
    final PlayerSubtitleState subtitles = ref.watch(
      playerSubtitleControllerProvider,
    );
    final bool useSubtitles =
        subtitles.stableId == widget.item?.stableId && subtitles.usesSubtitles;
    if (useSubtitles) {
      _syncSubtitles(subtitles);
    } else {
      _syncLyrics(metadataState);
    }

    final Widget content = _buildContent(context, metadataState, useSubtitles);
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
    bool useSubtitles,
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

    if (item.isSpoken && !useSubtitles) {
      return _PlayerLyricPanelStatus(
        key: ValueKey<String>('spoken-$itemKey'),
        variant: widget.variant,
        title: '听书模式',
        message: '不匹配音乐歌词，可选择可用字幕。',
        icon: Icons.subtitles_outlined,
      );
    }

    if (!useSubtitles && metadataState.stableId != item.stableId) {
      return _PlayerLyricPanelStatus(
        key: ValueKey<String>('preparing-$itemKey'),
        variant: widget.variant,
        title: '正在准备歌词',
        message: _isDesktop ? '歌词会在当前歌曲匹配完成后显示。' : '歌词会在当前分 P 匹配完成后显示。',
        icon: _isDesktop ? Icons.graphic_eq_rounded : Icons.lyrics_outlined,
      );
    }

    if (!useSubtitles && metadataState.isLoading) {
      return _PlayerLyricPanelStatus(
        key: ValueKey<String>('loading-$itemKey'),
        variant: widget.variant,
        title: '正在查找歌词',
        message: _isDesktop ? '正在从 Meting 匹配当前歌曲。' : '已开始从 Meting 查询当前分 P 的歌词。',
        icon: Icons.lyrics_outlined,
        isLoading: true,
      );
    }

    if (useSubtitles || metadataState.hasLyrics) {
      return Padding(
        key: ValueKey<String>('lyrics-$itemKey'),
        padding: _isDesktop
            ? const EdgeInsets.symmetric(horizontal: 30)
            : EdgeInsets.zero,
        child: TickerMode(
          enabled: widget.isActive,
          child: LyricView(
            controller: _lyricController,
            preset: _buildLyricPreset(context, useSubtitles: useSubtitles),
            onLineTap: (LyricLineDetails details) {
              if (_loadedStableId != widget.item?.stableId) return;
              widget.onSeek(details.seekPosition);
            },
          ),
        ),
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

  void _syncSubtitles(PlayerSubtitleState subtitles) {
    _lyricController.timeOffset = Duration(milliseconds: subtitles.offsetMs);
    if (_loadedStableId == subtitles.stableId &&
        listEquals(_loadedSubtitleLines, subtitles.lines)) {
      return;
    }
    _loadedStableId = subtitles.stableId;
    _loadedSubtitleLines = subtitles.lines;
    _loadedRenderableLyrics = null;
    _loadedTranslationLyrics = null;
    _lyricController.loadDocument(buildSubtitleDocument(subtitles.lines));
  }

  void _syncLyrics(MetadataState metadataState) {
    if (_loadedSubtitleLines != null) {
      _loadedSubtitleLines = null;
      _loadedStableId = null;
      _lyricController.clear();
    }
    _lyricController.timeOffset = Duration(
      milliseconds: resolveDisplayLyricOffsetMs(metadataState.metadata),
    );

    final String? rawLyrics = resolveDisplayLyrics(metadataState.metadata);
    final bool showTranslation =
        widget.showTranslation &&
        ref.watch(playerLyricSettingsLogicProvider).showTranslation;
    final String? translationLyrics = showTranslation
        ? resolveDisplayTranslationLyrics(metadataState.metadata)
        : null;
    final String? stableId = metadataState.stableId;
    final String? renderableLyrics = PlayerUtil.buildRenderableLyrics(
      rawLyrics,
      widget.state.duration,
    );
    if (renderableLyrics == null || stableId == null) {
      if (_loadedStableId != null ||
          _loadedRenderableLyrics != null ||
          _loadedTranslationLyrics != null) {
        _loadedStableId = null;
        _loadedRenderableLyrics = null;
        _loadedTranslationLyrics = null;
        _lyricController.clear();
      }
      return;
    }

    if (_loadedStableId == stableId &&
        _loadedRenderableLyrics == renderableLyrics &&
        _loadedTranslationLyrics == translationLyrics) {
      return;
    }

    _loadedStableId = stableId;
    _loadedRenderableLyrics = renderableLyrics;
    _loadedTranslationLyrics = translationLyrics;
    _lyricController.load(renderableLyrics, translation: translationLyrics);
  }

  LyricPreset _buildLyricPreset(
    BuildContext context, {
    required bool useSubtitles,
  }) {
    final LyricPreset preset = buildPlayerLyricPreset(
      theme: Theme.of(context),
      settings: ref.watch(playerLyricSettingsLogicProvider),
      activeColor: widget.activeColor,
      reduceMotion: MediaQuery.disableAnimationsOf(context),
    ).copyWith(selectionForegroundBuilder: _buildSelectionForeground);
    if (!useSubtitles) return preset;
    return preset.copyWith(
      activeTextStyle: preset.activeTextStyle.copyWith(
        color: preset.highlight.color,
      ),
      highlight: const LyricHighlight.none(),
      wordEffects: const LyricWordEffects(),
      countdown: const LyricCountdown.none(),
    );
  }

  Widget _buildSelectionForeground(
    BuildContext context,
    LyricSelectionDetails details,
  ) => _PlayerLyricSelectionProgress(details: details, variant: widget.variant);
}

class _PlayerLyricProgressSource implements LyricProgressSource {
  _PlayerLyricProgressSource(this._state, this._enabled, this._stableId)
    : _position = _state.position,
      _sampledAt = SchedulerBinding.instance.currentFrameTimeStamp;

  final StreamController<void> _changes = StreamController<void>.broadcast(
    sync: true,
  );
  PlayerState _state;
  bool _enabled;
  String? _stableId;
  Duration _position;
  Duration _sampledAt;

  @override
  Stream<void> get changes => _changes.stream;

  @override
  bool get isAdvancing =>
      _enabled &&
      _state.isReady &&
      _state.isPlaying &&
      !_state.isBuffering &&
      !_state.isLoading &&
      !_state.hasError;

  @override
  Duration get position {
    final Duration elapsed = isAdvancing
        ? SchedulerBinding.instance.currentFrameTimeStamp - _sampledAt
        : Duration.zero;
    final Duration next =
        _position +
        Duration(microseconds: (elapsed.inMicroseconds * _state.speed).round());
    final Duration? duration = _state.duration;
    return duration != null && next > duration ? duration : next;
  }

  void update(
    PlayerState state, {
    required bool enabled,
    required String? stableId,
  }) {
    if (_state.position == state.position &&
        _state.duration == state.duration &&
        _state.isReady == state.isReady &&
        _state.isPlaying == state.isPlaying &&
        _state.isBuffering == state.isBuffering &&
        _state.isLoading == state.isLoading &&
        _state.hasError == state.hasError &&
        _state.speed == state.speed &&
        _enabled == enabled &&
        _stableId == stableId) {
      return;
    }
    _position =
        _state.position != state.position ||
            _stableId != stableId ||
            _enabled != enabled
        ? state.position
        : position;
    _sampledAt = SchedulerBinding.instance.currentFrameTimeStamp;
    _state = state;
    _enabled = enabled;
    _stableId = stableId;
    _changes.add(null);
  }

  void dispose() => unawaited(_changes.close());
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
  }) : goSetting = false;

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
      child: SingleChildScrollView(
        child: _isDesktop
            ? ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: content,
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                child: content,
              ),
      ),
    );
  }
}

class _PlayerLyricSelectionProgress extends StatelessWidget {
  const _PlayerLyricSelectionProgress({
    required this.details,
    required this.variant,
  });

  final LyricSelectionDetails details;
  final PlayerLyricPanelVariant variant;

  bool get _isDesktop => variant == PlayerLyricPanelVariant.desktop;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color labelColor = colorScheme.onSurfaceVariant;
    final Color labelBackground = colorScheme.surfaceContainerHighest
        .withValues(alpha: 0.52);

    return Stack(
      children: <Widget>[
        Positioned(
          top: details.anchorY,
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
                    ? _buildDesktopSelection(context, labelColor)
                    : _buildMobileSelection(labelColor, labelBackground),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDesktopSelection(BuildContext context, Color labelColor) {
    final Color dividerColor = Theme.of(
      context,
    ).colorScheme.outlineVariant.withValues(alpha: 0.72);

    return <Widget>[
      Positioned(
        left: 0,
        child: Text(
          _formatDuration(details.line.seekPosition),
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
          tooltip: '播放这一句',
          onPressed: details.onTap,
          icon: Icon(Icons.play_arrow_rounded, size: 24, color: labelColor),
        ),
      ),
    ];
  }

  List<Widget> _buildMobileSelection(Color labelColor, Color labelBackground) {
    return <Widget>[
      Positioned(
        right: 0,
        child: GestureDetector(
          onTap: details.onTap,
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
                    _formatDuration(details.line.seekPosition),
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
