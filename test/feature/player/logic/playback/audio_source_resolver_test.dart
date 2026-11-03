import 'dart:io';

import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/player/data/audio_cache_repository.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/logic/playback/audio_source_resolver.dart';
import 'package:bilimusic/feature/player/logic/playback/player_audio_engine.dart';
import 'package:bilimusic/feature/player/logic/playback/player_playback_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AudioResolutionRequest', () {
    test('cacheKey isolates pages when cid is missing', () {
      final AudioResolutionRequest pageOne = AudioResolutionRequest(
        item: _item(cid: null, page: 1),
        qualityPreference: PlayerAudioQualityPreference.auto,
      );
      final AudioResolutionRequest pageTwo = AudioResolutionRequest(
        item: _item(cid: null, page: 2),
        qualityPreference: PlayerAudioQualityPreference.auto,
      );

      expect(pageOne.cacheKey, isNot(pageTwo.cacheKey));
    });

    test('cacheKey keeps identity for fallback requests only', () {
      final AudioResolutionRequest base = _request();

      expect(
        base.withQualityFallback().cacheKey,
        base.cacheKey,
        reason: '兜底标记不应改变缓存身份',
      );
      expect(
        AudioResolutionRequest(
          item: _item(),
          qualityPreference: PlayerAudioQualityPreference.k192,
        ).cacheKey,
        isNot(base.cacheKey),
      );
      expect(
        AudioResolutionRequest(
          item: _item(),
          qualityPreference: PlayerAudioQualityPreference.auto,
          preferredQualityId: 30232,
        ).cacheKey,
        isNot(base.cacheKey),
      );
    });
  });

  group('AudioSourceChain', () {
    test('returns the first non-null result and skips misses', () async {
      final List<String> calls = <String>[];
      final AudioSourceChain chain = AudioSourceChain(<AudioSourceResolver>[
        _FakeResolver('first', calls: calls, onResolve: (_) async => null),
        _FakeResolver(
          'second',
          calls: calls,
          onResolve: (_) async => _entry('BVsecond'),
        ),
        _FakeResolver(
          'third',
          calls: calls,
          onResolve: (_) async => _entry('BVthird'),
        ),
      ]);

      final ResolvedQueueEntry? result = await chain.resolve(_request());

      expect(result?.item.bvid, 'BVsecond');
      expect(calls, <String>['first', 'second']);
      expect(chain.id, 'chain(first>second>third)');
    });

    test('returns null when every source misses', () async {
      final AudioSourceChain chain = AudioSourceChain(<AudioSourceResolver>[
        _FakeResolver('a', onResolve: (_) async => null),
        _FakeResolver('b', onResolve: (_) async => null),
      ]);

      expect(await chain.resolve(_request()), isNull);
      expect(chain.id, 'chain(a>b)');
    });
  });

  group('PlayerPlaybackLoader 音源链', () {
    test('额外音源优先于 B 站主源，并在命中后写入内存缓存', () async {
      final _RecordingRepository repository = _RecordingRepository();
      int extraCalls = 0;
      final PlayerPlaybackLoader loader = _loader(
        repository: repository,
        extraSources: <AudioSourceResolver>[
          _FakeResolver(
            'third-party',
            onResolve: (_) async {
              extraCalls++;
              return _entry('BVthird');
            },
          ),
        ],
      );

      final ResolvedQueueEntry first = await loader.resolveQueueEntry(_item());
      final ResolvedQueueEntry second = await loader.resolveQueueEntry(_item());

      expect(first.item.bvid, 'BVthird');
      expect(second.item.bvid, 'BVthird');
      expect(extraCalls, 1, reason: '第二次应命中内存缓存');
      expect(repository.calls, 0);
    });

    test('额外音源放弃后回落到 B 站主源', () async {
      final _RecordingRepository repository = _RecordingRepository();
      final PlayerPlaybackLoader loader = _loader(
        repository: repository,
        extraSources: <AudioSourceResolver>[
          _FakeResolver('third-party', onResolve: (_) async => null),
        ],
      );

      final ResolvedQueueEntry entry = await loader.resolveQueueEntry(_item());

      expect(entry.item.bvid, 'BVmain');
      expect(repository.calls, 1);
    });

    test('未注入额外音源时行为与原先一致', () async {
      final _RecordingRepository repository = _RecordingRepository();
      final PlayerPlaybackLoader loader = _loader(repository: repository);

      final ResolvedQueueEntry entry = await loader.resolveQueueEntry(_item());

      expect(entry.item.bvid, 'BVmain');
      expect(entry.audioStream.streamUrl, isNotEmpty);
      expect(
        loader.resolvedEntryCacheKey(
          _item(),
          preference: PlayerAudioQualityPreference.auto,
        ),
        _request().cacheKey,
      );
    });
  });
}

AudioResolutionRequest _request() {
  return AudioResolutionRequest(
    item: _item(),
    qualityPreference: PlayerAudioQualityPreference.auto,
  );
}

PlayerPlaybackLoader _loader({
  required BiliPlayerRepository repository,
  List<AudioSourceResolver> extraSources = const <AudioSourceResolver>[],
}) {
  return PlayerPlaybackLoader(
    repository: repository,
    audioCacheRepository: _emptyCache(),
    audioEngine: _UnusedPlayerAudioEngine(),
    readSession: () => null,
    readQualityPreference: () => PlayerAudioQualityPreference.auto,
    logEvent: (_, {details}) {},
    isOffline: () async => false,
    extraSources: extraSources,
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

PlayableItem _item({int? cid = 222, int? page = 1}) {
  return PlayableItem(
    aid: 1,
    bvid: 'BVmain',
    cid: cid,
    page: page,
    title: 'Title',
    author: 'Author',
    coverUrl: '',
  );
}

ResolvedQueueEntry _entry(String bvid) {
  return ResolvedQueueEntry(
    item: PlayableItem(
      aid: 2,
      bvid: bvid,
      cid: 333,
      page: 1,
      title: 'Title',
      author: 'Author',
      coverUrl: '',
    ),
    availableParts: const <PlayableItem>[],
    audioStream: const AudioStreamInfo(
      streamUrl: 'https://audio/third',
      backupUrls: <String>[],
      headers: <String, String>{},
      cid: 333,
      duration: Duration(seconds: 1),
      bandwidth: 132000,
      qualityId: 30232,
      qualityLabel: '132K',
      availableQualities: <AudioQualityOption>[],
    ),
    cachedFile: null,
  );
}

class _FakeResolver implements AudioSourceResolver {
  _FakeResolver(this.id, {required this.onResolve, this.calls});

  @override
  final String id;

  final Future<ResolvedQueueEntry?> Function(AudioResolutionRequest request)
  onResolve;
  final List<String>? calls;

  @override
  Future<ResolvedQueueEntry?> resolve(AudioResolutionRequest request) {
    calls?.add(id);
    return onResolve(request);
  }
}

class _RecordingRepository extends BiliPlayerRepository {
  _RecordingRepository() : super(_UnusedBiliHttpClient());

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
    calls++;
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
}

class _UnusedBiliHttpClient implements BiliHttpClient {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedPlayerAudioEngine implements PlayerAudioEngine {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
