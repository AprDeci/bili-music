import 'dart:io';

import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/player/domain/player_event.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/logic/player_event_hub.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_progress_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

const PlayableItem _item = PlayableItem(
  aid: 1,
  bvid: 'BV1',
  title: '测试曲目',
  author: 'UP',
  coverUrl: '',
);

const String _stableId = 'bvid:BV1';

void main() {
  late Directory tempDirectory;
  late Box<String> prefsBox;
  late PlayerEventHub hub;
  late ProviderContainer container;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('recent-progress-');
    Hive.init(tempDirectory.path);
    prefsBox = await Hive.openBox<String>('prefs');
    hub = PlayerEventHub();
    container = ProviderContainer(
      overrides: [
        appSettingsStoreProvider.overrideWithValue(AppSettingsStore(prefsBox)),
        playerEventHubProvider.overrideWithValue(hub),
      ],
    );
    container.listen(
      recentPlaybackProgressControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
  });

  tearDown(() async {
    container.dispose();
    await hub.dispose();
    await prefsBox.close();
    await Hive.deleteBoxFromDisk('prefs');
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('低于最短时长阈值不记录进度', () async {
    hub.add(_event(PlayerEventType.trackChanged));
    hub.add(
      _event(PlayerEventType.position, position: const Duration(seconds: 2)),
    );
    await Future<void>.delayed(Duration.zero);

    final RecentPlaybackProgressController controller = container.read(
      recentPlaybackProgressControllerProvider.notifier,
    );
    expect(controller.positionFor(_stableId), isNull);
    expect(prefsBox.get('recent.playback_progress'), anyOf(isNull, '{}'));
  });

  test('超过阈值后保存进度并可重新读取', () async {
    hub.add(_event(PlayerEventType.trackChanged));
    hub.add(
      _event(PlayerEventType.position, position: const Duration(seconds: 42)),
    );
    await Future<void>.delayed(Duration.zero);

    final RecentPlaybackProgressController controller = container.read(
      recentPlaybackProgressControllerProvider.notifier,
    );
    expect(controller.positionFor(_stableId), 42000);
    expect(prefsBox.get('recent.playback_progress'), contains('42000'));

    container.dispose();
    final ProviderContainer restored = ProviderContainer(
      overrides: [
        appSettingsStoreProvider.overrideWithValue(AppSettingsStore(prefsBox)),
        playerEventHubProvider.overrideWithValue(hub),
      ],
    );
    addTearDown(() {});
    restored.listen(
      recentPlaybackProgressControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    expect(
      restored
          .read(recentPlaybackProgressControllerProvider.notifier)
          .positionFor(_stableId),
      42000,
    );
    container = restored;
  });

  test('暂停时强制落盘当前进度', () async {
    hub.add(_event(PlayerEventType.trackChanged));
    hub.add(
      _event(PlayerEventType.position, position: const Duration(seconds: 10)),
    );
    await Future<void>.delayed(Duration.zero);
    hub.add(
      _event(PlayerEventType.position, position: const Duration(seconds: 12)),
    );
    hub.add(
      _event(
        PlayerEventType.playbackState,
        position: const Duration(seconds: 12),
        isPlaying: false,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(
      container
          .read(recentPlaybackProgressControllerProvider.notifier)
          .positionFor(_stableId),
      12000,
    );
  });

  test('播放完成后清除进度', () async {
    hub.add(_event(PlayerEventType.trackChanged));
    hub.add(
      _event(PlayerEventType.position, position: const Duration(seconds: 30)),
    );
    await Future<void>.delayed(Duration.zero);
    hub.add(
      _event(PlayerEventType.completed, position: const Duration(minutes: 3)),
    );
    await Future<void>.delayed(Duration.zero);

    expect(
      container
          .read(recentPlaybackProgressControllerProvider.notifier)
          .positionFor(_stableId),
      isNull,
    );
  });

  test('接近结尾的位置不记录为可续播进度', () async {
    hub.add(_event(PlayerEventType.trackChanged));
    hub.add(
      _event(
        PlayerEventType.position,
        position: const Duration(minutes: 2, seconds: 58),
        duration: const Duration(minutes: 3),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(
      container
          .read(recentPlaybackProgressControllerProvider.notifier)
          .positionFor(_stableId),
      isNull,
    );
  });
}

PlayerEvent _event(
  PlayerEventType type, {
  Duration position = Duration.zero,
  Duration? duration = const Duration(minutes: 3),
  bool isPlaying = true,
}) {
  return PlayerEvent(
    type: type,
    item: _item,
    position: position,
    duration: duration,
    isPlaying: isPlaying,
  );
}
