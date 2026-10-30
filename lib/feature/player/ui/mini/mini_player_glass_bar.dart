import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/ui/mini/mini_player_content.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class MiniPlayerGlassBar extends StatelessWidget {
  const MiniPlayerGlassBar({
    super.key,
    required this.state,
    required this.onTap,
    required this.onTogglePlayback,
  });

  final PlayerState state;
  final VoidCallback onTap;
  final VoidCallback onTogglePlayback;

  @override
  Widget build(BuildContext context) {
    return GlassButton.custom(
      onTap: onTap,
      shape: const LiquidRoundedSuperellipse(borderRadius: 24),
      interactionScale: 1.04,
      stretch: 0.2,
      useOwnLayer: true,
      child: MiniPlayerContent(
        state: state,
        onTogglePlayback: onTogglePlayback,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
