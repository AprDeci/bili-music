import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/comment/domain/comment_target.dart';
import 'package:bilimusic/feature/comment/ui/comment_page.dart';
import 'package:bilimusic/feature/download/domain/download_task.dart';
import 'package:bilimusic/feature/download/logic/download_controller.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_playback_speed.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/domain/playback_chapter.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_provider.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_source_logic.dart';
import 'package:bilimusic/feature/player/logic/display/player_cover_color_provider.dart';
import 'package:bilimusic/feature/player/ui/components/player_dynamic_backdrop.dart';
import 'package:bilimusic/feature/player/ui/components/player_landscape_page.dart';
import 'package:bilimusic/feature/player/ui/lyrics/player_lyric_page.dart';
import 'package:bilimusic/feature/player/ui/components/player_main_page.dart';
import 'package:bilimusic/feature/player/ui/components/player_chapter_selector.dart';
import 'package:bilimusic/feature/player/ui/components/player_collection_sheet.dart';
import 'package:bilimusic/feature/player/ui/components/player_meta_page.dart';
import 'package:bilimusic/feature/player/ui/components/player_part_selector.dart';
import 'package:bilimusic/feature/player/ui/components/player_queue_sheet.dart';
import 'package:bilimusic/feature/player/ui/components/player_top_bar.dart';
import 'package:bilimusic/feature/player/ui/sleep_timer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class PlayerPage extends ConsumerStatefulWidget {
  const PlayerPage({super.key, this.initialItem});

  final PlayableItem? initialItem;

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage> {
  late final PageController _pageController;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialItem();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PlayerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialItem != widget.initialItem) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadInitialItem();
      });
    }
  }

  void _loadInitialItem() {
    final PlayableItem? item = widget.initialItem;
    if (item == null) {
      return;
    }
    final PlayerController controller = ref.read(
      playerControllerProvider.notifier,
    );
    final PlayerState state = ref.read(playerControllerProvider);
    if (state.currentItem?.stableId == item.stableId && state.isReady) {
      return;
    }
    controller.setQueue(
      <PlayableItem>[item],
      startIndex: 0,
      sourceLabel: '当前播放',
    );
  }

  @override
  Widget build(BuildContext context) {
    final PlayerState state = ref.watch(
      playerControllerProvider.select(_withoutPlaybackPosition),
    );
    final PlayerDisplayInfo display = ref.watch(playerDisplayProvider);
    final favoritesState = ref.watch(favoritesControllerProvider);
    final PlayerController playerController = ref.read(
      playerControllerProvider.notifier,
    );
    final PlayableItem? item = state.currentItem ?? widget.initialItem;
    final List<PlayableItem> availableParts = state.availableParts;
    final List<PlaybackChapter> chapters = state.chapters;
    final bool canOpenJumpPanel =
        item != null && (availableParts.length > 1 || chapters.length > 1);
    final bool isFavorite = item != null ? favoritesState.isLiked(item) : false;
    final bool isLyricPageActive = _currentPage == 2;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color? coverColor = ref.watch(playerCoverColorControllerProvider);

    if (MediaQuery.orientationOf(context) == Orientation.landscape) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: PlayerDynamicBackdrop(baseColor: coverColor),
            ),
            SafeArea(
              child: PlayerLandscapePage(
                state: state,
                item: item,
                display: display,
                activeColor: coverColor,
                isFavorite: isFavorite,
                onFavoriteToggle: item == null
                    ? null
                    : () => _toggleFavorite(item),
                onSeek: _seekFromProgressBar,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: PlayerDynamicBackdrop(baseColor: coverColor)),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),

                child: Column(
                  children: <Widget>[
                    PlayerTopBar(
                      currentPage: _currentPage,
                      onBack: () => Navigator.of(context).maybePop(),
                      onOpenMenu: item == null
                          ? null
                          : () => _showPlayerMenu(item),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: PageView(
                        key: const PageStorageKey<String>('playerPages'),
                        controller: _pageController,
                        onPageChanged: (int index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: PlayerMetaPage(state: state, item: item),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: PlayerMainPage(
                              state: state,
                              item: item,
                              display: display,
                              commentCount: item?.replyCount,
                              canOpenJumpPanel: canOpenJumpPanel,
                              onPartTap: !canOpenJumpPanel
                                  ? null
                                  : () => _openJumpPanel(
                                      context,
                                      state,
                                      item,
                                      availableParts,
                                      playerController,
                                    ),
                              onOpenCollectionSheet: item == null
                                  ? null
                                  : () => showPlayerCollectionSheet(
                                      context: context,
                                      item: item,
                                    ),
                              isFavorite: isFavorite,
                              onFavoriteToggle: item == null
                                  ? null
                                  : () => _toggleFavorite(item),
                              onToggleSource: _toggleDisplaySource,
                              onSeek: _seekFromProgressBar,
                              onToggleQueueMode:
                                  playerController.toggleQueueMode,
                              onBackward: playerController.skipToPrevious,
                              onTogglePlayback: playerController.togglePlayback,
                              onForward: playerController.skipToNext,
                              onOpenQueue: () => showPlayerQueueSheet(
                                context: context,
                                state: state,
                              ),
                              onOpenComments: item == null
                                  ? null
                                  : () => _openComments(item),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: PlayerLyricPage(
                              state: state,
                              item: item,
                              isActive: isLyricPageActive,
                              onSeek: playerController.seek,
                              activeColor: coverColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleDisplaySource() {
    HapticFeedback.lightImpact();
    ref.read(playerDisplaySourceLogicProvider.notifier).toggle();
  }

  Future<void> _openJumpPanel(
    BuildContext context,
    PlayerState state,
    PlayableItem item,
    List<PlayableItem> availableParts,
    PlayerController controller,
  ) async {
    if (availableParts.length > 1) {
      await showPlayerPartSelector(
        context: context,
        parts: availableParts,
        currentItem: item,
        state: state,
        controller: controller,
        onDownloadAll: () => _downloadAllParts(availableParts),
      );
      return;
    }
    final PlayerState liveState = ref.read(playerControllerProvider);
    if (liveState.chapters.length < 2) {
      return;
    }
    await showPlayerChapterSelector(
      context: context,
      chapters: liveState.chapters,
      position: liveState.position,
      isPlaying: liveState.isPlaying,
      onSeek: controller.seek,
    );
  }

  Future<void> _downloadAllParts(List<PlayableItem> parts) async {
    try {
      final int queued = await ref
          .read(downloadControllerProvider.notifier)
          .downloadAll(parts);
      if (mounted) {
        ToastUtil.show(queued > 0 ? '已加入 $queued 首下载队列' : '这些分P已下载或正在下载');
      }
    } on Object {
      if (mounted) {
        ToastUtil.show('加入下载队列失败，请重试');
      }
    }
  }

  void _seekFromProgressBar(double value) {
    final Duration duration =
        ref.read(playerControllerProvider).duration ?? Duration.zero;
    ref
        .read(playerControllerProvider.notifier)
        .seekFromProgressBar(
          Duration(milliseconds: (duration.inMilliseconds * value).round()),
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
    // 适用navigator进入 不用gorouter 使评论区压在播放器上
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CommentPage(target: target)),
    );
  }

  Future<void> _showPlayerMenu(PlayableItem item) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                ListTile(
                  key: const Key('sleepTimerMenuEntry'),
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text('定时关闭'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(this.context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SleepTimerPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  key: const Key('playbackSpeedMenuEntry'),
                  leading: const Icon(Icons.speed_rounded),
                  title: const Text('倍速播放'),
                  trailing: Text(
                    formatPlaybackSpeed(
                      ref.read(playerControllerProvider).speed,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showPlaybackSpeedSheet();
                  },
                ),
                const _PlayerVolumeTile(),
                _PlayerDownloadTile(
                  item: item,
                  onDone: () => Navigator.of(context).pop(),
                ),
                ListTile(
                  leading: const Icon(Icons.open_in_new_rounded),
                  title: const Text('外部应用打开'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openInBrowser(item);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPlaybackSpeedSheet() async {
    final ThemeData theme = Theme.of(context);
    final double currentSpeed = ref.read(playerControllerProvider).speed;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
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
                tileColor: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : null,
                title: Text(formatPlaybackSpeed(speed)),
                trailing: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        color: theme.colorScheme.primary,
                      )
                    : null,
                onTap: () async {
                  Navigator.of(context).pop();
                  await ref
                      .read(playerControllerProvider.notifier)
                      .setSpeed(speed);
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

class _PlayerVolumeTile extends ConsumerWidget {
  const _PlayerVolumeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double volume = ref.watch(
      playerControllerProvider.select((state) => state.volume),
    );
    return ListTile(
      leading: Icon(
        volume == 0 ? Icons.volume_off_rounded : Icons.volume_up_rounded,
      ),
      title: Row(
        children: <Widget>[
          const Text('应用内音量'),
          const SizedBox(width: 8),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                trackShape: const RoundedRectSliderTrackShape(),
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 6,
                  elevation: 0,
                ),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Semantics(
                label: '应用内音量',
                child: Slider(
                  key: const Key('playerVolumeSlider'),
                  value: volume,
                  semanticFormatterCallback: (double value) =>
                      '${(value * 100).round()}%',
                  onChanged: (double value) async {
                    try {
                      await ref
                          .read(playerControllerProvider.notifier)
                          .setVolume(value);
                    } on Object {
                      if (context.mounted) {
                        ToastUtil.show('音量设置失败，请重试');
                      }
                    }
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              '${(volume * 100).round()}',
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerDownloadTile extends ConsumerWidget {
  const _PlayerDownloadTile({required this.item, required this.onDone});

  final PlayableItem item;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DownloadState state = ref.watch(downloadControllerProvider);
    final bool downloaded = state.contains(item.contentId);
    final DownloadTask? task = state.taskFor(item.contentId);
    final String? subtitle = downloaded
        ? '已下载，可离线播放'
        : switch (task?.status) {
            DownloadTaskStatus.queued => '等待下载',
            DownloadTaskStatus.running =>
              task?.progress == null
                  ? '下载中'
                  : '下载中 ${(task!.progress! * 100).toStringAsFixed(0)}%',
            DownloadTaskStatus.failed => '下载失败，点按重试',
            null => null,
          };

    return ListTile(
      key: const Key('downloadMenuEntry'),
      leading: Icon(
        downloaded ? Icons.download_done_rounded : Icons.download_rounded,
      ),
      title: const Text('下载'),
      subtitle: subtitle == null ? null : Text(subtitle),
      onTap: () async {
        if (downloaded) {
          ToastUtil.show('已经下载过了');
          return;
        }
        if (task?.isActive ?? false) {
          ToastUtil.show('正在下载中');
          return;
        }
        onDone();
        try {
          final bool queued = await ref
              .read(downloadControllerProvider.notifier)
              .download(item);
          ToastUtil.show(queued ? '已加入下载队列' : '下载未开始');
        } on Object {
          ToastUtil.show('加入下载队列失败，请重试');
        }
      },
    );
  }
}

Future<void> _openInBrowser(PlayableItem item) async {
  if (item.aid <= 0) {
    return;
  }
  try {
    await launchUrl(Uri.parse('bilibili://video/${item.bvid}'));
  } catch (e) {
    await launchUrl(Uri.parse('https://www.bilibili.com/video/${item.bvid}'));
  }
}
