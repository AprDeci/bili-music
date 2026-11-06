import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_provider.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_playback_waveform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CarPlayerQueueList extends ConsumerWidget {
  const CarPlayerQueueList({
    super.key,
    required this.state,
    required this.controller,
  });

  final PlayerState state;
  final PlayerController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    if (!state.hasQueue) {
      return const Center(child: Text('播放队列为空'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: state.queue.length,
      itemBuilder: (BuildContext context, int index) {
        final item = state.queue[index];
        final display = ref
            .watch(playerQueueDisplayProvider(item))
            .asData
            ?.value;
        final bool current = state.currentQueueIndex == index;
        return Padding(
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
              controller.skipToQueueIndex(index);
            },
          ),
        );
      },
    );
  }
}
