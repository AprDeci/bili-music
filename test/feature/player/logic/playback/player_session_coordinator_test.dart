import 'dart:async';
import 'dart:io';

import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/player/data/audio_cache_repository.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/player/domain/player_event.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/logic/playback/player_audio_engine.dart';
import 'package:bilimusic/feature/player/logic/playback/player_playback_loader.dart';
import 'package:bilimusic/feature/player/logic/playback/player_queue_manager.dart';
import 'package:bilimusic/feature/player/logic/playback/player_session_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('load 成功后写入状态、播放并持久化', () async {
    final _FakeHost host = _FakeHost(
      state: PlayerState(queue: <PlayableItem>[_item()]),
    );
    final _ScriptedRepository repository = _ScriptedRepository(<Object>[
      _ok(_item()),
    ]);
    final PlayerSessionCoordinator coordinator = _coordinator(host, repository);

    final bool loaded = await coordinator.load(
      0,
      autoplay: true,
      initialPosition: Duration.zero,
    );

    expect(loaded, isTrue);
    expect(host.state.currentItem?.bvid, 'BV1');
    expect(host.state.currentQueueIndex, 0);
    expect(host.state.isReady, isTrue);
    expect(host.calls, containsAll(<String>['play', 'persist']));
    expect(repository.calls, 1);
  });

  test('网络错误重试后成功', () async {
    final _FakeHost host = _FakeHost(
      state: PlayerState(queue: <PlayableItem>[_item()]),
    );
    final _ScriptedRepository repository = _ScriptedRepository(<Object>[
      const SocketException('offline'),
      _ok(_item()),
    ]);
    final PlayerSessionCoordinator coordinator = _coordinator(host, repository);

    final bool loaded = await coordinator.load(
      0,
      autoplay: false,
      initialPosition: Duration.zero,
    );

    expect(loaded, isTrue);
    expect(repository.calls, 2);
    expect(host.state.isReady, isTrue);
  });

  test('不可播放条目跳过并提示一次，继续加载下一项', () async {
    final _FakeHost host = _FakeHost(
      state: PlayerState(
        queue: <PlayableItem>[
          _item(),
          _item(bvid: 'BV2', cid: 333),
        ],
      ),
    );
    final _ScriptedRepository repository = _ScriptedRepository(<Object>[
      const BiliPlayerException('稿件不可见', code: -404),
      _ok(_item(bvid: 'BV2', cid: 333)),
    ]);
    final PlayerSessionCoordinator coordinator = _coordinator(host, repository);

    final bool loaded = await coordinator.load(
      0,
      autoplay: false,
      initialPosition: Duration.zero,
    );

    expect(loaded, isTrue);
    expect(host.toasts, <String>['稿件不可见']);
    expect(host.state.currentQueueIndex, 1);
    expect(host.state.currentItem?.bvid, 'BV2');
    expect(repository.calls, 2);
  });

  test('队列全部不可用时进入错误态', () async {
    final _FakeHost host = _FakeHost(
      state: PlayerState(queue: <PlayableItem>[_item()]),
    );
    final _ScriptedRepository repository = _ScriptedRepository(<Object>[
      const BiliPlayerException('稿件不可见', code: -404),
    ]);
    final PlayerSessionCoordinator coordinator = _coordinator(host, repository);

    final bool loaded = await coordinator.load(
      0,
      autoplay: false,
      initialPosition: Duration.zero,
    );

    expect(loaded, isFalse);
    expect(host.state.hasError, isTrue);
    expect(host.state.errorMessage, '稿件不可见');
    expect(host.state.isLoading, isFalse);
  });

  test('重试等待期间取消会中止加载', () async {
    final _FakeHost host = _FakeHost(
      state: PlayerState(queue: <PlayableItem>[_item()]),
    );
    final _ScriptedRepository repository = _ScriptedRepository(<Object>[
      const SocketException('offline'),
      _ok(_item()),
    ]);
    final PlayerSessionCoordinator coordinator = _coordinator(host, repository);

    final Future<bool> loading = coordinator.load(
      0,
      autoplay: false,
      initialPosition: Duration.zero,
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
    coordinator.cancelPendingRetry();

    expect(await loading, isFalse);
    expect(host.state.isReady, isFalse);
  });

  test('单曲循环完成时回到起点重播', () async {
    final _FakeHost host = _FakeHost(
      state: PlayerState(
        queue: <PlayableItem>[_item()],
        currentQueueIndex: 0,
        queueMode: PlayerQueueMode.singleRepeat,
      ),
    );
    final PlayerSessionCoordinator coordinator = _coordinator(
      host,
      _ScriptedRepository(<Object>[]),
    );

    await coordinator.handlePlaybackCompleted(host.generation);

    expect(host.calls, contains('seek:0'));
    expect(host.calls, contains('play'));
  });

  test('顺序模式完成时切到下一首', () async {
    final _FakeHost host = _FakeHost(
      state: PlayerState(
        queue: <PlayableItem>[
          _item(),
          _item(bvid: 'BV2', cid: 333),
        ],
        currentQueueIndex: 0,
      ),
    );
    final PlayerSessionCoordinator coordinator = _coordinator(
      host,
      _ScriptedRepository(<Object>[]),
    );

    await coordinator.handlePlaybackCompleted(host.generation);

    expect(host.calls, contains('skipNext'));
    expect(host.calls, isNot(contains('seek:0')));
  });

  test('load 成功后自动把全部分P加入队列', () async {
    final PlayableItem first = _item();
    final PlayableItem second = _item(cid: 333);
    final _FakeHost host = _FakeHost(
      state: PlayerState(queue: <PlayableItem>[first]),
    );
    final _ScriptedRepository repository = _ScriptedRepository(<Object>[
      _okWithParts(first, <PlayableItem>[first, second]),
    ]);
    final PlayerSessionCoordinator coordinator = _coordinator(host, repository);

    final bool loaded = await coordinator.load(
      0,
      autoplay: false,
      initialPosition: Duration.zero,
    );

    expect(loaded, isTrue);
    expect(host.calls, contains('enqueueParts:2'));
  });

  test('队列推进中忽略完成回调', () async {
    final _FakeHost host = _FakeHost(
      state: PlayerState(queue: <PlayableItem>[_item()], currentQueueIndex: 0),
    )..advancing = true;
    final PlayerSessionCoordinator coordinator = _coordinator(
      host,
      _ScriptedRepository(<Object>[]),
    );

    await coordinator.handlePlaybackCompleted(host.generation);

    expect(host.calls, isEmpty);
  });
}

PlayerSessionCoordinator _coordinator(
  _FakeHost host,
  _ScriptedRepository repository,
) {
  return PlayerSessionCoordinator(
    host: host,
    playbackLoader: PlayerPlaybackLoader(
      repository: repository,
      audioCacheRepository: _emptyCache(),
      audioEngine: _FakeAudioEngine(),
      readSession: () => null,
      readQualityPreference: () => PlayerAudioQualityPreference.auto,
      logEvent: (_, {details}) {},
      isOffline: () async => false,
    ),
    queueManager: PlayerQueueManager(),
  );
}

PlayerLoadResult _ok(PlayableItem item) {
  return PlayerLoadResult(
    item: item,
    availableParts: const <PlayableItem>[],
    audioStream: const AudioStreamInfo(
      streamUrl: 'https://audio/main',
      backupUrls: <String>[],
      headers: <String, String>{},
      cid: 222,
      duration: Duration(seconds: 1),
      bandwidth: 192000,
      qualityId: 30280,
      qualityLabel: '192K',
      availableQualities: <AudioQualityOption>[],
    ),
  );
}

PlayerLoadResult _okWithParts(PlayableItem item, List<PlayableItem> parts) {
  return PlayerLoadResult(
    item: item,
    availableParts: parts,
    audioStream: _ok(item).audioStream,
  );
}

PlayerAudioCacheRepository _emptyCache() {
  return PlayerAudioCacheRepository(
    null,
    readIndex: () async => '[]',
    writeIndex: (_) async {},
    readCachedFile: (_) async => null,
    downloadFile: (_, _, _) async => File('unused.audio'),
    removeFile: (_) async {},
  );
}

PlayableItem _item({String bvid = 'BV1', int cid = 222}) {
  return PlayableItem(
    aid: 1,
    bvid: bvid,
    cid: cid,
    page: 1,
    title: 'Title',
    author: 'Author',
    coverUrl: '',
  );
}

class _FakeHost implements PlayerSessionHost {
  _FakeHost({PlayerState? state}) : state = state ?? PlayerState();

  PlayerState state;

  int generation = 0;
  bool advancing = false;
  final List<String> calls = <String>[];
  final List<String> toasts = <String>[];

  @override
  PlayerState get sessionState => state;

  @override
  set sessionState(PlayerState value) => state = value;

  @override
  int nextGeneration() => ++generation;

  @override
  bool isCurrentGeneration(int value) => value == generation;

  @override
  bool get isAdvancingQueue => advancing;

  @override
  int? qualityOverrideFor(String stableId) => null;

  @override
  PlayerAudioQualityPreference get qualityPreference =>
      PlayerAudioQualityPreference.auto;

  @override
  void publishPlaybackState() => calls.add('publish');

  @override
  Future<void> persistQueueSnapshot() async => calls.add('persist');

  @override
  Future<void> enqueueAvailableParts(List<PlayableItem> parts) async {
    calls.add('enqueueParts:${parts.length}');
  }

  @override
  void resetEnginePlaybackSnapshot({
    required PlayerEngineProcessingState processingState,
  }) {}

  @override
  void suspendListening() {}

  @override
  void logPlayerEvent(String event, {Map<String, Object?>? details}) {}

  @override
  void emitPlayerEvent(PlayerEventType type) => calls.add('event:${type.name}');

  @override
  Future<void> activateAudioSessionForPlayback() async => calls.add('activate');

  @override
  Future<void> playCurrentSource() async => calls.add('play');

  @override
  Future<void> seekSession(Duration position) async {
    calls.add('seek:${position.inMilliseconds}');
  }

  @override
  Future<void> skipToNextTrack() async => calls.add('skipNext');

  @override
  Future<void> stopAudioEngine() async => calls.add('stopEngine');

  @override
  Future<void> pauseAudioEngine() async => calls.add('pauseEngine');

  @override
  Future<Duration> resumeListeningPosition(
    PlayableItem item, {
    required Duration fallback,
    required bool Function() isCurrent,
  }) async {
    return fallback;
  }

  @override
  void beginListening(
    PlayableItem item,
    Duration position,
    Duration? duration,
  ) {}

  @override
  void recordRecentPlayback(PlayableItem item) => calls.add('recent');

  @override
  void showToast(String message) => toasts.add(message);
}

class _ScriptedRepository extends BiliPlayerRepository {
  _ScriptedRepository(this._results) : super(_UnusedBiliHttpClient());

  final List<Object> _results;
  int calls = 0;

  @override
  Future<List<PlayableItem>> resolveAllParts(PlayableItem item) async {
    return <PlayableItem>[item];
  }

  @override
  Future<PlayerLoadResult> resolveAudioStream(
    PlayableItem item, {
    required BiliSession? session,
    required PlayerAudioQualityPreference qualityPreference,
    int? preferredQualityId,
  }) async {
    final int index = calls < _results.length ? calls : _results.length - 1;
    final Object result = _results.isEmpty
        ? _ok(item)
        : _results[index < 0 ? 0 : index];
    calls++;
    if (result is Exception) {
      throw result;
    }
    return result as PlayerLoadResult;
  }
}

class _UnusedBiliHttpClient implements BiliHttpClient {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAudioEngine implements PlayerAudioEngine {
  @override
  Stream<Duration?> get durationStream => const Stream<Duration?>.empty();

  @override
  Future<Duration?> setRemoteSource({
    required Uri uri,
    Map<String, String>? headers,
    Duration? initialPosition,
  }) async {
    return const Duration(minutes: 1);
  }

  @override
  Future<Duration?> setFileSource({
    required String filePath,
    Duration? initialPosition,
  }) async {
    return const Duration(minutes: 1);
  }

  @override
  Future<void> seek(Duration position) async {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
