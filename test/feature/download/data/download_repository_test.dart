import 'dart:io';

import 'package:bilimusic/feature/download/data/download_repository.dart';
import 'package:bilimusic/feature/download/domain/downloaded_track.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
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

  test('repository downloads, lists and deletes tracks', () async {
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
            required Map<String, String> headers,
            void Function(int, int)? onProgress,
          }) async {
            onProgress?.call(4, 8);
            onProgress?.call(8, 8);
            return <int>[1, 2, 3, 4, 5, 6, 7, 8];
          },
    );

    final DownloadedTrack track = await repository.downloadTrack(
      item: _item(),
      stream: _stream(),
    );

    expect(File(track.filePath).existsSync(), isTrue);
    expect(await File(track.filePath).length(), 8);
    expect(repository.loadAll().length, 1);
    expect(repository.totalBytes(), 8);
    expect(repository.findByContentId('bvid:BV1:page:1')?.title, '夜曲');

    await repository.remove(track);
    expect(repository.loadAll(), isEmpty);
    expect(File(track.filePath).existsSync(), isFalse);
  });

  test('repository clears all downloads and files', () async {
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
            required Map<String, String> headers,
            void Function(int, int)? onProgress,
          }) async => <int>[1, 2, 3],
    );

    final DownloadedTrack first = await repository.downloadTrack(
      item: _item(),
      stream: _stream(),
    );
    final DownloadedTrack second = await repository.downloadTrack(
      item: _item(page: 2, cid: 11),
      stream: _stream(cid: 11),
    );

    await repository.clearAll();

    expect(repository.loadAll(), isEmpty);
    expect(File(first.filePath).existsSync(), isFalse);
    expect(File(second.filePath).existsSync(), isFalse);
  });
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

AudioStreamInfo _stream({int cid = 10}) {
  return AudioStreamInfo(
    streamUrl: 'https://example.com/audio.m4a',
    backupUrls: const <String>[],
    headers: const <String, String>{},
    cid: cid,
    duration: const Duration(seconds: 225),
    bandwidth: 192000,
    availableQualities: const <AudioQualityOption>[],
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
