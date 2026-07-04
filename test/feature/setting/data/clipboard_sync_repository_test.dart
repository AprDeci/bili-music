import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bilimusic/feature/setting/data/clipboard_sync_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'saveContent initializes and retries when clipboard is missing',
    () async {
      final _FakeHttpClientAdapter adapter = _FakeHttpClientAdapter(
        <_FakeReply>[
          _FakeReply.json(500, <String, Object>{'error': '服务器错误: 剪贴板不存在'}),
          _FakeReply.text(200, '<html></html>'),
          _FakeReply.json(200, <String, Object>{'success': true}),
          _FakeReply.json(200, <String, Object>{'success': true}),
        ],
      );
      final ClipboardSyncRepository repository = ClipboardSyncRepository(
        dio: _dioWithAdapter(adapter),
      );

      await repository.saveContent(
        clipboardName: '123bilimusic',
        content: '{"v":1}',
      );

      expect(
        adapter.requests.map((String request) => request.split(' ').take(2)),
        <Iterable<String>>[
          <String>['POST', '/api/clipboard/123bilimusic'],
          <String>['GET', '/123bilimusic'],
          <String>['POST', '/api/clipboard/123bilimusic'],
          <String>['PUT', '/api/clipboard/123bilimusic/settings'],
        ],
      );
      expect(adapter.requests.last, contains('"expireHours":0'));
    },
  );

  test('saveContent does not initialize page when save succeeds', () async {
    final _FakeHttpClientAdapter adapter = _FakeHttpClientAdapter(<_FakeReply>[
      _FakeReply.json(200, <String, Object>{'success': true}),
      _FakeReply.json(200, <String, Object>{'success': true}),
    ]);
    final ClipboardSyncRepository repository = ClipboardSyncRepository(
      dio: _dioWithAdapter(adapter),
    );

    await repository.saveContent(
      clipboardName: '123bilimusic',
      content: '{"v":1}',
    );

    expect(
      adapter.requests.map((String request) => request.split(' ').take(2)),
      <Iterable<String>>[
        <String>['POST', '/api/clipboard/123bilimusic'],
        <String>['PUT', '/api/clipboard/123bilimusic/settings'],
      ],
    );
  });
}

Dio _dioWithAdapter(_FakeHttpClientAdapter adapter) {
  return Dio(BaseOptions(baseUrl: 'https://jq.torgw.com'))
    ..httpClientAdapter = adapter;
}

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this._replies);

  final List<_FakeReply> _replies;
  final List<String> requests = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final String body = await _readBody(requestStream);
    requests.add('${options.method} ${options.uri.path} $body');
    if (_replies.isEmpty) {
      return ResponseBody.fromString(
        jsonEncode(<String, Object>{'error': 'unexpected request'}),
        500,
      );
    }
    final _FakeReply reply = _replies.removeAt(0);
    return ResponseBody.fromString(
      reply.body,
      reply.statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[reply.contentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}

  Future<String> _readBody(Stream<Uint8List>? requestStream) async {
    if (requestStream == null) {
      return '';
    }
    return utf8.decode(
      await requestStream.expand((Uint8List data) => data).toList(),
    );
  }
}

class _FakeReply {
  const _FakeReply({
    required this.statusCode,
    required this.body,
    required this.contentType,
  });

  factory _FakeReply.json(int statusCode, Map<String, Object> body) {
    return _FakeReply(
      statusCode: statusCode,
      body: jsonEncode(body),
      contentType: Headers.jsonContentType,
    );
  }

  factory _FakeReply.text(int statusCode, String body) {
    return _FakeReply(
      statusCode: statusCode,
      body: body,
      contentType: Headers.textPlainContentType,
    );
  }

  final int statusCode;
  final String body;
  final String contentType;
}
