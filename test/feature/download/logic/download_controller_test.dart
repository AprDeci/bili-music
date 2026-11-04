import 'dart:io';

import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/download/data/download_repository.dart';
import 'package:bilimusic/feature/download/logic/download_controller.dart';
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

Future<ProviderContainer> _container() async {
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
          required Map<String, String> headers,
          void Function(int, int)? onProgress,
        }) async => <int>[1, 2, 3],
  );
  final ProviderContainer container = ProviderContainer(
    overrides: [
      downloadRepositoryProvider.overrideWithValue(repository),
      biliPlayerRepositoryProvider.overrideWithValue(_FakePlayerRepository()),
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
  @override
  Future<PlayerLoadResult> resolveAudioStream(
    PlayableItem item, {
    required BiliSession? session,
    required PlayerAudioQualityPreference qualityPreference,
    int? preferredQualityId,
  }) async {
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
