import 'package:bilimusic/common/util/json_util.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/comment/data/bilibili_comment_repository.dart';
import 'package:bilimusic/feature/comment/domain/comment_item.dart';
import 'package:bilimusic/feature/comment/domain/comment_page_result.dart';
import 'package:bilimusic/feature/comment/domain/comment_target.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/playback_chapter.dart';
import 'package:bilimusic/feature/player/logic/chapters/playback_chapter_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bili_chapter_repository.g.dart';

@riverpod
BiliChapterRepository biliChapterRepository(Ref ref) {
  return BiliChapterRepository(
    ref.read(biliClientProvider.notifier),
    ref.read(biliCommentRepositoryProvider),
  );
}

class BiliChapterRepository {
  BiliChapterRepository(this._client, this._commentRepository);

  final BiliHttpClient _client;
  final BiliCommentRepository _commentRepository;
  final Map<String, List<PlaybackChapter>> _cache =
      <String, List<PlaybackChapter>>{};

  Future<List<PlaybackChapter>> fetchChapters(
    PlayableItem item, {
    Duration? duration,
  }) async {
    if (!item.hasIdentity) {
      return const <PlaybackChapter>[];
    }

    final String cacheKey = item.contentId;
    final List<PlaybackChapter>? cached = _cache[cacheKey];
    if (cached != null) {
      return _resolveWithinDuration(cached, duration);
    }

    final List<PlaybackChapter> chapters = await _resolve(item, duration);
    _cache[cacheKey] = chapters;
    return _resolveWithinDuration(chapters, duration);
  }

  void clearCache() {
    _cache.clear();
  }

  Future<List<PlaybackChapter>> _resolve(
    PlayableItem item,
    Duration? duration,
  ) async {
    final List<PlaybackChapter> fromViewPoints = await _fetchViewPoints(item);
    final List<PlaybackChapter> fromDescription = PlaybackChapterParser.parse(
      item.description,
      duration: duration,
    );

    List<PlaybackChapter> base = _chooseFiner(
      base: fromViewPoints,
      candidate: fromDescription,
    );
    if (base.length > _refinementChapterLimit) {
      return base;
    }

    final List<PlaybackChapter> fromComment = await _fetchPinnedCommentChapters(
      item,
      duration,
    );
    final List<PlaybackChapter> result = _chooseFiner(
      base: base,
      candidate: fromComment,
    );
    if (result.length < PlaybackChapterParser.minimumChapterCount) {
      return const <PlaybackChapter>[];
    }
    return result;
  }

  static const int _refinementChapterLimit = 10;
  static const Duration _wholeVideoStartTolerance = Duration(minutes: 1);

  List<PlaybackChapter> _chooseFiner({
    required List<PlaybackChapter> base,
    required List<PlaybackChapter> candidate,
  }) {
    if (candidate.length < PlaybackChapterParser.minimumChapterCount) {
      return base;
    }
    if (base.isEmpty) {
      return candidate;
    }
    if (candidate.length <= base.length) {
      return base;
    }

    final bool candidateStartsEarly =
        candidate.first.start <= _wholeVideoStartTolerance;
    final bool baseStartsEarly = base.first.start <= _wholeVideoStartTolerance;
    if (candidateStartsEarly || !baseStartsEarly) {
      return candidate;
    }

    final List<PlaybackChapter> refined = _refineWithinChapters(
      base: base,
      finer: candidate,
    );
    return refined.length > base.length ? refined : base;
  }

  List<PlaybackChapter> _refineWithinChapters({
    required List<PlaybackChapter> base,
    required List<PlaybackChapter> finer,
  }) {
    final List<PlaybackChapter> result = <PlaybackChapter>[];
    for (int index = 0; index < base.length; index += 1) {
      final PlaybackChapter chapter = base[index];
      final Duration end =
          chapter.end ??
          (index + 1 < base.length
              ? base[index + 1].start
              : const Duration(days: 365));
      final List<PlaybackChapter> nested = <PlaybackChapter>[
        for (final PlaybackChapter entry in finer)
          if (entry.start >= chapter.start && entry.start < end) entry,
      ];
      if (nested.length >= PlaybackChapterParser.minimumChapterCount) {
        result.addAll(nested);
      } else {
        result.add(chapter);
      }
    }
    return PlaybackChapterParser.normalize(result);
  }

  Future<List<PlaybackChapter>> _fetchViewPoints(PlayableItem item) async {
    final int? cid = item.cid;
    if (cid == null || cid <= 0 || !item.hasIdentity) {
      return const <PlaybackChapter>[];
    }

    final BiliSession? session = _client.currentSession;
    try {
      final Map<String, dynamic> json = await _client.getJson(
        '/x/player/wbi/v2',
        queryParameters: <String, dynamic>{
          if (item.bvid.isNotEmpty) 'bvid': item.bvid else 'aid': item.aid,
          'cid': cid,
        },
        requiresWbi: session?.hasWbiKeys ?? false,
      );
      if (json['code'] != 0) {
        return const <PlaybackChapter>[];
      }

      final Map<String, dynamic> data = asStringKeyedMapOrEmpty(json['data']);
      final List<PlaybackChapter> chapters = <PlaybackChapter>[];
      for (final Map<String, dynamic> point in asListOfMaps(
        data['view_points'],
      )) {
        final int from = _readInt(point['from']);
        final int to = _readInt(point['to']);
        final String title = (point['content'] as String? ?? '').trim();
        if (from < 0 || title.isEmpty) {
          continue;
        }
        chapters.add(
          PlaybackChapter(
            start: Duration(seconds: from),
            end: to > from ? Duration(seconds: to) : null,
            title: title,
          ),
        );
      }

      return PlaybackChapterParser.normalize(chapters);
    } on Object {
      return const <PlaybackChapter>[];
    }
  }

  Future<List<PlaybackChapter>> _fetchPinnedCommentChapters(
    PlayableItem item,
    Duration? duration,
  ) async {
    final BiliSession? session = _client.currentSession;
    if (session == null || !session.isLoggedIn || item.aid <= 0) {
      return const <PlaybackChapter>[];
    }

    try {
      final CommentPageResult result = await _commentRepository
          .fetchRootComments(
            CommentTarget.video(
              aid: item.aid,
              bvid: item.bvid.isEmpty ? null : item.bvid,
              title: item.title,
              coverUrl: item.coverUrl,
            ),
          );
      final List<CommentItem> candidates = <CommentItem>[
        if (result.topItem != null) result.topItem!,
        ...result.items,
      ];
      List<PlaybackChapter> best = const <PlaybackChapter>[];
      for (final CommentItem comment in candidates) {
        final List<PlaybackChapter> chapters = PlaybackChapterParser.parse(
          comment.message,
          duration: duration,
        );
        if (chapters.length > best.length) {
          best = chapters;
        }
      }
      return best;
    } on Object {
      return const <PlaybackChapter>[];
    }
  }

  List<PlaybackChapter> _resolveWithinDuration(
    List<PlaybackChapter> chapters,
    Duration? duration,
  ) {
    final int limitMs = duration?.inMilliseconds ?? 0;
    if (limitMs <= 0 || chapters.isEmpty) {
      return chapters;
    }

    final List<PlaybackChapter> filtered = chapters
        .where(
          (PlaybackChapter chapter) => chapter.start.inMilliseconds < limitMs,
        )
        .toList(growable: false);
    if (filtered.length < PlaybackChapterParser.minimumChapterCount) {
      return const <PlaybackChapter>[];
    }
    return filtered;
  }

  int _readInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? -1;
    }
    return -1;
  }
}
