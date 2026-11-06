import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/feature/download/data/download_repository.dart';
import 'package:bilimusic/feature/download/domain/download_task.dart';
import 'package:bilimusic/feature/download/domain/downloaded_track.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('downloaded track json round trip', () {
    const DownloadedTrack track = DownloadedTrack(
      contentId: 'bvid:BV1:page:1',
      aid: 1,
      bvid: 'BV1',
      cid: 10,
      page: 1,
      pageTitle: 'P1',
      title: '夜曲',
      author: '周杰伦',
      coverUrl: 'https://example.com/cover.jpg',
      filePath: '/tmp/a.m4a',
      byteLength: 1024,
      downloadedAtMs: 1700000000000,
      durationMs: 225000,
      qualityId: 30280,
      qualityLabel: '192K',
      bandwidth: 192000,
    );
    final DownloadedTrack? parsed = DownloadedTrack.fromJson(track.toJson());
    expect(parsed, isNotNull);
    expect(parsed!.contentId, track.contentId);
    expect(parsed.title, '夜曲');
    expect(parsed.author, '周杰伦');
    expect(parsed.byteLength, 1024);
    expect(parsed.durationMs, 225000);
    expect(parsed.toPlayableItem().stableId, 'bvid:BV1:cid:10');
  });

  test('downloaded track json rejects broken payloads', () {
    expect(DownloadedTrack.fromJson(null), isNull);
    expect(DownloadedTrack.fromJson(<String, Object?>{}), isNull);
    expect(
      DownloadedTrack.fromJson(<String, Object?>{
        'contentId': 'x',
        'filePath': '',
        'byteLength': 1,
        'cid': 1,
      }),
      isNull,
    );
  });

  test(
    'streams to part file, renames before indexing, lists and deletes',
    () async {
      final _MemoryIndexStore store = _MemoryIndexStore();
      final Directory directory = await _directory();
      final CancelToken token = CancelToken();
      final List<int> progress = <int>[];
      store.onPut = (String key, String json) async {
        final DownloadedTrack track = DownloadedTrack.fromJson(
          jsonDecode(json),
        )!;
        expect(File(track.filePath).existsSync(), isTrue);
        expect(File('${track.filePath}.part').existsSync(), isFalse);
      };
      final DownloadRepository repository = DownloadRepository(
        store,
        readDirectory: () async => directory,
        fetcher:
            ({
              required String url,
              required String savePath,
              required Map<String, String> headers,
              required CancelToken cancelToken,
              void Function(int, int)? onProgress,
            }) async {
              expect(url, _stream().streamUrl);
              expect(headers, _stream().headers);
              expect(cancelToken, same(token));
              expect(savePath, endsWith('.m4a.part'));
              expect(store.loadAll(), isEmpty);
              final IOSink sink = File(savePath).openWrite();
              sink.add(<int>[1, 2, 3, 4]);
              await sink.flush();
              onProgress?.call(4, 8);
              expect(directory.listSync().single.path, savePath);
              sink.add(<int>[5, 6, 7, 8]);
              await sink.close();
              onProgress?.call(8, 8);
            },
      );
      final DownloadedTrack track = await repository.downloadTrack(
        item: _item(),
        stream: _stream(),
        cancelToken: token,
        onProgress: (int received, int total) => progress.add(received),
      );
      expect(await File(track.filePath).readAsBytes(), <int>[
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
      ]);
      expect(track.byteLength, 8);
      expect(progress, <int>[4, 8]);
      expect(repository.loadAll().length, 1);
      expect(repository.totalBytes(), 8);
      expect(repository.findByContentId(_item().contentId)?.title, '夜曲');
      await repository.remove(track);
      expect(repository.loadAll(), isEmpty);
      expect(directory.listSync(), isEmpty);
    },
  );

  test('accepts nonempty download without known content length', () async {
    final Directory directory = await _directory();
    final DownloadRepository repository = DownloadRepository(
      _MemoryIndexStore(),
      readDirectory: () async => directory,
      fetcher: _writeAudio,
    );
    final DownloadedTrack track = await repository.downloadTrack(
      item: _item(),
      stream: _stream(),
    );
    expect(track.byteLength, 3);
  });

  for (final String failure in <String>[
    'transport',
    'missing file',
    'empty',
    'truncated',
    'oversized',
    'cancelled',
  ]) {
    test('cleans partial file and avoids indexing on $failure', () async {
      final Directory directory = await _directory();
      final _MemoryIndexStore store = _MemoryIndexStore();
      final DownloadRepository repository = DownloadRepository(
        store,
        readDirectory: () async => directory,
        fetcher:
            ({
              required String url,
              required String savePath,
              required Map<String, String> headers,
              required CancelToken cancelToken,
              void Function(int, int)? onProgress,
            }) async {
              if (failure == 'missing file') {
                return;
              }
              await File(
                savePath,
              ).writeAsBytes(failure == 'empty' ? <int>[] : <int>[1, 2, 3]);
              if (failure == 'transport') {
                throw StateError('network failed');
              }
              if (failure == 'cancelled') {
                cancelToken.cancel();
              }
              onProgress?.call(3, failure == 'oversized' ? 2 : 10);
            },
      );
      await expectLater(
        repository.downloadTrack(item: _item(), stream: _stream()),
        throwsA(
          failure == 'cancelled'
              ? isA<DioException>().having(
                  (DioException error) => error.type,
                  'type',
                  DioExceptionType.cancel,
                )
              : anyOf(isA<Exception>(), isA<StateError>()),
        ),
      );
      expect(store.putCalls, 0);
      expect(store.loadAll(), isEmpty);
      expect(directory.listSync(), isEmpty);
    });
  }

  test(
    'pre-cancelled token never resolves directory or starts transport',
    () async {
      final CancelToken token = CancelToken()..cancel();
      final DownloadRepository repository = DownloadRepository(
        _MemoryIndexStore(),
        readDirectory: () async =>
            throw StateError('must not resolve directory'),
        fetcher: _writeAudio,
      );
      await expectLater(
        repository.downloadTrack(
          item: _item(),
          stream: _stream(),
          cancelToken: token,
        ),
        throwsA(isA<DioException>()),
      );
    },
  );

  test(
    'cancellation while resolving directory does not start transport',
    () async {
      final Directory directory = await _directory();
      final CancelToken token = CancelToken();
      final DownloadRepository repository = DownloadRepository(
        _MemoryIndexStore(),
        readDirectory: () async {
          token.cancel();
          return directory;
        },
        fetcher: _writeAudio,
      );
      await expectLater(
        repository.downloadTrack(
          item: _item(),
          stream: _stream(),
          cancelToken: token,
        ),
        throwsA(isA<DioException>()),
      );
      expect(directory.listSync(), isEmpty);
    },
  );

  for (final bool writeBeforeFailure in <bool>[false, true]) {
    test(
      'rolls back file and failed index (written: $writeBeforeFailure)',
      () async {
        final Directory directory = await _directory();
        final _MemoryIndexStore store = _MemoryIndexStore();
        store.onPut = (String key, String json) async {
          if (writeBeforeFailure) {
            store.values[key] = json;
          }
          throw StateError('index failed');
        };
        final DownloadRepository repository = DownloadRepository(
          store,
          readDirectory: () async => directory,
          fetcher: _writeAudio,
        );
        await expectLater(
          repository.downloadTrack(item: _item(), stream: _stream()),
          throwsStateError,
        );
        expect(store.removeCalls, 1);
        expect(store.loadAll(), isEmpty);
        expect(directory.listSync(), isEmpty);
      },
    );
  }

  test(
    'cancellation during async indexing removes committed file and index',
    () async {
      final Directory directory = await _directory();
      final _MemoryIndexStore store = _MemoryIndexStore();
      final CancelToken token = CancelToken();
      final Completer<void> indexing = Completer<void>();
      final Completer<void> finishIndexing = Completer<void>();
      store.onPut = (String key, String json) async {
        expect(
          File(
            DownloadedTrack.fromJson(jsonDecode(json))!.filePath,
          ).existsSync(),
          isTrue,
        );
        indexing.complete();
        await finishIndexing.future;
      };
      final DownloadRepository repository = DownloadRepository(
        store,
        readDirectory: () async => directory,
        fetcher: _writeAudio,
      );
      final Future<DownloadedTrack> result = repository.downloadTrack(
        item: _item(),
        stream: _stream(),
        cancelToken: token,
      );
      final Future<void> assertion = expectLater(
        result,
        throwsA(isA<DioException>()),
      );
      await indexing.future;
      token.cancel();
      finishIndexing.complete();
      await assertion;
      expect(store.removeCalls, 1);
      expect(store.loadAll(), isEmpty);
      expect(directory.listSync(), isEmpty);
    },
  );

  test(
    'returns prior valid track without overwriting or refetching it',
    () async {
      final Directory directory = await _directory();
      final _MemoryIndexStore store = _MemoryIndexStore();
      int fetches = 0;
      final DownloadRepository repository = DownloadRepository(
        store,
        readDirectory: () async => directory,
        fetcher:
            ({
              required String url,
              required String savePath,
              required Map<String, String> headers,
              required CancelToken cancelToken,
              void Function(int, int)? onProgress,
            }) async {
              fetches++;
              await _writeAudio(
                url: url,
                savePath: savePath,
                headers: headers,
                cancelToken: cancelToken,
                onProgress: onProgress,
              );
            },
      );
      final DownloadedTrack first = await repository.downloadTrack(
        item: _item(),
        stream: _stream(),
      );
      store.onPut = (_, _) async => throw StateError('must not reindex');
      final DownloadedTrack second = await repository.downloadTrack(
        item: _item(),
        stream: _stream(),
      );
      expect(second.filePath, first.filePath);
      expect(await File(first.filePath).readAsBytes(), <int>[1, 2, 3]);
      expect(fetches, 1);
      expect(store.putCalls, 1);
    },
  );

  test('repository clears all downloads and files', () async {
    final Directory directory = await _directory();
    final DownloadRepository repository = DownloadRepository(
      _MemoryIndexStore(),
      readDirectory: () async => directory,
      fetcher: _writeAudio,
    );
    await repository.downloadTrack(item: _item(), stream: _stream());
    await repository.downloadTrack(
      item: _item(page: 2, cid: 11),
      stream: _stream(cid: 11),
    );
    await repository.clearAll();
    expect(repository.loadAll(), isEmpty);
    expect(directory.listSync(), isEmpty);
  });

  test('default Dio transport streams audio and forwards headers', () async {
    final Directory directory = await _directory();
    final HttpServer server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      0,
    );
    addTearDown(() => server.close(force: true));
    final Completer<void> served = Completer<void>();
    server.listen((HttpRequest request) async {
      expect(request.headers.value('referer'), 'https://www.bilibili.com/');
      request.response.contentLength = 6;
      request.response.add(<int>[1, 2, 3]);
      await request.response.flush();
      request.response.add(<int>[4, 5, 6]);
      await request.response.close();
      served.complete();
    });
    final DownloadRepository repository = DownloadRepository(
      _MemoryIndexStore(),
      readDirectory: () async => directory,
    );
    final DownloadedTrack track = await repository.downloadTrack(
      item: _item(),
      stream: _stream(url: 'http://127.0.0.1:${server.port}/audio'),
    );
    await served.future;
    expect(await File(track.filePath).readAsBytes(), <int>[1, 2, 3, 4, 5, 6]);
    expect(track.byteLength, 6);
    expect(directory.listSync().length, 1);
  });

  test('default Dio transport cancels an incomplete streamed response', () async {
    final Directory directory = await _directory();
    final HttpServer server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      0,
    );
    addTearDown(() => server.close(force: true));
    final CancelToken token = CancelToken();
    final Completer<void> served = Completer<void>();
    server.listen((HttpRequest request) async {
      final Socket socket = await request.response.detachSocket(
        writeHeaders: false,
      );
      socket.add(
        ascii.encode(
          'HTTP/1.1 200 OK\r\nContent-Length: 100\r\nConnection: close\r\n\r\nabc',
        ),
      );
      await socket.flush();
      addTearDown(socket.destroy);
      await token.whenCancel;
      served.complete();
    });
    final _MemoryIndexStore store = _MemoryIndexStore();
    final DownloadRepository repository = DownloadRepository(
      store,
      readDirectory: () async => directory,
    );
    await expectLater(
      repository.downloadTrack(
        item: _item(),
        stream: _stream(url: 'http://127.0.0.1:${server.port}/audio'),
        cancelToken: token,
        onProgress: (int received, int total) {
          expect(total, 100);
          expect(received, 3);
          token.cancel();
        },
      ),
      throwsA(
        isA<DioException>().having(
          (DioException error) => error.type,
          'type',
          DioExceptionType.cancel,
        ),
      ),
    );
    await served.future;
    expect(store.loadAll(), isEmpty);
    expect(directory.listSync(), isEmpty);
  });

  test(
    'default Dio transport rejects a truncated Content-Length response',
    () async {
      final Directory directory = await _directory();
      final HttpServer server = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        0,
      );
      addTearDown(() => server.close(force: true));
      final Completer<void> served = Completer<void>();
      server.listen((HttpRequest request) async {
        final Socket socket = await request.response.detachSocket(
          writeHeaders: false,
        );
        socket.add(
          ascii.encode(
            'HTTP/1.1 200 OK\r\nContent-Length: 100\r\nConnection: close\r\n\r\nabc',
          ),
        );
        await socket.flush();
        await socket.close();
        served.complete();
      });
      final _MemoryIndexStore store = _MemoryIndexStore();
      final DownloadRepository repository = DownloadRepository(
        store,
        readDirectory: () async => directory,
      );
      await expectLater(
        repository.downloadTrack(
          item: _item(),
          stream: _stream(url: 'http://127.0.0.1:${server.port}/audio'),
        ),
        throwsA(isA<DioException>()),
      );
      await served.future;
      expect(store.loadAll(), isEmpty);
      expect(directory.listSync(), isEmpty);
    },
  );

  test('restart discards a stale part file before fetching', () async {
    final Directory directory = await _directory();
    final _MemoryIndexStore store = _MemoryIndexStore();
    final DownloadRepository repository = DownloadRepository(
      store,
      readDirectory: () async => directory,
      fetcher: _writeAudio,
    );
    final DownloadedTrack track = await repository.downloadTrack(
      item: _item(),
      stream: _stream(),
    );
    final File stale = File('${track.filePath}.part');
    await stale.writeAsBytes(<int>[9, 9, 9, 9]);
    await repository.remove(track);
    final DownloadRepository restarted = DownloadRepository(
      store,
      readDirectory: () async => directory,
      fetcher:
          ({
            required String url,
            required String savePath,
            required Map<String, String> headers,
            required CancelToken cancelToken,
            void Function(int, int)? onProgress,
          }) async {
            expect(File(savePath).existsSync(), isFalse);
            await _writeAudio(
              url: url,
              savePath: savePath,
              headers: headers,
              cancelToken: cancelToken,
            );
          },
    );
    final DownloadedTrack restored = await restarted.downloadTrack(
      item: _item(),
      stream: _stream(),
    );
    expect(await File(restored.filePath).readAsBytes(), <int>[1, 2, 3]);
    expect(stale.existsSync(), isFalse);
  });

  test(
    'discardPartial removes only a stale part and is safe to repeat',
    () async {
      final Directory directory = await _directory();
      final _MemoryIndexStore store = _MemoryIndexStore();
      final DownloadRepository repository = DownloadRepository(
        store,
        readDirectory: () async => directory,
        fetcher: _writeAudio,
      );
      final DownloadedTrack track = await repository.downloadTrack(
        item: _item(),
        stream: _stream(),
      );
      final File partial = File('${track.filePath}.part');
      await partial.writeAsBytes(<int>[9, 9]);
      await repository.discardPartial(_item());
      await repository.discardPartial(_item());
      expect(partial.existsSync(), isFalse);
      expect(await File(track.filePath).readAsBytes(), <int>[1, 2, 3]);
      expect(repository.loadAll().single.contentId, track.contentId);
      expect(store.removeCalls, 0);
    },
  );

  test('discardPartial propagates cleanup failures', () async {
    final DownloadRepository repository = DownloadRepository(
      _MemoryIndexStore(),
      readDirectory: () async =>
          throw const FileSystemException('unavailable storage'),
    );
    await expectLater(
      repository.discardPartial(_item()),
      throwsA(isA<FileSystemException>()),
    );
  });

  test('task defaults, identity and copyWith clear errors', () {
    final DownloadTask task = DownloadTask(item: _item());
    expect(task.contentId, _item().contentId);
    expect(task.status, DownloadTaskStatus.queued);
    expect(task.isActive, isTrue);
    expect(task.progress, isNull);
    expect(task.receivedBytes, 0);
    expect(task.totalBytes, 0);
    expect(task.copyWith(receivedBytes: 2, totalBytes: 1).progress, 1);
    expect(
      task
          .copyWith(status: DownloadTaskStatus.failed, errorMessage: 'failure')
          .copyWith(errorMessage: null)
          .errorMessage,
      isNull,
    );
  });

  test(
    'persists atomic task snapshot, full playback identity and safe errors',
    () async {
      final _MemoryIndexStore taskStore = _MemoryIndexStore();
      final _MemoryIndexStore trackStore = _MemoryIndexStore();
      final DownloadRepository repository = DownloadRepository(
        trackStore,
        taskStore: taskStore,
        fetcher: _writeAudio,
      );
      final PlayableItem spoken = _item(page: 2, cid: 11).copyWith(
        bvid: '',
        pageTitle: '第二章',
        coverUrl: 'https://example.com/cover.jpg',
        kind: CollectionKind.spoken,
        collectionId: 'spoken-1',
      );
      final List<DownloadTask> tasks = <DownloadTask>[
        DownloadTask(item: spoken),
        DownloadTask(
          item: _item(),
          status: DownloadTaskStatus.failed,
          errorMessage: 'https://audio.example/?token=secret Cookie=session',
        ),
        DownloadTask(
          item: _item(page: 3, cid: 12),
          status: DownloadTaskStatus.running,
          receivedBytes: 5,
          totalBytes: 10,
        ),
      ];
      await repository.saveTasks(tasks);
      expect(taskStore.putCalls, 1);
      expect(taskStore.values.keys, <String>['queue']);
      expect(taskStore.values['queue'], isNot(contains('token=secret')));
      expect(taskStore.values['queue'], isNot(contains('Cookie=session')));
      expect(trackStore.loadAll(), isEmpty);
      final List<DownloadTask> restored = DownloadRepository(
        trackStore,
        taskStore: taskStore,
        readDirectory: () async =>
            throw StateError('must not access filesystem'),
        fetcher:
            ({
              required String url,
              required String savePath,
              required Map<String, String> headers,
              required CancelToken cancelToken,
              void Function(int, int)? onProgress,
            }) async => throw StateError('must not start networking'),
      ).loadTasks();
      expect(restored[0].item, spoken);
      expect(restored[0].contentId, 'aid:1:page:2');
      expect(restored[1].status, DownloadTaskStatus.failed);
      expect(restored[1].errorMessage, '下载失败，请重试');
      expect(restored[1].isActive, isFalse);
      expect(restored[2].status, DownloadTaskStatus.queued);
      expect(restored[2].receivedBytes, 0);
      expect(restored[2].totalBytes, 0);
      await repository.saveTasks(<DownloadTask>[]);
      expect(repository.loadTasks(), isEmpty);
      expect(taskStore.putCalls, 2);
      expect(taskStore.removeCalls, 0);
    },
  );

  test(
    'persists actionable safe messages and accepts unresolved zero cid',
    () async {
      final DownloadRepository repository = DownloadRepository(
        _MemoryIndexStore(),
        taskStore: _MemoryIndexStore(),
      );
      for (final String message in <String>[
        '下载超时，请检查网络后重试',
        '网络连接失败，请检查网络后重试',
        '下载失败，请检查网络、登录状态或存储空间后重试',
      ]) {
        await repository.saveTasks(<DownloadTask>[
          DownloadTask(
            item: _item(cid: 0),
            status: DownloadTaskStatus.failed,
            errorMessage: message,
          ),
        ]);
        expect(repository.loadTasks().single.item.cid, 0);
        expect(repository.loadTasks().single.errorMessage, message);
      }
    },
  );

  test('skips malformed task records and snapshots', () {
    final _MemoryIndexStore taskStore = _MemoryIndexStore();
    final DownloadRepository repository = DownloadRepository(
      _MemoryIndexStore(),
      taskStore: taskStore,
    );
    for (final String invalid in <String>['', '{', '{}', 'null', '1']) {
      taskStore.values['queue'] = invalid;
      expect(repository.loadTasks(), isEmpty);
    }
    final Map<String, Object?> valid = DownloadTask(item: _item()).toJson();
    final Map<String, Object?> item = Map<String, Object?>.from(
      valid['item']! as Map,
    );
    final List<Object?> invalid = <Object?>[
      null,
      'bad',
      <String, Object?>{},
      <String, Object?>{
        ...valid,
        'item': <String, Object?>{...item, 'aid': 'bad'},
      },
      <String, Object?>{
        ...valid,
        'item': <String, Object?>{...item, 'bvid': '', 'aid': 0},
      },
      <String, Object?>{
        ...valid,
        'item': <String, Object?>{...item, 'page': 0},
      },
      <String, Object?>{
        ...valid,
        'item': <String, Object?>{...item, 'cid': -1},
      },
      <String, Object?>{
        ...valid,
        'item': <String, Object?>{...item, 'kind': 'unknown'},
      },
      <String, Object?>{...valid, 'status': 'completed'},
      <String, Object?>{...valid, 'receivedBytes': -1},
      <String, Object?>{...valid, 'totalBytes': 'bad'},
      <String, Object?>{...valid, 'errorMessage': 42},
    ];
    taskStore.values['queue'] = jsonEncode(<Object?>[...invalid, valid]);
    expect(
      repository.loadTasks().map((DownloadTask task) => task.contentId),
      <String>[_item().contentId],
    );
  });

  test('propagates task store load and snapshot failures', () async {
    final _MemoryIndexStore taskStore = _MemoryIndexStore();
    final DownloadRepository repository = DownloadRepository(
      _MemoryIndexStore(),
      taskStore: taskStore,
    );
    await repository.saveTasks(<DownloadTask>[DownloadTask(item: _item())]);
    final String snapshot = taskStore.values['queue']!;
    taskStore.onPut = (_, _) async => throw StateError('disk full');
    await expectLater(repository.saveTasks(<DownloadTask>[]), throwsStateError);
    expect(taskStore.values['queue'], snapshot);
    taskStore.loadError = StateError('read failed');
    expect(repository.loadTasks, throwsStateError);
  });

  test('omitting task store keeps legacy fake repositories usable', () async {
    final DownloadRepository repository = DownloadRepository(
      _MemoryIndexStore(),
    );
    await repository.saveTasks(<DownloadTask>[DownloadTask(item: _item())]);
    expect(repository.loadTasks(), isEmpty);
  });
}

Future<Directory> _directory() async {
  final Directory directory = await Directory.systemTemp.createTemp('dl_');
  addTearDown(() async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });
  return directory;
}

Future<void> _writeAudio({
  required String url,
  required String savePath,
  required Map<String, String> headers,
  required CancelToken cancelToken,
  void Function(int, int)? onProgress,
}) async {
  await File(savePath).writeAsBytes(<int>[1, 2, 3]);
  onProgress?.call(3, -1);
}

PlayableItem _item({int page = 1, int cid = 10}) => PlayableItem(
  aid: 1,
  bvid: 'BV1',
  cid: cid,
  page: page,
  title: '夜曲',
  author: '周杰伦',
  coverUrl: '',
);

AudioStreamInfo _stream({int cid = 10, String? url}) => AudioStreamInfo(
  streamUrl: url ?? 'https://example.com/audio.m4a',
  backupUrls: const <String>[],
  headers: const <String, String>{'referer': 'https://www.bilibili.com/'},
  cid: cid,
  duration: const Duration(seconds: 225),
  bandwidth: 192000,
  availableQualities: const <AudioQualityOption>[],
  qualityId: 30280,
  qualityLabel: '192K',
);

class _MemoryIndexStore implements DownloadIndexStore {
  final Map<String, String> values = <String, String>{};
  Future<void> Function(String, String)? onPut;
  Object? loadError;
  int putCalls = 0;
  int removeCalls = 0;

  @override
  Map<String, String> loadAll() {
    if (loadError != null) {
      throw loadError!;
    }
    return Map<String, String>.of(values);
  }

  @override
  Future<void> put(String contentId, String json) async {
    putCalls++;
    await onPut?.call(contentId, json);
    values[contentId] = json;
  }

  @override
  Future<void> remove(String contentId) async {
    removeCalls++;
    values.remove(contentId);
  }

  @override
  Future<void> clear() async => values.clear();
}
