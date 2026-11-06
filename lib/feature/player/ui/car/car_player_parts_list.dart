import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_playback_waveform.dart';
import 'package:flutter/material.dart';

class CarPlayerPartsList extends StatelessWidget {
  const CarPlayerPartsList({
    super.key,
    required this.state,
    required this.controller,
  });

  final PlayerState state;
  final PlayerController controller;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    if (state.availableParts.length < 2) {
      return const Center(child: Text('当前视频没有分P'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: state.availableParts.length,
      itemBuilder: (BuildContext context, int index) {
        final PlayableItem part = state.availableParts[index];
        final bool current = part == state.currentItem;
        final String title = part.pageTitle?.trim() ?? '';
        final int page = part.page ?? index + 1;
        final String label = title.isEmpty ? 'P$page' : 'P$page · $title';
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
              if (part != state.currentItem) {
                controller.replaceCurrentQueueItem(part);
              }
            },
          ),
        );
      },
    );
  }
}
