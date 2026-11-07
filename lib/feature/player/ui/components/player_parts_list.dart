import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_playback_waveform.dart';
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class PlayerPartsList extends StatefulWidget {
  const PlayerPartsList({
    super.key,
    required this.parts,
    required this.currentItem,
    required this.state,
    required this.controller,
    required this.onClose,
    this.isCar = false,
  });

  final List<PlayableItem> parts;
  final PlayableItem? currentItem;
  final PlayerState state;
  final PlayerController controller;
  final Future<void> Function() onClose;
  final bool isCar;

  @override
  State<PlayerPartsList> createState() => _PlayerPartsListState();
}

class _PlayerPartsListState extends State<PlayerPartsList> {
  late final AutoScrollController _scrollController;
  bool _didFocusInitialItem = false;
  bool _focusScheduled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = AutoScrollController(
      suggestedRowHeight: widget.isCar ? 96 : 56,
    );
    _focusInitialItem();
  }

  @override
  void didUpdateWidget(covariant PlayerPartsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isCar &&
        oldWidget.currentItem?.stableId != widget.currentItem?.stableId) {
      _didFocusInitialItem = false;
    }
    _focusInitialItem();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _focusInitialItem() {
    if (_didFocusInitialItem || _focusScheduled) {
      return;
    }
    _focusScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _focusScheduled = false;
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      final int index = widget.parts.indexWhere(
        (PlayableItem part) => part.stableId == widget.currentItem?.stableId,
      );
      if (index < 0) {
        return;
      }
      _didFocusInitialItem = true;
      await _scrollController.scrollToIndex(
        index,
        preferPosition: AutoScrollPosition.middle,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    if (widget.isCar && widget.parts.length < 2) {
      return const Center(child: Text('当前视频没有分P'));
    }
    return ListView.builder(
      controller: _scrollController,
      padding: widget.isCar
          ? const EdgeInsets.fromLTRB(20, 0, 20, 20)
          : const EdgeInsets.only(bottom: 24),
      itemCount: widget.parts.length,
      itemBuilder: (BuildContext context, int index) {
        final PlayableItem part = widget.parts[index];
        final bool current = part.stableId == widget.currentItem?.stableId;
        final String title = part.pageTitle?.trim() ?? '';
        final int page = part.page ?? index + 1;
        final String label = title.isEmpty ? 'P$page' : 'P$page · $title';
        final bool isPlaying =
            widget.state.isPlaying &&
            !widget.state.isBuffering &&
            !widget.state.isLoading;
        Future<void> onTap() async {
          await widget.onClose();
          if (!current) {
            await widget.controller.replaceCurrentQueueItem(part);
          }
        }

        return AutoScrollTag(
          key: ValueKey<String>(
            '${widget.isCar ? 'car-part' : 'part-selector'}-${part.stableId}',
          ),
          controller: _scrollController,
          index: index,
          child: widget.isCar
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minTileHeight: 88,
                    selected: current,
                    selectedTileColor: colors.primaryContainer,
                    selectedColor: colors.onPrimaryContainer,
                    leading: SizedBox(
                      width: 32,
                      child: current
                          ? Center(
                              widthFactor: 1,
                              heightFactor: 1,
                              child: PlayerPlaybackWaveform(
                                isPlaying: isPlaying,
                              ),
                            )
                          : Text(
                              '$page',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium,
                            ),
                    ),
                    title: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: current ? colors.onPrimaryContainer : null,
                      ),
                    ),
                    onTap: onTap,
                  ),
                )
              : Semantics(
                  selected: current,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
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
                                    color: current
                                        ? colors.primary
                                        : colors.onSurface,
                                    fontWeight: current
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (current) ...<Widget>[
                                const SizedBox(width: 8),
                                PlayerPlaybackWaveform(isPlaying: isPlaying),
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
    );
  }
}
