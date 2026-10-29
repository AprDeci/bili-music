import 'dart:math' as math;

import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_artwork.dart';
import 'package:bilimusic/feature/player/ui/components/player_controls.dart';
import 'package:bilimusic/feature/player/ui/components/player_landscape_controls.dart';
import 'package:bilimusic/feature/player/ui/components/player_queue_sheet.dart';
import 'package:bilimusic/feature/player/ui/lyrics/player_lyric_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerLandscapePage extends ConsumerWidget {
  const PlayerLandscapePage({
    super.key,
    required this.state,
    required this.item,
    required this.display,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onToggleSource,
    required this.onSeek,
    this.activeColor,
  });

  final PlayerState state;
  final PlayableItem? item;
  final PlayerDisplayInfo display;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onToggleSource;
  final ValueChanged<double> onSeek;
  final Color? activeColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlayerController controller = ref.read(
      playerControllerProvider.notifier,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(64, 8, 64, 24),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double artworkSize =
              math.min(
                constraints.maxHeight,
                math.min(
                  constraints.maxWidth * 0.4,
                  math.max(0, constraints.maxWidth - 324),
                ),
              ) *
              0.85;

          return Center(
            child: Row(
              children: <Widget>[
                SizedBox.square(
                  dimension: artworkSize,
                  child: GestureDetector(
                    onDoubleTap: onToggleSource,
                    child: Hero(
                      tag: 'artwork',
                      child: PlayerArtworkFrame(
                        coverUrl: display.coverUrl ?? '',
                        borderRadius: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: SizedBox(
                    height: artworkSize,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: PlayerLyricPage(
                            state: state,
                            item: item,
                            isActive: true,
                            onSeek: controller.seek,
                            activeColor: activeColor,
                            showToolbar: false,
                          ),
                        ),
                        if (state.statusHint != null)
                          PlayerPlaybackStatusChip(state: state),
                        PlayerProgressHost(state: state, onChanged: onSeek),
                        const SizedBox.shrink(),
                        PlayerLandscapeControls(
                          state: state,
                          isFavorite: isFavorite,
                          onFavoriteToggle: onFavoriteToggle,
                          onBackward: controller.skipToPrevious,
                          onTogglePlayback: controller.togglePlayback,
                          onForward: controller.skipToNext,
                          onOpenQueue: () => showPlayerQueueSheet(
                            context: context,
                            state: state,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
