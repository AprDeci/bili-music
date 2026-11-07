import 'package:bilimusic/common/components/desktop/desktop_side_panel.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_parts_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

Future<void> showPlayerPartSelector({
  required BuildContext context,
  required List<PlayableItem> parts,
  required PlayableItem currentItem,
  required PlayerState state,
  required PlayerController controller,
  VoidCallback? onDownloadAll,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (BuildContext context) {
      return _PlayerPartSelectorSheet(
        parts: parts,
        currentItem: currentItem,
        state: state,
        controller: controller,
        onDownloadAll: onDownloadAll,
      );
    },
  );
}

Future<void> showDesktopPlayerPartSelectorPanel({
  required BuildContext context,
  required List<PlayableItem> parts,
  required PlayableItem currentItem,
  required PlayerState state,
  required PlayerController controller,
  VoidCallback? onDownloadAll,
}) async {
  await showDesktopSidePanel(
    tag: 'player_part_selector',
    context: context,
    width: 420,
    builder: (BuildContext context) {
      return SafeArea(
        child: _PlayerPartSelectorContent(
          parts: parts,
          currentItem: currentItem,
          state: state,
          controller: controller,
          closeTarget: _PartSelectorCloseTarget.sidePanel,
          onDownloadAll: onDownloadAll,
        ),
      );
    },
  );
}

enum _PartSelectorCloseTarget { navigator, sidePanel }

class _PlayerPartSelectorSheet extends StatelessWidget {
  const _PlayerPartSelectorSheet({
    required this.parts,
    required this.currentItem,
    required this.state,
    required this.controller,
    this.onDownloadAll,
  });

  final List<PlayableItem> parts;
  final PlayableItem currentItem;
  final PlayerState state;
  final PlayerController controller;
  final VoidCallback? onDownloadAll;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _PlayerPartSelectorContent(
        parts: parts,
        currentItem: currentItem,
        state: state,
        controller: controller,
        closeTarget: _PartSelectorCloseTarget.navigator,
        onDownloadAll: onDownloadAll,
      ),
    );
  }
}

class _PlayerPartSelectorContent extends StatelessWidget {
  const _PlayerPartSelectorContent({
    required this.parts,
    required this.currentItem,
    required this.state,
    required this.controller,
    required this.closeTarget,
    this.onDownloadAll,
  });

  final List<PlayableItem> parts;
  final PlayableItem currentItem;
  final PlayerState state;
  final PlayerController controller;
  final _PartSelectorCloseTarget closeTarget;
  final VoidCallback? onDownloadAll;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Set<String> queuedIds = state.queue
        .map((PlayableItem item) => item.stableId)
        .toSet();
    final List<PlayableItem> partsToEnqueue = parts
        .where((PlayableItem part) => part.stableId != currentItem.stableId)
        .where((PlayableItem part) => !queuedIds.contains(part.stableId))
        .toList();

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
                      '分P列表',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${parts.length} 项',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: partsToEnqueue.isEmpty
                    ? null
                    : () async {
                        await _close(context);
                        await controller.enqueue(partsToEnqueue);
                        if (!context.mounted) {
                          return;
                        }
                        ToastUtil.show('已将 ${partsToEnqueue.length} 个分P加入队列');
                      },
                child: const Text('全部加入队列'),
              ),
              if (onDownloadAll != null) ...<Widget>[
                const SizedBox(width: 4),
                IconButton(
                  tooltip: '下载全部分P',
                  visualDensity: VisualDensity.compact,
                  onPressed: onDownloadAll,
                  icon: const Icon(Icons.download_rounded, size: 20),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: PlayerPartsList(
            parts: parts,
            currentItem: currentItem,
            state: state,
            controller: controller,
            onClose: () => _close(context),
          ),
        ),
      ],
    );
  }

  Future<void> _close(BuildContext context) async {
    switch (closeTarget) {
      case _PartSelectorCloseTarget.navigator:
        Navigator.of(context).pop();
      case _PartSelectorCloseTarget.sidePanel:
        await SmartDialog.dismiss<void>(tag: desktopSidePanelTag);
    }
  }
}
