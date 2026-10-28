import 'dart:async';
import 'dart:io';

import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:bilimusic/feature/player/data/audio_cache_repository.dart';
import 'package:bilimusic/feature/player/data/bili_player_repository.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/logic/playback/player_playback_loader.dart';
import 'package:bilimusic/feature/player/logic/playback/player_audio_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;

  setUp(() async => directory = await Directory.systemTemp.createTemp());
  tearDown(() async => directory.delete(recursive: true));

  for (final bool hangingConnectivity in <bool>[true, false]) {
    test(
      'resolution times out within five seconds with hanging ${hangingConnectivity ? 'connectivity' : 'request'}',
      () async {
        final PlayerPlaybackLoader loader = _loader(
          repository: _RecordingRepository(
            null,
            pending: Completer<PlayerLoadResult>().future,
          ),
          cache: _cache(directory),
          isOffline: () => hangingConnectivity
              ? Completer<bool>().future
              : Future<bool>.value(false),
        );
        final Stopwatch watch = Stopwatch()..start();

        await expectLater(
          loader.resolveQueueEntry(_item()),
          throwsA(isA<TimeoutException>()),
        );

        expect(watch.elapsed, greaterThanOrEqualTo(const Duration(seconds: 5)));
        expect(watch.elapsed, lessThan(const Duration(seconds: 6)));
      },
    );
  }

  test('cache hit bypasses a hanging connectivity check', () async {
    final PlayerAudioCacheRepository cache = _cache(directory);
    final File file = await cache.cacheAudio(
      item: _item(),
      audioStream: _stream(qualityId: 30232, bandwidth: 132000),
    );
    final _RecordingRepository remote = _RecordingRepository(
      null,
      error: StateError('network must not be used'),
    );
    int checks = 0;
    final ResolvedQueueEntry entry = await _loader(
      repository: remote,
      cache: cache,
      isOffline: () {
        checks++;
        return Completer<bool>().future;
      },
    ).resolveQueueEntry(_item()).timeout(const Duration(seconds: 1));

    expect(entry.cachedFile?.path, file.path);
    expect(checks, 0);
    expect(remote.calls, 0);
  });

  test('online exact cache retains remote qualities and preference', () async {
    final _RecordingRepository remote = _RecordingRepository(_loadResult());
    final PlayerAudioCacheRepository cache = _cache(directory);
    final AudioStreamInfo stream = _loadResult().audioStream;
    final File file = await cache.cacheAudio(
      item: _item(),
      audioStream: stream,
    );
    final PlayerPlaybackLoader loader = _loader(
      repository: remote,
      cache: cache,
      preference: PlayerAudioQualityPreference.k132,
      isOffline: () async => false,
    );
    final ResolvedQueueEntry entry = await loader.resolveQueueEntry(
      _item(),
      preferredQualityId: 30232,
    );

    expect(remote.calls, 0);
    expect(entry.cachedFile?.path, file.path);
    expect(entry.audioStream.availableQualities, hasLength(1));

    final ResolvedQueueEntry? refreshed = await loader.resolveCachedEntryParts(
      entry,
    );
    expect(remote.calls, 1);
    expect(remote.preference, PlayerAudioQualityPreference.k132);
    expect(remote.preferredQualityId, 30232);
    expect(refreshed?.audioStream.availableQualities, hasLength(2));
  });

  test('online missing selected cache does not use another quality', () async {
    final PlayerAudioCacheRepository cache = _cache(directory);
    await cache.cacheAudio(
      item: _item(),
      audioStream: _stream(qualityId: 30280, bandwidth: 192000),
    );
    final ResolvedQueueEntry entry = await _loader(
      repository: _RecordingRepository(_loadResult()),
      cache: cache,
      isOffline: () async => false,
    ).resolveQueueEntry(_item(), preferredQualityId: 30232);

    expect(entry.cachedFile, isNull);
  });

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
      expect(entry.audioStream.qualityId, 30232);
    },
  );

  test('network failure falls back while connectivity stays online', () async {
    final PlayerAudioCacheRepository cache = _cache(directory);
    await cache.cacheAudio(
      item: _item(),
      audioStream: _stream(qualityId: 30280, bandwidth: 192000),
    );
    int checks = 0;
    final ResolvedQueueEntry entry = await _loader(
      repository: _RecordingRepository(
        null,
        error: const SocketException('network unavailable'),
      ),
      cache: cache,
      preference: PlayerAudioQualityPreference.k132,
      isOffline: () async {
        checks++;
        return false;
      },
    ).resolveQueueEntry(_item());

    expect(checks, 1);
    expect(entry.cachedFile, isNotNull);
    expect(entry.audioStream.qualityId, 30280);
  });

  test('business error does not fall back to another cached quality', () async {
    final PlayerAudioCacheRepository cache = _cache(directory);
    await cache.cacheAudio(
      item: _item(),
      audioStream: _stream(qualityId: 30280, bandwidth: 192000),
    );
    const BiliPlayerException error = BiliPlayerException(
      'API failed',
      code: -404,
    );
    final PlayerPlaybackLoader loader = _loader(
      repository: _RecordingRepository(null, error: error),
      cache: cache,
      preference: PlayerAudioQualityPreference.k132,
      isOffline: () async => false,
    );

    await expectLater(loader.resolveQueueEntry(_item()), throwsA(same(error)));
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
    expect(result?.audioStream.qualityId, stream.qualityId);
    expect(result?.audioStream.bandwidth, stream.bandwidth);
    expect(result?.audioStream.streamUrl, stream.streamUrl);
    expect(
      result?.audioStream.availableQualities
          .where((AudioQualityOption option) => option.isSelected)
          .single
          .qualityId,
      stream.qualityId,
    );
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

  test('reconnecting keeps cache playback and refreshes qualities', () async {
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
    final ResolvedQueueEntry resolved = await loader.resolveQueueEntry(_item());

    expect(cached.audioStream.availableQualities, hasLength(1));
    expect(remote.calls, 0);
    expect(resolved.cachedFile, isNotNull);
    final ResolvedQueueEntry? refreshed = await loader.resolveCachedEntryParts(
      resolved,
    );
    expect(remote.calls, 1);
    expect(refreshed?.audioStream.availableQualities, hasLength(2));
  });

  test('offline falls back when the requested quality is not cached', () async {
    final PlayerAudioCacheRepository cache = _cache(directory);
    await cache.cacheAudio(
      item: _item(),
      audioStream: _stream(qualityId: 30232, bandwidth: 132000),
    );
    final _RecordingRepository remote = _RecordingRepository(_loadResult());
    final ResolvedQueueEntry entry = await _loader(
      repository: remote,
      cache: cache,
      preference: PlayerAudioQualityPreference.hires,
      isOffline: () async => true,
    ).resolveQueueEntry(_item());

    expect(entry.audioStream.qualityId, 30232);
    expect(remote.calls, 0);
  });

  test('auto uses the highest cached quality without network', () async {
    final PlayerAudioCacheRepository cache = _cache(directory);
    for (final int bandwidth in <int>[132000, 192000]) {
      await cache.cacheAudio(
        item: _item(),
        audioStream: _stream(
          qualityId: bandwidth == 132000 ? 30232 : 30280,
          bandwidth: bandwidth,
        ),
      );
    }
    final _RecordingRepository remote = _RecordingRepository(_loadResult());
    final ResolvedQueueEntry entry = await _loader(
      repository: remote,
      cache: cache,
      isOffline: () async => throw StateError('must not check'),
    ).resolveQueueEntry(_item());

    expect(entry.audioStream.qualityId, 30280);
    expect(remote.calls, 0);
  });

  test('cache lookup isolates cid and resolves missing cid by page', () async {
    final PlayerAudioCacheRepository cache = _cache(directory);
    await cache.cacheAudio(
      item: _item(cid: 333, page: 2),
      audioStream: _stream(cid: 333, qualityId: 30280, bandwidth: 192000),
    );
    final _RecordingRepository remote = _RecordingRepository(_loadResult());
    final PlayerPlaybackLoader loader = _loader(
      repository: remote,
      cache: cache,
      isOffline: () async => false,
    );
    final ResolvedQueueEntry part2 = await loader.resolveQueueEntry(
      _item(cid: null, page: 2),
    );
    expect(part2.item.cid, 333);
    expect(part2.item.page, 2);
    expect(remote.calls, 0);

    final ResolvedQueueEntry part1 = await loader.resolveQueueEntry(_item());
    expect(remote.calls, 1);
    expect(part1.cachedFile, isNull);
  });

  test('memory aliases isolate pages when cid is missing', () async {
    final PlayerPlaybackLoader loader = _loader(
      repository: _RecordingRepository(_loadResult()),
      cache: _cache(directory),
      isOffline: () async => false,
    );
    final _RecordingRepository remote = _RecordingRepository(_loadResult());
    final PlayerPlaybackLoader recordingLoader = _loader(
      repository: remote,
      cache: _cache(directory),
      isOffline: () async => false,
    );
    expect(
      loader.resolvedEntryCacheKey(
        _item(cid: null, page: 1),
        preference: PlayerAudioQualityPreference.auto,
      ),
      isNot(
        loader.resolvedEntryCacheKey(
          _item(cid: null, page: 2),
          preference: PlayerAudioQualityPreference.auto,
        ),
      ),
    );
    await recordingLoader.resolveQueueEntry(_item(cid: null, page: 2));
    await recordingLoader.resolveQueueEntry(_item(cid: null, page: 1));
    expect(remote.calls, 2);
  });

  test(
    'offline background completion does not request parts or qualities',
    () async {
      final _RecordingRepository remote = _RecordingRepository(_loadResult());
      final ResolvedQueueEntry? completed =
          await _loader(
            repository: remote,
            cache: _cache(directory),
            isOffline: () async => true,
            resolveAllParts: (_) async =>
                throw StateError('must not request parts'),
          ).resolveCachedEntryParts(
            ResolvedQueueEntry(
              item: _item(),
              availableParts: const <PlayableItem>[],
              audioStream: _stream(qualityId: 30232, bandwidth: 132000),
              cachedFile: File('cached.audio'),
            ),
          );

      expect(completed, isNull);
      expect(remote.calls, 0);
    },
  );

  test('quality refresh failure preserves successful parts', () async {
    final AudioStreamInfo stream = _stream(qualityId: 30232, bandwidth: 132000);
    final ResolvedQueueEntry? completed =
        await _loader(
          repository: _RecordingRepository(
            null,
            error: const SocketException('offline'),
          ),
          cache: _cache(directory),
          isOffline: () async => false,
          resolveAllParts: (_) async => <PlayableItem>[
            _item(pageTitle: 'Enriched'),
          ],
        ).resolveCachedEntryParts(
          ResolvedQueueEntry(
            item: _item(),
            availableParts: const <PlayableItem>[],
            audioStream: stream,
            cachedFile: File('cached.audio'),
          ),
        );

    expect(completed?.item.pageTitle, 'Enriched');
    expect(completed?.availableParts, hasLength(1));
    expect(completed?.audioStream, same(stream));
  });

  test(
    'refresh retains a cached quality missing from remote options',
    () async {
      final AudioStreamInfo stream = _stream(
        qualityId: 30251,
        bandwidth: 1000000,
      );
      final ResolvedQueueEntry? completed =
          await _loader(
            repository: _RecordingRepository(_loadResult()),
            cache: _cache(directory),
            isOffline: () async => false,
          ).resolveCachedEntryParts(
            ResolvedQueueEntry(
              item: _item(),
              availableParts: const <PlayableItem>[],
              audioStream: stream,
              cachedFile: File('cached.audio'),
            ),
          );

      expect(completed?.audioStream.qualityId, 30251);
      expect(completed?.audioStream.bandwidth, 1000000);
      expect(completed?.audioStream.availableQualities, hasLength(3));
      expect(
        completed?.audioStream.availableQualities
            .where((AudioQualityOption option) => option.isSelected)
            .single
            .qualityId,
        30251,
      );
    },
  );

  test(
    'file open failure removes cache and next resolve uses remote',
    () async {
      final PlayerAudioCacheRepository cache = _cache(directory);
      await cache.cacheAudio(
        item: _item(),
        audioStream: _stream(qualityId: 30232, bandwidth: 132000),
      );
      final _RecordingRepository remote = _RecordingRepository(_loadResult());
      final _RecordingAudioEngine engine = _RecordingAudioEngine();
      final PlayerPlaybackLoader loader = _loader(
        repository: remote,
        cache: cache,
        audioEngine: engine,
        isOffline: () async => false,
      );
      final ResolvedQueueEntry cached = await loader.resolveQueueEntry(_item());
      await loader.setSourceForEntry(
        entry: cached,
        initialPosition: const Duration(seconds: 10),
        onStatusHint: (_) {},
      );
      expect(engine.filePaths, <String>[cached.cachedFile!.path]);
      expect(engine.initialPosition, const Duration(seconds: 10));
      expect(remote.calls, 0);

      engine.fileError = StateError('decoder rejected file');
      await expectLater(
        loader.setSourceForEntry(
          entry: cached,
          initialPosition: Duration.zero,
          onStatusHint: (_) {},
        ),
        throwsStateError,
      );
      expect(engine.remoteUris, isEmpty);
      final ResolvedQueueEntry next = await loader.resolveQueueEntry(_item());
      expect(next.cachedFile, isNull);
      expect(next.audioStream.streamUrl, isNotEmpty);
      expect(remote.calls, 1);
    },
  );

  test('network failure without cache preserves the original error', () async {
    const SocketException error = SocketException('offline');
    final PlayerPlaybackLoader loader = _loader(
      repository: _RecordingRepository(null, error: error),
      cache: _cache(directory),
      isOffline: () async => false,
    );
    await expectLater(loader.resolveQueueEntry(_item()), throwsA(same(error)));
  });
}

PlayerPlaybackLoader _loader({
  required BiliPlayerRepository repository,
  required PlayerAudioCacheRepository cache,
  PlayerAudioQualityPreference preference = PlayerAudioQualityPreference.auto,
  required Future<bool> Function() isOffline,
  PlayerAudioEngine? audioEngine,
  Future<List<PlayableItem>> Function(PlayableItem item)? resolveAllParts,
}) => PlayerPlaybackLoader(
  repository: repository,
  audioCacheRepository: cache,
  audioEngine: audioEngine ?? _UnusedPlayerAudioEngine(),
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

PlayableItem _item({
  int? cid = 222,
  int? page = 1,
  String? pageTitle,
  int? replyCount,
}) => PlayableItem(
  aid: 1,
  bvid: 'BV1',
  cid: cid,
  page: page,
  title: 'Title',
  author: 'Author',
  coverUrl: '',
  pageTitle: pageTitle,
  replyCount: replyCount,
);

AudioStreamInfo _stream({
  int cid = 222,
  required int qualityId,
  required int bandwidth,
}) => AudioStreamInfo(
  streamUrl: 'https://audio/$qualityId',
  backupUrls: const <String>[],
  headers: const <String, String>{},
  cid: cid,
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
  _RecordingRepository(this.result, {this.error, this.pending})
    : super(_UnusedBiliHttpClient());

  final PlayerLoadResult? result;
  final Future<PlayerLoadResult>? pending;
  final Object? error;
  int calls = 0;
  PlayerAudioQualityPreference? preference;
  int? preferredQualityId;

  @override
  Future<List<PlayableItem>> resolveAllParts(PlayableItem item) async {
    return <PlayableItem>[_item()];
  }

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
    if (pending != null) return pending!;
    return result!;
  }
}

class _UnusedBiliHttpClient implements BiliHttpClient {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RecordingAudioEngine implements PlayerAudioEngine {
  final List<String> filePaths = <String>[];
  final List<Uri> remoteUris = <Uri>[];
  Duration? initialPosition;
  Object? fileError;

  @override
  Future<Duration?> setFileSource({
    required String filePath,
    Duration? initialPosition,
  }) async {
    filePaths.add(filePath);
    this.initialPosition = initialPosition;
    if (fileError != null) throw fileError!;
    return const Duration(seconds: 1);
  }

  @override
  Future<Duration?> setRemoteSource({
    required Uri uri,
    Map<String, String>? headers,
    Duration? initialPosition,
  }) async {
    remoteUris.add(uri);
    return const Duration(seconds: 1);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedPlayerAudioEngine implements PlayerAudioEngine {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
