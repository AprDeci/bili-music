import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/listening/data/bili_history_remote_repository.dart';
import 'package:bilimusic/feature/listening/domain/listening_progress.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeBiliHttpClient client;
  late BiliHistoryRemoteRepository repository;
  const List<Object?> malformedPositions = <Object?>[
    null,
    'invalid',
    '0',
    '-1',
    false,
    <Object?>[],
    <String, Object?>{},
    -0.5,
    -1.5,
    double.nan,
    double.infinity,
    double.negativeInfinity,
  ];

  setUp(() {
    client = _FakeBiliHttpClient();
    repository = BiliHistoryRemoteRepository(client);
  });

  group('fetchProgress', () {
    test(
      'keeps last_play_time in milliseconds and preserves returned cid',
      () async {
        client.getResponses.add(_playerResponse(cid: 202, position: 123456));

        final ListeningProgress? result = await repository.fetchProgress(
          _item(),
          _session(),
        );

        expect(result, isNotNull);
        expect(result!.positionMs, 123456);
        expect(result.cid, 202);
        expect(result.accountId, '1');
        expect(result.aid, 1001);
        expect(result.bvid, 'BVTEST1');
        expect(result.completed, isFalse);
        expect(result.matchesChapter(_item()), isFalse);
        final _Request request = client.requests.single;
        expect(request.path, '/x/player/v2');
        expect(request.queryParameters, <String, dynamic>{
          'aid': 1001,
          'bvid': 'BVTEST1',
          'cid': 101,
        });
        expect(request.requiresAuth, isTrue);
        expect(request.options?.headers?['Cookie'], _session().cookie);
      },
    );

    test('maps the completed sentinel to zero resume position', () async {
      client.getResponses.add(_playerResponse(position: -1));

      final ListeningProgress? result = await repository.fetchProgress(
        _item(),
        _session(),
      );

      expect(result!.completed, isTrue);
      expect(result.positionMs, 0);
      expect(result.resumePosition, Duration.zero);
    });

    test('ignores missing last_play_time', () async {
      client.getResponses.add(<String, dynamic>{
        'code': 0,
        'data': <String, dynamic>{'last_play_cid': 101},
      });

      expect(await repository.fetchProgress(_item(), _session()), isNull);
    });

    for (final Object? position in malformedPositions) {
      test('ignores malformed last_play_time $position', () async {
        client.getResponses.add(<String, dynamic>{
          'code': 0,
          'data': <String, dynamic>{
            'last_play_cid': 101,
            'last_play_time': position,
          },
        });

        expect(await repository.fetchProgress(_item(), _session()), isNull);
      });
    }

    test('preserves numeric zero as unfinished progress', () async {
      client.getResponses.add(_playerResponse(position: 0));

      final ListeningProgress? result = await repository.fetchProgress(
        _item(),
        _session(),
      );

      expect(result!.positionMs, 0);
      expect(result.completed, isFalse);
    });

    for (final int position in <int>[-2, -1000]) {
      test('ignores invalid negative player position $position', () async {
        client.getResponses.add(_playerResponse(position: position));

        expect(await repository.fetchProgress(_item(), _session()), isNull);
      });
    }

    test(
      'does not request player data for invalid video or chapter identity',
      () async {
        client.getResponses.add(_playerResponse());
        for (final PlayableItem item in <PlayableItem>[
          _item().copyWith(aid: 0, bvid: ''),
          _item().copyWith(aid: -1, bvid: ''),
          _item().copyWith(aid: -1),
          _item().copyWith(cid: null),
          _item().copyWith(cid: 0),
          _item().copyWith(cid: -1),
        ]) {
          expect(await repository.fetchProgress(item, _session()), isNull);
        }
        expect(client.requests, isEmpty);
      },
    );

    test('propagates player API errors from the HTTP client', () async {
      const BiliApiException failure = BiliApiException(
        'player rejected',
        code: -101,
      );
      client.getResponses.add(failure);

      await expectLater(
        repository.fetchProgress(_item(), _session()),
        throwsA(same(failure)),
      );
    });

    test('rejects malformed player payload', () async {
      client.getResponses.add(<String, dynamic>{
        'code': 0,
        'data': <dynamic>[],
      });

      await expectLater(
        repository.fetchProgress(_item(), _session()),
        throwsFormatException,
      );
    });
  });

  group('fetchRecent', () {
    test('parses history seconds, completion and chapter metadata', () async {
      client.getResponses.add(
        _historyPage(<Map<String, dynamic>>[
          _historyRow(
            progress: 123,
            viewedAt: 1700000000,
            duration: 240,
            page: 2,
          ),
          _historyRow(aid: 1002, bvid: 'BVTEST2', cid: 202, progress: -1),
          _historyRow(business: 'live'),
          _historyRow(cid: 0),
          _historyRow(progress: -2),
          _historyRow(viewedAt: 0),
          _historyRow(aid: 0, bvid: ''),
          _historyRow(aid: -1),
        ]),
      );

      final List<ListeningProgress> result = await repository.fetchRecent(
        _session(),
      );

      expect(result, hasLength(2));
      expect(result.first.positionMs, 123000);
      expect(result.first.durationMs, 240000);
      expect(result.first.updatedAtMs, 1700000000000);
      expect(result.first.page, 2);
      expect(result.first.cid, 101);
      expect(result.first.accountId, '1');
      expect(result.last.completed, isTrue);
      expect(result.last.positionMs, 0);
      expect(result.last.resumePosition, Duration.zero);
      expect(client.requests.single.queryParameters, <String, dynamic>{
        'type': 'archive',
        'ps': 30,
      });
      expect(client.requests.single.requiresAuth, isTrue);
      expect(
        client.requests.single.options?.headers?['Cookie'],
        _session().cookie,
      );
    });

    test('ignores missing progress', () async {
      client.getResponses.add(
        _historyPage(<Map<String, dynamic>>[_historyRow()..remove('progress')]),
      );

      expect(await repository.fetchRecent(_session()), isEmpty);
    });

    for (final Object? progress in malformedPositions) {
      test('ignores malformed progress $progress', () async {
        client.getResponses.add(
          _historyPage(<Map<String, dynamic>>[
            _historyRow()..['progress'] = progress,
          ]),
        );

        expect(await repository.fetchRecent(_session()), isEmpty);
      });
    }

    test('preserves numeric zero as unfinished progress', () async {
      client.getResponses.add(
        _historyPage(<Map<String, dynamic>>[_historyRow(progress: 0)]),
      );

      final List<ListeningProgress> result = await repository.fetchRecent(
        _session(),
      );

      expect(result.single.positionMs, 0);
      expect(result.single.completed, isFalse);
    });

    test('follows exact cursors until the target video appears', () async {
      client.getResponses.addAll(<Object>[
        _historyPage(
          <Map<String, dynamic>>[_historyRow()],
          max: 91,
          viewedAt: 1700000091,
        ),
        _historyPage(
          <Map<String, dynamic>>[_historyRow(aid: 1002, bvid: 'BVTEST2')],
          max: 80,
          viewedAt: 1700000080,
        ),
        _historyPage(<Map<String, dynamic>>[
          _historyRow(aid: 1003, bvid: 'BVTEST3', cid: 303),
        ], max: 70),
      ]);

      final List<ListeningProgress> result = await repository.fetchRecent(
        _session(),
        videoIds: <String>{'bvid:BVTEST3'},
      );

      expect(result.single.bvid, 'BVTEST3');
      expect(result.single.cid, 303);
      expect(client.requests, hasLength(3));
      expect(client.requests[1].queryParameters, <String, dynamic>{
        'type': 'archive',
        'ps': 30,
        'max': 91,
        'view_at': 1700000091,
        'business': 'archive',
      });
      expect(client.requests[2].queryParameters, <String, dynamic>{
        'type': 'archive',
        'ps': 30,
        'max': 80,
        'view_at': 1700000080,
        'business': 'archive',
      });
    });

    test(
      'matches an aid target even when the history row has a bvid',
      () async {
        client.getResponses.add(
          _historyPage(<Map<String, dynamic>>[_historyRow()]),
        );

        final List<ListeningProgress> result = await repository.fetchRecent(
          _session(),
          videoIds: <String>{'aid:1001'},
        );

        expect(result.single.videoId, 'bvid:BVTEST1');
      },
    );

    test('stops when the server repeats the same cursor', () async {
      final Map<String, dynamic> page = _historyPage(
        <Map<String, dynamic>>[_historyRow()],
        max: 91,
        viewedAt: 1700000091,
      );
      client.getResponses.addAll(<Object>[page, page]);

      expect(
        await repository.fetchRecent(
          _session(),
          videoIds: <String>{'bvid:missing'},
        ),
        isEmpty,
      );
      expect(client.requests, hasLength(2));
    });

    test('stops at an empty history page', () async {
      client.getResponses.addAll(<Object>[
        _historyPage(<Map<String, dynamic>>[_historyRow()], max: 91),
        _historyPage(<Map<String, dynamic>>[], max: 80),
      ]);

      expect(
        await repository.fetchRecent(
          _session(),
          videoIds: <String>{'bvid:missing'},
        ),
        isEmpty,
      );
      expect(client.requests, hasLength(2));
    });

    test('stops at the terminal zero cursor', () async {
      client.getResponses.add(
        _historyPage(<Map<String, dynamic>>[_historyRow()], max: 0),
      );

      expect(
        await repository.fetchRecent(
          _session(),
          videoIds: <String>{'bvid:missing'},
        ),
        isEmpty,
      );
      expect(client.requests, hasLength(1));
    });

    test('keeps the supplied cookie and account across pagination', () async {
      final BiliSession pinned = _session();
      client.getResponses.addAll(<Object>[
        _historyPage(<Map<String, dynamic>>[_historyRow()], max: 91),
        _historyPage(<Map<String, dynamic>>[_historyRow(bvid: 'BVTEST2')]),
      ]);
      client.onGet = () => client.currentSession = _session(accountId: '2');

      final List<ListeningProgress> result = await repository.fetchRecent(
        pinned,
        videoIds: <String>{'bvid:BVTEST2'},
      );

      expect(result.single.accountId, pinned.dedeUserId);
      expect(client.requests, hasLength(2));
      expect(
        client.requests.every(
          (_Request request) =>
              request.options?.headers?['Cookie'] == pinned.cookie,
        ),
        isTrue,
      );
    });

    for (final Object? data in <Object?>[
      null,
      <dynamic>[],
      <String, dynamic>{'list': 'not a list'},
      <String, dynamic>{
        'list': <dynamic>[null],
      },
      <String, dynamic>{
        'list': <dynamic>[
          <String, dynamic>{'history': null},
        ],
      },
    ]) {
      test('rejects malformed history data $data', () async {
        client.getResponses.add(<String, dynamic>{'code': 0, 'data': data});

        await expectLater(
          repository.fetchRecent(_session()),
          throwsFormatException,
        );
      });
    }

    test('propagates history API errors from the HTTP client', () async {
      const BiliApiException failure = BiliApiException(
        'history rejected',
        code: -403,
      );
      client.getResponses.add(failure);

      await expectLater(
        repository.fetchRecent(_session()),
        throwsA(same(failure)),
      );
    });
  });

  group('report', () {
    test(
      'posts form data with csrf, pinned cookie and whole seconds',
      () async {
        final BiliSession pinned = _session();
        client.currentSession = pinned.copyWith(
          cookie: 'SESSDATA=rotated; bili_jct=rotated',
        );
        client.postResponse = <String, dynamic>{'code': 0};

        await repository.report(_progress(positionMs: 123456), pinned);

        final _Request request = client.requests.single;
        expect(request.path, '/x/v2/history/report');
        expect(request.data, <String, dynamic>{
          'aid': 1001,
          'cid': 101,
          'progress': 123,
          'platform': 'android',
          'csrf': pinned.biliJct,
        });
        expect(request.options?.contentType, Headers.formUrlEncodedContentType);
        expect(request.options?.headers?['Cookie'], pinned.cookie);
      },
    );

    test('reports completed playback as minus one', () async {
      client.postResponse = <String, dynamic>{'code': 0};

      await repository.report(
        _progress().copyWith(completed: true),
        _session(),
      );

      expect(
        (client.requests.single.data as Map<String, dynamic>)['progress'],
        -1,
      );
    });

    test('refuses a progress record belonging to another account', () async {
      await expectLater(
        repository.report(_progress().copyWith(accountId: '2'), _session()),
        throwsFormatException,
      );

      expect(client.requests, isEmpty);
    });

    test('throws a typed error for a nonzero API code', () async {
      client.postResponse = <String, dynamic>{
        'code': -111,
        'message': 'csrf rejected',
      };

      await expectLater(
        repository.report(_progress(), _session()),
        throwsA(
          isA<BiliApiException>()
              .having((BiliApiException error) => error.code, 'code', -111)
              .having(
                (BiliApiException error) => error.message,
                'message',
                'csrf rejected',
              ),
        ),
      );
    });

    for (final Object? response in <Object?>[
      null,
      'not json',
      <dynamic>[],
      <String, dynamic>{},
      <String, dynamic>{'code': 'invalid'},
      <String, dynamic>{'code': double.nan},
    ]) {
      test('rejects malformed report response $response', () async {
        client.postResponse = response;

        await expectLater(
          repository.report(_progress(), _session()),
          throwsA(anyOf(isA<FormatException>(), isA<BiliApiException>())),
        );
      });
    }

    final Map<String, ListeningProgress> invalidProgress =
        <String, ListeningProgress>{
          'missing video identity': _progress().copyWith(aid: 0, bvid: ''),
          'missing report aid with bvid': _progress().copyWith(aid: 0),
          'negative aid without bvid': _progress().copyWith(aid: -1, bvid: ''),
          'negative aid with bvid': _progress().copyWith(aid: -1),
          'zero cid': _progress().copyWith(cid: 0),
          'negative cid': _progress().copyWith(cid: -1),
          'zero page': _progress().copyWith(page: 0),
          'negative position': _progress().copyWith(positionMs: -1),
          'negative duration': _progress().copyWith(durationMs: -1),
          'negative timestamp': _progress().copyWith(updatedAtMs: -1),
        };
    for (final MapEntry<String, ListeningProgress> entry
        in invalidProgress.entries) {
      test('refuses ${entry.key} before posting', () async {
        client.postResponse = <String, dynamic>{'code': 0};

        await expectLater(
          repository.report(entry.value, _session()),
          throwsFormatException,
        );
        expect(client.requests, isEmpty);
      });
    }
  });

  group('account guard', () {
    for (final BiliSession? current in <BiliSession?>[
      null,
      _session(accountId: '2'),
      _session().clearAuth(),
    ]) {
      test('refuses all requests for stale session $current', () async {
        client.currentSession = current;

        await expectLater(
          repository.fetchProgress(_item(), _session()),
          throwsA(isA<BiliApiException>()),
        );
        await expectLater(
          repository.fetchRecent(_session()),
          throwsA(isA<BiliApiException>()),
        );
        await expectLater(
          repository.report(_progress(), _session()),
          throwsA(isA<BiliApiException>()),
        );
        expect(client.requests, isEmpty);
      });
    }

    test('refuses an unauthenticated supplied session', () async {
      final BiliSession loggedOut = _session().clearAuth();

      await expectLater(
        repository.fetchProgress(_item(), loggedOut),
        throwsA(isA<BiliApiException>()),
      );
      await expectLater(
        repository.fetchRecent(loggedOut),
        throwsA(isA<BiliApiException>()),
      );
      await expectLater(
        repository.report(_progress(), loggedOut),
        throwsA(isA<BiliApiException>()),
      );
      expect(client.requests, isEmpty);
    });
  });
}

Map<String, dynamic> _playerResponse({
  int cid = 101,
  int position = 45678,
}) => <String, dynamic>{
  'code': 0,
  'data': <String, dynamic>{'last_play_cid': cid, 'last_play_time': position},
};

Map<String, dynamic> _historyPage(
  List<Map<String, dynamic>> rows, {
  int max = 0,
  int viewedAt = 1700000000,
}) => <String, dynamic>{
  'code': 0,
  'data': <String, dynamic>{
    'list': rows,
    'cursor': <String, dynamic>{
      'max': max,
      'view_at': viewedAt,
      'business': 'archive',
    },
  },
};

Map<String, dynamic> _historyRow({
  int aid = 1001,
  String bvid = 'BVTEST1',
  int cid = 101,
  int page = 1,
  int progress = 42,
  int duration = 200,
  int viewedAt = 1700000000,
  String business = 'archive',
}) => <String, dynamic>{
  'history': <String, dynamic>{
    'oid': aid,
    'bvid': bvid,
    'cid': cid,
    'page': page,
    'business': business,
  },
  'progress': progress,
  'duration': duration,
  'view_at': viewedAt,
};

PlayableItem _item() => const PlayableItem(
  aid: 1001,
  bvid: 'BVTEST1',
  cid: 101,
  page: 1,
  title: 'Video',
  author: 'Author',
  coverUrl: '',
);

ListeningProgress _progress({int positionMs = 42000}) => ListeningProgress(
  accountId: '1',
  aid: 1001,
  bvid: 'BVTEST1',
  cid: 101,
  positionMs: positionMs,
  updatedAtMs: 1700000000000,
  pendingSync: true,
);

BiliSession _session({String accountId = '1'}) => BiliSession(
  sessData: 'sess-$accountId',
  biliJct: 'csrf-$accountId',
  dedeUserId: accountId,
  refreshToken: '',
  cookie:
      'SESSDATA=sess-$accountId; bili_jct=csrf-$accountId; DedeUserID=$accountId',
);

class _FakeBiliHttpClient implements BiliHttpClient {
  @override
  BiliSession? currentSession = _session();

  final List<Object> getResponses = <Object>[];
  final List<_Request> requests = <_Request>[];
  Object? postResponse;
  void Function()? onGet;

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
    bool requiresWbi = false,
    BiliRequestMode mode = BiliRequestMode.defaultCookie,
    Options? options,
  }) async {
    requests.add(
      _Request(
        path: path,
        queryParameters: queryParameters,
        requiresAuth: requiresAuth,
        options: options,
      ),
    );
    if (getResponses.isEmpty) throw StateError('Unexpected request: $path');
    final Object response = getResponses.removeAt(0);
    onGet?.call();
    if (response is Exception) throw response;
    return response as Map<String, dynamic>;
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    requests.add(
      _Request(
        path: path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
    return Response<T>(
      data: postResponse as T?,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Request {
  const _Request({
    required this.path,
    this.queryParameters,
    this.requiresAuth = false,
    this.options,
    this.data,
  });

  final String path;
  final Map<String, dynamic>? queryParameters;
  final bool requiresAuth;
  final Options? options;
  final Object? data;
}
