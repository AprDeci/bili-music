import 'dart:ui' show ImageFilter;

import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/comment/domain/comment_target.dart';
import 'package:bilimusic/feature/comment/ui/comment_page.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/metadata/ui/components/lyric_offset_sheet.dart';
import 'package:bilimusic/feature/metadata/ui/components/lyric_search_sheet.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_playback_speed.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/player_cover_color_provider.dart';
import 'package:bilimusic/feature/player/logic/player_cover_logic.dart';
import 'package:bilimusic/feature/player/logic/player_cover_settings_logic.dart';
import 'package:bilimusic/feature/player/logic/player_progress_provider.dart';
import 'package:bilimusic/feature/player/logic/utils/player_display_metadata.dart';
import 'package:bilimusic/feature/player/logic/utils/player_progress_ui_helpers.dart';
import 'package:bilimusic/feature/player/logic/utils/player_ui_helpers.dart';
import 'package:bilimusic/feature/player/ui/components/player_artwork.dart';
import 'package:bilimusic/feature/player/ui/components/player_collection_sheet.dart';
import 'package:bilimusic/feature/player/ui/components/player_lyric_panel.dart';
import 'package:bilimusic/feature/player/ui/components/player_part_selector.dart';
import 'package:bilimusic/feature/player/ui/components/player_queue_sheet.dart';
import 'package:bilimusic/feature/player/ui/sleep_timer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

class AppleMusicPlayerPage extends ConsumerStatefulWidget {
  const AppleMusicPlayerPage({super.key, this.initialItem});

  final PlayableItem? initialItem;

  @override
  ConsumerState<AppleMusicPlayerPage> createState() =>
      _AppleMusicPlayerPageState();
}

class _AppleMusicPlayerPageState extends ConsumerState<AppleMusicPlayerPage> {
  bool _showLyrics = false;

  bool _showTranslation = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialItem();
    });
  }

  @override
  void didUpdateWidget(covariant AppleMusicPlayerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialItem != widget.initialItem) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadInitialItem();
      });
    }
  }

  void _loadInitialItem() {
    if (!mounted) {
      return;
    }
    final PlayableItem? item = widget.initialItem;
    if (item == null) {
      return;
    }
    final PlayerState state = ref.read(playerControllerProvider);
    // 同曲加载中也复用队列，避免重播。
    if (state.currentItem?.stableId == item.stableId) {
      return;
    }
    ref
        .read(playerControllerProvider.notifier)
        .setQueue(<PlayableItem>[item], startIndex: 0, sourceLabel: '当前播放');
  }

  @override
  Widget build(BuildContext context) {
    final PlayerState state = ref.watch(
      playerControllerProvider.select(_withoutPlaybackPosition),
    );
    final PlayerController controller = ref.read(
      playerControllerProvider.notifier,
    );
    final PlayableItem? item = state.currentItem ?? widget.initialItem;
    final MetadataState metadataState = ref.watch(metadataControllerProvider);
    final bool isFavorite = item != null
        ? ref.watch(favoritesControllerProvider).isLiked(item)
        : false;
    final Color? coverColor = ref.watch(playerCoverColorControllerProvider);
    final bool defaultUseMetadataCover = ref.watch(
      playerCoverSettingsLogicProvider,
    );
    final bool useMetadataCover =
        ref.watch(playerCoverLogicProvider) ?? defaultUseMetadataCover;
    final String? displayCoverUrl = resolveDisplayCoverUrl(
      item: item,
      metadata: metadataState.stableId == item?.stableId
          ? metadataState.metadata
          : null,
      useMetadataCover: useMetadataCover,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF221F1D),
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: _AppleMusicBackdrop(baseColor: coverColor)),
          SafeArea(
            bottom: false,
            child: _buildMobile(
              context,
              state,
              item,
              controller,
              displayCoverUrl,
              metadataState,
              isFavorite,
              defaultUseMetadataCover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobile(
    BuildContext context,
    PlayerState state,
    PlayableItem? item,
    PlayerController controller,
    String? displayCoverUrl,
    MetadataState metadataState,
    bool isFavorite,
    bool defaultUseMetadataCover,
  ) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double height = constraints.maxHeight;
        final double safeBottom = MediaQuery.paddingOf(context).bottom;
        final double screenWidth = MediaQuery.sizeOf(context).width;

        final Widget header = _AppleMusicDragBar(
          onClose: () => Navigator.of(context).maybePop(),
        );

        if (item == null) {
          return Column(
            children: <Widget>[
              header,
              const Expanded(child: _AppleMusicEmptyState()),
            ],
          );
        }

        // 固定封面尺寸，避免留白挤压控制区。
        final double artworkSize = (screenWidth * 0.89).clamp(
          120.0,
          (height * 0.52).clamp(120.0, 420.0),
        );
        final double artworkTopGap = height < 640 ? 8 : 12;
        const double artworkToInfoGap = 44;

        final Widget artwork = SizedBox(
          width: artworkSize,
          height: artworkSize,
          child: _AppleMusicArtwork(coverUrl: displayCoverUrl),
        );

        final Widget lyricArea = SizedBox(
          height: artworkSize,
          width: double.infinity,
          child: _AppleMusicLyricView(
            state: state,
            item: item,
            onSeek: controller.seek,
            showTranslation: _showTranslation,
          ),
        );

        final Widget artworkArea = Padding(
          padding: EdgeInsets.only(top: artworkTopGap),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            switchInCurve: Curves.easeOutCubic,
            child: _showLyrics
                ? KeyedSubtree(
                    key: const ValueKey<String>('apple-lyrics'),
                    child: lyricArea,
                  )
                : KeyedSubtree(
                    key: const ValueKey<String>('apple-artwork'),
                    child: artwork,
                  ),
          ),
        );

        final Widget controls = Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: artworkToInfoGap),
            _AppleMusicInfo(
              item: item,
              state: state,
              isFavorite: isFavorite,
              onFavoriteToggle: () => _toggleFavorite(item),
              onOpenMenu: () => _showMoreMenu(item),
              onToggleCover:
                  hasSwitchableCover(
                    item: item,
                    metadata: metadataState.stableId == item.stableId
                        ? metadataState.metadata
                        : null,
                  )
                  ? () => ref
                        .read(playerCoverLogicProvider.notifier)
                        .toggle(
                          defaultUseMetadataCover: defaultUseMetadataCover,
                        )
                  : null,
            ),
            const SizedBox(height: 10),
            _AppleMusicProgress(state: state),
            _AppleMusicStatus(state: state),
            const SizedBox(height: 44),
            _AppleMusicTransport(
              state: state,
              onPrevious: controller.skipToPrevious,
              onTogglePlayback: controller.togglePlayback,
              onNext: controller.skipToNext,
            ),
            const SizedBox(height: 40),
            _AppleMusicVolume(
              volume: state.volume,
              onVolumeChanged: controller.setVolume,
              onToggleMute: controller.toggleMute,
            ),
            const SizedBox(height: 16),
            _AppleMusicBottomBar(
              onLyrics: () => setState(() => _showLyrics = !_showLyrics),
              lyricsActive: _showLyrics,
              onQueue: state.hasQueue
                  ? () => showPlayerQueueSheet(context: context, state: state)
                  : null,
              onMore: () => _showMoreMenu(item),
            ),
            SizedBox(height: safeBottom > 0 ? 4 : 12),
          ],
        );

        return Column(
          children: <Widget>[
            header,
            artworkArea,
            Expanded(child: SingleChildScrollView(child: controls)),
          ],
        );
      },
    );
  }

  Future<void> _toggleFavorite(PlayableItem item) async {
    final bool isLiked = await ref
        .read(favoritesControllerProvider.notifier)
        .toggleLiked(item);
    if (!mounted) {
      return;
    }
    ToastUtil.show(isLiked ? '已加入“我喜欢”' : '已从“我喜欢”移除');
  }

  Future<void> _openComments(PlayableItem item) async {
    if (item.aid <= 0) {
      return;
    }
    final CommentTarget target = CommentTarget.video(
      aid: item.aid,
      bvid: item.bvid,
      title: item.title,
      coverUrl: item.coverUrl,
    );
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => CommentPage(target: target),
      ),
    );
  }

  Future<void> _openExternally(PlayableItem item) async {
    if (item.aid <= 0) {
      return;
    }
    try {
      await launchUrl(Uri.parse('bilibili://video/${item.bvid}'));
    } catch (_) {
      await launchUrl(Uri.parse('https://www.bilibili.com/video/${item.bvid}'));
    }
  }

  Future<void> _showMoreMenu(PlayableItem item) async {
    final PlayerState state = ref.read(playerControllerProvider);
    final MetadataState metadataState = ref.read(metadataControllerProvider);
    final List<AudioQualityOption> qualities =
        state.audioStream?.availableQualities ?? const <AudioQualityOption>[];
    final bool canPickPart = state.availableParts.length > 1;
    final String? translationLyrics = resolveDisplayTranslationLyrics(
      metadataState.stableId == item.stableId ? metadataState.metadata : null,
    );

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFF2B2724),
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _MenuTile(
                  icon: Icons.timer_outlined,
                  title: '定时关闭',
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(this.context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SleepTimerPage(),
                      ),
                    );
                  },
                ),
                _MenuTile(
                  icon: Icons.speed_rounded,
                  title: '倍速播放',
                  subtitle: formatPlaybackSpeed(state.speed),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showPlaybackSpeedSheet();
                  },
                ),
                if (qualities.isNotEmpty)
                  _MenuTile(
                    icon: Icons.graphic_eq_rounded,
                    title: '音质',
                    subtitle: _qualityLabel(qualities),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showQualitySheet(qualities);
                    },
                  ),
                if (canPickPart)
                  _MenuTile(
                    icon: Icons.playlist_play_rounded,
                    title: '选择分 P',
                    subtitle: '共 ${state.availableParts.length} 个分 P',
                    onTap: () {
                      Navigator.of(context).pop();
                      showPlayerPartSelector(
                        context: context,
                        parts: state.availableParts,
                        currentItem: item,
                        state: state,
                        controller: ref.read(playerControllerProvider.notifier),
                      );
                    },
                  ),
                _MenuTile(
                  icon: Icons.library_music_outlined,
                  title: '收藏到歌单',
                  onTap: () {
                    Navigator.of(context).pop();
                    showPlayerCollectionSheet(context: context, item: item);
                  },
                ),
                if (item.aid > 0)
                  _MenuTile(
                    icon: Icons.comment_outlined,
                    title: '查看评论',
                    onTap: () {
                      Navigator.of(context).pop();
                      _openComments(item);
                    },
                  ),
                _MenuTile(
                  icon: Icons.search_rounded,
                  title: '手动匹配歌词',
                  onTap: () {
                    Navigator.of(context).pop();
                    showManualLyricSearchSheet(
                      context: context,
                      initialKeyword: resolveLyricSearchKeyword(
                        metadataState: metadataState,
                        item: item,
                      ),
                    );
                  },
                ),
                _MenuTile(
                  icon: Icons.hourglass_empty_rounded,
                  title: '歌词偏移',
                  onTap: () {
                    Navigator.of(context).pop();
                    showLyricOffsetSheet(context);
                  },
                ),
                if (translationLyrics?.trim().isNotEmpty == true)
                  _MenuTile(
                    key: const Key('appleMusicTranslationToggle'),
                    icon: _showTranslation
                        ? Icons.translate_rounded
                        : Icons.translate_outlined,
                    title: '译文',
                    subtitle: _showTranslation ? '已显示 · 点击关闭' : '已关闭 · 点击显示',
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _showTranslation = !_showTranslation;
                        _showLyrics = true;
                      });
                    },
                  ),
                if (item.aid > 0)
                  _MenuTile(
                    icon: Icons.open_in_new_rounded,
                    title: '外部应用打开',
                    onTap: () {
                      Navigator.of(context).pop();
                      _openExternally(item);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _qualityLabel(List<AudioQualityOption> qualities) {
    for (final AudioQualityOption option in qualities) {
      if (option.isSelected) {
        return option.label;
      }
    }
    return qualities.first.label;
  }

  Future<void> _showQualitySheet(List<AudioQualityOption> qualities) async {
    const Color surface = Color(0xFF2B2724);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: surface,
      builder: (BuildContext context) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: qualities.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (BuildContext context, int index) {
              final AudioQualityOption option = qualities[index];
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                tileColor: option.isSelected
                    ? Colors.white.withValues(alpha: 0.12)
                    : null,
                title: Text(
                  option.label,
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: option.isSelected
                    ? const Icon(Icons.check_rounded, color: Colors.white)
                    : null,
                onTap: () {
                  Navigator.of(context).pop();
                  ref
                      .read(playerControllerProvider.notifier)
                      .switchCurrentAudioQuality(option.qualityId);
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showPlaybackSpeedSheet() async {
    final double currentSpeed = ref.read(playerControllerProvider).speed;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFF2B2724),
      builder: (BuildContext context) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: kPlayerPlaybackSpeeds.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (BuildContext context, int index) {
              final double speed = kPlayerPlaybackSpeeds[index];
              final bool isSelected = speed == currentSpeed;
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                tileColor: isSelected
                    ? Colors.white.withValues(alpha: 0.12)
                    : null,
                title: Text(
                  formatPlaybackSpeed(speed),
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_rounded, color: Colors.white)
                    : null,
                onTap: () {
                  Navigator.of(context).pop();
                  ref.read(playerControllerProvider.notifier).setSpeed(speed);
                },
              );
            },
          ),
        );
      },
    );
  }
}

PlayerState _withoutPlaybackPosition(PlayerState state) {
  if (state.position == Duration.zero) {
    return state;
  }
  return state.copyWith(position: Duration.zero);
}

class _AppleMusicBackdrop extends StatelessWidget {
  const _AppleMusicBackdrop({required this.baseColor});

  final Color? baseColor;

  @override
  Widget build(BuildContext context) {
    final Color seed = baseColor ?? const Color(0xFF7A6255);
    final HSLColor hsl = HSLColor.fromColor(seed);
    // 背景向中性灰收敛，保留少量封面色。
    const Color neutral = Color(0xFF464443);
    Color tone(double saturation, double lightness, {double gray = 0}) {
      final Color tinted = hsl
          .withSaturation(saturation.clamp(0.0, 1.0))
          .withLightness(lightness.clamp(0.0, 1.0))
          .toColor();
      if (gray <= 0) {
        return tinted;
      }
      return Color.lerp(tinted, neutral, gray) ?? tinted;
    }

    final Color top = tone(0.22, 0.31, gray: 0.22);
    final Color middle = tone(0.12, 0.276, gray: 0.42);
    final Color bottom = tone(0.06, 0.267, gray: 0.80);
    final Color glow = tone(0.30, 0.44);

    return IgnorePointer(
      child: RepaintBoundary(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[top, middle, bottom],
                  stops: const <double>[0.0, 0.62, 1.0],
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, -0.62),
              child: FractionallySizedBox(
                widthFactor: 1.1,
                heightFactor: 0.7,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: <Color>[
                          glow.withValues(alpha: 0.26),
                          glow.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppleMusicDragBar extends StatelessWidget {
  const _AppleMusicDragBar({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Center(
        child: Tooltip(
          message: '收起播放页',
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onClose,
            child: Semantics(
              button: true,
              label: '收起播放页',
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppleMusicArtwork extends StatelessWidget {
  const _AppleMusicArtwork({required this.coverUrl});

  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '专辑封面',
      image: true,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: CommonCachedImage(
          imageUrl: coverUrl,
          fit: BoxFit.cover,
          placeholder: const PlayerArtworkFallback(),
          errorWidget: const PlayerArtworkFallback(),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class _AppleMusicInfo extends StatelessWidget {
  const _AppleMusicInfo({
    required this.item,
    required this.state,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onOpenMenu,
    this.onToggleCover,
  });

  final PlayableItem item;
  final PlayerState state;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onOpenMenu;
  final VoidCallback? onToggleCover;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 14, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onDoubleTap: onToggleCover,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    buildPlayerSubtitle(item.author, state),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.66),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _CircleIconButton(
            key: const Key('appleMusicFavoriteButton'),
            iconWidget: HugeIcon(
              icon: HugeIcons.strokeRoundedStar,
              size: 22,
              color: isFavorite
                  ? const Color(0xFFFFD166)
                  : Colors.white.withValues(alpha: 0.92),
            ),
            tooltip: isFavorite ? '已收藏' : '收藏',
            size: 38,
            onPressed: onFavoriteToggle,
          ),
          const SizedBox(width: 10),
          _CircleIconButton(
            key: const Key('appleMusicMoreButton'),
            iconWidget: HugeIcon(
              icon: HugeIcons.strokeRoundedMoreHorizontal,
              size: 24,
              color: Colors.white.withValues(alpha: 0.92),
            ),
            tooltip: '更多',
            size: 38,
            onPressed: onOpenMenu,
          ),
        ],
      ),
    );
  }
}

class _AppleMusicLyricView extends StatelessWidget {
  const _AppleMusicLyricView({
    required this.state,
    required this.item,
    required this.onSeek,
    this.showTranslation = true,
  });

  final PlayerState state;
  final PlayableItem item;
  final ValueChanged<Duration> onSeek;
  final bool showTranslation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: _ProgressLyricPanel(
        baseState: state,
        item: item,
        variant: PlayerLyricPanelVariant.mobile,
        isActive: true,
        activeColor: Colors.white,
        onSeek: onSeek,
        showTranslation: showTranslation,
      ),
    );
  }
}

class _AppleMusicProgress extends ConsumerStatefulWidget {
  const _AppleMusicProgress({required this.state});

  final PlayerState state;

  @override
  ConsumerState<_AppleMusicProgress> createState() =>
      _AppleMusicProgressState();
}

class _AppleMusicProgressState extends ConsumerState<_AppleMusicProgress> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final PlayerProgressSnapshot progress = resolvePlayerProgressSnapshot(
      ref.watch(playerProgressProvider),
      widget.state,
    );
    final Duration total =
        progress.duration ??
        widget.state.duration ??
        widget.state.audioStream?.duration ??
        Duration.zero;
    final double ratio = total.inMilliseconds <= 0
        ? 0
        : (progress.position.inMilliseconds / total.inMilliseconds).clamp(
            0.0,
            1.0,
          );
    final double value = (_dragValue ?? ratio).clamp(0.0, 1.0);
    final Duration shownPosition = Duration(
      milliseconds: (total.inMilliseconds * value).round(),
    );
    final Duration remaining = total - shownPosition;
    final bool enabled = progress.isReady && total > Duration.zero;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                activeTrackColor: Colors.white.withValues(alpha: 0.9),
                inactiveTrackColor: Colors.white.withValues(alpha: 0.22),
                thumbColor: Colors.transparent,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                overlayColor: Colors.white.withValues(alpha: 0.1),
                trackShape: const RoundedRectSliderTrackShape(),
              ),
              child: Slider(
                value: value,
                onChangeStart: enabled
                    ? (double v) => setState(() => _dragValue = v)
                    : null,
                onChanged: enabled
                    ? (double v) => setState(() => _dragValue = v)
                    : null,
                onChangeEnd: enabled
                    ? (double v) {
                        setState(() => _dragValue = null);
                        ref
                            .read(playerControllerProvider.notifier)
                            .seekFromProgressBar(
                              Duration(
                                milliseconds: (total.inMilliseconds * v)
                                    .round(),
                              ),
                            );
                      }
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              children: <Widget>[
                Text(
                  formatPlayerDuration(shownPosition),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  remaining.inMilliseconds <= 0
                      ? '--:--'
                      : '-${formatPlayerDuration(remaining)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
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

class _AppleMusicTransport extends StatelessWidget {
  const _AppleMusicTransport({
    required this.state,
    required this.onPrevious,
    required this.onTogglePlayback,
    required this.onNext,
  });

  final PlayerState state;
  final VoidCallback onPrevious;
  final VoidCallback onTogglePlayback;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bool canTogglePlayback = state.hasQueue && !state.isLoading;
    final bool canGoPrevious = state.isReady && state.hasPrevious;
    final bool canGoNext =
        state.isReady &&
        (state.queueMode == PlayerQueueMode.singleRepeat || state.hasNext);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _PlainIconButton(
            icon: Icons.fast_rewind_rounded,
            tooltip: '上一首',
            iconSize: 38,
            onPressed: canGoPrevious ? onPrevious : null,
          ),
          _AppleMusicPlayButton(
            isPlaying: state.isPlaying,
            isLoading: state.isLoading,
            onPressed: canTogglePlayback ? onTogglePlayback : null,
          ),
          _PlainIconButton(
            icon: Icons.fast_forward_rounded,
            tooltip: '下一首',
            iconSize: 38,
            onPressed: canGoNext ? onNext : null,
          ),
        ],
      ),
    );
  }
}

class _AppleMusicPlayButton extends StatelessWidget {
  const _AppleMusicPlayButton({
    required this.isPlaying,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isPlaying;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final Color color = onPressed == null
        ? Colors.white.withValues(alpha: 0.35)
        : Colors.white;
    return Semantics(
      button: true,
      label: isPlaying ? '暂停' : '播放',
      child: InkResponse(
        key: const Key('appleMusicPlayPause'),
        onTap: onPressed,
        radius: 36,
        child: SizedBox(
          width: 64,
          height: 64,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      color: color,
                    ),
                  )
                : Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 56,
                    color: color,
                  ),
          ),
        ),
      ),
    );
  }
}

class _AppleMusicVolume extends StatefulWidget {
  const _AppleMusicVolume({
    required this.volume,
    required this.onVolumeChanged,
    required this.onToggleMute,
  });

  final double volume;
  final ValueChanged<double> onVolumeChanged;
  final Future<double> Function() onToggleMute;

  @override
  State<_AppleMusicVolume> createState() => _AppleMusicVolumeState();
}

class _AppleMusicVolumeState extends State<_AppleMusicVolume> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final double value = (_dragValue ?? widget.volume).clamp(0.0, 1.0);
    final bool muted = value <= 0;
    final bool dragging = _dragValue != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: <Widget>[
          _PlainIconButton(
            iconWidget: HugeIcon(
              icon: muted
                  ? HugeIcons.strokeRoundedVolumeMute02
                  : HugeIcons.strokeRoundedVolumeLow,
              size: 20,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            tooltip: muted ? '取消静音' : '静音',
            iconSize: 20,
            onPressed: () => widget.onToggleMute(),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                activeTrackColor: Colors.white.withValues(alpha: 0.85),
                inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                thumbColor: dragging ? Colors.white : Colors.transparent,
                // 仅拖动时显示滑块，并去掉默认阴影。
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: dragging ? 5 : 0,
                  elevation: 0,
                  pressedElevation: 0,
                ),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                overlayColor: Colors.white.withValues(alpha: 0.1),
                trackShape: const RoundedRectSliderTrackShape(),
              ),
              child: Slider(
                value: value,
                onChanged: (double v) => setState(() => _dragValue = v),
                onChangeEnd: (double v) {
                  setState(() => _dragValue = null);
                  widget.onVolumeChanged(v);
                },
              ),
            ),
          ),
          _PlainIconButton(
            iconWidget: HugeIcon(
              icon: HugeIcons.strokeRoundedVolumeHigh,
              size: 20,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            tooltip: '音量',
            iconSize: 20,
            onPressed: () => widget.onVolumeChanged(1),
          ),
        ],
      ),
    );
  }
}

class _AppleMusicBottomBar extends StatelessWidget {
  const _AppleMusicBottomBar({
    this.onLyrics,
    this.lyricsActive = false,
    required this.onQueue,
    required this.onMore,
  });

  final VoidCallback? onLyrics;
  final bool lyricsActive;
  final VoidCallback? onQueue;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final Color base = Colors.white.withValues(alpha: 0.9);
    final Color active = Colors.white;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 6, 28, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          if (onLyrics != null)
            _PlainIconButton(
              key: const Key('appleMusicLyricsToggle'),
              iconWidget: HugeIcon(
                icon: HugeIcons.strokeRoundedQuoteDown,
                size: 22,
                color: lyricsActive ? active : base,
              ),
              tooltip: lyricsActive ? '显示封面' : '显示歌词',
              iconSize: 22,
              onPressed: onLyrics,
            )
          else
            const SizedBox(width: 22),
          _PlainIconButton(
            iconWidget: HugeIcon(
              icon: HugeIcons.strokeRoundedQueue01,
              size: 22,
              color: base,
            ),
            tooltip: '播放队列',
            iconSize: 22,
            onPressed: onQueue,
          ),
          _PlainIconButton(
            iconWidget: HugeIcon(
              icon: HugeIcons.strokeRoundedMore01,
              size: 22,
              color: base,
            ),
            tooltip: '更多',
            iconSize: 22,
            onPressed: onMore,
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    super.key,
    required this.iconWidget,
    required this.tooltip,
    required this.onPressed,
    this.size = 40,
  });

  final Widget iconWidget;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.12),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(child: iconWidget),
          ),
        ),
      ),
    );
  }
}

class _PlainIconButton extends StatelessWidget {
  const _PlainIconButton({
    super.key,
    this.icon,
    this.iconWidget,
    required this.tooltip,
    required this.onPressed,
    this.iconSize = 24,
  }) : assert(icon != null || iconWidget != null);

  final IconData? icon;
  final Widget? iconWidget;
  final String tooltip;
  final VoidCallback? onPressed;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final Color color = onPressed == null
        ? Colors.white.withValues(alpha: 0.3)
        : Colors.white.withValues(alpha: 0.92);
    final Widget glyph = iconWidget ?? Icon(icon, size: iconSize, color: color);
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onPressed,
        radius: 26,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Opacity(opacity: onPressed == null ? 0.55 : 1.0, child: glyph),
        ),
      ),
    );
  }
}

class _AppleMusicStatus extends StatelessWidget {
  const _AppleMusicStatus({required this.state});

  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    final String? label = switch (state.statusHint) {
      PlayerStatusHint.resolvingAudio => '正在解析音频...',
      PlayerStatusHint.connectingStream => '正在连接播放流...',
      PlayerStatusHint.loadingCache => '正在加载缓存音频...',
      PlayerStatusHint.buffering => '缓冲中...',
      PlayerStatusHint.error => state.errorMessage ?? '播放失败，请稍后重试',
      null => null,
    };
    if (label == null) {
      return const SizedBox.shrink();
    }
    final bool isError = state.hasError;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isError
              ? const Color(0xFFFFB4A8)
              : Colors.white.withValues(alpha: 0.7),
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AppleMusicEmptyState extends StatelessWidget {
  const _AppleMusicEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.music_note_rounded,
              size: 72,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 20),
            const Text(
              '还没有选择播放内容',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '从搜索或收藏中选一首歌，封面、歌词与控制会显示在这里。',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.62),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white.withValues(alpha: 0.85)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
      onTap: onTap,
    );
  }
}

class _ProgressLyricPanel extends ConsumerWidget {
  const _ProgressLyricPanel({
    required this.baseState,
    required this.item,
    required this.variant,
    required this.isActive,
    required this.onSeek,
    this.activeColor,
    this.showTranslation = true,
  });

  final PlayerState baseState;
  final PlayableItem item;
  final PlayerLyricPanelVariant variant;
  final bool isActive;
  final ValueChanged<Duration> onSeek;
  final Color? activeColor;
  final bool showTranslation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlayerProgressSnapshot progress = resolvePlayerProgressSnapshot(
      ref.watch(playerProgressProvider),
      baseState,
    );
    return PlayerLyricPanel(
      state: baseState.copyWith(
        position: progress.position,
        duration: progress.duration,
      ),
      item: item,
      isActive: isActive,
      onSeek: onSeek,
      activeColor: activeColor,
      variant: variant,
      showTranslation: showTranslation,
    );
  }
}
