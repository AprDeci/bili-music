import 'dart:io';

import 'package:bilimusic/feature/player/domain/player_event.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/statistics/data/statistics_local_repository.dart';
import 'package:bilimusic/feature/statistics/domain/song_statistics.dart';
import 'package:bilimusic/feature/statistics/logic/statistics_tracker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Box<Map> box;
  late StatisticsLocalRepository repository;
  late StatisticsTracker tracker;
  final PlayableItem item = PlayableItem(
    aid: 1,
    bvid: 'BV1',
    title: 'song',
    author: 'author',
    coverUrl: '',
  );

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    Hive.init(Directory.systemTemp.path);
  });

  setUp(() async {
    box = await Hive.openBox<Map>('statistics_test');
    await box.clear();
    repository = StatisticsLocalRepository(box);
    tracker = StatisticsTracker(const Stream.empty(), repository);
  });

  tearDown(() async {
    await tracker.dispose();
    await box.close();
  });

  PlayerEvent event(
    PlayerEventType type, {
    Duration position = Duration.zero,
    Duration? duration,
    bool isPlaying = false,
  }) => PlayerEvent(
    type: type,
    item: item,
    position: position,
    duration: duration,
    isPlaying: isPlaying,
  );

  test('counts playback at ten percent', () async {
    await tracker.onEvent(
      event(
        PlayerEventType.trackChanged,
        duration: const Duration(seconds: 100),
      ),
    );
    await tracker.onEvent(
      event(PlayerEventType.playbackState, isPlaying: true),
    );
    for (final int seconds in <int>[3, 6, 9]) {
      await tracker.onEvent(
        event(
          PlayerEventType.position,
          position: Duration(seconds: seconds),
          isPlaying: true,
        ),
      );
    }
    await tracker.onEvent(
      event(
        PlayerEventType.position,
        position: const Duration(seconds: 10),
        isPlaying: true,
      ),
    );
    await tracker.onEvent(event(PlayerEventType.playbackState));

    expect(repository.read(item.stableId)!.playCount, 1);
  });

  test('pausing commits accumulated playback, while seek is ignored', () async {
    await tracker.onEvent(
      event(
        PlayerEventType.trackChanged,
        duration: const Duration(seconds: 100),
      ),
    );
    await tracker.onEvent(
      event(PlayerEventType.playbackState, isPlaying: true),
    );
    await tracker.onEvent(
      event(
        PlayerEventType.position,
        position: const Duration(seconds: 2),
        isPlaying: true,
      ),
    );
    await tracker.onEvent(
      event(
        PlayerEventType.position,
        position: const Duration(seconds: 2),
        isPlaying: true,
      ),
    );
    await tracker.onEvent(
      event(
        PlayerEventType.seek,
        position: const Duration(seconds: 80),
        isPlaying: true,
      ),
    );
    await tracker.onEvent(
      event(
        PlayerEventType.position,
        position: const Duration(seconds: 81),
        isPlaying: true,
      ),
    );
    await tracker.onEvent(event(PlayerEventType.playbackState));

    expect(repository.read(item.stableId)!.totalPlayedMs, 3000);
  });

  test('below ten percent only accumulates time without timestamps', () async {
    await tracker.onEvent(
      event(
        PlayerEventType.trackChanged,
        duration: const Duration(seconds: 100),
      ),
    );
    await tracker.onEvent(
      event(PlayerEventType.playbackState, isPlaying: true),
    );
    await tracker.onEvent(
      event(
        PlayerEventType.position,
        position: const Duration(seconds: 2),
        isPlaying: true,
      ),
    );
    await tracker.onEvent(
      event(
        PlayerEventType.position,
        position: const Duration(seconds: 3),
        isPlaying: true,
      ),
    );
    await tracker.onEvent(event(PlayerEventType.playbackState));

    final SongStatistics statistics = repository.read(item.stableId)!;
    expect(statistics.totalPlayedMs, 3000);
    expect(statistics.playCount, 0);
    expect(statistics.firstPlayedAtEpochMs, isNull);
    expect(statistics.lastPlayedAtEpochMs, isNull);
  });

  test('a new playback attempt can be counted after pausing', () async {
    await tracker.onEvent(
      event(
        PlayerEventType.trackChanged,
        duration: const Duration(seconds: 10),
      ),
    );
    await tracker.onEvent(
      event(PlayerEventType.playbackState, isPlaying: true),
    );
    await tracker.onEvent(
      event(
        PlayerEventType.position,
        position: const Duration(seconds: 1),
        isPlaying: true,
      ),
    );
    await tracker.onEvent(event(PlayerEventType.playbackState));
    await tracker.onEvent(
      event(PlayerEventType.playbackState, isPlaying: true),
    );
    await tracker.onEvent(
      event(
        PlayerEventType.position,
        position: const Duration(seconds: 1),
        isPlaying: true,
      ),
    );
    await tracker.onEvent(event(PlayerEventType.playbackState));

    expect(repository.read(item.stableId)!.playCount, 2);
  });

  test('resume uses the paused position as its delta baseline', () async {
    await tracker.onEvent(
      event(
        PlayerEventType.trackChanged,
        duration: const Duration(seconds: 100),
      ),
    );
    await tracker.onEvent(
      event(PlayerEventType.playbackState, isPlaying: true),
    );
    await tracker.onEvent(
      event(
        PlayerEventType.position,
        position: const Duration(seconds: 2),
        isPlaying: true,
      ),
    );
    await tracker.onEvent(
      event(
        PlayerEventType.position,
        position: const Duration(seconds: 5),
        isPlaying: true,
      ),
    );
    await tracker.onEvent(
      event(
        PlayerEventType.playbackState,
        position: const Duration(seconds: 5),
      ),
    );
    await tracker.onEvent(
      event(
        PlayerEventType.playbackState,
        position: const Duration(seconds: 5),
        isPlaying: true,
      ),
    );
    await tracker.onEvent(
      event(
        PlayerEventType.position,
        position: const Duration(seconds: 8),
        isPlaying: true,
      ),
    );
    await tracker.onEvent(event(PlayerEventType.playbackState));

    expect(repository.read(item.stableId)!.totalPlayedMs, 8000);
  });

  test('first played time is retained', () async {
    await tracker.onEvent(
      event(
        PlayerEventType.trackChanged,
        duration: const Duration(seconds: 10),
      ),
    );
    await tracker.onEvent(
      event(PlayerEventType.playbackState, isPlaying: true),
    );
    await tracker.onEvent(
      event(
        PlayerEventType.position,
        position: const Duration(milliseconds: 800),
        isPlaying: true,
      ),
    );
    await tracker.onEvent(
      event(
        PlayerEventType.position,
        position: const Duration(seconds: 1),
        isPlaying: true,
      ),
    );
    await tracker.onEvent(event(PlayerEventType.playbackState));
    final int first = repository.read(item.stableId)!.firstPlayedAtEpochMs!;
    await tracker.onEvent(
      event(PlayerEventType.playbackState, isPlaying: true),
    );
    await tracker.onEvent(
      event(
        PlayerEventType.position,
        position: const Duration(seconds: 2),
        isPlaying: true,
      ),
    );
    await tracker.onEvent(event(PlayerEventType.playbackState));

    expect(repository.read(item.stableId)!.firstPlayedAtEpochMs, first);
  });

  test('resolved cid identity continues the original bvid playback', () async {
    final PlayableItem resolvedItem = item.copyWith(cid: 99);
    await tracker.onEvent(
      event(
        PlayerEventType.trackChanged,
        duration: const Duration(seconds: 10),
      ),
    );
    await tracker.onEvent(
      PlayerEvent(
        type: PlayerEventType.trackChanged,
        item: resolvedItem,
        position: Duration.zero,
        duration: const Duration(seconds: 10),
        isPlaying: true,
      ),
    );
    await tracker.onEvent(
      PlayerEvent(
        type: PlayerEventType.playbackState,
        item: resolvedItem,
        position: const Duration(seconds: 1),
        duration: const Duration(seconds: 10),
        isPlaying: true,
      ),
    );
    await tracker.onEvent(
      PlayerEvent(
        type: PlayerEventType.position,
        item: resolvedItem,
        position: const Duration(seconds: 2),
        duration: const Duration(seconds: 10),
        isPlaying: true,
      ),
    );
    await tracker.onEvent(
      PlayerEvent(
        type: PlayerEventType.playbackState,
        item: resolvedItem,
        position: const Duration(seconds: 2),
        duration: const Duration(seconds: 10),
        isPlaying: false,
      ),
    );

    final SongStatistics? statistics = repository.read(resolvedItem.stableId);
    expect(statistics?.playCount, 1);
    expect(statistics?.totalPlayedMs, 1000);
  });

  test('old identity events do not contaminate the resolved song', () async {
    final PlayableItem resolvedItem = item.copyWith(cid: 99);
    await tracker.onEvent(
      PlayerEvent(
        type: PlayerEventType.trackChanged,
        item: resolvedItem,
        position: Duration.zero,
        duration: const Duration(seconds: 10),
        isPlaying: true,
      ),
    );
    await tracker.onEvent(
      event(
        PlayerEventType.position,
        position: const Duration(seconds: 9),
        isPlaying: true,
      ),
    );
    await tracker.onEvent(
      PlayerEvent(
        type: PlayerEventType.position,
        item: resolvedItem,
        position: const Duration(seconds: 1),
        duration: const Duration(seconds: 10),
        isPlaying: true,
      ),
    );
    await tracker.onEvent(
      PlayerEvent(
        type: PlayerEventType.playbackState,
        item: resolvedItem,
        position: const Duration(seconds: 1),
        duration: const Duration(seconds: 10),
        isPlaying: false,
      ),
    );

    expect(repository.read(resolvedItem.stableId)?.totalPlayedMs, 1000);
    expect(repository.read(item.stableId), isNull);
  });
}
