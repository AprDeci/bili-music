import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<AppAudioHandler> appAudioHandlerProvider =
    Provider<AppAudioHandler>((Ref ref) {
      return PlayerAudioService.handler;
    });

abstract interface class PlayerCommandTarget {
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> skipToNext();
  Future<void> skipToPrevious();
}

class PlayerAudioService {
  PlayerAudioService._();

  static AppAudioHandler? _handler;

  static AppAudioHandler get handler {
    final AppAudioHandler? handler = _handler;
    if (handler == null) {
      throw StateError('PlayerAudioService has not been initialized.');
    }
    return handler;
  }

  static Future<void> initialize() async {
    if (_handler != null) {
      return;
    }

    final AudioHandler audioHandler = await AudioService.init(
      builder: AppAudioHandler.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.bilimusic.channel.audio',
        androidNotificationChannelName: 'Bilimusic Playback',
        androidNotificationOngoing: true,
      ),
    );

    _handler = audioHandler as AppAudioHandler;
  }
}

class AppAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  PlayerCommandTarget? _target;

  void attachTarget(PlayerCommandTarget target) {
    _target = target;
  }

  void detachTarget(PlayerCommandTarget target) {
    if (identical(_target, target)) {
      _target = null;
    }
  }

  @override
  Future<void> updateQueue(List<MediaItem> items) async {
    queue.add(List<MediaItem>.unmodifiable(items));
  }

  void updateCurrentMediaItem(MediaItem? item) {
    mediaItem.add(item);
  }

  void clearSession() {
    queue.add(const <MediaItem>[]);
    mediaItem.add(null);
  }

  void updatePlaybackSnapshot({
    required bool isPlaying,
    required bool isBuffering,
    required bool hasPrevious,
    required bool hasNext,
    required Duration position,
    required Duration bufferedPosition,
    required Duration? duration,
    required AudioProcessingState processingState,
  }) {
    final List<MediaControl> controls = <MediaControl>[
      if (hasPrevious) MediaControl.skipToPrevious,
      isPlaying ? MediaControl.pause : MediaControl.play,
      if (hasNext) MediaControl.skipToNext,
      MediaControl.stop,
    ];

    playbackState.add(
      PlaybackState(
        controls: controls,
        systemActions: const <MediaAction>{
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.play,
          MediaAction.pause,
          MediaAction.stop,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
        },
        androidCompactActionIndices: _compactActionIndices(controls),
        processingState: processingState,
        playing: isPlaying,
        updatePosition: position,
        bufferedPosition: bufferedPosition,
        speed: 1.0,
        queueIndex: queue.value.isEmpty ? null : _resolveQueueIndex(),
      ),
    );

    final MediaItem? current = mediaItem.value;
    if (current != null && duration != null && current.duration != duration) {
      mediaItem.add(current.copyWith(duration: duration));
    }
  }

  int? _resolveQueueIndex() {
    final MediaItem? current = mediaItem.value;
    if (current == null) {
      return null;
    }

    final List<MediaItem> items = queue.value;
    for (int index = 0; index < items.length; index++) {
      if (items[index].id == current.id) {
        return index;
      }
    }
    return null;
  }

  List<int> _compactActionIndices(List<MediaControl> controls) {
    final List<int> indices = <int>[];
    for (int index = 0; index < controls.length; index++) {
      final MediaAction action = controls[index].action;
      if (action == MediaAction.skipToPrevious ||
          action == MediaAction.play ||
          action == MediaAction.pause ||
          action == MediaAction.skipToNext) {
        indices.add(index);
      }
    }
    return indices.take(3).toList(growable: false);
  }

  @override
  Future<void> play() async {
    final PlayerCommandTarget? target = _target;
    if (target == null) {
      return;
    }
    await target.play();
  }

  @override
  Future<void> pause() async {
    final PlayerCommandTarget? target = _target;
    if (target == null) {
      return;
    }
    await target.pause();
  }

  @override
  Future<void> stop() async {
    final PlayerCommandTarget? target = _target;
    if (target == null) {
      return;
    }
    await target.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    final PlayerCommandTarget? target = _target;
    if (target == null) {
      return;
    }
    await target.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    final PlayerCommandTarget? target = _target;
    if (target == null) {
      return;
    }
    await target.skipToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    final PlayerCommandTarget? target = _target;
    if (target == null) {
      return;
    }
    await target.skipToPrevious();
  }
}

AudioProcessingState mapAudioProcessingState(String processingStateName) {
  return switch (processingStateName) {
    'idle' => AudioProcessingState.idle,
    'loading' => AudioProcessingState.loading,
    'buffering' => AudioProcessingState.buffering,
    'ready' => AudioProcessingState.ready,
    'completed' => AudioProcessingState.completed,
    _ => AudioProcessingState.idle,
  };
}
