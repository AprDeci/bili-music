import 'dart:math' as math;

import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/lyrics/player_lyric_settings_logic.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_artwork.dart';
import 'package:bilimusic/feature/player/ui/components/player_cover_browser_page.dart';
import 'package:bilimusic/feature/player/ui/components/player_controls.dart';
import 'package:bilimusic/feature/player/ui/components/player_landscape_controls.dart';
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
    required this.onSeek,
    this.activeColor,
  });

  final PlayerState state;
  final PlayableItem? item;
  final PlayerDisplayInfo display;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final ValueChanged<double> onSeek;
  final Color? activeColor;

  Future<void> _browseCovers(BuildContext context, WidgetRef ref) async {
    final PlayerState initial = ref.read(playerControllerProvider);
    if (!initial.hasQueue) {
      return;
    }
    final PlayableItem? selected = await Navigator.of(context)
        .push<PlayableItem>(
          MaterialPageRoute<PlayableItem>(
            builder: (BuildContext context) => PlayerCoverBrowserPage(
              queue: List<PlayableItem>.unmodifiable(initial.queue),
              initialIndex: initial.hasActiveQueueIndex
                  ? initial.currentQueueIndex!
                  : 0,
              activeColor: activeColor,
            ),
          ),
        );
    if (!context.mounted || selected == null) {
      return;
    }
    final PlayerState current = ref.read(playerControllerProvider);
    final int index = current.queue.indexWhere(
      (PlayableItem candidate) => candidate.contentId == selected.contentId,
    );
    if (index < 0 || current.currentQueueIndex == index) {
      return;
    }
    await ref.read(playerControllerProvider.notifier).skipToQueueIndex(index);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlayerController controller = ref.read(
      playerControllerProvider.notifier,
    );

    final double contentPadding = ref.watch(
      playerLyricSettingsLogicProvider.select(
        (settings) => settings.horizontalPadding,
      ),
    );
    final double sidePadding = MediaQuery.sizeOf(context).width < 700 ? 24 : 64;

    return Padding(
      padding: EdgeInsets.fromLTRB(sidePadding, 8, sidePadding, 24),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double artworkSize = math.min(
            playerArtworkSize(MediaQuery.sizeOf(context)),
            math.min(
              constraints.maxHeight,
              math.max(0, constraints.maxWidth - 324),
            ),
          );

          return Center(
            child: Row(
              children: <Widget>[
                SizedBox.square(
                  dimension: artworkSize,
                  child: Semantics(
                    button: state.hasQueue,
                    label: '浏览播放队列封面',
                    child: GestureDetector(
                      onTap: state.hasQueue
                          ? () => _browseCovers(context, ref)
                          : null,
                      child: Hero(
                        tag: 'artwork',
                        child: PlayerArtworkFrame(
                          coverUrl: display.coverUrl ?? '',
                        ),
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
                        Transform.translate(
                          offset: const Offset(0, 8),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: contentPadding,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                PlayerProgressHost(
                                  state: state,
                                  onChanged: onSeek,
                                ),
                                PlayerLandscapeControls(
                                  state: state,
                                  isFavorite: isFavorite,
                                  onFavoriteToggle: onFavoriteToggle,
                                  onBackward: controller.skipToPrevious,
                                  onTogglePlayback: controller.togglePlayback,
                                  onForward: controller.skipToNext,
                                  onToggleQueueMode: controller.toggleQueueMode,
                                ),
                              ],
                            ),
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
