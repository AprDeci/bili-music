import 'package:bilimusic/feature/comment/domain/comment_target.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_main_page.dart';
import 'package:bilimusic/feature/player/ui/components/player_collection_sheet.dart';
import 'package:bilimusic/feature/player/ui/components/player_meta_page.dart';
import 'package:bilimusic/feature/player/ui/components/player_part_selector.dart';
import 'package:bilimusic/feature/player/ui/components/player_queue_sheet.dart';
import 'package:bilimusic/feature/player/ui/components/player_shared.dart';
import 'package:bilimusic/feature/player/ui/components/player_top_bar.dart';
import 'package:bilimusic/router/player_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    markPlayerPageVisible();
    _pageController = PageController(initialPage: 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialItem();
    });
  }

  @override
  void dispose() {
    markPlayerPageHidden();
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
    final PlayerState state = ref.watch(playerControllerProvider);
    final favoritesState = ref.watch(favoritesControllerProvider);
    final PlayerController playerController = ref.read(
      playerControllerProvider.notifier,
    );
    final PlayableItem? item = state.currentItem ?? widget.initialItem;
    final List<PlayableItem> availableParts = state.availableParts;
    final bool isFavorite = item != null ? favoritesState.isLiked(item) : false;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: DecoratedBox(
        decoration: BoxDecoration(),
        child: Stack(
          children: <Widget>[
            const Positioned(top: -120, left: -90, child: PlayerBackdropOrb()),
            const Positioned(
              right: -70,
              top: 180,
              child: PlayerBackdropOrb(size: 220, opacity: 0.35),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),

                  child: Column(
                    children: <Widget>[
                      PlayerTopBar(
                        currentPage: _currentPage,
                        onBack: () => Navigator.of(context).maybePop(),
                        onOpenInBrowser: item == null
                            ? null
                            : () => _openInBrowser(item),
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (int index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: PlayerMetaPage(state: state, item: item),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: PlayerMainPage(
                                state: state,
                                item: item,
                                commentCount: item?.replyCount,
                                availableParts: availableParts,
                                onPartTap:
                                    item == null || availableParts.length < 2
                                    ? null
                                    : () => showPlayerPartSelector(
                                        context: context,
                                        parts: availableParts,
                                        currentItem: item,
                                        state: state,
                                        controller: playerController,
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
                                onSeek: (double value) {
                                  final int totalMs =
                                      (state.duration ?? Duration.zero)
                                          .inMilliseconds;
                                  final Duration position = Duration(
                                    milliseconds: (totalMs * value).round(),
                                  );
                                  playerController.seek(position);
                                },
                                onToggleQueueMode:
                                    playerController.toggleQueueMode,
                                onBackward: playerController.skipToPrevious,
                                onTogglePlayback:
                                    playerController.togglePlayback,
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
      ),
    );
  }

  Future<void> _toggleFavorite(PlayableItem item) async {
    final bool isLiked = await ref
        .read(favoritesControllerProvider.notifier)
        .toggleLiked(item);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(isLiked ? '已加入“我喜欢”' : '已从“我喜欢”移除')),
      );
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
    await context.push('/comments', extra: target);
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
