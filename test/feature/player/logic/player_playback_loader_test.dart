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
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cached entry parts selects matching enriched part', () async {
    final File cachedFile = File('cached.audio');
    final AudioStreamInfo stream = _stream();
    final ResolvedQueueEntry entry = ResolvedQueueEntry(
      item: _item(cid: 222),
      availableParts: const <PlayableItem>[],
      audioStream: stream,
      cachedFile: cachedFile,
    );
    bool called = false;
    final PlayerPlaybackLoader loader = _loader(
      resolveAllParts: (PlayableItem item) async {
        called = true;
        expect(item.cid, 222);
        return <PlayableItem>[
          _item(cid: 111, pageTitle: 'Part 1', replyCount: 100),
          _item(cid: 222, pageTitle: 'Part 2', replyCount: 200),
        ];
      },
    );

    final ResolvedQueueEntry? result = await loader.resolveCachedEntryParts(
      entry,
    );

    expect(called, isTrue);
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
      resolveAllParts: (_) async => throw StateError('view failed'),
    );

    final ResolvedQueueEntry? result = await loader.resolveCachedEntryParts(
      ResolvedQueueEntry(
        item: _item(cid: 222),
        availableParts: const <PlayableItem>[],
        audioStream: _stream(),
        cachedFile: File('cached.audio'),
      ),
    );

    expect(result, isNull);
  });
}

PlayerPlaybackLoader _loader({
  required Future<List<PlayableItem>> Function(PlayableItem) resolveAllParts,
}) {
  return PlayerPlaybackLoader(
    repository: BiliPlayerRepository(_UnusedBiliHttpClient()),
    audioCacheRepository: PlayerAudioCacheRepository(
      null,
      readCachedFile: (_) async => null,
      downloadFile: (_, _, _) async => throw UnimplementedError(),
      removeFile: (_) async {},
    ),
    audioEngine: _UnusedPlayerAudioEngine(),
    readSession: () => null,
    readQualityPreference: () => PlayerAudioQualityPreference.auto,
    logEvent: (_, {details}) {},
    resolveAllParts: resolveAllParts,
  );
}

PlayableItem _item({required int cid, String? pageTitle, int? replyCount}) {
  return PlayableItem(
    aid: 1,
    bvid: 'BV1',
    cid: cid,
    title: 'Title',
    author: 'Author',
    coverUrl: '',
    pageTitle: pageTitle,
    replyCount: replyCount,
  );
}

AudioStreamInfo _stream() {
  return const AudioStreamInfo(
    streamUrl: '',
    backupUrls: <String>[],
    headers: <String, String>{},
    cid: 222,
    duration: null,
    bandwidth: 192000,
    availableQualities: <AudioQualityOption>[],
  );
}

class _UnusedBiliHttpClient implements BiliHttpClient {
  @override
  BiliSession? get currentSession => null;

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
    bool requiresWbi = false,
    BiliRequestMode mode = BiliRequestMode.defaultCookie,
    Options? options,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    BiliRequestMode mode = BiliRequestMode.defaultCookie,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    throw UnimplementedError();
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedPlayerAudioEngine implements PlayerAudioEngine {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
