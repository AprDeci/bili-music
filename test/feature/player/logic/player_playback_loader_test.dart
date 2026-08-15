import 'dart:io';

import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/player/data/audio_cache_repository.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/logic/controller/player_playback_loader.dart';
import 'package:bilimusic/feature/player/logic/player_audio_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;

  setUp(() async => directory = await Directory.systemTemp.createTemp());
  tearDown(() async => directory.delete(recursive: true));

  test('online exact cache plays locally without waiting for remote', () async {
    final _RecordingRepository remote = _RecordingRepository(_loadResult());
    final PlayerAudioCacheRepository cache = _cache(directory);
    final AudioStreamInfo stream = _loadResult().audioStream;
    final File file = await cache.cacheAudio(
      item: _item(),
      audioStream: stream,
    );
    final ResolvedQueueEntry entry = await _loader(
      repository: remote,
      cache: cache,
      preference: PlayerAudioQualityPreference.k132,
      isOffline: () async => false,
    ).resolveQueueEntry(_item(), preferredQualityId: 30232);

    expect(remote.calls, 0);
    expect(entry.cachedFile?.path, file.path);
    expect(entry.audioStream.availableQualities, hasLength(1));
  });

  test(
    'online missing selected cache falls back to available local quality',
    () async {
      final PlayerAudioCacheRepository cache = _cache(directory);
      await cache.cacheAudio(
        item: _item(),
        audioStream: _stream(qualityId: 30280, bandwidth: 192000),
      );
      final ResolvedQueueEntry entry = await _loader(
        repository: _RecordingRepository(_loadResult()),
        cache: cache,
        isOffline: () async => false,
      ).resolveQueueEntry(_item());

      expect(entry.cachedFile, isNotNull);
      expect(entry.audioStream.qualityId, 30280);
    },
  );

  test(
    'initial offline uses preferred cached fallback without remote',
    () async {
      final PlayerAudioCacheRepository cache = _cache(directory);
      await cache.cacheAudio(
        item: _item(),
        audioStream: _stream(qualityId: 30280, bandwidth: 192000),
      );
      await cache.cacheAudio(
        item: _item(),
        audioStream: _stream(qualityId: 30232, bandwidth: 132000),
      );
      final _RecordingRepository remote = _RecordingRepository(_loadResult());
      final ResolvedQueueEntry entry = await _loader(
        repository: remote,
        cache: cache,
        preference: PlayerAudioQualityPreference.k132,
        isOffline: () async => true,
      ).resolveQueueEntry(_item());

      expect(remote.calls, 0);
      expect(entry.cachedFile, isNotNull);
      expect(entry.audioStream.qualityId, 30232);
    },
  );

  test('cache hit does not start a remote request', () async {
    final PlayerAudioCacheRepository cache = _cache(directory);
    await cache.cacheAudio(
      item: _item(),
      audioStream: _stream(qualityId: 30232, bandwidth: 132000),
    );
    int checks = 0;
    final _RecordingRepository remote = _RecordingRepository(
      null,
      error: StateError('failed'),
    );
    final ResolvedQueueEntry entry = await _loader(
      repository: remote,
      cache: cache,
      isOffline: () async => checks++ > 0,
    ).resolveQueueEntry(_item());

    expect(checks, 0);
    expect(remote.calls, 0);
    expect(entry.cachedFile, isNotNull);
  });

  test('online cache avoids a business request failure', () async {
    final PlayerAudioCacheRepository cache = _cache(directory);
    await cache.cacheAudio(
      item: _item(),
      audioStream: _stream(qualityId: 30232, bandwidth: 132000),
    );
    final BiliPlayerException error = BiliPlayerException('API failed');
    final PlayerPlaybackLoader loader = _loader(
      repository: _RecordingRepository(null, error: error),
      cache: cache,
      isOffline: () async => false,
    );

    final ResolvedQueueEntry entry = await loader.resolveQueueEntry(_item());

    expect(entry.cachedFile, isNotNull);
  });

  test('prefetched entry is reused before connectivity check', () async {
    int connectivityChecks = 0;
    final _RecordingRepository remote = _RecordingRepository(_loadResult());
    final PlayerPlaybackLoader loader = _loader(
      repository: remote,
      cache: _cache(directory),
      isOffline: () async {
        connectivityChecks += 1;
        return false;
      },
    );

    expect(await loader.prefetchQueueEntry(_item()), isTrue);
    final ResolvedQueueEntry entry = await loader.resolveQueueEntry(_item());

    expect(entry.audioStream.streamUrl, isNotEmpty);
    expect(connectivityChecks, 1);
    expect(remote.calls, 1);
  });

  test('cached entry parts selects matching enriched part', () async {
    final File cachedFile = File('cached.audio');
    final AudioStreamInfo stream = _stream(qualityId: 30232, bandwidth: 132000);
    final ResolvedQueueEntry entry = ResolvedQueueEntry(
      item: _item(),
      availableParts: const <PlayableItem>[],
      audioStream: stream,
      cachedFile: cachedFile,
    );
    final PlayerPlaybackLoader loader = _loader(
      repository: _RecordingRepository(_loadResult()),
      cache: _cache(directory),
      isOffline: () async => false,
      resolveAllParts: (PlayableItem item) async => <PlayableItem>[
        _item(cid: 111, pageTitle: 'Part 1', replyCount: 100),
        _item(cid: 222, pageTitle: 'Part 2', replyCount: 200),
      ],
    );

    final ResolvedQueueEntry? result = await loader.resolveCachedEntryParts(
      entry,
    );

    expect(result?.item.cid, 222);
    expect(result?.item.pageTitle, 'Part 2');
    expect(result?.item.replyCount, 200);
    expect(result?.availableParts.map((PlayableItem item) => item.cid), <int?>[
      111,
      222,
    ]);
    expect(result?.audioStream, same(stream));
    expect(result?.cachedFile, same(cachedFile));
  });

  test('cached entry parts returns null when view request fails', () async {
    final PlayerPlaybackLoader loader = _loader(
      repository: _RecordingRepository(_loadResult()),
      cache: _cache(directory),
      isOffline: () async => false,
      resolveAllParts: (_) async => throw StateError('view failed'),
    );

    final ResolvedQueueEntry? result = await loader.resolveCachedEntryParts(
      ResolvedQueueEntry(
        item: _item(),
        availableParts: const <PlayableItem>[],
        audioStream: _stream(qualityId: 30232, bandwidth: 132000),
        cachedFile: File('cached.audio'),
      ),
    );

    expect(result, isNull);
  });

  test(
    'cached entry remains immediately available after reconnecting',
    () async {
      final PlayerAudioCacheRepository cache = _cache(directory);
      await cache.cacheAudio(
        item: _item(),
        audioStream: _stream(qualityId: 30232, bandwidth: 132000),
      );
      bool offline = true;
      final _RecordingRepository remote = _RecordingRepository(_loadResult());
      final PlayerPlaybackLoader loader = _loader(
        repository: remote,
        cache: cache,
        isOffline: () async => offline,
      );

      final ResolvedQueueEntry cached = await loader.resolveQueueEntry(_item());
      offline = false;
      final ResolvedQueueEntry resolved = await loader.resolveQueueEntry(
        _item(),
      );

      expect(cached.audioStream.availableQualities, hasLength(1));
      expect(remote.calls, 0);
      expect(resolved.audioStream.availableQualities, hasLength(1));
    },
  );
}

PlayerPlaybackLoader _loader({
  required BiliPlayerRepository repository,
  required PlayerAudioCacheRepository cache,
  PlayerAudioQualityPreference preference = PlayerAudioQualityPreference.auto,
  required Future<bool> Function() isOffline,
  Future<List<PlayableItem>> Function(PlayableItem item)? resolveAllParts,
}) => PlayerPlaybackLoader(
  repository: repository,
  audioCacheRepository: cache,
  audioEngine: _UnusedPlayerAudioEngine(),
  readSession: () => null,
  readQualityPreference: () => preference,
  logEvent: (_, {details}) {},
  isOffline: isOffline,
  resolveAllParts: resolveAllParts,
);

PlayerAudioCacheRepository _cache(Directory directory) {
  String index = '[]';
  final Map<String, File> files = <String, File>{};
  return PlayerAudioCacheRepository(
    null,
    readIndex: () async => index,
    writeIndex: (String value) async => index = value,
    readCachedFile: (String key) async => files[key],
    downloadFile: (String _, String key, Map<String, String>? _) async {
      final File file = File('${directory.path}/${files.length}.audio');
      await file.writeAsString('audio');
      files[key] = file;
      return file;
    },
    removeFile: (String key) async => files.remove(key),
  );
}

PlayableItem _item({int cid = 222, String? pageTitle, int? replyCount}) =>
    PlayableItem(
      aid: 1,
      bvid: 'BV1',
      cid: cid,
      title: 'Title',
      author: 'Author',
      coverUrl: '',
      pageTitle: pageTitle,
      replyCount: replyCount,
    );

AudioStreamInfo _stream({required int qualityId, required int bandwidth}) =>
    AudioStreamInfo(
      streamUrl: 'https://audio/$qualityId',
      backupUrls: const <String>[],
      headers: const <String, String>{},
      cid: 222,
      duration: const Duration(seconds: 1),
      bandwidth: bandwidth,
      qualityId: qualityId,
      qualityLabel: '$qualityId',
      availableQualities: const <AudioQualityOption>[],
    );

PlayerLoadResult _loadResult() {
  final AudioStreamInfo selected = _stream(qualityId: 30232, bandwidth: 132000);
  return PlayerLoadResult(
    item: _item(),
    availableParts: const <PlayableItem>[],
    audioStream: AudioStreamInfo(
      streamUrl: selected.streamUrl,
      backupUrls: selected.backupUrls,
      headers: selected.headers,
      cid: selected.cid,
      duration: selected.duration,
      bandwidth: selected.bandwidth,
      qualityId: selected.qualityId,
      qualityLabel: selected.qualityLabel,
      availableQualities: const <AudioQualityOption>[
        AudioQualityOption(qualityId: 30280, bandwidth: 192000, label: '192K'),
        AudioQualityOption(
          qualityId: 30232,
          bandwidth: 132000,
          label: '132K',
          isSelected: true,
        ),
      ],
    ),
  );
}

class _RecordingRepository extends BiliPlayerRepository {
  _RecordingRepository(this.result, {this.error})
    : super(_UnusedBiliHttpClient());

  final PlayerLoadResult? result;
  final Object? error;
  int calls = 0;
  PlayerAudioQualityPreference? preference;
  int? preferredQualityId;

  @override
  Future<PlayerLoadResult> resolveAudioStream(
    PlayableItem item, {
    required BiliSession? session,
    required PlayerAudioQualityPreference qualityPreference,
    int? preferredQualityId,
  }) async {
    calls++;
    preference = qualityPreference;
    this.preferredQualityId = preferredQualityId;
    if (error != null) throw error!;
    return result!;
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
