import 'package:bilimusic/feature/player/domain/playback_chapter.dart';

class PlaybackChapterParser {
  const PlaybackChapterParser._();

  static const int minimumChapterCount = 2;
  static const Duration minimumChapterGap = Duration(seconds: 1);

  static final RegExp _timestampPattern = RegExp(
    r'(?:^|[^\d:/])(?:(\d{1,2}):)?(\d{1,3}):([0-5]\d)(?![\d:])',
  );
  static final RegExp _trailingTimestampPattern = RegExp(
    r'\s*[\(（\[【]?\d{1,3}:\d{2}(?::\d{2})?[\)）\]】]?\s*$',
  );
  static final RegExp _leadingNoisePattern = RegExp(
    r'^[\s\-–—:：~～,，、.)）\]】】）]+',
  );
  static final RegExp _trailingNoisePattern = RegExp(
    r'[\s\-–—:：~～,，、(（\[【|｜]+$',
  );

  static const List<String> _segmentSeparators = <String>['|', '｜', ';', '；'];

  static List<PlaybackChapter> parse(String? text, {Duration? duration}) {
    final String source = (text ?? '').trim();
    if (source.isEmpty) {
      return const <PlaybackChapter>[];
    }

    final List<PlaybackChapter> chapters = <PlaybackChapter>[];
    for (final String rawLine in source.split('\n')) {
      for (final String segment in _splitSegments(rawLine)) {
        final PlaybackChapter? chapter = _parseSegment(segment);
        if (chapter != null) {
          chapters.add(chapter);
        }
      }
    }

    return normalize(chapters, duration: duration);
  }

  static List<PlaybackChapter> normalize(
    List<PlaybackChapter> chapters, {
    Duration? duration,
  }) {
    final List<PlaybackChapter> sorted = List<PlaybackChapter>.of(chapters)
      ..sort(
        (PlaybackChapter left, PlaybackChapter right) =>
            left.start.compareTo(right.start),
      );

    final int limitMs = duration?.inMilliseconds ?? 0;
    final List<PlaybackChapter> result = <PlaybackChapter>[];
    for (final PlaybackChapter chapter in sorted) {
      if (chapter.title.trim().isEmpty) {
        continue;
      }
      if (limitMs > 0 && chapter.start.inMilliseconds >= limitMs) {
        continue;
      }
      if (result.isNotEmpty &&
          chapter.start - result.last.start < minimumChapterGap) {
        continue;
      }
      result.add(chapter);
    }

    if (result.length < minimumChapterCount) {
      return const <PlaybackChapter>[];
    }

    return List<PlaybackChapter>.unmodifiable(<PlaybackChapter>[
      for (int index = 0; index < result.length; index += 1)
        result[index].copyWith(
          end:
              result[index].end ??
              (index + 1 < result.length ? result[index + 1].start : null),
        ),
    ]);
  }

  static List<String> _splitSegments(String rawLine) {
    final String line = rawLine.trim();
    if (line.isEmpty) {
      return const <String>[];
    }

    final List<String> segments = <String>[line];
    for (final String separator in _segmentSeparators) {
      final List<String> next = <String>[];
      for (final String segment in segments) {
        next.addAll(segment.split(separator));
      }
      segments
        ..clear()
        ..addAll(next);
    }
    return segments;
  }

  static PlaybackChapter? _parseSegment(String rawSegment) {
    final String segment = rawSegment.trim();
    if (segment.isEmpty) {
      return null;
    }

    final RegExpMatch? match = _timestampPattern.firstMatch(segment);
    if (match == null) {
      return null;
    }

    final String title = _cleanTitle(segment.substring(match.end));
    if (title.isEmpty) {
      return null;
    }

    final int? hours = match.group(1) == null
        ? null
        : int.tryParse(match.group(1)!);
    final int? minutes = int.tryParse(match.group(2)!);
    final int? seconds = int.tryParse(match.group(3)!);
    if (minutes == null || seconds == null) {
      return null;
    }
    if (hours != null && minutes >= 60) {
      return null;
    }

    final int totalSeconds = (hours ?? 0) * 3600 + minutes * 60 + seconds;
    return PlaybackChapter(
      start: Duration(seconds: totalSeconds),
      title: title,
    );
  }

  static String _cleanTitle(String rawTitle) {
    String title = rawTitle.trim();
    if (title.isEmpty) {
      return '';
    }

    title = title.replaceFirst(_trailingTimestampPattern, '');
    title = title.replaceFirst(_leadingNoisePattern, '');
    title = title.replaceFirst(_trailingNoisePattern, '');
    return title.trim();
  }
}
