import 'package:bilimusic/common/components/desktop/desktop_side_panel.dart';
import 'package:bilimusic/common/util/toast_util.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_playback_waveform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

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
  static const double _estimatedPartItemExtent = 56;

  late final AutoScrollController _scrollController;
  bool _didFocusInitialItem = false;

  @override
  void initState() {
    super.initState();
    _scrollController = AutoScrollController(
      suggestedRowHeight: _estimatedPartItemExtent,
    );
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
                      '${widget.parts.length} 项',
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
                        await widget.controller.enqueue(partsToEnqueue);
                        if (!context.mounted) {
                          return;
                        }
                        ToastUtil.show('已将 ${partsToEnqueue.length} 个分P加入队列');
                      },
                child: const Text('全部加入队列'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: widget.parts.length,
            itemBuilder: (BuildContext context, int index) {
              final PlayableItem part = widget.parts[index];
              final bool isSelected = part == widget.currentItem;
              final String title = part.pageTitle?.trim() ?? '';
              final int page = part.page ?? index + 1;
              final String label = title.isEmpty ? 'P$page' : 'P$page · $title';

              return AutoScrollTag(
                key: ValueKey<String>('part-selector-${part.stableId}'),
                controller: _scrollController,
                index: index,
                child: Semantics(
                  selected: isSelected,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        await _close(context);
                        if (!isSelected) {
                          widget.controller.replaceCurrentQueueItem(part);
                        }
                      },
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 56),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 4,
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isSelected) ...<Widget>[
                                const SizedBox(width: 8),
                                PlayerPlaybackWaveform(
                                  isPlaying:
                                      widget.state.isPlaying &&
                                      !widget.state.isBuffering &&
                                      !widget.state.isLoading,
                                ),
                              ],
                            ],
                          ),
                        ),
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      await _scrollController.scrollToIndex(
        selectedIndex,
        preferPosition: AutoScrollPosition.middle,
      );
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
