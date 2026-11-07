import 'dart:math' as math;

import 'package:bilimusic/core/layout/shell_content_insets.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

FavoriteEntry? findCurrentFavoriteEntry(
  List<FavoriteEntry> items,
  PlayableItem? current,
) {
  if (current == null || !current.hasIdentity) {
    return null;
  }
  bool sameVideo(FavoriteEntry entry) => current.bvid.isNotEmpty
      ? entry.bvid == current.bvid
      : entry.aid == current.aid;

  for (final FavoriteEntry entry in items) {
    if (sameVideo(entry) &&
        current.cid != null &&
        current.cid! > 0 &&
        entry.cid == current.cid) {
      return entry;
    }
  }
  for (final FavoriteEntry entry in items) {
    if (sameVideo(entry) &&
        (current.cid == null ||
            current.cid! <= 0 ||
            entry.cid == null ||
            entry.cid! <= 0) &&
        (entry.page ?? 1) == (current.page ?? 1)) {
      return entry;
    }
  }
  return null;
}

class FavoriteCurrentTrackOverlay extends ConsumerWidget {
  const FavoriteCurrentTrackOverlay({
    super.key,
    required this.items,
    required this.selectionMode,
    required this.onLocate,
    required this.child,
  });

  final List<FavoriteEntry> items;
  final bool selectionMode;
  final ValueChanged<String> onLocate;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlayableItem? current = items.isEmpty
        ? null
        : ref.watch(
            playerControllerProvider.select((state) => state.currentItem),
          );
    final FavoriteEntry? target = selectionMode
        ? null
        : findCurrentFavoriteEntry(items, current);
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        child,
        if (target != null)
          Positioned(
            right: 14 + MediaQuery.paddingOf(context).right,
            bottom: math.max(
              ShellContentInsets.bottomOf(context) - 4,
              MediaQuery.paddingOf(context).bottom + 12,
            ),
            child: IconButton(
              tooltip: '定位当前播放',
              onPressed: () => onLocate(target.itemId),
              style: IconButton.styleFrom(
                fixedSize: const Size.square(48),
                minimumSize: const Size.square(48),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.standard,
                tapTargetSize: MaterialTapTargetSize.padded,
                foregroundColor: colors.primary,
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(),
              ),
              icon: Material(
                color: colors.primary.withValues(alpha: 0.12),
                shape: const CircleBorder(),
                child: const SizedBox.square(
                  dimension: 30,
                  child: Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedCircleDot,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
