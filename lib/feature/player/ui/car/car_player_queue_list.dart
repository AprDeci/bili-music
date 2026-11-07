import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_provider.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_playback_waveform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class CarPlayerQueueList extends ConsumerStatefulWidget {
  const CarPlayerQueueList({
    super.key,
    required this.state,
    required this.controller,
  });

  final PlayerState state;
  final PlayerController controller;

  @override
  ConsumerState<CarPlayerQueueList> createState() => _CarPlayerQueueListState();
}

class _CarPlayerQueueListState extends ConsumerState<CarPlayerQueueList> {
  final AutoScrollController _scrollController = AutoScrollController(
    suggestedRowHeight: 96,
  );
  bool _didFocusInitialItem = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _focusInitialItem() {
    if (_didFocusInitialItem || !widget.state.hasActiveQueueIndex) {
      return;
    }
    _didFocusInitialItem = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      final int? index = widget.state.currentQueueIndex;
      if (!widget.state.hasActiveQueueIndex || index == null) {
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
    if (!state.hasQueue) {
      return const Center(child: Text('播放队列为空'));
    }
    _focusInitialItem();
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: state.queue.length,
      itemBuilder: (BuildContext context, int index) {
        final item = state.queue[index];
        final display = ref
            .watch(playerQueueDisplayProvider(item))
            .asData
            ?.value;
        final bool current = state.currentQueueIndex == index;
        return AutoScrollTag(
          key: ValueKey<String>('car-queue-${item.stableId}'),
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
                        '${index + 1}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium,
                      ),
              ),
              title: Text(
                display?.title ?? item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: current ? colors.onPrimaryContainer : null,
                ),
              ),
              subtitle: Text(
                display?.artist ?? item.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: current
                      ? colors.onPrimaryContainer
                      : colors.onSurfaceVariant,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                widget.controller.skipToQueueIndex(index);
              },
            ),
          ),
        );
      },
    );
  }
}
