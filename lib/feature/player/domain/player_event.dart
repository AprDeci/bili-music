import 'package:bilimusic/feature/player/domain/playable_item.dart';

enum PlayerEventType {
  trackChanged,
  position,
  duration,
  playbackState,
  seek,
  stop,
}

class PlayerEvent {
  const PlayerEvent({
    required this.type,
    required this.item,
    required this.position,
    required this.duration,
    required this.isPlaying,
  });

  final PlayerEventType type;
  final PlayableItem? item;
  final Duration position;
  final Duration? duration;
  final bool isPlaying;
}
