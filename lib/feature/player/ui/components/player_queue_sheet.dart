import 'package:bilimusic/common/components/desktop/desktop_side_panel.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_queue_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

Future<void> showPlayerQueueSheet({
  required BuildContext context,
  required PlayerState state,
  bool useRootNavigator = false,
}) async {
  if (!state.hasQueue) {
    return;
  }

  final NavigatorState navigator = Navigator.of(
    context,
    rootNavigator: useRootNavigator,
  );
  final MaterialLocalizations localizations = MaterialLocalizations.of(context);
  final ThemeData theme = Theme.of(context);
  final ModalBottomSheetRoute<void> route = ModalBottomSheetRoute<void>(
    capturedThemes: InheritedTheme.capture(
      from: context,
      to: navigator.context,
    ),
    barrierLabel: localizations.scrimLabel,
    barrierOnTapHint: localizations.scrimOnTapHint(
      localizations.bottomSheetLabel,
    ),
    modalBarrierColor: theme.bottomSheetTheme.modalBarrierColor,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: theme.colorScheme.surface,
    sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
        ? AnimationStyle.noAnimation
        : null,
    builder: (BuildContext context) {
      return const SafeArea(child: _PlayerQueueSheet());
    },
  );
  final Future<void> popped = navigator.push<void>(route);
  await popped;
  await route.completed;
}

Future<void> showDesktopPlayerQueuePanel({
  required BuildContext context,
  required PlayerState state,
}) async {
  if (!state.hasQueue) {
    return;
  }

  await showDesktopSidePanel(
    tag: 'player_queue_panel',
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
      builder: (BuildContext context, ScrollController _) {
        return _PlayerQueueContent(closeTarget: _QueueCloseTarget.navigator);
      },
    );
  }
}

class _PlayerQueueContent extends ConsumerWidget {
  const _PlayerQueueContent({required this.closeTarget});

  final _QueueCloseTarget closeTarget;

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
          child: PlayerQueueList(
            state: liveState,
            controller: liveController,
            onClose: () => _close(context),
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
