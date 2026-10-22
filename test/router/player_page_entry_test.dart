import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/domain/player_ui_style.dart';
import 'package:bilimusic/feature/player/logic/desktop_lyrics_controller.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/player_cover_color_provider.dart';
import 'package:bilimusic/feature/player/logic/player_cover_logic.dart';
import 'package:bilimusic/feature/player/logic/player_cover_settings_logic.dart';
import 'package:bilimusic/feature/player/logic/player_progress_provider.dart';
import 'package:bilimusic/feature/player/logic/player_ui_style_logic.dart';
import 'package:bilimusic/feature/player/ui/apple_music/apple_music_player_page.dart';
import 'package:bilimusic/feature/player/ui/desktop_player_page.dart';
import 'package:bilimusic/feature/player/ui/player_page.dart';
import 'package:bilimusic/router/routers.dart';
import 'package:bilimusic/router/util/player_navigation.dart';
import 'package:bilimusic/router/util/player_page_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const PlayableItem _item = PlayableItem(
  aid: 42,
  bvid: 'BV1appleMusic',
  title: '晴天',
  author: '周杰伦',
  coverUrl: '',
  durationText: '04:29',
);

dynamic _commonOverrides(_FakePlayerController fake) {
  return [
    playerControllerProvider.overrideWith(() => fake),
    favoritesControllerProvider.overrideWith(_FakeFavoritesController.new),
    metadataControllerProvider.overrideWith(_FakeMetadataController.new),
    playerCoverSettingsLogicProvider.overrideWithValue(true),
    playerCoverLogicProvider.overrideWithValue(null),
    playerCoverColorControllerProvider.overrideWithValue(
      const Color(0xFF3E6DB5),
    ),
    playerProgressProvider.overrideWithValue(
      AsyncValue<PlayerProgressSnapshot>.data((
        position: const Duration(seconds: 30),
        duration: const Duration(minutes: 4, seconds: 29),
        isReady: true,
      )),
    ),
    // 桌面页会读取桌面歌词开关 provider；显式覆盖为 false 以免依赖 Hive。
    desktopLyricsControllerProvider.overrideWithValue(false),
  ];
}

Widget _wrap(PlayerUiStyle style, Widget child, {_FakePlayerController? fake}) {
  final _FakePlayerController controller =
      fake ?? _FakePlayerController(_item, isReady: true);
  return ProviderScope(
    overrides: [
      ..._commonOverrides(controller),
      playerUiStyleLogicProvider.overrideWith(() => _FakeStyleLogic(style)),
    ],
    child: child,
  );
}

Widget _desktopApp() {
  final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/player',
    initialExtra: _item,
    routes: <RouteBase>[
      desktopRoutes.whereType<GoRoute>().singleWhere(
        (GoRoute route) => route.path == '/player',
      ),
    ],
  );
  addTearDown(router.dispose);
  return MaterialApp.router(routerConfig: router);
}

void main() {
  testWidgets('classic mobile style renders PlayerPage', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        PlayerUiStyle.classic,
        const MaterialApp(home: PlayerPageEntry(initialItem: _item)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PlayerPage), findsOneWidget);
    expect(find.byType(AppleMusicPlayerPage), findsNothing);
  });

  testWidgets('appleMusic mobile style renders AppleMusicPlayerPage', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        PlayerUiStyle.appleMusic,
        const MaterialApp(home: PlayerPageEntry(initialItem: _item)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppleMusicPlayerPage), findsOneWidget);
    expect(find.byType(PlayerPage), findsNothing);
  });

  testWidgets('classic desktop style renders DesktopPlayerPage', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrap(PlayerUiStyle.classic, _desktopApp()));
    await tester.pumpAndSettle();

    expect(find.byType(DesktopPlayerPage), findsOneWidget);
    expect(find.byType(AppleMusicPlayerPage), findsNothing);
  });

  testWidgets(
    'desktop route stays classic with a saved Apple Music preference',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(PlayerUiStyle.appleMusic, _desktopApp()));
      await tester.pumpAndSettle();

      expect(find.byType(DesktopPlayerPage), findsOneWidget);
      expect(find.byType(AppleMusicPlayerPage), findsNothing);
    },
  );

  testWidgets('style switch keeps the same entry and does not replay', (
    WidgetTester tester,
  ) async {
    final _FakePlayerController fake = _FakePlayerController(
      _item,
      isReady: true,
    );
    final ProviderContainer container = ProviderContainer(
      overrides: [
        ..._commonOverrides(fake),
        playerUiStyleLogicProvider.overrideWith(
          () => _FakeStyleLogic(PlayerUiStyle.classic),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: PlayerPageEntry(initialItem: _item)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PlayerPage), findsOneWidget);
    expect(find.byType(AppleMusicPlayerPage), findsNothing);

    // 模拟用户在设置中切换风格，同一入口应即时重建为新风格且不重播。
    container
        .read(playerUiStyleLogicProvider.notifier)
        .setStyle(PlayerUiStyle.appleMusic);
    await tester.pumpAndSettle();

    expect(find.byType(AppleMusicPlayerPage), findsOneWidget);
    expect(find.byType(PlayerPage), findsNothing);
    // 切换风格复用同一播放器状态，不重播、不清队列。
    expect(fake.setQueueCallCount, 0);
  });

  testWidgets(
    'mobile style changes do not replace or replay the desktop page',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final _FakePlayerController fake = _FakePlayerController(
        _item,
        isReady: true,
      );
      final ProviderContainer container = ProviderContainer(
        overrides: [
          ..._commonOverrides(fake),
          playerUiStyleLogicProvider.overrideWith(
            () => _FakeStyleLogic(PlayerUiStyle.classic),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: _desktopApp()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DesktopPlayerPage), findsOneWidget);

      final State desktopState = tester.state(find.byType(DesktopPlayerPage));
      expect(playerPageVisibilityListenable.value, isTrue);

      // 手机风格变化不影响当前桌面播放器。
      container
          .read(playerUiStyleLogicProvider.notifier)
          .setStyle(PlayerUiStyle.appleMusic);
      await tester.pumpAndSettle();
      expect(find.byType(AppleMusicPlayerPage), findsNothing);
      expect(find.byType(DesktopPlayerPage), findsOneWidget);
      expect(tester.state(find.byType(DesktopPlayerPage)), same(desktopState));
      expect(playerPageVisibilityListenable.value, isTrue);

      // 切回手机经典风格，桌面页仍保持同一个状态。
      container
          .read(playerUiStyleLogicProvider.notifier)
          .setStyle(PlayerUiStyle.classic);
      await tester.pumpAndSettle();
      expect(find.byType(DesktopPlayerPage), findsOneWidget);
      expect(find.byType(AppleMusicPlayerPage), findsNothing);
      expect(tester.state(find.byType(DesktopPlayerPage)), same(desktopState));
      expect(playerPageVisibilityListenable.value, isTrue);

      // 全程共享同一播放器状态，不重播、不清队列。
      expect(fake.setQueueCallCount, 0);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(playerPageVisibilityListenable.value, isFalse);
    },
  );
}

class _FakeStyleLogic extends PlayerUiStyleLogic {
  _FakeStyleLogic(this.initial);

  final PlayerUiStyle initial;

  @override
  PlayerUiStyle build() => initial;

  @override
  Future<void> setStyle(PlayerUiStyle value) async {
    state = value;
  }
}

class _FakePlayerController extends PlayerController {
  _FakePlayerController(this.item, {this.isReady = false});

  final PlayableItem? item;
  final bool isReady;

  int setQueueCallCount = 0;

  @override
  PlayerState build() {
    return PlayerState(
      currentItem: item,
      queue: item == null ? const <PlayableItem>[] : <PlayableItem>[item!],
      currentQueueIndex: item == null ? null : 0,
      isReady: isReady,
      duration: const Duration(minutes: 4, seconds: 29),
    );
  }

  @override
  Future<void> setQueue(
    List<PlayableItem> items, {
    int startIndex = 0,
    String? sourceLabel,
    bool autoplay = true,
  }) async {
    setQueueCallCount += 1;
  }

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> seekFromProgressBar(Duration position) async {}

  @override
  Future<void> togglePlayback() async {}

  @override
  Future<void> skipToPrevious() async {}

  @override
  Future<void> skipToNext() async {}
}

class _FakeFavoritesController extends FavoritesController {
  @override
  FavoritesState build() {
    return const FavoritesState();
  }
}

class _FakeMetadataController extends MetadataController {
  @override
  MetadataState build() {
    return MetadataState(stableId: _item.stableId, hasSearched: true);
  }
}
