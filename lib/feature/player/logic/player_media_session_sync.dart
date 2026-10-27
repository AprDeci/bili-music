import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/app_audio_handler.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/player_display_provider.dart';
import 'package:bilimusic/feature/player/logic/player_media_item_mapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_media_session_sync.g.dart';

@riverpod
void playerMediaSessionSync(Ref ref) {
  final AppAudioHandler handler = ref.watch(appAudioHandlerProvider);

  void publish() {
    final PlayerState state = ref.read(playerControllerProvider);
    final PlayerDisplayInfo display = ref.read(playerDisplayProvider);
    final List<MediaItem> queue = state.queue
        .map(
          (item) => buildPlayerQueueMediaItem(
            item,
            queueSourceLabel: state.queueSourceLabel,
            duration: item.stableId == state.currentItem?.stableId
                ? state.duration ?? state.audioStream?.duration
                : null,
            display: display,
          ),
        )
        .toList(growable: false);
    final item = state.currentItem;
    final stream = state.audioStream;
    final MediaItem? current = item == null
        ? null
        : stream == null
        ? buildPlayerQueueMediaItem(
            item,
            queueSourceLabel: state.queueSourceLabel,
            duration: state.duration,
            display: display,
          )
        : buildPlayerMediaItem(
            item,
            audioStream: stream,
            queueSourceLabel: state.queueSourceLabel,
            duration: state.duration,
            display: display,
          );
    if (!listEquals(
      handler.queue.value.map(_mediaContent).toList(growable: false),
      queue.map(_mediaContent).toList(growable: false),
    )) {
      unawaited(handler.updateQueue(queue));
    }
    if (_mediaContent(handler.mediaItem.value) != _mediaContent(current)) {
      handler.updateCurrentMediaItem(current);
    }
  }

  ref.listen(
    playerControllerProvider.select(
      (state) => (
        state.queue,
        state.currentItem,
        state.queueSourceLabel,
        state.duration,
        state.audioStream,
      ),
    ),
    (_, _) => publish(),
  );
  ref.listen(
    playerDisplayProvider.select(
      (display) =>
          (display.stableId, display.title, display.artist, display.coverUrl),
    ),
    (_, _) => publish(),
    fireImmediately: true,
  );
}

Record? _mediaContent(MediaItem? item) => item == null
    ? null
    : (
        item.id,
        item.album,
        item.title,
        item.artist,
        item.artUri,
        item.duration,
        item.displayTitle,
        item.displaySubtitle,
        item.displayDescription,
      );
