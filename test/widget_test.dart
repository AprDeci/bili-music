import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/player_cover_settings_logic.dart';
import 'package:bilimusic/feature/player/logic/sleep_timer_controller.dart';
import 'package:bilimusic/feature/player/ui/player_page.dart';
import 'package:bilimusic/feature/player/ui/sleep_timer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('player page shows swipe indicator and meta page', (
    WidgetTester tester,
  ) async {
    const PlayableItem item = PlayableItem(
      aid: 1,
      bvid: 'BV1xx411c7mD',
      title: '测试播放内容',
      author: '测试UP主',
      coverUrl: '',
      durationText: '03:21',
      playCountText: '12.3万',
      danmakuCountText: '456',
      likeCountText: '8,888',
      coinCountText: '666',
      favoriteCountText: '1.2万',
      shareCountText: '234',
      replyCountText: '321',
      publishTimeText: '2026-03-27',
      description: '这是一段测试简介。',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesControllerProvider.overrideWith(
            _FakeFavoritesController.new,
          ),
          playerControllerProvider.overrideWith(
            () => _FakePlayerController(item),
          ),
          metadataControllerProvider.overrideWith(
            () => _FakeMetadataController(item),
          ),
          playerCoverSettingsLogicProvider.overrideWithValue(true),
        ],
        child: MaterialApp(home: PlayerPage(initialItem: item)),
      ),
    );
    await tester.pump();

    expect(find.text('测试播放内容'), findsOneWidget);

    await tester.fling(find.byType(PageView), const Offset(400, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text('播放信息'), findsOneWidget);
    expect(find.text('播放'), findsOneWidget);
  });

  testWidgets('player menu opens sleep timer page', (
    WidgetTester tester,
  ) async {
    const PlayableItem item = PlayableItem(
      aid: 1,
      bvid: 'BV1xx411c7mD',
      title: '测试播放内容',
      author: '测试UP主',
      coverUrl: '',
      durationText: '03:21',
      playCountText: '12.3万',
      danmakuCountText: '456',
      likeCountText: '8,888',
      coinCountText: '666',
      favoriteCountText: '1.2万',
      shareCountText: '234',
      replyCountText: '321',
      publishTimeText: '2026-03-27',
      description: '这是一段测试简介。',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesControllerProvider.overrideWith(
            _FakeFavoritesController.new,
          ),
          playerControllerProvider.overrideWith(
            () => _FakePlayerController(item),
          ),
          metadataControllerProvider.overrideWith(
            () => _FakeMetadataController(item),
          ),
          playerCoverSettingsLogicProvider.overrideWithValue(true),
        ],
        child: MaterialApp(home: PlayerPage(initialItem: item)),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('playerMenuButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sleepTimerMenuEntry')), findsOneWidget);

    await tester.tap(find.byKey(const Key('sleepTimerMenuEntry')));
    await tester.pumpAndSettle();

    expect(find.byType(SleepTimerPage), findsOneWidget);
    expect(find.text('倒计时'), findsOneWidget);
    expect(find.text('未开启'), findsOneWidget);
  });

  testWidgets('sleep timer page starts fixed timer from option tap', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(_BareFakePlayerController.new),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SleepTimerPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('30分钟'));
    await tester.pump();

    final SleepTimerState state = container.read(sleepTimerControllerProvider);
    expect(state.isActive, isTrue);
    expect(state.expiresAt, isNotNull);

    container.read(sleepTimerControllerProvider.notifier).cancel();
    await tester.pump();
  });
}

class _FakeFavoritesController extends FavoritesController {
  @override
  FavoritesState build() {
    return const FavoritesState();
  }
}

class _FakePlayerController extends PlayerController {
  _FakePlayerController(this.item);

  final PlayableItem item;

  @override
  PlayerState build() {
    return PlayerState(
      currentItem: item,
      queue: <PlayableItem>[item],
      currentQueueIndex: 0,
      isReady: true,
      duration: const Duration(minutes: 3, seconds: 21),
    );
  }

  @override
  Future<void> setQueue(
    List<PlayableItem> items, {
    int startIndex = 0,
    String? sourceLabel,
    bool autoplay = true,
  }) async {}

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> togglePlayback() async {}

  @override
  Future<void> toggleQueueMode() async {}

  @override
  Future<void> skipToPrevious() async {}

  @override
  Future<void> skipToNext() async {}
}

class _FakeMetadataController extends MetadataController {
  _FakeMetadataController(this.item);

  final PlayableItem item;

  @override
  MetadataState build() {
    return MetadataState(stableId: item.stableId, hasSearched: true);
  }
}

class _BareFakePlayerController extends PlayerController {
  @override
  PlayerState build() {
    return const PlayerState();
  }

  @override
  Future<void> pause() async {}
}
