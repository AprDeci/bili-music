import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/router/player_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/utils/lyric_lrc_to_qrc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerUtil {
  static final RegExp _lrcPattern = RegExp(
    r'\[(\d{1,2}:\d{1,2}(?:\.\d{1,3})?)\]',
  );
  static final RegExp _qrcPattern = RegExp(r'\[(\d+),(\d+)\]');

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

    if (context.mounted && PlatformUtil.isMobile) {
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

  static String? buildRenderableLyrics(String? rawLyrics, Duration? duration) {
    final String trimmed = rawLyrics?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }

    if (_looksLikeQrc(trimmed)) {
      return trimmed;
    }

    if (!_looksLikeLrc(trimmed)) {
      return trimmed;
    }

    if (duration == null || duration <= Duration.zero) {
      return trimmed;
    }

    try {
      return LrcToQrcUtil.convert(trimmed, totalDuration: duration);
    } on Object {
      return trimmed;
    }
  }

  static bool _looksLikeLrc(String lyrics) {
    return _lrcPattern.hasMatch(lyrics);
  }

  static bool _looksLikeQrc(String lyrics) {
    return _qrcPattern.hasMatch(lyrics);
  }
}
