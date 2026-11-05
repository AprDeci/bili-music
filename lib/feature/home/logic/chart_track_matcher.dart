import 'package:bilimusic/feature/home/domain/music_chart_track.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';

class ChartTrackMatcher {
  const ChartTrackMatcher._();

  static const int minimumConfidentScore = 2;
  static const int _titleScore = 3;
  static const int _artistScore = 2;
  static const int _closeDurationScore = 2;
  static const int _nearDurationScore = 1;
  static const int _closeDurationWindowSeconds = 8;
  static const int _nearDurationWindowSeconds = 20;

  static final RegExp _ignoredCharacters = RegExp(
    r'''[\s\-_/\\.。，,、:：!！?？"'`~@#%&*+=|<>()\[\]{}（）【】「」『』《》]''',
  );

  static SearchResultItem? pickBest({
    required MusicChartTrack track,
    required List<SearchResultItem> candidates,
  }) {
    SearchResultItem? best;
    int bestScore = -1;
    for (final SearchResultItem candidate in candidates) {
      final _MatchScore score = _score(track: track, item: candidate);
      if (!score.isConfident) {
        continue;
      }
      if (score.total > bestScore) {
        best = candidate;
        bestScore = score.total;
      }
    }
    return best;
  }

  static int scoreOf({
    required MusicChartTrack track,
    required SearchResultItem item,
  }) {
    return _score(track: track, item: item).total;
  }

  static _MatchScore _score({
    required MusicChartTrack track,
    required SearchResultItem item,
  }) {
    final String title = normalize(track.title);
    final String artist = normalize(track.artist);
    final String candidate = normalize(item.title);
    final bool titleMatched = title.isNotEmpty && candidate.contains(title);
    final bool artistMatched = artist.isNotEmpty && candidate.contains(artist);
    int durationScore = 0;
    bool durationClose = false;
    final int candidateSeconds = parseDurationSeconds(item.duration);
    if (track.durationSeconds > 0 && candidateSeconds > 0) {
      final int diff = (track.durationSeconds - candidateSeconds).abs();
      if (diff <= _closeDurationWindowSeconds) {
        durationScore = _closeDurationScore;
        durationClose = true;
      } else if (diff <= _nearDurationWindowSeconds) {
        durationScore = _nearDurationScore;
        durationClose = true;
      }
    }

    final int total =
        (titleMatched ? _titleScore : 0) +
        (artistMatched ? _artistScore : 0) +
        durationScore;
    final bool isConfident = titleMatched || (artistMatched && durationClose);
    return _MatchScore(total: total, isConfident: isConfident);
  }

  static String normalize(String value) {
    return value.toLowerCase().replaceAll(_ignoredCharacters, '');
  }

  static int parseDurationSeconds(String value) {
    final List<String> parts = value
        .trim()
        .split(':')
        .map((String part) => part.trim())
        .toList(growable: false);
    if (parts.length < 2 || parts.length > 3) {
      return 0;
    }
    int seconds = 0;
    for (final String part in parts) {
      final int? value = int.tryParse(part);
      if (value == null || value < 0) {
        return 0;
      }
      seconds = seconds * 60 + value;
    }
    return seconds;
  }
}

class _MatchScore {
  const _MatchScore({required this.total, required this.isConfident});

  final int total;
  final bool isConfident;
}
