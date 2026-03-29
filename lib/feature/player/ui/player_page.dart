import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_main_page.dart';
import 'package:bilimusic/feature/player/ui/components/player_meta_page.dart';
import 'package:bilimusic/feature/player/ui/components/player_shared.dart';
import 'package:bilimusic/feature/player/ui/components/player_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              colorScheme.surface,
              colorScheme.primary.withValues(alpha: 0.08),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
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
                        onMore: item == null
                            ? null
                            : () => playerController.loadFromItem(item),
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
                                availableParts: availableParts,
                                onPartTap:
                                    item == null || availableParts.length < 2
                                    ? null
                                    : () => _showPartSelector(
                                        context: context,
                                        parts: availableParts,
                                        currentItem: item,
                                        controller: playerController,
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
                                onOpenQueue: () => _showQueueSheet(
                                  context: context,
                                  state: state,
                                  controller: playerController,
                                ),
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

  Future<void> _showPartSelector({
    required BuildContext context,
    required List<PlayableItem> parts,
    required PlayableItem currentItem,
    required PlayerController controller,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext context) {
        final ThemeData theme = Theme.of(context);
        final ColorScheme colorScheme = theme.colorScheme;

        return SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemBuilder: (BuildContext context, int index) {
              final PlayableItem part = parts[index];
              final bool isSelected = part == currentItem;
              final String title = part.pageTitle?.trim() ?? '';
              final int page = part.page ?? (index + 1);
              final String label = title.isEmpty ? 'P$page' : 'P$page · $title';

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                tileColor: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.1)
                    : colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.35,
                      ),
                leading: CircleAvatar(
                  backgroundColor: isSelected
                      ? colorScheme.primary
                      : colorScheme.primary.withValues(alpha: 0.12),
                  foregroundColor: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.primary,
                  child: Text('P$page'),
                ),
                title: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_rounded, color: colorScheme.primary)
                    : const Icon(Icons.play_arrow_rounded),
                onTap: () {
                  Navigator.of(context).pop();
                  if (part != currentItem) {
                    controller.replaceCurrentQueueItem(part);
                  }
                },
              );
            },
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemCount: parts.length,
          ),
        );
      },
    );
  }

  Future<void> _showQueueSheet({
    required BuildContext context,
    required PlayerState state,
    required PlayerController controller,
  }) async {
    if (!state.hasQueue) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext context) {
        return SafeArea(
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final PlayerState liveState = ref.watch(playerControllerProvider);
              final PlayerController liveController = ref.read(
                playerControllerProvider.notifier,
              );
              final ThemeData theme = Theme.of(context);
              final ColorScheme colorScheme = theme.colorScheme;
              final String modeLabel = switch (liveState.queueMode) {
                PlayerQueueMode.sequence => '列表循环',
                PlayerQueueMode.singleRepeat => '单曲循环',
                PlayerQueueMode.shuffle => '随机播放',
              };

              return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.72,
                minChildSize: 0.4,
                maxChildSize: 0.92,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                      return Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        '播放队列',
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${liveState.queue.length} 项 · $modeLabel',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: colorScheme.onSurface
                                                  .withValues(alpha: 0.65),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (liveState.hasQueue)
                                  TextButton(
                                    onPressed: () async {
                                      await liveController.clearQueue();
                                      if (!context.mounted) {
                                        return;
                                      }
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('清空'),
                                  ),
                                IconButton.filledTonal(
                                  onPressed: liveState.hasQueue
                                      ? liveController.toggleQueueMode
                                      : null,
                                  icon: Icon(switch (liveState.queueMode) {
                                    PlayerQueueMode.sequence =>
                                      Icons.repeat_rounded,
                                    PlayerQueueMode.singleRepeat =>
                                      Icons.repeat_one_rounded,
                                    PlayerQueueMode.shuffle =>
                                      Icons.shuffle_rounded,
                                  }),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              itemCount: liveState.queue.length,
                              itemBuilder: (BuildContext context, int index) {
                                final PlayableItem queuedItem =
                                    liveState.queue[index];
                                final bool isCurrent =
                                    liveState.currentQueueIndex == index;
                                final String partTitle =
                                    queuedItem.pageTitle?.trim() ?? '';
                                final int page = queuedItem.page ?? 1;
                                final String subtitle = partTitle.isEmpty
                                    ? queuedItem.author
                                    : 'P$page · $partTitle';

                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: index == liveState.queue.length - 1
                                        ? 0
                                        : 10,
                                  ),
                                  child: Material(
                                    color: isCurrent
                                        ? colorScheme.primary.withValues(
                                            alpha: 0.1,
                                          )
                                        : colorScheme.surfaceContainerHighest
                                              .withValues(alpha: 0.45),
                                    borderRadius: BorderRadius.circular(20),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () async {
                                        Navigator.of(context).pop();
                                        await liveController.skipToQueueIndex(
                                          index,
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: isCurrent
                                                  ? colorScheme.primary
                                                  : colorScheme.primary
                                                        .withValues(
                                                          alpha: 0.12,
                                                        ),
                                              foregroundColor: isCurrent
                                                  ? colorScheme.onPrimary
                                                  : colorScheme.primary,
                                              child: Text('${index + 1}'),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    queuedItem.title,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: theme
                                                        .textTheme
                                                        .titleSmall
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w800,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    subtitle,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: colorScheme
                                                              .onSurface
                                                              .withValues(
                                                                alpha: 0.64,
                                                              ),
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (isCurrent)
                                              Icon(
                                                Icons.graphic_eq_rounded,
                                                color: colorScheme.primary,
                                              ),
                                            IconButton(
                                              tooltip: '移出队列',
                                              onPressed: () async {
                                                await liveController
                                                    .removeQueueItemAt(index);
                                                if (!context.mounted) {
                                                  return;
                                                }
                                                final PlayerState
                                                refreshedState = ref.read(
                                                  playerControllerProvider,
                                                );
                                                if (!refreshedState.hasQueue) {
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.close_rounded,
                                              ),
                                            ),
                                          ],
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
                    },
              );
            },
          ),
        );
      },
    );
  }
}
