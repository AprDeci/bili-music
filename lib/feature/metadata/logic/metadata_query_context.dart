import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/playback_chapter.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/utils/player_ui_helpers.dart';
import 'package:flutter/foundation.dart';

class MetadataQueryContext {
  const MetadataQueryContext({
    required this.stableId,
    required this.titles,
    required this.chapterStartMs,
  });

  final String stableId;
  final List<String> titles;
  final int? chapterStartMs;

  static const MetadataQueryContext empty = MetadataQueryContext(
    stableId: '',
    titles: <String>[],
    chapterStartMs: null,
  );

  bool get hasChapter => chapterStartMs != null;

  int get lyricBaseOffsetMs => chapterStartMs == null ? 0 : -chapterStartMs!;

  String get defaultKeyword => titles.isEmpty ? '' : titles.first;

  MetadataQueryContext withTitlesUpTo(int count) {
    if (count >= titles.length) {
      return this;
    }
    return MetadataQueryContext(
      stableId: stableId,
      titles: titles.take(count).toList(growable: false),
      chapterStartMs: chapterStartMs,
    );
  }

  bool matches(MetadataQueryContext other) {
    return stableId == other.stableId &&
        chapterStartMs == other.chapterStartMs &&
        listEquals(titles, other.titles);
  }

  static MetadataQueryContext fromState({
    required PlayableItem item,
    required PlayerState state,
  }) {
    final PlaybackChapter? chapter = _currentChapter(state);
    final String itemTitle = item.title.trim();
    final String pageTitle = item.pageTitle?.trim() ?? '';
    final bool hasMultipleParts = state.availableParts.length > 1;

    final List<String> titles = <String>[];
    void addTitle(String value) {
      final String trimmed = value.trim();
      if (trimmed.isEmpty || titles.contains(trimmed)) {
        return;
      }
      titles.add(trimmed);
    }

    if (chapter != null) {
      addTitle(chapter.title);
    } else {
      if (hasMultipleParts) {
        addTitle(pageTitle);
      }
      addTitle(itemTitle);
    }

    return MetadataQueryContext(
      stableId: item.stableId,
      titles: List<String>.unmodifiable(titles),
      chapterStartMs: chapter?.start.inMilliseconds,
    );
  }

  static PlaybackChapter? _currentChapter(PlayerState state) {
    final PlaybackChapter? chapter = resolveCurrentChapter(
      state.chapters,
      state.position,
    );
    if (chapter == null || chapter.title.trim().isEmpty) {
      return null;
    }
    return chapter;
  }
}
