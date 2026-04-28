import 'package:bilimusic/common/components/desktop/desktop_side_panel.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

Future<void> showPlayerQueueSheet({
  required BuildContext context,
  required PlayerState state,
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
      return const SafeArea(child: _PlayerQueueSheet());
    },
  );
}

Future<void> showDesktopPlayerQueuePanel({
  required BuildContext context,
  required PlayerState state,
}) async {
  if (!state.hasQueue) {
    return;
  }

  await showDesktopSidePanel(
    context: context,
    width: 420,
    builder: (BuildContext context) {
      return const SafeArea(
        child: _PlayerQueueContent(closeTarget: _QueueCloseTarget.sidePanel),
      );
    },
  );
}

enum _QueueCloseTarget { navigator, sidePanel }

class _PlayerQueueSheet extends ConsumerWidget {
  const _PlayerQueueSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (BuildContext context, ScrollController scrollController) {
        return _PlayerQueueContent(
          closeTarget: _QueueCloseTarget.navigator,
          scrollController: scrollController,
        );
      },
    );
  }
}

class _PlayerQueueContent extends ConsumerWidget {
  const _PlayerQueueContent({required this.closeTarget, this.scrollController});

  final _QueueCloseTarget closeTarget;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '播放队列',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${liveState.queue.length} 项 · $modeLabel',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
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
                    await _close(context);
                  },
                  child: const Text('清空'),
                ),
              IconButton.filledTonal(
                onPressed: liveState.hasQueue
                    ? liveController.toggleQueueMode
                    : null,
                icon: Icon(switch (liveState.queueMode) {
                  PlayerQueueMode.sequence => Icons.repeat_rounded,
                  PlayerQueueMode.singleRepeat => Icons.repeat_one_rounded,
                  PlayerQueueMode.shuffle => Icons.shuffle_rounded,
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
              final PlayableItem queuedItem = liveState.queue[index];
              final bool isCurrent = liveState.currentQueueIndex == index;
              final String partTitle = queuedItem.pageTitle?.trim() ?? '';
              final int page = queuedItem.page ?? 1;
              final String subtitle = partTitle.isEmpty
                  ? queuedItem.author
                  : 'P$page · $partTitle';

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == liveState.queue.length - 1 ? 0 : 10,
                ),
                child: Material(
                  color: isCurrent
                      ? colorScheme.primary.withValues(alpha: 0.1)
                      : colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.45,
                        ),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      await _close(context);
                      await liveController.skipToQueueIndex(index);
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
                                : colorScheme.primary.withValues(alpha: 0.12),
                            foregroundColor: isCurrent
                                ? colorScheme.onPrimary
                                : colorScheme.primary,
                            child: Text('${index + 1}'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  queuedItem.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withValues(
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
                              await liveController.removeQueueItemAt(index);
                              if (!context.mounted) {
                                return;
                              }
                              final PlayerState refreshedState = ref.read(
                                playerControllerProvider,
                              );
                              if (!refreshedState.hasQueue) {
                                await _close(context);
                              }
                            },
                            icon: const Icon(Icons.close_rounded),
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
  }

  Future<void> _close(BuildContext context) async {
    switch (closeTarget) {
      case _QueueCloseTarget.navigator:
        Navigator.of(context).pop();
      case _QueueCloseTarget.sidePanel:
        await SmartDialog.dismiss<void>(tag: desktopSidePanelTag);
    }
  }
}
