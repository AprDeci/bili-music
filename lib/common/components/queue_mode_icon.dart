import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';

HugeIcon queueModeIcon(PlayerQueueMode mode) {
  return switch (mode) {
    PlayerQueueMode.sequence => HugeIcon(
      icon: HugeIcons.strokeRoundedRepeat,
      size: 22,
    ),
    PlayerQueueMode.singleRepeat => HugeIcon(
      icon: HugeIcons.strokeRoundedRepeatOne01,
      size: 22,
    ),
    PlayerQueueMode.shuffle => HugeIcon(
      icon: HugeIcons.strokeRoundedShuffle,
      size: 22,
    ),
  };
}
