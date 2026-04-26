import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_lyrics_state.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_lyrics_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_lyric_panel.dart';
import 'package:bilimusic/feature/player/ui/components/player_lyric_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerLyricPage extends ConsumerWidget {
  const PlayerLyricPage({
    super.key,
    required this.state,
    required this.item,
    required this.onSeek,
  });

  final PlayerState state;
  final PlayableItem? item;
  final ValueChanged<Duration> onSeek;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlayerLyricsState lyricsState = ref.watch(
      playerLyricsControllerProvider,
    );

    final Widget content = PlayerLyricPanel(
      state: state,
      item: item,
      onSeek: onSeek,
    );
    if (item == null) {
      return content;
    }

    return Column(
      children: <Widget>[
        Expanded(child: content),
        _PlayerLyricToolbar(
          onSearch: () => showManualLyricSearchSheet(
            context: context,
            initialKeyword: resolveLyricSearchKeyword(
              lyricsState: lyricsState,
              item: item,
            ),
          ),
          onOffset: () => showLyricOffsetSheet(context),
        ),
      ],
    );
  }
}

class _PlayerLyricToolbar extends StatelessWidget {
  const _PlayerLyricToolbar({required this.onOffset, this.onSearch});

  final VoidCallback? onSearch;
  final VoidCallback onOffset;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color iconColor = colorScheme.primary.withValues(alpha: 0.72);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              tooltip: '手动匹配歌词',
              onPressed: onSearch,
              color: iconColor,
              icon: const Icon(Icons.search_rounded),
            ),
            const SizedBox(width: 20),
            IconButton(
              tooltip: '歌词偏移',
              onPressed: onOffset,
              color: iconColor,
              icon: const Icon(Icons.hourglass_empty_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
