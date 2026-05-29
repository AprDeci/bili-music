import 'package:bilimusic/feature/favorites/domain/import/favorites_import_candidate.dart';
import 'package:bilimusic/feature/favorites/domain/import/favorites_import_track.dart';
import 'package:bilimusic/feature/search/domain/search_result_item.dart';

class FavoritesImportMatcher {
  const FavoritesImportMatcher();

  static const Set<int> _blacklistZones = <int>{
    26, // 音MAD
    29, // 现场
    31, // 翻唱
    201, // 科普
    238, // 运动
  };

  static const Set<int> _priorityZones = <int>{
    193, // MV
    130, // 音乐综合
    267, // 电台
  };

  static const int _maxDurationDiffMs = 20 * 1000;

  // 匹配算法
  FavoritesImportCandidate? matchTrack({
    required FavoritesImportTrack track,
    required List<SearchResultItem> candidates,
  }) {
    for (final SearchResultItem candidate in candidates) {
      if (_blacklistZones.contains(candidate.typeId)) {
        continue;
      }

      final int durationMs = _parseDurationMs(candidate.duration);
      if (durationMs <= 0 || track.durationMs <= 0) {
        continue;
      }

      final int durationDiff = (durationMs - track.durationMs).abs();
      if (durationDiff > _maxDurationDiffMs) {
        continue;
      }

      return FavoritesImportCandidate(
        aid: candidate.aid,
        bvid: candidate.bvid,
        title: candidate.title,
        author: candidate.author,
        coverUrl: candidate.coverUrl,
        durationText: candidate.duration,
        durationMs: durationMs,
        score: _scoreFor(candidate.typeId, durationDiff),
      );
    }

    return null;
  }

  String buildQuery(FavoritesImportTrack track) {
    final String title = _cleanText(track.title);
    final String author = _cleanText(track.author);
    if (title.isEmpty && author.isEmpty) {
      return '';
    }
    if (author.isEmpty) {
      return title;
    }
    if (title.isEmpty) {
      return author;
    }
    return '$title-$author';
  }

  String _cleanText(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  int _parseDurationMs(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == '--:--') {
      return 0;
    }
    final List<String> segments = trimmed.split(':');
    if (segments.length == 2) {
      final int? minutes = int.tryParse(segments[0]);
      final int? seconds = int.tryParse(segments[1]);
      if (minutes == null || seconds == null) {
        return 0;
      }
      return (minutes * 60 + seconds) * 1000;
    }
    if (segments.length == 3) {
      final int? hours = int.tryParse(segments[0]);
      final int? minutes = int.tryParse(segments[1]);
      final int? seconds = int.tryParse(segments[2]);
      if (hours == null || minutes == null || seconds == null) {
        return 0;
      }
      return ((hours * 60 + minutes) * 60 + seconds) * 1000;
    }
    final int? parsed = int.tryParse(trimmed);
    if (parsed == null || parsed <= 0) {
      return 0;
    }
    return parsed >= 10000 ? parsed : parsed * 1000;
  }

  int _scoreFor(int typeId, int durationDiffMs) {
    final int zonePenalty = _priorityZones.contains(typeId) ? 0 : 100000;
    return zonePenalty + durationDiffMs;
  }
}
