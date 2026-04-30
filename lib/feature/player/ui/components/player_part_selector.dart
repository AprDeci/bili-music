import 'package:bilimusic/common/components/desktop/desktop_side_panel.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

Future<void> showPlayerPartSelector({
  required BuildContext context,
  required List<PlayableItem> parts,
  required PlayableItem currentItem,
  required PlayerState state,
  required PlayerController controller,
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
}) async {
  await showDesktopSidePanel(
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
  });

  final List<PlayableItem> parts;
  final PlayableItem currentItem;
  final PlayerState state;
  final PlayerController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _PlayerPartSelectorContent(
        parts: parts,
        currentItem: currentItem,
        state: state,
        controller: controller,
        closeTarget: _PartSelectorCloseTarget.navigator,
      ),
    );
  }
}

class _PlayerPartSelectorContent extends StatefulWidget {
  const _PlayerPartSelectorContent({
    required this.parts,
    required this.currentItem,
    required this.state,
    required this.controller,
    required this.closeTarget,
  });

  final List<PlayableItem> parts;
  final PlayableItem currentItem;
  final PlayerState state;
  final PlayerController controller;
  final _PartSelectorCloseTarget closeTarget;

  @override
  State<_PlayerPartSelectorContent> createState() =>
      _PlayerPartSelectorContentState();
}

class _PlayerPartSelectorContentState
    extends State<_PlayerPartSelectorContent> {
  static const double _estimatedPartItemExtent = 66;

  late final ScrollController _scrollController;
  bool _didFocusInitialItem = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant _PlayerPartSelectorContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentItem.stableId != widget.currentItem.stableId ||
        oldWidget.parts != widget.parts) {
      _didFocusInitialItem = false;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Set<String> queuedIds = widget.state.queue
        .map((PlayableItem item) => item.stableId)
        .toSet();
    final List<PlayableItem> partsToEnqueue = widget.parts
        .where((PlayableItem part) => part != widget.currentItem)
        .where((PlayableItem part) => !queuedIds.contains(part.stableId))
        .toList();
    _focusInitialItem();

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: widget.parts.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              leading: CircleAvatar(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                child: const Icon(Icons.queue_music_rounded),
              ),
              title: Text(
                '全部加入队列',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                partsToEnqueue.isEmpty
                    ? '其余分P已全部在队列中'
                    : '将 ${partsToEnqueue.length} 个其余分P追加到当前队列',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.68),
                ),
              ),
              trailing: const Icon(Icons.add_rounded),
              onTap: partsToEnqueue.isEmpty
                  ? null
                  : () async {
                      await _close(context);
                      await widget.controller.enqueue(partsToEnqueue);
                      if (!context.mounted) {
                        return;
                      }
                      ToastUtil.show('已将 ${partsToEnqueue.length} 个分P加入队列');
                    },
            ),
          );
        }

        final PlayableItem part = widget.parts[index - 1];
        final bool isSelected = part == widget.currentItem;
        final String title = part.pageTitle?.trim() ?? '';
        final int page = part.page ?? index;
        final String label = title.isEmpty ? 'P$page' : 'P$page · $title';

        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 4,
            ),
            tileColor: isSelected
                ? colorScheme.primary.withValues(alpha: 0.1)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
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
            onTap: () async {
              await _close(context);
              if (part != widget.currentItem) {
                widget.controller.replaceCurrentQueueItem(part);
              }
            },
          ),
        );
      },
      separatorBuilder: (_, _) => const SizedBox(height: 10),
    );
  }

  void _focusInitialItem() {
    if (_didFocusInitialItem) {
      return;
    }

    final int selectedIndex = widget.parts.indexWhere(
      (PlayableItem part) => part.stableId == widget.currentItem.stableId,
    );
    if (selectedIndex < 0) {
      return;
    }

    _didFocusInitialItem = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      final ScrollPosition position = _scrollController.position;
      final double targetOffset =
          (selectedIndex + 1) * _estimatedPartItemExtent -
          position.viewportDimension * 0.35;
      final double clampedOffset = targetOffset.clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      _scrollController.jumpTo(clampedOffset);
    });
  }

  Future<void> _close(BuildContext context) async {
    switch (widget.closeTarget) {
      case _PartSelectorCloseTarget.navigator:
        Navigator.of(context).pop();
      case _PartSelectorCloseTarget.sidePanel:
        await SmartDialog.dismiss<void>(tag: desktopSidePanelTag);
    }
  }
}
