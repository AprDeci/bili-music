import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/player/data/bili_subtitle_repository.dart';
import 'package:bilimusic/feature/player/domain/bili_subtitle.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'fetchTracks uses type for AI and ai_type only for translation',
    () async {
      final _FakeBiliHttpClient client = _FakeBiliHttpClient();
      client.json = _response(<Object?>[
        _track(type: 0, aiType: 1),
        _track(type: 1, aiType: 0),
        _track(type: 1, aiType: 1, id: 'translated'),
      ]);

      final List<BiliSubtitleTrack> tracks = await BiliSubtitleRepository(
        client,
      ).fetchTracks(_item);

      expect(tracks, <BiliSubtitleTrack>[
        const BiliSubtitleTrack(
          id: 'original',
          language: 'ai-zh',
          label: '中文（自动生成）',
          url: _url,
        ),
        const BiliSubtitleTrack(
          id: 'translated',
          language: 'ai-zh',
          label: '中文（自动生成）',
          url: _url,
          isTranslated: true,
        ),
      ]);
      expect(client.paths.single, '/x/player/wbi/v2');
      expect(client.query, <String, dynamic>{'bvid': 'BVtest', 'cid': 22});
      expect(client.requiresAuth, isTrue);
      expect(client.requiresWbi, isTrue);
    },
  );

  test('fetchTracks omits unavailable tracks with empty URLs', () async {
    final _FakeBiliHttpClient client = _FakeBiliHttpClient()
      ..json = _response(<Object?>[
        _track(type: 1, aiType: 0, url: ''),
        _track(type: 1, aiType: 0, id: 'available'),
      ]);
    final tracks = await BiliSubtitleRepository(client).fetchTracks(_item);
    expect(tracks.map((track) => track.id), ['available']);
  });

  test('fetchTracks supports aid and sessions without WBI keys', () async {
    final _FakeBiliHttpClient client = _FakeBiliHttpClient()
      ..currentSession = _session.copyWith(imgKey: null, subKey: null);
    expect(
      await BiliSubtitleRepository(
        client,
      ).fetchTracks(_item.copyWith(bvid: '')),
      isEmpty,
    );
    expect(client.query, <String, dynamic>{'aid': 11, 'cid': 22});
    expect(client.requiresWbi, isFalse);
  });

  test('fetchTracks skips requests without login or cid', () async {
    final _FakeBiliHttpClient client = _FakeBiliHttpClient();
    final BiliSubtitleRepository repository = BiliSubtitleRepository(client);
    expect(await repository.fetchTracks(_item.copyWith(cid: null)), isEmpty);
    expect(await repository.fetchTracks(_item.copyWith(cid: 0)), isEmpty);
    client.currentSession = _session.clearAuth();
    expect(await repository.fetchTracks(_item), isEmpty);
    client.currentSession = null;
    expect(await repository.fetchTracks(_item), isEmpty);
    expect(client.paths, isEmpty);
  });

  test('fetchTracks validates response identities when present', () async {
    for (final Map<String, dynamic> mismatch in <Map<String, dynamic>>[
      <String, dynamic>{'cid': 23},
      <String, dynamic>{'aid': 12},
      <String, dynamic>{'bvid': 'BVother'},
    ]) {
      final _FakeBiliHttpClient client = _FakeBiliHttpClient();
      client.json = _response(<Object?>[]);
      (client.json['data'] as Map<String, dynamic>).addAll(mismatch);
      await expectLater(
        BiliSubtitleRepository(client).fetchTracks(_item),
        throwsA(isA<BiliSubtitleException>()),
      );
    }
  });

  test(
    'missing or gated subtitle metadata is not a successful empty list',
    () async {
      for (final Map<String, dynamic> data in <Map<String, dynamic>>[
        <String, dynamic>{},
        <String, dynamic>{'need_login_subtitle': true},
        <String, dynamic>{'subtitle': <String, dynamic>{}},
        <String, dynamic>{
          'login_mid': 0,
          'subtitle': <String, dynamic>{'subtitles': <Object?>[]},
        },
        <String, dynamic>{
          'need_login_subtitle': true,
          'subtitle': <String, dynamic>{'subtitles': <Object?>[]},
        },
      ]) {
        final _FakeBiliHttpClient client = _FakeBiliHttpClient()
          ..json = <String, dynamic>{'code': 0, 'data': data};
        await expectLater(
          BiliSubtitleRepository(client).fetchTracks(_item),
          throwsA(isA<BiliSubtitleException>()),
        );
      }
    },
  );

  test('API errors and auth failures are not swallowed', () async {
    final _FakeBiliHttpClient client = _FakeBiliHttpClient()
      ..json = <String, dynamic>{'code': -352};
    final BiliSubtitleRepository repository = BiliSubtitleRepository(client);
    await expectLater(
      repository.fetchTracks(_item),
      throwsA(isA<BiliSubtitleException>()),
    );
    const BiliApiException error = BiliApiException('Blocked', code: -403);
    client.error = error;
    await expectLater(repository.fetchTracks(_item), throwsA(same(error)));
  });

  test(
    'unsafe URLs are rejected both in metadata and before download',
    () async {
      for (final String url in <String>[
        'http://aisubtitle.hdslb.com/subtitle.json',
        'https://evil.com/subtitle.json',
        'https://hdslb.com.evil.com/subtitle.json',
        'https://evilhdslb.com/subtitle.json',
        'https://hdslb.com/subtitle.json',
        'https://user@aisubtitle.hdslb.com/subtitle.json',
        'https://@aisubtitle.hdslb.com/subtitle.json',
        'https://aisubtitle.hdslb.com:443/subtitle.json',
        'https://aisubtitle.hdslb.com:/subtitle.json',
        'https://-bad.hdslb.com/subtitle.json',
        'https://aisubtitle.hdslb.com./subtitle.json',
        'https://aisubtitle.hdslb.com/subtitle.json#fragment',
        '/subtitle.json',
        'not a url',
      ]) {
        final _FakeBiliHttpClient client = _FakeBiliHttpClient()
          ..json = _response(<Object?>[_track(url: url)]);
        final BiliSubtitleRepository repository = BiliSubtitleRepository(
          client,
        );
        await expectLater(
          repository.fetchTracks(_item),
          throwsA(isA<BiliSubtitleException>()),
          reason: url,
        );
        client.paths.clear();
        await expectLater(
          repository.fetchLines(_subtitle.copyWith(url: url)),
          throwsA(isA<BiliSubtitleException>()),
          reason: url,
        );
        expect(client.paths, isEmpty);
      }
    },
  );

  test(
    'fetchLines downloads anonymously and stably sorts millisecond lines',
    () async {
      final _FakeBiliHttpClient client = _FakeBiliHttpClient()
        ..body = <String, dynamic>{
          'body': <Object?>[
            _line(2.123, 3.456, 'later'),
            _line(0, 0.001, ' first '),
            _line(2.123, 2.999, 'same start'),
          ],
        };
      final List<BiliSubtitleLine> lines = await BiliSubtitleRepository(client)
          .fetchLines(
            _subtitle.copyWith(url: '//aisubtitle.hdslb.com/subtitle.json'),
          );
      expect(lines, <BiliSubtitleLine>[
        const BiliSubtitleLine(startMs: 0, endMs: 1, text: 'first'),
        const BiliSubtitleLine(startMs: 2123, endMs: 3456, text: 'later'),
        const BiliSubtitleLine(startMs: 2123, endMs: 2999, text: 'same start'),
      ]);
      expect(client.paths.single, _url);
      expect(client.mode, BiliRequestMode.anonymous);
      expect(client.options?.followRedirects, isFalse);
      expect(client.options?.headers, isNull);
    },
  );

  test('fetchLines accepts JSON strings and bilibili CDN subdomains', () async {
    final _FakeBiliHttpClient client = _FakeBiliHttpClient()
      ..body = '{"body":[{"from":0.125,"to":0.5,"content":"text"}]}';
    expect(
      await BiliSubtitleRepository(client).fetchLines(
        _subtitle.copyWith(url: 'https://subtitle.bilibili.com/a.json'),
      ),
      <BiliSubtitleLine>[
        const BiliSubtitleLine(startMs: 125, endMs: 500, text: 'text'),
      ],
    );
    client.body = <String, dynamic>{'body': <Object?>[]};
    expect(await BiliSubtitleRepository(client).fetchLines(_subtitle), isEmpty);
  });

  test('fetchLines rejects malformed payloads and invalid time/text', () async {
    for (final Object? body in <Object?>[
      null,
      'not json',
      '[]',
      <String, dynamic>{
        'data': <String, dynamic>{'body': <Object?>[]},
      },
      <String, dynamic>{'body': 'wrong'},
      for (final Object? line in <Object?>[
        null,
        _line(-1, 1, 'text'),
        _line(double.nan, 1, 'text'),
        _line(0, double.infinity, 'text'),
        _line(0, 1e20, 'text'),
        _line(1, 1, 'text'),
        _line(2, 1, 'text'),
        _line(0, 0.0001, 'text'),
        _line('0', 1, 'text'),
        _line(0, 1, ''),
        _line(0, 1, '  '),
        _line(0, 1, 42),
      ])
        <String, dynamic>{
          'body': <Object?>[line],
        },
    ]) {
      final _FakeBiliHttpClient client = _FakeBiliHttpClient()..body = body;
      await expectLater(
        BiliSubtitleRepository(client).fetchLines(_subtitle),
        throwsA(isA<BiliSubtitleException>()),
        reason: '$body',
      );
    }
  });

  test('fetchLines does not accept HTTP failures or redirects', () async {
    for (final int status in <int>[302, 403, 412, 500]) {
      final _FakeBiliHttpClient client = _FakeBiliHttpClient()
        ..status = status
        ..body = <String, dynamic>{'body': <Object?>[]};
      await expectLater(
        BiliSubtitleRepository(client).fetchLines(_subtitle),
        throwsA(isA<BiliSubtitleException>()),
      );
    }
  });
}

const String _url = 'https://aisubtitle.hdslb.com/subtitle.json';
const BiliSubtitleTrack _subtitle = BiliSubtitleTrack(
  id: 'original',
  language: 'ai-zh',
  label: '中文（自动生成）',
  url: _url,
);
const PlayableItem _item = PlayableItem(
  aid: 11,
  bvid: 'BVtest',
  cid: 22,
  title: '',
  author: '',
  coverUrl: '',
);
const BiliSession _session = BiliSession(
  sessData: 'fake',
  biliJct: 'fake',
  dedeUserId: '42',
  refreshToken: '',
  cookie: 'fake',
  imgKey: 'fake',
  subKey: 'fake',
);

Map<String, dynamic> _track({
  int type = 1,
  int aiType = 0,
  String id = 'original',
  String url = '//aisubtitle.hdslb.com/subtitle.json',
}) => <String, dynamic>{
  'id_str': id,
  'type': type,
  'ai_type': aiType,
  'lan': 'ai-zh',
  'lan_doc': '中文（自动生成）',
  'subtitle_url': url,
};

Map<String, dynamic> _response(List<Object?> tracks) => <String, dynamic>{
  'code': 0,
  'data': <String, dynamic>{
    'aid': 11,
    'bvid': 'BVtest',
    'cid': 22,
    'subtitle': <String, dynamic>{'subtitles': tracks},
  },
};

Map<String, dynamic> _line(Object? from, Object? to, Object? text) =>
    <String, dynamic>{'from': from, 'to': to, 'content': text};

class _FakeBiliHttpClient implements BiliHttpClient {
  @override
  BiliSession? currentSession = _session;

  Map<String, dynamic> json = _response(<Object?>[]);
  Object? body;
  Object? error;
  int status = 200;
  final List<String> paths = <String>[];
  Map<String, dynamic>? query;
  bool requiresAuth = false;
  bool requiresWbi = false;
  BiliRequestMode? mode;
  Options? options;

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
    bool requiresWbi = false,
    BiliRequestMode mode = BiliRequestMode.defaultCookie,
    Options? options,
  }) async {
    paths.add(path);
    query = queryParameters;
    this.requiresAuth = requiresAuth;
    this.requiresWbi = requiresWbi;
    if (error != null) {
      throw error!;
    }
    return json;
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    BiliRequestMode mode = BiliRequestMode.defaultCookie,
  }) async {
    paths.add(path);
    this.mode = mode;
    this.options = options;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: status,
      data: body as T?,
    );
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
