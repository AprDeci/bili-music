import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'dart:io';

import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/download/data/download_repository.dart';
import 'package:bilimusic/feature/download/logic/download_controller.dart';
import 'package:bilimusic/feature/download/domain/download_task.dart';
import 'package:dio/dio.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/player/logic/playback/player_audio_quality_preference_logic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('download stores a track and clears the task', () async {
    final ProviderContainer container = await _container();
    addTearDown(container.dispose);
    final DownloadController controller = container.read(
      downloadControllerProvider.notifier,
    );

    expect(await controller.download(_item()), isTrue);
    await _waitFor(
      () => container.read(downloadControllerProvider).tracks.isNotEmpty,
    );

    final DownloadState state = container.read(downloadControllerProvider);
    expect(state.tracks.single.title, '夜曲');
    expect(state.tracks.single.byteLength, 3);
    expect(state.totalBytes, 3);
    expect(state.tasks, isEmpty);
    expect(state.contains('bvid:BV1:page:1'), isTrue);
  });

  test('download is ignored when the track is already downloaded', () async {
    final ProviderContainer container = await _container();
    addTearDown(container.dispose);
    final DownloadController controller = container.read(
      downloadControllerProvider.notifier,
    );

    await controller.download(_item());
    await _waitFor(
      () => container.read(downloadControllerProvider).tracks.isNotEmpty,
    );

    expect(await controller.download(_item()), isFalse);
  });

  test('downloadAll queues each item once', () async {
    final ProviderContainer container = await _container();
    addTearDown(container.dispose);
    final DownloadController controller = container.read(
      downloadControllerProvider.notifier,
    );

    final int queued = await controller.downloadAll(<PlayableItem>[
      _item(),
      _item(page: 2, cid: 11),
    ]);
    await _waitFor(
      () => container.read(downloadControllerProvider).tracks.length == 2,
    );

    expect(queued, 2);
    expect(container.read(downloadControllerProvider).tracks.length, 2);
  });

  test(
    'queue is serial, deduplicates, cancels waiting and running tasks',
    () async {
      final List<CancelToken> tokens = <CancelToken>[];
      final List<Completer<void>> completions = <Completer<void>>[];
      final ProviderContainer container = await _container(
        fetcher:
            ({
              required url,
              required savePath,
              required headers,
              required cancelToken,
              onProgress,
            }) async {
              tokens.add(cancelToken);
              final Completer<void> completion = Completer<void>();
              completions.add(completion);
              await Future.any<void>([
                completion.future,
                cancelToken.whenCancel.then((error) => throw error),
              ]);
              await _writeAudio(
                url: url,
                savePath: savePath,
                headers: headers,
                cancelToken: cancelToken,
                onProgress: onProgress,
              );
            },
      );
      addTearDown(container.dispose);
      final DownloadController controller = container.read(
        downloadControllerProvider.notifier,
      );
      expect(
        await controller.downloadAll([
          _item(),
          _item(page: 2),
          _item(page: 3),
          _item(),
        ]),
        3,
      );
      await _waitFor(() => tokens.length == 1);
      expect(container.read(downloadControllerProvider).activeTaskCount, 3);
      expect(await controller.download(_item()), isFalse);
      await controller.cancel(_item(page: 2).contentId);
      expect(tokens, hasLength(1));
      await controller.cancel(_item().contentId);
      await _waitFor(() => tokens.length == 2);
      expect(tokens.first.isCancelled, isTrue);
      expect(container.read(downloadControllerProvider).tasks.keys, [
        _item(page: 3).contentId,
      ]);
      completions.last.complete();
      await _waitFor(
        () => container.read(downloadControllerProvider).tracks.length == 1,
      );
      expect(container.read(downloadControllerProvider).tracks.single.page, 3);
    },
  );

  test(
    'failure does not block the queue and retry resolves a fresh URL',
    () async {
      int calls = 0;
      final _FakePlayerRepository player = _FakePlayerRepository();
      final ProviderContainer container = await _container(
        playerRepository: player,
        fetcher:
            ({
              required url,
              required savePath,
              required headers,
              required cancelToken,
              onProgress,
            }) async {
              if (calls++ == 0) {
                throw DioException(
                  requestOptions: RequestOptions(path: 'secret-url'),
                );
              }
              await _writeAudio(
                url: url,
                savePath: savePath,
                headers: headers,
                cancelToken: cancelToken,
                onProgress: onProgress,
              );
            },
      );
      addTearDown(container.dispose);
      final DownloadController controller = container.read(
        downloadControllerProvider.notifier,
      );
      await controller.downloadAll([_item(), _item(page: 2)]);
      await _waitFor(
        () => container.read(downloadControllerProvider).tracks.length == 1,
      );
      expect(
        container
            .read(downloadControllerProvider)
            .taskFor(_item().contentId)!
            .status,
        DownloadTaskStatus.failed,
      );
      expect(
        container
            .read(downloadControllerProvider)
            .taskFor(_item().contentId)!
            .errorMessage,
        isNot(contains('secret-url')),
      );
      expect(await controller.retryFailed(), 1);
      await _waitFor(
        () => container.read(downloadControllerProvider).tracks.length == 2,
      );
      expect(player.calls, 3);
      expect(await controller.retry(_item().contentId), isFalse);
    },
  );

  test('cancel while resolving immediately allows the next task', () async {
    final Completer<PlayerLoadResult> pending = Completer<PlayerLoadResult>();
    final _BlockingPlayerRepository player = _BlockingPlayerRepository(pending);
    final ProviderContainer container = await _container(
      playerRepository: player,
    );
    addTearDown(container.dispose);
    final DownloadController controller = container.read(
      downloadControllerProvider.notifier,
    );
    await controller.downloadAll([_item(), _item(page: 2)]);
    await _waitFor(() => player.calls == 1);
    await controller.cancel(_item().contentId);
    await _waitFor(
      () => container.read(downloadControllerProvider).tracks.length == 1,
    );
    expect(player.calls, 2);
    pending.completeError(StateError('late resolution failure'));
    await Future<void>.delayed(Duration.zero);
    expect(container.read(downloadControllerProvider).tasks, isEmpty);
  });

  test(
    'restores waiting tasks only after initialization and preserves failed tasks',
    () async {
      final _MemoryIndexStore tasks = _MemoryIndexStore();
      final DownloadRepository persistence = DownloadRepository(
        _MemoryIndexStore(),
        taskStore: tasks,
      );
      await persistence.saveTasks([
        DownloadTask(
          item: _item(),
          status: DownloadTaskStatus.running,
          receivedBytes: 10,
        ),
        DownloadTask(item: _item(page: 2)),
        DownloadTask(
          item: _item(page: 3),
          status: DownloadTaskStatus.failed,
          errorMessage: '失败',
        ),
      ]);
      final _FakePlayerRepository player = _FakePlayerRepository();
      final ProviderContainer container = await _container(
        taskStore: tasks,
        playerRepository: player,
      );
      addTearDown(container.dispose);
      final DownloadController controller = container.read(
        downloadControllerProvider.notifier,
      );
      await Future<void>.delayed(Duration.zero);
      expect(player.calls, 0);
      expect(container.read(downloadControllerProvider).activeTaskCount, 2);
      await controller.initialize();
      await _waitFor(
        () => container.read(downloadControllerProvider).tracks.length == 2,
      );
      expect(persistence.loadTasks().single.status, DownloadTaskStatus.failed);
      expect(await controller.retry(_item(page: 3).contentId), isTrue);
      await _waitFor(
        () => container.read(downloadControllerProvider).tracks.length == 3,
      );
      expect(persistence.loadTasks(), isEmpty);
    },
  );

  test(
    'queue persistence failure rejects enqueue and cancel without losing state',
    () async {
      final _FailingStore tasks = _FailingStore();
      final Completer<PlayerLoadResult> pending = Completer<PlayerLoadResult>();
      final ProviderContainer container = await _container(
        taskStore: tasks,
        playerRepository: _BlockingPlayerRepository(pending),
      );
      addTearDown(container.dispose);
      final DownloadController controller = container.read(
        downloadControllerProvider.notifier,
      );
      tasks.failWrites = true;
      await expectLater(controller.download(_item()), throwsStateError);
      expect(container.read(downloadControllerProvider).tasks, isEmpty);
      tasks.failWrites = false;
      expect(await controller.download(_item()), isTrue);
      await _waitFor(
        () =>
            container
                .read(downloadControllerProvider)
                .tasks
                .values
                .single
                .status ==
            DownloadTaskStatus.running,
      );
      tasks.failWrites = true;
      await expectLater(controller.cancel(_item().contentId), throwsStateError);
      expect(container.read(downloadControllerProvider).activeTaskCount, 1);
      tasks.failWrites = false;
      await controller.cancel(_item().contentId);
      expect(container.read(downloadControllerProvider).tasks, isEmpty);
    },
  );

  test(
    'clearAll preserves pending tasks and invalid identities are rejected',
    () async {
      final Completer<PlayerLoadResult> pending = Completer<PlayerLoadResult>();
      final ProviderContainer container = await _container(
        playerRepository: _BlockingPlayerRepository(pending),
      );
      addTearDown(container.dispose);
      final DownloadController controller = container.read(
        downloadControllerProvider.notifier,
      );
      await expectLater(
        controller.download(_item().copyWith(aid: 0, bvid: '')),
        throwsArgumentError,
      );
      await controller.download(_item());
      await controller.clearAll();
      expect(container.read(downloadControllerProvider).activeTaskCount, 1);
      await controller.cancel(_item().contentId);
    },
  );

  test(
    'cancel and immediately requeue does not revive an old attempt',
    () async {
      final List<CancelToken> tokens = <CancelToken>[];
      final List<Completer<void>> gates = <Completer<void>>[];
      final ProviderContainer container = await _container(
        fetcher:
            ({
              required url,
              required savePath,
              required headers,
              required cancelToken,
              onProgress,
            }) async {
              tokens.add(cancelToken);
              final Completer<void> gate = Completer<void>();
              gates.add(gate);
              await Future.any<void>([
                gate.future,
                cancelToken.whenCancel.then((error) => throw error),
              ]);
              await _writeAudio(
                url: url,
                savePath: savePath,
                headers: headers,
                cancelToken: cancelToken,
                onProgress: onProgress,
              );
            },
      );
      addTearDown(container.dispose);
      final DownloadController controller = container.read(
        downloadControllerProvider.notifier,
      );
      await controller.download(_item());
      await _waitFor(() => tokens.isNotEmpty);
      final Future<void> cancel = controller.cancel(_item().contentId);
      final Future<bool> requeue = controller.download(_item());
      await cancel;
      expect(await requeue, isTrue);
      await _waitFor(() => tokens.length == 2);
      gates.last.complete();
      await _waitFor(
        () => container.read(downloadControllerProvider).tracks.length == 1,
      );
      expect(container.read(downloadControllerProvider).tasks, isEmpty);
    },
  );

  test(
    'clearAll cannot delete a new download that commits during removal',
    () async {
      final _DelayedRemovalStore tracks = _DelayedRemovalStore();
      final List<Completer<void>> gates = <Completer<void>>[];
      final ProviderContainer container = await _container(
        trackStore: tracks,
        fetcher:
            ({
              required url,
              required savePath,
              required headers,
              required cancelToken,
              onProgress,
            }) async {
              if (gates.isNotEmpty) {
                gates.add(Completer<void>());
                await gates.last.future;
              } else {
                gates.add(Completer<void>()..complete());
              }
              await _writeAudio(
                url: url,
                savePath: savePath,
                headers: headers,
                cancelToken: cancelToken,
                onProgress: onProgress,
              );
            },
      );
      addTearDown(container.dispose);
      final DownloadController controller = container.read(
        downloadControllerProvider.notifier,
      );
      await controller.download(_item());
      await _waitFor(
        () => container.read(downloadControllerProvider).tracks.length == 1,
      );
      await controller.download(_item(page: 2));
      await _waitFor(() => gates.length == 2);
      final Future<void> clear = controller.clearAll();
      await _waitFor(() => tracks.removing);
      gates.last.complete();
      await _waitFor(
        () => tracks.loadAll().containsKey(_item(page: 2).contentId),
      );
      tracks.removalGate.complete();
      await clear;
      await _waitFor(
        () => container.read(downloadControllerProvider).tracks.length == 1,
      );
      final track = container.read(downloadControllerProvider).tracks.single;
      expect(track.page, 2);
      expect(await File(track.filePath).exists(), isTrue);
      expect(tracks.loadAll().keys, [_item(page: 2).contentId]);
    },
  );

  test(
    'task snapshot writes preserve progress published while awaiting disk',
    () async {
      final _DelayedWriteStore tasks = _DelayedWriteStore();
      late void Function(int, int) progress;
      final ProviderContainer container = await _container(
        taskStore: tasks,
        fetcher:
            ({
              required url,
              required savePath,
              required headers,
              required cancelToken,
              onProgress,
            }) async {
              progress = onProgress!;
              await cancelToken.whenCancel.then((error) => throw error);
            },
      );
      addTearDown(container.dispose);
      final DownloadController controller = container.read(
        downloadControllerProvider.notifier,
      );
      await controller.download(_item());
      await _waitFor(
        () =>
            container
                .read(downloadControllerProvider)
                .tasks
                .values
                .single
                .status ==
            DownloadTaskStatus.running,
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
      tasks.delay = true;
      final Future<bool> enqueue = controller.download(_item(page: 2));
      await _waitFor(() => tasks.writing);
      progress(128000, 256000);
      tasks.gate.complete();
      await enqueue;
      final DownloadTask current = container
          .read(downloadControllerProvider)
          .taskFor(_item().contentId)!;
      expect(current.receivedBytes, 128000);
      expect(current.totalBytes, 256000);
      tasks.delay = false;
      await controller.cancel(_item(page: 2).contentId);
      await controller.cancel(_item().contentId);
    },
  );

  for (final bool clear in [false, true]) {
    test(
      'deletion clear=$clear reconciles a failed completion snapshot save',
      () async {
        final _FailingStore tasks = _FailingStore();
        final _MemoryIndexStore tracks = _MemoryIndexStore();
        final Completer<void> gate = Completer<void>();
        final ProviderContainer container = await _container(
          taskStore: tasks,
          trackStore: tracks,
          fetcher:
              ({
                required url,
                required savePath,
                required headers,
                required cancelToken,
                onProgress,
              }) async {
                await gate.future;
                await _writeAudio(
                  url: url,
                  savePath: savePath,
                  headers: headers,
                  cancelToken: cancelToken,
                  onProgress: onProgress,
                );
              },
        );
        addTearDown(container.dispose);
        final DownloadController controller = container.read(
          downloadControllerProvider.notifier,
        );
        await controller.download(_item());
        tasks.failWrites = true;
        gate.complete();
        await _waitFor(
          () => container.read(downloadControllerProvider).tracks.length == 1,
        );
        expect(container.read(downloadControllerProvider).tasks, isEmpty);
        expect(
          DownloadRepository(tracks, taskStore: tasks).loadTasks(),
          hasLength(1),
        );
        tasks.failWrites = false;
        if (clear) {
          await controller.clearAll();
        } else {
          await controller.removeTrack(
            container.read(downloadControllerProvider).tracks.single,
          );
        }
        final DownloadRepository restored = DownloadRepository(
          tracks,
          taskStore: tasks,
        );
        expect(restored.loadAll(), isEmpty);
        expect(restored.loadTasks(), isEmpty);
      },
    );
  }

  test('restored partial is removed on cancel before resolving', () async {
    final Directory directory = await Directory.systemTemp.createTemp(
      'recovered_dl_',
    );
    final String name = sha1.convert(utf8.encode(_item().contentId)).toString();
    final File partial = File('${directory.path}/$name.m4a.part');
    await partial.writeAsBytes([1, 2, 3]);
    final _MemoryIndexStore tasks = _MemoryIndexStore();
    await DownloadRepository(
      _MemoryIndexStore(),
      taskStore: tasks,
    ).saveTasks([DownloadTask(item: _item())]);
    final ProviderContainer container = await _container(
      taskStore: tasks,
      readDirectory: directory,
    );
    addTearDown(container.dispose);
    await container
        .read(downloadControllerProvider.notifier)
        .cancel(_item().contentId);
    expect(await partial.exists(), isFalse);
  });

  test(
    'restored partial is removed before an audio resolution failure',
    () async {
      final Directory directory = await Directory.systemTemp.createTemp(
        'recovered_dl_',
      );
      final String name = sha1
          .convert(utf8.encode(_item().contentId))
          .toString();
      final File partial = File('${directory.path}/$name.m4a.part');
      await partial.writeAsBytes([1, 2, 3]);
      final _MemoryIndexStore tasks = _MemoryIndexStore();
      await DownloadRepository(
        _MemoryIndexStore(),
        taskStore: tasks,
      ).saveTasks([DownloadTask(item: _item())]);
      final Completer<PlayerLoadResult> result = Completer<PlayerLoadResult>();
      final _BlockingPlayerRepository player = _BlockingPlayerRepository(
        result,
      );
      final ProviderContainer container = await _container(
        taskStore: tasks,
        readDirectory: directory,
        playerRepository: player,
      );
      addTearDown(container.dispose);
      await container.read(downloadControllerProvider.notifier).initialize();
      await _waitFor(() => player.calls == 1);
      result.completeError(StateError('private video'));
      await _waitFor(
        () =>
            container
                .read(downloadControllerProvider)
                .tasks
                .values
                .single
                .status ==
            DownloadTaskStatus.failed,
      );
      expect(await partial.exists(), isFalse);
    },
  );

  test(
    'unreadable queue is visible and cannot overwrite stored tasks',
    () async {
      final _UnreadableStore tasks = _UnreadableStore();
      final ProviderContainer container = await _container(taskStore: tasks);
      addTearDown(container.dispose);
      final DownloadState state = container.read(downloadControllerProvider);
      expect(state.errorMessage, contains('读取失败'));
      await container.read(downloadControllerProvider.notifier).initialize();
      await expectLater(
        container.read(downloadControllerProvider.notifier).download(_item()),
        throwsStateError,
      );
      expect(tasks.writes, 0);
    },
  );

  test('removeTrack and clearAll update state', () async {
    final ProviderContainer container = await _container();
    addTearDown(container.dispose);
    final DownloadController controller = container.read(
      downloadControllerProvider.notifier,
    );

    await controller.downloadAll(<PlayableItem>[
      _item(),
      _item(page: 2, cid: 11),
    ]);
    await _waitFor(
      () => container.read(downloadControllerProvider).tracks.length == 2,
    );

    final DownloadState state = container.read(downloadControllerProvider);
    await controller.removeTrack(state.tracks.first);
    expect(container.read(downloadControllerProvider).tracks.length, 1);

    await controller.clearAll();
    expect(container.read(downloadControllerProvider).tracks, isEmpty);
    expect(container.read(downloadControllerProvider).totalBytes, 0);
  });
}

Future<ProviderContainer> _container({
  DownloadFetcher? fetcher,
  DownloadIndexStore? taskStore,
  DownloadIndexStore? trackStore,
  BiliPlayerRepository? playerRepository,
  Directory? readDirectory,
}) async {
  final Directory directory =
      readDirectory ?? await Directory.systemTemp.createTemp('dl_');
  addTearDown(() async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });
  final DownloadRepository repository = DownloadRepository(
    trackStore ?? _MemoryIndexStore(),
    taskStore: taskStore ?? _MemoryIndexStore(),
    readDirectory: () async => directory,
    fetcher: fetcher ?? _writeAudio,
  );
  final ProviderContainer container = ProviderContainer(
    overrides: [
      downloadRepositoryProvider.overrideWithValue(repository),
      biliPlayerRepositoryProvider.overrideWithValue(
        playerRepository ?? _FakePlayerRepository(),
      ),
      biliSessionControllerProvider.overrideWith(_GuestSession.new),
      playerAudioQualityPreferenceLogicProvider.overrideWith(
        _FakeQualityPreference.new,
      ),
    ],
  );
  final ProviderSubscription<DownloadState> subscription = container.listen(
    downloadControllerProvider,
    (_, _) {},
    fireImmediately: true,
  );
  addTearDown(subscription.close);
  return container;
}

Future<void> _writeAudio({
  required String url,
  required String savePath,
  required Map<String, String> headers,
  required CancelToken cancelToken,
  void Function(int, int)? onProgress,
}) async {
  await File(savePath).writeAsBytes(<int>[1, 2, 3]);
  onProgress?.call(3, 3);
}

Future<void> _waitFor(bool Function() condition) async {
  final DateTime deadline = DateTime.now().add(const Duration(seconds: 5));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('timed out waiting for download state');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

PlayableItem _item({int page = 1, int cid = 10}) {
  return PlayableItem(
    aid: 1,
    bvid: 'BV1',
    cid: cid,
    page: page,
    title: '夜曲',
    author: '周杰伦',
    coverUrl: '',
  );
}

class _FakePlayerRepository implements BiliPlayerRepository {
  int calls = 0;

  @override
  Future<PlayerLoadResult> resolveAudioStream(
    PlayableItem item, {
    required BiliSession? session,
    required PlayerAudioQualityPreference qualityPreference,
    int? preferredQualityId,
  }) async {
    calls++;
    return PlayerLoadResult(
      item: item,
      availableParts: const <PlayableItem>[],
      audioStream: AudioStreamInfo(
        streamUrl: 'https://example.com/audio.m4a',
        backupUrls: const <String>[],
        headers: const <String, String>{},
        cid: item.cid ?? 10,
        duration: const Duration(seconds: 225),
        bandwidth: 192000,
        availableQualities: const <AudioQualityOption>[],
        qualityId: 30280,
        qualityLabel: '192K',
      ),
    );
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _BlockingPlayerRepository extends _FakePlayerRepository {
  _BlockingPlayerRepository(this.pending);

  final Completer<PlayerLoadResult> pending;

  @override
  Future<PlayerLoadResult> resolveAudioStream(
    PlayableItem item, {
    required BiliSession? session,
    required PlayerAudioQualityPreference qualityPreference,
    int? preferredQualityId,
  }) {
    if (calls == 0) {
      calls++;
      return pending.future;
    }
    return super.resolveAudioStream(
      item,
      session: session,
      qualityPreference: qualityPreference,
      preferredQualityId: preferredQualityId,
    );
  }
}

class _UnreadableStore extends _MemoryIndexStore {
  int writes = 0;

  @override
  Map<String, String> loadAll() => throw StateError('storage unavailable');

  @override
  Future<void> put(String contentId, String json) async {
    writes++;
  }
}

class _DelayedWriteStore extends _MemoryIndexStore {
  bool delay = false;
  bool writing = false;
  final Completer<void> gate = Completer<void>();

  @override
  Future<void> put(String contentId, String json) async {
    if (delay) {
      writing = true;
      await gate.future;
    }
    await super.put(contentId, json);
  }
}

class _DelayedRemovalStore extends _MemoryIndexStore {
  bool removing = false;
  final Completer<void> removalGate = Completer<void>();

  @override
  Future<void> remove(String contentId) async {
    removing = true;
    await removalGate.future;
    await super.remove(contentId);
  }
}

class _FailingStore extends _MemoryIndexStore {
  bool failWrites = false;

  @override
  Future<void> put(String contentId, String json) async {
    if (failWrites) {
      throw StateError('storage unavailable');
    }
    await super.put(contentId, json);
  }
}

class _GuestSession extends BiliSessionController {
  @override
  BiliSession? build() => null;
}

class _FakeQualityPreference extends PlayerAudioQualityPreferenceLogic {
  @override
  PlayerAudioQualityPreference build() => PlayerAudioQualityPreference.auto;
}

class _MemoryIndexStore implements DownloadIndexStore {
  final Map<String, String> _values = <String, String>{};

  @override
  Map<String, String> loadAll() => Map<String, String>.of(_values);

  @override
  Future<void> put(String contentId, String json) async {
    _values[contentId] = json;
  }

  @override
  Future<void> remove(String contentId) async {
    _values.remove(contentId);
  }

  @override
  Future<void> clear() async {
    _values.clear();
  }
}
