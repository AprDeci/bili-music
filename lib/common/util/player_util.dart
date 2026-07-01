import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/multi_part_queue_preference.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/player_multi_part_queue_preference_logic.dart';
import 'package:bilimusic/router/util/player_navigation.dart';
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
    if (items.isEmpty) {
      return;
    }

    final _ResolvedQueue resolvedQueue = await _resolveQueueForStartItem(
      context,
      ref,
      items: items,
      startIndex: startIndex,
    );

    final Future<void> setQueueFuture = ref
        .read(playerControllerProvider.notifier)
        .setQueue(
          resolvedQueue.items,
          startIndex: resolvedQueue.startIndex,
          sourceLabel: sourceLabel,
        );

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

  static Future<void> playItemNextWithMultiPart(
    BuildContext context,
    WidgetRef ref, {
    required PlayableItem item,
  }) async {
    final _ResolvedMultiPartItems resolvedItems =
        await _resolveMultiPartItemsForItem(context, ref, item);
    await ref
        .read(playerControllerProvider.notifier)
        .playNextMany(resolvedItems.items);
  }

  static Future<void> enqueueItemWithMultiPart(
    BuildContext context,
    WidgetRef ref, {
    required PlayableItem item,
  }) async {
    final _ResolvedMultiPartItems resolvedItems =
        await _resolveMultiPartItemsForItem(context, ref, item);
    await ref
        .read(playerControllerProvider.notifier)
        .enqueue(resolvedItems.items);
  }

  static Future<_ResolvedQueue> _resolveQueueForStartItem(
    BuildContext context,
    WidgetRef ref, {
    required List<PlayableItem> items,
    required int startIndex,
  }) async {
    final int resolvedStartIndex = startIndex
        .clamp(0, items.length - 1)
        .toInt();
    final _ResolvedMultiPartItems resolvedItems =
        await _resolveMultiPartItemsForItem(
          context,
          ref,
          items[resolvedStartIndex],
        );
    final List<PlayableItem> queue = <PlayableItem>[
      ...items.take(resolvedStartIndex),
      ...resolvedItems.items,
      ...items.skip(resolvedStartIndex + 1),
    ];
    return _ResolvedQueue(
      items: List<PlayableItem>.unmodifiable(queue),
      startIndex: resolvedStartIndex + resolvedItems.startIndex,
    );
  }

  static Future<_ResolvedMultiPartItems> _resolveMultiPartItemsForItem(
    BuildContext context,
    WidgetRef ref,
    PlayableItem item,
  ) async {
    final List<PlayableItem> parts = await ref
        .read(biliPlayerRepositoryProvider)
        .resolvePlayableParts(item);
    final PlayableItem currentPart = _resolveCurrentPart(parts, item);
    if (parts.length <= 1) {
      return _ResolvedMultiPartItems(
        items: <PlayableItem>[currentPart],
        startIndex: 0,
      );
    }
    if (!context.mounted) {
      return _ResolvedMultiPartItems(
        items: <PlayableItem>[currentPart],
        startIndex: 0,
      );
    }

    final MultiPartQueuePreference preference =
        await _resolveMultiPartQueuePreference(context, ref, parts.length);
    if (preference == MultiPartQueuePreference.currentPart) {
      return _ResolvedMultiPartItems(
        items: <PlayableItem>[currentPart],
        startIndex: 0,
      );
    }

    final int currentPartIndex = parts.indexWhere(
      (PlayableItem part) => part.stableId == currentPart.stableId,
    );
    return _ResolvedMultiPartItems(
      items: parts,
      startIndex: currentPartIndex < 0 ? 0 : currentPartIndex,
    );
  }

  static PlayableItem _resolveCurrentPart(
    List<PlayableItem> parts,
    PlayableItem item,
  ) {
    final int? targetCid = item.cid;
    if (targetCid != null && targetCid > 0) {
      for (final PlayableItem part in parts) {
        if (part.cid == targetCid) {
          return part;
        }
      }
    }

    final int? targetPage = item.page;
    if (targetPage != null && targetPage > 0) {
      for (final PlayableItem part in parts) {
        if (part.page == targetPage) {
          return part;
        }
      }
    }

    return parts.first;
  }

  static Future<MultiPartQueuePreference> _resolveMultiPartQueuePreference(
    BuildContext context,
    WidgetRef ref,
    int partCount,
  ) async {
    if (ref.read(playerMultiPartTipShownLogicProvider)) {
      return ref.read(playerMultiPartQueuePreferenceLogicProvider);
    }
    if (!context.mounted) {
      return MultiPartQueuePreference.currentPart;
    }

    final MultiPartQueuePreference? selected =
        await showDialog<MultiPartQueuePreference>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('发现分段视频'),
              content: Text(
                '当前投稿包含 $partCount 个分段。请选择以后遇到这类投稿时的默认添加方式。'
                '这个选择只会提示一次，后续可在播放器设置中修改。',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(
                    dialogContext,
                  ).pop(MultiPartQueuePreference.currentPart),
                  child: const Text('默认添加首个分段'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(
                    dialogContext,
                  ).pop(MultiPartQueuePreference.allParts),
                  child: const Text('默认添加所有分段'),
                ),
              ],
            );
          },
        );
    final MultiPartQueuePreference preference =
        selected ?? MultiPartQueuePreference.currentPart;
    await ref
        .read(playerMultiPartQueuePreferenceLogicProvider.notifier)
        .setPreference(preference);
    await ref
        .read(playerMultiPartTipShownLogicProvider.notifier)
        .setShown(true);
    return preference;
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

class _ResolvedQueue {
  const _ResolvedQueue({required this.items, required this.startIndex});

  final List<PlayableItem> items;
  final int startIndex;
}

class _ResolvedMultiPartItems {
  const _ResolvedMultiPartItems({
    required this.items,
    required this.startIndex,
  });

  final List<PlayableItem> items;
  final int startIndex;
}
