import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/router/player_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerUtil {
  // 播放队列并打开播放器
  static Future<void> playQueueAndOpenPlayer(
    BuildContext context,
    WidgetRef ref, {
    required List<PlayableItem> items,
    int startIndex = 0,
    String? sourceLabel,
  }) async {
    final Future<void> setQueueFuture = ref
        .read(playerControllerProvider.notifier)
        .setQueue(items, startIndex: startIndex, sourceLabel: sourceLabel);

    if (context.mounted) {
      await openPlayerPage(context);
    }

    await setQueueFuture;
  }

  // 播放单曲并打开播放器
  static Future<void> playItemAndOpenPlayer(
    BuildContext context,
    WidgetRef ref, {
    required PlayableItem item,
    String? sourceLabel,
  }) {
    return playQueueAndOpenPlayer(
      context,
      ref,
      items: <PlayableItem>[item],
      startIndex: 0,
      sourceLabel: sourceLabel,
    );
  }
}
