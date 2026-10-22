import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_ui_style.dart';
import 'package:bilimusic/feature/player/logic/player_ui_style_logic.dart';
import 'package:bilimusic/feature/player/ui/apple_music/apple_music_player_page.dart';
import 'package:bilimusic/feature/player/ui/player_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerPageEntry extends ConsumerWidget {
  const PlayerPageEntry({super.key, this.initialItem});

  final PlayableItem? initialItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlayerUiStyle style = ref.watch(playerUiStyleLogicProvider);
    return style == PlayerUiStyle.appleMusic
        ? AppleMusicPlayerPage(initialItem: initialItem)
        : PlayerPage(initialItem: initialItem);
  }
}
