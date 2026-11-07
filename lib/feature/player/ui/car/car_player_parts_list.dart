import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_playback_waveform.dart';
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class CarPlayerPartsList extends StatefulWidget {
  const CarPlayerPartsList({
    super.key,
    required this.state,
    required this.controller,
  });

  final PlayerState state;
  final PlayerController controller;

  @override
  State<CarPlayerPartsList> createState() => _CarPlayerPartsListState();
}

class _CarPlayerPartsListState extends State<CarPlayerPartsList> {
  final AutoScrollController _scrollController = AutoScrollController(
    suggestedRowHeight: 96,
  );
  bool _didFocusInitialItem = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int get _currentIndex => widget.state.availableParts.indexWhere(
    (part) => part.stableId == widget.state.currentItem?.stableId,
  );

  void _focusInitialItem() {
    if (_didFocusInitialItem || _currentIndex < 0) {
      return;
    }
    _didFocusInitialItem = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      final int index = _currentIndex;
      if (index < 0) {
        _didFocusInitialItem = false;
        return;
      }
      await _scrollController.scrollToIndex(
        index,
        preferPosition: AutoScrollPosition.middle,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final PlayerState state = widget.state;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    if (state.availableParts.length < 2) {
      return const Center(child: Text('当前视频没有分P'));
    }
    _focusInitialItem();
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: state.availableParts.length,
      itemBuilder: (BuildContext context, int index) {
        final PlayableItem part = state.availableParts[index];
        final bool current = part.stableId == state.currentItem?.stableId;
        final String title = part.pageTitle?.trim() ?? '';
        final int page = part.page ?? index + 1;
        final String label = title.isEmpty ? 'P$page' : 'P$page · $title';
        return AutoScrollTag(
          key: ValueKey<String>('car-part-${part.stableId}'),
          controller: _scrollController,
          index: index,
          child: Padding(
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
                          isPlaying:
                              state.isPlaying &&
                              !state.isBuffering &&
                              !state.isLoading,
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
              onTap: () {
                Navigator.of(context).pop();
                if (!current) {
                  widget.controller.replaceCurrentQueueItem(part);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
