import 'dart:convert';

import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/playback_chapter.dart';
import 'package:bilimusic/feature/player/logic/chapters/playback_chapter_parser.dart';
import 'package:hive_ce/hive.dart';

const String chapterCacheBoxName = 'chapter_cache';

class ChapterCacheRepository {
  const ChapterCacheRepository(this._box);

  final Box<String> _box;

  List<PlaybackChapter> getChapters(String contentId) {
    final String? raw = _box.get(contentId);
    if (raw == null) {
      return const <PlaybackChapter>[];
    }
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const <PlaybackChapter>[];
      }
      final List<PlaybackChapter> chapters = <PlaybackChapter>[];
      for (final Object? value in decoded) {
        if (value is! Map ||
            value['startMs'] is! int ||
            value['title'] is! String ||
            (value['endMs'] != null && value['endMs'] is! int)) {
          return const <PlaybackChapter>[];
        }
        final int startMs = value['startMs'] as int;
        final int? endMs = value['endMs'] as int?;
        if (startMs < 0 || (endMs != null && endMs <= startMs)) {
          return const <PlaybackChapter>[];
        }
        chapters.add(
          PlaybackChapter(
            start: Duration(milliseconds: startMs),
            end: endMs == null ? null : Duration(milliseconds: endMs),
            title: (value['title'] as String).trim(),
          ),
        );
      }
      return PlaybackChapterParser.normalize(chapters);
    } on FormatException {
      return const <PlaybackChapter>[];
    }
  }

  bool isCompilation(PlayableItem item) =>
      getChapters(item.contentId).isNotEmpty || item.isCompilation;

  Stream<BoxEvent> watch(String contentId) => _box.watch(key: contentId);

  Future<void> putChapters(String contentId, List<PlaybackChapter> chapters) {
    final List<PlaybackChapter> normalized = PlaybackChapterParser.normalize(
      chapters,
    );
    if (normalized.isEmpty) {
      return Future<void>.value();
    }
    return _box.put(
      contentId,
      jsonEncode(<Map<String, Object?>>[
        for (final PlaybackChapter chapter in normalized)
          <String, Object?>{
            'startMs': chapter.start.inMilliseconds,
            'endMs': chapter.end?.inMilliseconds,
            'title': chapter.title,
          },
      ]),
    );
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
