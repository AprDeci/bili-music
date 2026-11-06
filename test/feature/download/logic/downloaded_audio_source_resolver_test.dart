import 'dart:io';

import 'package:bilimusic/feature/download/data/download_repository.dart';
import 'package:bilimusic/feature/download/domain/downloaded_track.dart';
import 'package:bilimusic/feature/download/logic/downloaded_audio_source_resolver.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/player/logic/playback/audio_source_resolver.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolves a downloaded track to a local file source', () async {
    final _MemoryIndexStore store = _MemoryIndexStore();
    final Directory directory = await Directory.systemTemp.createTemp('dl_');
    addTearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });
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
            await File(savePath).writeAsBytes(<int>[1, 2, 3]);
          },
    );
    await repository.downloadTrack(item: _item(), stream: _stream());

    final DownloadedAudioSourceResolver resolver =
        DownloadedAudioSourceResolver(repository);
    final ResolvedQueueEntry? entry = await resolver.resolve(
      AudioResolutionRequest(
        item: _item(),
        qualityPreference: PlayerAudioQualityPreference.auto,
      ),
    );

    expect(entry, isNotNull);
    expect(entry!.cachedFile?.existsSync(), isTrue);
    expect(entry.audioStream.cid, 10);
    expect(entry.audioStream.qualityLabel, '192K');
    expect(entry.audioStream.duration, const Duration(seconds: 225));
  });

  test('returns null when the track was never downloaded', () async {
    final Directory directory = await Directory.systemTemp.createTemp('dl_');
    addTearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });
    final DownloadRepository repository = DownloadRepository(
      _MemoryIndexStore(),
      readDirectory: () async => directory,
      fetcher:
          ({
            required String url,
            required String savePath,
            required Map<String, String> headers,
            required CancelToken cancelToken,
            void Function(int, int)? onProgress,
          }) async {
            await File(savePath).writeAsBytes(<int>[]);
          },
    );

    final DownloadRepository emptyRepository = DownloadRepository(
      _EmptyStore(),
      readDirectory: _tempDirectory,
    );

    expect(
      await DownloadedAudioSourceResolver(emptyRepository).resolve(
        AudioResolutionRequest(
          item: _item(),
          qualityPreference: PlayerAudioQualityPreference.auto,
        ),
      ),
      isNull,
    );
    expect(repository.loadAll(), isEmpty);
  });

  test('returns null when the downloaded file is gone', () async {
    final _MemoryIndexStore store = _MemoryIndexStore();
    final Directory directory = await Directory.systemTemp.createTemp('dl_');
    addTearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });
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
            await File(savePath).writeAsBytes(<int>[1, 2, 3]);
          },
    );
    final DownloadedTrack track = await repository.downloadTrack(
      item: _item(),
      stream: _stream(),
    );
    await File(track.filePath).delete();

    expect(
      await DownloadedAudioSourceResolver(repository).resolve(
        AudioResolutionRequest(
          item: _item(),
          qualityPreference: PlayerAudioQualityPreference.auto,
        ),
      ),
      isNull,
    );
  });
}

Future<Directory> _tempDirectory() async =>
    Directory.systemTemp.createTemp('dl_empty_');

PlayableItem _item() {
  return const PlayableItem(
    aid: 1,
    bvid: 'BV1',
    cid: 10,
    page: 1,
    title: '夜曲',
    author: '周杰伦',
    coverUrl: '',
  );
}

AudioStreamInfo _stream() {
  return const AudioStreamInfo(
    streamUrl: 'https://example.com/audio.m4a',
    backupUrls: <String>[],
    headers: <String, String>{},
    cid: 10,
    duration: Duration(seconds: 225),
    bandwidth: 192000,
    availableQualities: <AudioQualityOption>[],
    qualityId: 30280,
    qualityLabel: '192K',
  );
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

class _EmptyStore implements DownloadIndexStore {
  @override
  Map<String, String> loadAll() => <String, String>{};

  @override
  Future<void> put(String contentId, String json) async {}

  @override
  Future<void> remove(String contentId) async {}

  @override
  Future<void> clear() async {}
}
