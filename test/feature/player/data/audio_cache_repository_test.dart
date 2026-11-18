import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bilimusic/feature/player/data/audio_cache_repository.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/feature/player/domain/player_audio_quality_preference.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late String indexJson;
  late Map<String, File> files;
  late List<String> removedKeys;
  late PlayerAudioCacheRepository repository;
  late int limitBytes;
  Completer<void>? downloadGate;
  Completer<void>? downloadStarted;
  Completer<void>? readGate;
  Completer<void>? readStarted;
  Completer<void>? removeGate;
  Completer<void>? removeStarted;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('bilimusic_audio_cache_');
    indexJson = '[]';
    files = <String, File>{};
    removedKeys = <String>[];
    limitBytes = 512 * 1024 * 1024;
    downloadGate = null;
    downloadStarted = null;
    readGate = null;
    readStarted = null;
    removeGate = null;
    removeStarted = null;
    repository = PlayerAudioCacheRepository(
      null,
      readLimitBytes: () => limitBytes,
      readStoredKeys: () async => files.keys.toList(),
      readIndex: () async => indexJson,
      writeIndex: (String value) async => indexJson = value,
      readCachedFile: (String key) async {
        if (readStarted != null && !readStarted!.isCompleted) {
          readStarted!.complete();
        }
        await readGate?.future;
        return files[key];
      },
      downloadFile:
          (String url, String key, Map<String, String>? headers) async {
            downloadStarted?.complete();
            await downloadGate?.future;
            final File file = File('${directory.path}/${url.hashCode}.audio');
            await file.writeAsString('audio:$url');
            files[key] = file;
            return file;
          },
      removeFile: (String key) async {
        if (removeStarted != null && !removeStarted!.isCompleted) {
          removeStarted!.complete();
        }
        await removeGate?.future;
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

  Future<File?> cache(int id) => repository.cacheAudio(
    item: _item(bvid: 'BV$id', aid: id, cid: id),
    audioStream: _stream(url: 'https://$id', cid: id, qualityId: 30280),
  );

  test(
    'disabled cache skips downloads but still reads existing audio',
    () async {
      await cache(1);
      final String previousIndex = indexJson;
      limitBytes = 0;
      await repository.trim();
      expect(await cache(2), isNull);
      expect(files, hasLength(1));
      expect(indexJson, previousIndex);
      expect(
        await repository.lookupCachedAudio(
          item: _item(bvid: 'BV1', aid: 1, cid: 1),
          preference: PlayerAudioQualityPreference.auto,
        ),
        isNotNull,
      );
    },
  );

  test('size eviction uses persistent least recently used order', () async {
    await cache(1);
    await cache(2);
    await repository.lookupCachedAudio(
      item: _item(bvid: 'BV1', aid: 1, cid: 1),
      preference: PlayerAudioQualityPreference.auto,
    );
    final int size = await files.values.first.length();
    limitBytes = size * 2;
    await cache(3);
    final List<dynamic> entries = jsonDecode(indexJson) as List<dynamic>;
    expect(entries.map((dynamic e) => e['aid']), <int>[3, 1]);
    expect(files, hasLength(2));
    limitBytes = size;
    await repository.trim();
    expect((jsonDecode(indexJson) as List<dynamic>).single['aid'], 3);
  });

  test('oversized audio is discarded without evicting useful files', () async {
    final File? first = await cache(1);
    limitBytes = await first!.length();
    expect(await cache(12345), isNull);
    expect(files, hasLength(1));
    expect((jsonDecode(indexJson) as List<dynamic>).single['aid'], 1);
  });

  test('clear defers playing files until release even when disabled', () async {
    await cache(1);
    await cache(2);
    await repository.lookupCachedAudio(
      item: _item(bvid: 'BV1', aid: 1, cid: 1),
      preference: PlayerAudioQualityPreference.auto,
      protect: () => true,
    );
    limitBytes = 1;
    await repository.trim();
    expect(files, hasLength(1));
    limitBytes = 0;
    await repository.clear();
    expect(files, hasLength(1));
    await repository.releaseFiles();
    expect(files, isEmpty);
    expect(jsonDecode(indexJson), isEmpty);
  });

  for (final bool clear in <bool>[true, false]) {
    test(
      '${clear ? 'clear' : 'disable'} rejects an in-flight result',
      () async {
        downloadGate = Completer<void>();
        downloadStarted = Completer<void>();
        final Future<File?> pending = cache(1);
        await downloadStarted!.future;
        if (clear) {
          await repository.clear();
        } else {
          limitBytes = 0;
          await repository.trim();
          limitBytes = 512 * 1024 * 1024;
        }
        downloadGate!.complete();
        expect(await pending, isNull);
        expect(files, isEmpty);
        expect(jsonDecode(indexJson), isEmpty);
      },
    );
  }

  test(
    'real cache manager clear deletes orphan bytes as well as metadata',
    () async {
      const MethodChannel channel = MethodChannel(
        'plugins.flutter.io/path_provider',
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (_) async => directory.path);
      final CacheManager manager = CacheManager(
        Config(
          'audio-clear-test',
          repo: JsonCacheInfoRepository.withFile(
            File('${directory.path}/cache.json'),
          ),
        ),
      );
      try {
        final File file = await manager.putFile(
          'https://orphan',
          utf8.encode('audio'),
          key: 'orphan',
        );
        expect(await file.exists(), isTrue);
        await PlayerAudioCacheRepository(manager).clear();
        expect(await file.exists(), isFalse);
        expect(await manager.store.getCacheSize(), 0);
      } finally {
        await manager.dispose();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      }
    },
  );

  test('clear also removes files missing from the business index', () async {
    await cache(1);
    indexJson = '[]';
    await repository.clear();
    expect(files, isEmpty);
  });

  test(
    'clear wins over a cache request still checking existing data',
    () async {
      await cache(1);
      readGate = Completer<void>();
      readStarted = Completer<void>();
      final Future<File?> pending = cache(1);
      await readStarted!.future;
      final Future<void> clearing = repository.clear();
      readGate!.complete();
      await clearing;
      expect(await pending, isNull);
      expect(files, isEmpty);
    },
  );

  test(
    'validation protects a resolved file before exposing it to playback',
    () async {
      await cache(1);
      readGate = Completer<void>();
      readStarted = Completer<void>();
      final Future<CachedAudio?> pending = repository.lookupCachedAudio(
        item: _item(bvid: 'BV1', aid: 1, cid: 1),
        preference: PlayerAudioQualityPreference.auto,
        protect: () => true,
      );
      await readStarted!.future;
      final Future<void> clearing = repository.clear();
      readGate!.complete();
      expect(await pending, isNotNull);
      await clearing;
      expect(files, hasLength(1));
      await repository.releaseFiles();
      expect(files, isEmpty);
    },
  );

  test('a cancelled lookup cannot leave a file protected after stop', () async {
    await cache(1);
    readGate = Completer<void>();
    readStarted = Completer<void>();
    final Future<CachedAudio?> pending = repository.lookupCachedAudio(
      item: _item(bvid: 'BV1', aid: 1, cid: 1),
      preference: PlayerAudioQualityPreference.auto,
      protect: () => true,
    );
    await readStarted!.future;
    final Future<void> stopped = repository.releaseFiles();
    readGate!.complete();
    expect(await pending, isNull);
    await stopped;
    await repository.clear();
    expect(files, isEmpty);
  });

  test(
    'failed-source invalidation cannot race a new protected lookup',
    () async {
      await cache(1);
      removeGate = Completer<void>();
      removeStarted = Completer<void>();
      final Future<void> removal = repository.removeCachedFile(
        item: _item(bvid: 'BV1', aid: 1, cid: 1),
        audioStream: _stream(url: 'https://1', cid: 1, qualityId: 30280),
      );
      await removeStarted!.future;
      final Future<CachedAudio?> pending = repository.lookupCachedAudio(
        item: _item(bvid: 'BV1', aid: 1, cid: 1),
        preference: PlayerAudioQualityPreference.auto,
        protect: () => true,
      );
      removeGate!.complete();
      await removal;
      expect(await pending, isNull);
      expect(files, isEmpty);
    },
  );

  test('concurrent completions share the same capacity target', () async {
    limitBytes = 'audio:https://1'.length * 2;
    await Future.wait(<Future<File?>>[cache(1), cache(2), cache(3)]);
    expect(files, hasLength(2));
    expect(jsonDecode(indexJson), hasLength(2));
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

  test('missing cid falls back to cached video audio quality', () async {
    await repository.cacheAudio(
      item: _item(bvid: 'BV1', aid: 1, cid: 10),
      audioStream: _stream(
        url: 'https://audio',
        cid: 10,
        qualityId: 30232,
        bandwidth: 132000,
      ),
    );

    final CachedAudio? cached = await repository.lookupCachedAudio(
      item: _itemWithoutCid(bvid: 'BV1', aid: 1),
      preference: PlayerAudioQualityPreference.k192,
    );

    expect(cached?.metadata.cid, 10);
    expect(cached?.metadata.qualityId, 30232);
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

  test(
    'legacy metadata matches cid but does not guess a missing page',
    () async {
      final PlayableItem item = _item(bvid: 'BV1', aid: 1, cid: 10);
      await repository.cacheAudio(
        item: item,
        audioStream: _stream(url: 'https://audio', cid: 10, qualityId: 30280),
      );
      final List<dynamic> entries = jsonDecode(indexJson) as List<dynamic>;
      (entries.single as Map<String, dynamic>).remove('page');
      indexJson = jsonEncode(entries);

      expect(
        await repository.lookupCachedAudio(
          item: item,
          preference: PlayerAudioQualityPreference.auto,
        ),
        isNotNull,
      );
      expect(
        await repository.lookupCachedAudio(
          item: _itemWithoutCid(bvid: 'BV1', aid: 1),
          preference: PlayerAudioQualityPreference.auto,
        ),
        isNull,
      );
      expect(jsonDecode(indexJson), hasLength(1));
    },
  );

  test('strict quality lookup does not use another quality', () async {
    final PlayableItem item = _item(bvid: 'BV1', aid: 1, cid: 10);
    await repository.cacheAudio(
      item: item,
      audioStream: _stream(url: 'https://audio', cid: 10, qualityId: 30280),
    );
    expect(
      await repository.lookupCachedAudio(
        item: item,
        preference: PlayerAudioQualityPreference.k132,
        allowQualityFallback: false,
      ),
      isNull,
    );
  });

  test(
    'auto skips a damaged best candidate and uses the next valid one',
    () async {
      final PlayableItem item = _item(bvid: 'BV1', aid: 1, cid: 10);
      final AudioStreamInfo high = _stream(
        url: 'https://high',
        cid: 10,
        qualityId: 30280,
        bandwidth: 192000,
      );
      await repository.cacheAudio(item: item, audioStream: high);
      await repository.cacheAudio(
        item: item,
        audioStream: _stream(
          url: 'https://low',
          cid: 10,
          qualityId: 30232,
          bandwidth: 132000,
        ),
      );
      final String key = repository.buildCacheKey(
        item: item,
        audioStream: high,
      );
      await files[key]!.writeAsString('damaged');
      final CachedAudio? cached = await repository.lookupCachedAudio(
        item: item,
        preference: PlayerAudioQualityPreference.auto,
      );

      expect(cached?.metadata.qualityId, 30232);
      expect(removedKeys, contains(key));
      expect(jsonDecode(indexJson), hasLength(1));
    },
  );
}

PlayableItem _item({required String bvid, required int aid, required int cid}) {
  return PlayableItem(
    aid: aid,
    bvid: bvid,
    cid: cid,
    page: 1,
    title: 'title',
    author: 'author',
    coverUrl: '',
  );
}

PlayableItem _itemWithoutCid({required String bvid, required int aid}) {
  return PlayableItem(
    aid: aid,
    bvid: bvid,
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
