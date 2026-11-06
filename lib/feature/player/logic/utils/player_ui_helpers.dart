import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/playback_chapter.dart';
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

String? formatCommentBadgeCount(int? count) {
  if (count == null || count <= 0) {
    return null;
  }
  if (count <= 999) {
    return count.toString();
  }
  return '999+';
}

String? formatPartBadge(PlayableItem? item) {
  if (item == null) {
    return null;
  }
  final int currentPage = item.page ?? 1;
  return 'P$currentPage';
}

List<double> resolveChapterTickRatios(
  List<PlaybackChapter> chapters,
  Duration? total,
) {
  final int totalMs = total?.inMilliseconds ?? 0;
  if (chapters.length < 2 || totalMs <= 0) {
    return const <double>[];
  }

  return chapters
      .map(
        (PlaybackChapter chapter) =>
            (chapter.start.inMilliseconds / totalMs).clamp(0.0, 1.0),
      )
      .toList(growable: false);
}

int? resolveChapterIndex(List<PlaybackChapter> chapters, Duration position) {
  if (chapters.isEmpty) {
    return null;
  }

  int index = 0;
  for (int current = 1; current < chapters.length; current += 1) {
    if (chapters[current].start > position) {
      break;
    }
    index = current;
  }
  return index;
}

String? formatJumpBadge({
  required PlayableItem? item,
  required List<PlaybackChapter> chapters,
  required Duration position,
}) {
  if (item == null) {
    return null;
  }
  if (chapters.length > 1) {
    final int? index = resolveChapterIndex(chapters, position);
    return index == null ? null : '${index + 1}';
  }
  return formatPartBadge(item);
}

PlaybackChapter? resolveCurrentChapter(
  List<PlaybackChapter> chapters,
  Duration position,
) {
  if (chapters.length < 2) {
    return null;
  }
  final int? index = resolveChapterIndex(chapters, position);
  if (index == null) {
    return null;
  }
  return chapters[index];
}
