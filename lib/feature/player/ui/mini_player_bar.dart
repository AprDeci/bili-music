import 'package:bilimusic/common/bottom_height_helper.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/ui/components/mini_player_content.dart';
import 'package:flutter/material.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({
    super.key,
    required this.state,
    required this.onTap,
    required this.onTogglePlayback,
    this.bottomPadding = BottomHeightHelper.miniPlayerCollapsedBottomPadding,
  });

  final PlayerState state;
  final VoidCallback onTap;
  final VoidCallback onTogglePlayback;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.10),
              ),
            ),
            child: MiniPlayerContent(
              state: state,
              onTogglePlayback: onTogglePlayback,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
          ),
        ),
      ),
    );
  }
}
