import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_provider.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_playback_waveform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class PlayerQueueList extends ConsumerStatefulWidget {
  const PlayerQueueList({
    super.key,
    required this.state,
    required this.controller,
    required this.onClose,
    this.isCar = false,
  });

  final PlayerState state;
  final PlayerController controller;
  final Future<void> Function() onClose;
  final bool isCar;

  @override
  ConsumerState<PlayerQueueList> createState() => _PlayerQueueListState();
}

class _PlayerQueueListState extends ConsumerState<PlayerQueueList> {
  late final AutoScrollController _scrollController = AutoScrollController(
    suggestedRowHeight: widget.isCar ? 96 : 56,
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
      padding: widget.isCar
          ? const EdgeInsets.fromLTRB(20, 0, 20, 20)
          : const EdgeInsets.only(bottom: 24),
      itemCount: state.queue.length,
      itemBuilder: (BuildContext context, int index) {
        final PlayableItem item = state.queue[index];
        final display = ref
            .watch(playerQueueDisplayProvider(item))
            .asData
            ?.value;
        final bool current = state.currentQueueIndex == index;
        final String partTitle = item.pageTitle?.trim() ?? '';
        final String title = partTitle.isEmpty
            ? display?.title ?? item.title
            : partTitle;
        final String subtitle =
            partTitle.isEmpty || partTitle == item.title.trim()
            ? (display?.artist ?? item.author).trim()
            : item.title.trim();
        final Widget waveform = PlayerPlaybackWaveform(
          isPlaying: state.isPlaying && !state.isBuffering && !state.isLoading,
        );
        Future<void> play() async {
          await widget.onClose();
          await widget.controller.skipToQueueIndex(index);
        }

        return AutoScrollTag(
          key: ValueKey<String>('queue-${item.stableId}'),
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
                              child: waveform,
                            )
                          : Text(
                              '${index + 1}',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium,
                            ),
                    ),
                    title: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: current ? colors.onPrimaryContainer : null,
                      ),
                    ),
                    subtitle: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: current
                            ? colors.onPrimaryContainer
                            : colors.onSurfaceVariant,
                      ),
                    ),
                    onTap: play,
                  ),
                )
              : Semantics(
                  selected: current,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: play,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 8, 4),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  text: title,
                                  children: <InlineSpan>[
                                    if (subtitle.isNotEmpty)
                                      TextSpan(
                                        text: ' - $subtitle',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: current
                                                  ? colors.primary
                                                  : colors.onSurfaceVariant,
                                              fontWeight: FontWeight.normal,
                                            ),
                                      ),
                                  ],
                                ),
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
                              waveform,
                            ],
                            IconButton(
                              constraints: const BoxConstraints.tightFor(
                                width: 48,
                                height: 48,
                              ),
                              tooltip: '移出队列',
                              onPressed: () async {
                                await widget.controller.removeQueueItemAt(
                                  index,
                                );
                                if (!mounted) {
                                  return;
                                }
                                if (!ref
                                    .read(playerControllerProvider)
                                    .hasQueue) {
                                  await widget.onClose();
                                }
                              },
                              icon: HugeIcon(
                                icon: HugeIcons.strokeRoundedCancel01,
                                color: colors.onSurfaceVariant,
                                size: 18,
                              ),
                            ),
                          ],
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
