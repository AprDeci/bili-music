import 'dart:io';

import 'package:bilimusic/feature/player/data/chapter_cache_repository.dart';
import 'package:hive_ce/hive.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/comment/data/bilibili_comment_repository.dart';
import 'package:bilimusic/feature/comment/domain/comment_item.dart';
import 'package:bilimusic/feature/comment/domain/comment_page_result.dart';
import 'package:bilimusic/feature/comment/domain/comment_sort.dart';
import 'package:bilimusic/feature/comment/domain/comment_target.dart';
import 'package:bilimusic/feature/player/data/bili_chapter_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/playback_chapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

const String _playerPath = '/x/player/wbi/v2';

void main() {
  late Directory directory;
  late Box<String> box;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('chapter_repository_');
    Hive.init(directory.path);
    box = await Hive.openBox<String>(chapterCacheBoxName);
  });
  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('maps bilibili view points into chapters', () async {
    final _FakeClient client = _FakeClient(
      responses: <String, Map<String, dynamic>>{
        _playerPath: <String, dynamic>{
          'code': 0,
          'data': <String, dynamic>{
            'view_points': <Map<String, dynamic>>[
              <String, dynamic>{
                'from': 0,
                'to': 120,
                'content': '第一首',
                'type': 1,
              },
              <String, dynamic>{
                'from': 120,
                'to': 260,
                'content': '第二首',
                'type': 1,
              },
            ],
          },
        },
      },
    );
    final BiliChapterRepository repository = BiliChapterRepository(
      client,
      _FakeCommentRepository(null),
    );

    final List<PlaybackChapter> chapters = await repository.fetchChapters(
      _item(),
    );

    expect(chapters.length, 2);
    expect(chapters.first.title, '第一首');
    expect(chapters.first.start, Duration.zero);
    expect(chapters[1].start, const Duration(minutes: 2));
  });

  test(
    'falls back to description timestamps when view points are empty',
    () async {
      final _FakeClient client = _FakeClient(
        responses: <String, Map<String, dynamic>>{
          _playerPath: <String, dynamic>{
            'code': 0,
            'data': <String, dynamic>{},
          },
        },
      );
      final BiliChapterRepository repository = BiliChapterRepository(
        client,
        _FakeCommentRepository(null),
      );

      final List<PlaybackChapter> chapters = await repository.fetchChapters(
        _item(description: '00:00 夜曲\n03:45 晴天'),
      );

      expect(chapters.length, 2);
      expect(chapters.first.title, '夜曲');
    },
  );

  test('falls back to the pinned comment when logged in', () async {
    final _FakeClient client = _FakeClient(
      session: const BiliSession(
        sessData: 'sess',
        biliJct: 'jct',
        dedeUserId: '42',
        refreshToken: '',
        cookie: '',
      ),
      responses: <String, Map<String, dynamic>>{
        _playerPath: <String, dynamic>{'code': 0, 'data': <String, dynamic>{}},
      },
    );
    final _FakeCommentRepository comments = _FakeCommentRepository(
      CommentPageResult(
        topItem: _comment('01:00 第一首\n05:00 第二首'),
        items: <CommentItem>[_comment('00:00 非置顶第一首\n03:00 非置顶第二首')],
        page: 1,
        pageSize: 20,
        totalCount: 2,
        hasMore: false,
      ),
    );
    final BiliChapterRepository repository = BiliChapterRepository(
      client,
      comments,
    );

    final List<PlaybackChapter> chapters = await repository.fetchChapters(
      _item(),
    );

    expect(comments.calls, 1);
    expect(chapters.length, 2);
    expect(chapters.first.start, const Duration(minutes: 1));
  });

  for (final bool hasPinnedComment in <bool>[false, true]) {
    for (final bool firstHasChapters in <bool>[false, true]) {
      test(
        'only checks first hottest comment '
        '(pinned=$hasPinnedComment, firstHasChapters=$firstHasChapters)',
        () async {
          final _FakeClient client = _FakeClient(
            session: const BiliSession(
              sessData: 'sess',
              biliJct: 'jct',
              dedeUserId: '42',
              refreshToken: '',
              cookie: '',
            ),
          );
          final _FakeCommentRepository comments = _FakeCommentRepository(
            CommentPageResult(
              topItem: hasPinnedComment ? _comment('欢迎收听') : null,
              items: <CommentItem>[
                _comment(firstHasChapters ? '00:00 首条歌曲一\n03:00 首条歌曲二' : '好听'),
                _comment('00:00 后续歌曲一\n03:00 后续歌曲二'),
              ],
              hotItems: <CommentItem>[_comment('00:00 热评歌曲一\n03:00 热评歌曲二')],
              page: 1,
              pageSize: 2,
              totalCount: 100,
              hasMore: true,
              nextOffset: 'next-page',
            ),
          );
          final BiliChapterRepository repository = BiliChapterRepository(
            client,
            comments,
          );

          final List<PlaybackChapter> chapters = await repository.fetchChapters(
            _item(),
          );

          expect(comments.calls, 1);
          expect(comments.requestedSort, CommentSort.like);
          expect(comments.requestedIncludeHot, isFalse);
          if (firstHasChapters) {
            expect(
              chapters.map((PlaybackChapter chapter) => chapter.title),
              <String>['首条歌曲一', '首条歌曲二'],
            );
          } else {
            expect(chapters, isEmpty);
          }
        },
      );
    }
  }

  test('skips comment fallback when not logged in', () async {
    final _FakeClient client = _FakeClient(
      responses: <String, Map<String, dynamic>>{
        _playerPath: <String, dynamic>{'code': 0, 'data': <String, dynamic>{}},
      },
    );
    final _FakeCommentRepository comments = _FakeCommentRepository(
      CommentPageResult(
        topItem: _comment('01:00 第一首\n05:00 第二首'),
        items: <CommentItem>[_comment('00:00 非置顶第一首\n03:00 非置顶第二首')],
        page: 1,
        pageSize: 20,
        totalCount: 2,
        hasMore: false,
      ),
    );
    final BiliChapterRepository repository = BiliChapterRepository(
      client,
      comments,
    );

    expect(await repository.fetchChapters(_item()), isEmpty);
    expect(comments.calls, 0);
  });

  test('caches resolved chapters per content', () async {
    final _FakeClient client = _FakeClient(
      responses: <String, Map<String, dynamic>>{
        _playerPath: <String, dynamic>{
          'code': 0,
          'data': <String, dynamic>{
            'view_points': <Map<String, dynamic>>[
              <String, dynamic>{'from': 0, 'to': 60, 'content': '第一首'},
              <String, dynamic>{'from': 60, 'to': 120, 'content': '第二首'},
            ],
          },
        },
      },
    );
    final BiliChapterRepository repository = BiliChapterRepository(
      client,
      _FakeCommentRepository(null),
    );

    await repository.fetchChapters(_item());
    await repository.fetchChapters(_item());

    expect(client.calls, 1);
  });

  test(
    'persists chapters across a box reopen without network requests',
    () async {
      final _FakeClient client = _FakeClient();
      final BiliChapterRepository first = BiliChapterRepository(
        client,
        _FakeCommentRepository(null),
        chapterCache: ChapterCacheRepository(box),
      );
      final List<PlaybackChapter> chapters = await first.fetchChapters(
        _item(description: '00:00 第一首\n03:00 第二首'),
      );
      expect(chapters, hasLength(2));
      await box.close();
      box = await Hive.openBox<String>(chapterCacheBoxName);
      final _FakeClient offlineClient = _FakeClient();
      final BiliChapterRepository reopened = BiliChapterRepository(
        offlineClient,
        _FakeCommentRepository(null),
        chapterCache: ChapterCacheRepository(box),
      );

      expect(await reopened.fetchChapters(_item()), chapters);
      expect(offlineClient.calls, 0);
      expect(
        await reopened.fetchChapters(
          _item(),
          duration: const Duration(minutes: 1),
        ),
        isEmpty,
      );
      expect(await reopened.fetchChapters(_item()), chapters);
      expect(await reopened.fetchChapters(_item().copyWith(page: 2)), isEmpty);
      expect(offlineClient.calls, 1);
      await reopened.clearCache();
      expect(box.isEmpty, isTrue);
      expect(await reopened.fetchChapters(_item()), isEmpty);
      expect(offlineClient.calls, 2);
    },
  );

  test(
    'does not persist an empty result across repository instances',
    () async {
      final _FakeClient client = _FakeClient();
      final BiliChapterRepository first = BiliChapterRepository(
        client,
        _FakeCommentRepository(null),
        chapterCache: ChapterCacheRepository(box),
      );
      expect(await first.fetchChapters(_item()), isEmpty);
      expect(box.isEmpty, isTrue);
      final BiliChapterRepository next = BiliChapterRepository(
        client,
        _FakeCommentRepository(null),
        chapterCache: ChapterCacheRepository(box),
      );
      expect(
        await next.fetchChapters(_item(description: '00:00 第一首\n03:00 第二首')),
        hasLength(2),
      );
      expect(client.calls, 2);
    },
  );

  test(
    'invalid persisted data is ignored and replaced by fresh chapters',
    () async {
      for (final String raw in <String>[
        'broken json',
        '{}',
        '[{"startMs":-1,"title":"坏数据"}]',
        '[{"startMs":"0","title":"坏数据"}]',
        '[{"startMs":0,"title":"坏数据","endMs":-1}]',
        '[{"startMs":0,"title":"只有一章"}]',
      ]) {
        await box.put(_item().contentId, raw);
        final ChapterCacheRepository cache = ChapterCacheRepository(box);
        expect(cache.getChapters(_item().contentId), isEmpty);
        final BiliChapterRepository repository = BiliChapterRepository(
          _FakeClient(),
          _FakeCommentRepository(null),
          chapterCache: cache,
        );
        expect(
          await repository.fetchChapters(
            _item(description: '00:00 第一首\n03:00 第二首'),
          ),
          hasLength(2),
        );
        expect(cache.getChapters(_item().contentId), hasLength(2));
      }
    },
  );

  test('drops chapters beyond the media duration', () async {
    final _FakeClient client = _FakeClient(
      responses: <String, Map<String, dynamic>>{
        _playerPath: <String, dynamic>{'code': 0, 'data': <String, dynamic>{}},
      },
    );
    final BiliChapterRepository repository = BiliChapterRepository(
      client,
      _FakeCommentRepository(null),
    );

    final List<PlaybackChapter> chapters = await repository.fetchChapters(
      _item(description: '00:00 夜曲\n03:45 晴天\n10:00 稻香'),
      duration: const Duration(minutes: 5),
    );

    expect(chapters.length, 2);
    expect(chapters.last.title, '晴天');
  });
}

PlayableItem _item({String? description}) {
  return PlayableItem(
    aid: 1,
    bvid: 'BV1',
    cid: 10,
    page: 1,
    title: '合集',
    author: 'UP',
    coverUrl: '',
    description: description,
  );
}

CommentItem _comment(String message) {
  return CommentItem(
    rpid: 1,
    oid: 1,
    type: 1,
    root: 0,
    parent: 0,
    replyCount: 0,
    likeCount: 0,
    action: 0,
    publishedAt: DateTime(2026),
    message: message,
    memberName: 'UP',
    memberAvatarUrl: '',
    isTop: true,
  );
}

class _FakeClient implements BiliHttpClient {
  _FakeClient({this.session, Map<String, Map<String, dynamic>>? responses})
    : responses = responses ?? <String, Map<String, dynamic>>{};

  final BiliSession? session;
  final Map<String, Map<String, dynamic>> responses;
  int calls = 0;

  @override
  BiliSession? get currentSession => session;

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
    bool requiresWbi = false,
    BiliRequestMode mode = BiliRequestMode.defaultCookie,
    Options? options,
  }) async {
    calls++;
    return responses[path] ?? <String, dynamic>{'code': -352};
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCommentRepository extends BiliCommentRepository {
  _FakeCommentRepository(this.result) : super(_FakeClient());

  final CommentPageResult? result;
  int calls = 0;
  CommentSort? requestedSort;
  bool? requestedIncludeHot;

  @override
  Future<CommentPageResult> fetchRootComments(
    CommentTarget target, {
    int page = 1,
    String? nextOffset,
    CommentSort sort = CommentSort.time,
    bool includeHot = true,
  }) async {
    calls++;
    requestedSort = sort;
    requestedIncludeHot = includeHot;
    return result ??
        CommentPageResult(page: 1, pageSize: 20, totalCount: 0, hasMore: false);
  }
}
