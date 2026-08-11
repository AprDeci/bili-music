import 'dart:convert';
import 'dart:io';

import 'package:bilimusic/feature/player/data/audio_cache_repository.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late String indexJson;
  late Map<String, File> files;
  late List<String> removedKeys;
  late PlayerAudioCacheRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('bilimusic_audio_cache_');
    indexJson = '[]';
    files = <String, File>{};
    removedKeys = <String>[];
    repository = PlayerAudioCacheRepository(
      null,
      readIndex: () async => indexJson,
      writeIndex: (String value) async => indexJson = value,
      readCachedFile: (String key) async => files[key],
      downloadFile:
          (String url, String key, Map<String, String>? headers) async {
            final File file = File('${directory.path}/${files.length}.audio');
            await file.writeAsString('audio:$url');
            files[key] = file;
            return file;
          },
      removeFile: (String key) async {
        removedKeys.add(key);
        final File? file = files.remove(key);
        if (file != null && await file.exists()) {
          await file.delete();
        }
      },
    );
  });

  tearDown(() async {
    await directory.delete(recursive: true);
  });

  test('cache key ignores URL and isolates identity, cid and quality', () {
    final PlayableItem item = _item(bvid: 'BV1', aid: 1, cid: 10);
    final String first = repository.buildCacheKey(
      item: item,
      audioStream: _stream(url: 'https://one', cid: 10, qualityId: 30280),
    );
    final String refreshedUrl = repository.buildCacheKey(
      item: item,
      audioStream: _stream(url: 'https://two', cid: 10, qualityId: 30280),
    );

    expect(refreshedUrl, first);
    expect(
      repository.buildCacheKey(
        item: _item(bvid: 'BV2', aid: 1, cid: 10),
        audioStream: _stream(url: 'https://one', cid: 10, qualityId: 30280),
      ),
      isNot(first),
    );
    expect(
      repository.buildCacheKey(
        item: _item(bvid: 'BV1', aid: 1, cid: 11),
        audioStream: _stream(url: 'https://one', cid: 11, qualityId: 30280),
      ),
      isNot(first),
    );
    expect(
      repository.buildCacheKey(
        item: item,
        audioStream: _stream(url: 'https://one', cid: 10, qualityId: 30232),
      ),
      isNot(first),
    );
  });

  test(
    'persistent lookup selects exact quality or highest auto quality',
    () async {
      final PlayableItem item = _item(bvid: 'BV1', aid: 1, cid: 10);
      await repository.cacheAudio(
        item: item,
        audioStream: _stream(
          url: 'https://low',
          cid: 10,
          qualityId: 30232,
          bandwidth: 132000,
        ),
      );
      await repository.cacheAudio(
        item: item,
        audioStream: _stream(
          url: 'https://high',
          cid: 10,
          qualityId: 30280,
          bandwidth: 192000,
        ),
      );

      final CachedAudio? exact = await repository.lookupCachedAudio(
        item: item,
        preference: PlayerAudioQualityPreference.k132,
      );
      final CachedAudio? automatic = await repository.lookupCachedAudio(
        item: item,
        preference: PlayerAudioQualityPreference.auto,
      );
      final CachedAudio? fallback = await repository.lookupCachedAudio(
        item: item,
        preference: PlayerAudioQualityPreference.hires,
      );

      expect(exact?.metadata.qualityId, 30232);
      expect(automatic?.metadata.qualityId, 30280);
      expect(fallback?.metadata.qualityId, 30280);
      expect(jsonDecode(indexJson), hasLength(2));
    },
  );

  test('bvid cache hit does not depend on aid being populated', () async {
    await repository.cacheAudio(
      item: _item(bvid: 'BV1', aid: 1, cid: 10),
      audioStream: _stream(url: 'https://audio', cid: 10, qualityId: 30280),
    );

    final CachedAudio? cached = await repository.lookupCachedAudio(
      item: _item(bvid: 'BV1', aid: 0, cid: 10),
      preference: PlayerAudioQualityPreference.k192,
    );

    expect(cached?.metadata.qualityId, 30280);
  });

  test('damaged file invalidates persistent index', () async {
    final PlayableItem item = _item(bvid: 'BV1', aid: 1, cid: 10);
    final AudioStreamInfo stream = _stream(
      url: 'https://audio',
      cid: 10,
      qualityId: 30280,
    );
    await repository.cacheAudio(item: item, audioStream: stream);
    final String key = repository.buildCacheKey(
      item: item,
      audioStream: stream,
    );
    await files[key]!.writeAsString('damaged');

    expect(
      await repository.lookupCachedAudio(
        item: item,
        preference: PlayerAudioQualityPreference.k192,
      ),
      isNull,
    );
    expect(jsonDecode(indexJson), isEmpty);
    expect(removedKeys, contains(key));
  });
}

PlayableItem _item({required String bvid, required int aid, required int cid}) {
  return PlayableItem(
    aid: aid,
    bvid: bvid,
    cid: cid,
    title: 'title',
    author: 'author',
    coverUrl: '',
  );
}

AudioStreamInfo _stream({
  required String url,
  required int cid,
  required int qualityId,
  int bandwidth = 192000,
}) {
  return AudioStreamInfo(
    streamUrl: url,
    backupUrls: const <String>[],
    headers: const <String, String>{},
    cid: cid,
    duration: const Duration(minutes: 3),
    bandwidth: bandwidth,
    availableQualities: const <AudioQualityOption>[],
    qualityId: qualityId,
    qualityLabel: '$qualityId',
  );
}
