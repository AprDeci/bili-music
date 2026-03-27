import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/ui/components/player_meta_widgets.dart';
import 'package:flutter/material.dart';

class PlayerMetaPage extends StatelessWidget {
  const PlayerMetaPage({super.key, required this.state, required this.item});

  final PlayerState state;
  final PlayableItem? item;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: <Widget>[
        PlayerMetaSheet(state: state, item: item),
        const SizedBox(height: 18),
        PlayerStatsGrid(item: item),
        const SizedBox(height: 18),
        if ((item?.description ?? '').trim().isNotEmpty)
          PlayerDescriptionCard(description: item!.description!),
      ],
    );
  }
}
