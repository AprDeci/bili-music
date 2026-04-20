import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bilimusic/feature/meting/data/meting_repository.dart';
import 'package:bilimusic/feature/meting/domain/meting_search_item.dart';
import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MetingRepository', () {
    test('search rejects missing base URL', () async {
      final MetingRepository repository = MetingRepository(Dio());

      await expectLater(
        repository.search(keyword: '周杰伦'),
        throwsA(
          isA<MetingException>().having(
            (MetingException error) => error.message,
            'message',
            contains('配置 Meting API 地址'),
          ),
        ),
      );
    });

    test('search returns empty list for empty keyword', () async {
      final MetingRepository repository = MetingRepository(
        _dioWithResponse(<Map<String, dynamic>>[]),
      );

      final List<MetingSearchItem> items = await repository.search(
        keyword: '   ',
      );

      expect(items, isEmpty);
    });

    test('search parses search response', () async {
      final _FakeHttpClientAdapter adapter = _FakeHttpClientAdapter(
        <Map<String, dynamic>>[
          <String, dynamic>{
            'title': '晴天',
            'author': '周杰伦',
            'url': 'https://meting.example/api?type=url',
            'pic': 'https://meting.example/api?type=pic',
            'lrc': 'https://meting.example/api?type=lrc',
          },
        ],
      );
      final MetingRepository repository = MetingRepository(
        _dioWithAdapter(adapter),
      );

      final List<MetingSearchItem> items = await repository.search(
        keyword: ' 晴天 ',
        server: MetingServer.tencent,
      );

      expect(items, hasLength(1));
      expect(items.single.title, '晴天');
      expect(items.single.author, '周杰伦');
      expect(items.single.lrc, contains('type=lrc'));
      expect(adapter.requests.single.path, '/api');
      expect(adapter.requests.single.queryParameters['server'], 'tencent');
      expect(adapter.requests.single.queryParameters['type'], 'search');
      expect(adapter.requests.single.queryParameters['id'], '晴天');
    });

    test('search falls back to empty strings for missing fields', () async {
      final MetingRepository repository = MetingRepository(
        _dioWithResponse(<Map<String, dynamic>>[
          <String, dynamic>{'title': '歌曲'},
        ]),
      );

      final List<MetingSearchItem> items = await repository.search(
        keyword: '歌曲',
      );

      expect(items.single.title, '歌曲');
      expect(items.single.author, isEmpty);
      expect(items.single.url, isEmpty);
      expect(items.single.pic, isEmpty);
      expect(items.single.lrc, isEmpty);
    });

    test('search rejects malformed response', () async {
      final MetingRepository repository = MetingRepository(
        _dioWithResponse(<String, dynamic>{'bad': true}),
      );

      await expectLater(
        repository.search(keyword: '晴天'),
        throwsA(
          isA<MetingException>().having(
            (MetingException error) => error.message,
            'message',
            contains('返回格式异常'),
          ),
        ),
      );
    });

    test('fetchLyrics returns plain lrc text', () async {
      const String lyrics = '[00:00.000] 歌词第一行';
      final _FakeHttpClientAdapter adapter = _FakeHttpClientAdapter(
        lyrics,
        responseType: _FakeResponseType.text,
      );
      final MetingRepository repository = MetingRepository(
        _dioWithAdapter(adapter),
      );

      final String result = await repository.fetchLyrics(
        const MetingSearchItem(
          title: '晴天',
          author: '周杰伦',
          url: '',
          pic: '',
          lrc: 'https://meting.example/api?server=netease&type=lrc&id=1',
        ),
      );

      expect(result, lyrics);
      expect(adapter.requests.single.path, contains('/api'));
    });

    test('fetchLyrics rejects empty lrc url', () async {
      final MetingRepository repository = MetingRepository(
        _dioWithResponse(<Map<String, dynamic>>[]),
      );

      await expectLater(
        repository.fetchLyrics(
          const MetingSearchItem(
            title: '晴天',
            author: '周杰伦',
            url: '',
            pic: '',
            lrc: '',
          ),
        ),
        throwsA(
          isA<MetingException>().having(
            (MetingException error) => error.message,
            'message',
            contains('没有歌词地址'),
          ),
        ),
      );
    });
  });
}

Dio _dioWithResponse(Object response) {
  return _dioWithAdapter(_FakeHttpClientAdapter(response));
}

Dio _dioWithAdapter(_FakeHttpClientAdapter adapter) {
  return Dio(BaseOptions(baseUrl: 'https://meting.example'))
    ..httpClientAdapter = adapter;
}

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(
    this.response, {
    this.responseType = _FakeResponseType.json,
  });

  final Object response;
  final _FakeResponseType responseType;
  final List<_Request> requests = <_Request>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(
      _Request(
        path: options.path,
        queryParameters: Map<String, dynamic>.from(options.queryParameters),
      ),
    );

    if (responseType == _FakeResponseType.text) {
      return ResponseBody.fromString(
        response.toString(),
        200,
        headers: <String, List<String>>{
          Headers.contentTypeHeader: <String>['text/plain'],
        },
      );
    }

    return ResponseBody.fromString(
      jsonEncode(response),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

enum _FakeResponseType { json, text }

class _Request {
  const _Request({required this.path, required this.queryParameters});

  final String path;
  final Map<String, dynamic> queryParameters;
}
