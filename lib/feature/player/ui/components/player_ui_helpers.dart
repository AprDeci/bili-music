import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';

String formatPlayerDuration(Duration value) {
  if (value <= Duration.zero) {
    return '00:00';
  }

  final int totalSeconds = value.inSeconds;
  final int hours = totalSeconds ~/ 3600;
  final int minutes = (totalSeconds % 3600) ~/ 60;
  final int seconds = totalSeconds % 60;

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

String buildPlayerSubtitle(String author, PlayerState state) {
  final String? pageTitle = state.audioStream?.pageTitle;
  if (pageTitle == null || pageTitle.isEmpty) {
    return author;
  }
  return '$author · $pageTitle';
}

String resolvePlayerDurationLabel(PlayerState state, PlayableItem? item) {
  final Duration? duration = state.duration ?? state.audioStream?.duration;
  if (duration != null && duration > Duration.zero) {
    return formatPlayerDuration(duration);
  }
  return item?.durationText ?? '--:--';
}
