import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_lyric_settings.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/lyrics/desktop_lyrics_controller.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/display/player_cover_color_provider.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_settings_logic.dart';
import 'package:bilimusic/feature/player/logic/lyrics/player_lyric_settings_logic.dart';
import 'package:bilimusic/feature/player/logic/sleep_timer_controller.dart';
import 'package:bilimusic/feature/player/ui/lyrics/player_lyric_panel.dart';
import 'package:bilimusic/feature/player/ui/desktop/desktop_player_page.dart';
import 'package:bilimusic/feature/player/ui/player_page.dart';
import 'package:bilimusic/feature/player/ui/sleep_timer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';

const PlayableItem _testItem = PlayableItem(
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

void main() {
  testWidgets(
    'desktop lyric appearance button follows offset and opens settings',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const MethodChannel channel = MethodChannel('window_manager');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (_) async => false);
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            favoritesControllerProvider.overrideWith(
              _FakeFavoritesController.new,
            ),
            playerControllerProvider.overrideWith(
              () => _FakePlayerController(_testItem),
            ),
            metadataControllerProvider.overrideWith(
              () => _FakeMetadataController(_testItem),
            ),
            playerCoverColorControllerProvider.overrideWith(
              _FakeCoverColorController.new,
            ),
            playerLyricSettingsLogicProvider.overrideWith(
              _FakeLyricSettingsLogic.new,
            ),
            playerDisplaySettingsLogicProvider.overrideWithValue(true),
            desktopLyricsControllerProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: DesktopPlayerPage(initialItem: _testItem),
          ),
        ),
      );
      await tester.pump();
      final Finder appearance = find.byTooltip('歌词外观');
      expect(
        tester.getCenter(appearance).dy,
        greaterThan(tester.getCenter(find.byTooltip('歌词偏移')).dy),
      );
      expect(
        tester
            .widget<HugeIcon>(
              find.descendant(of: appearance, matching: find.byType(HugeIcon)),
            )
            .icon,
        HugeIcons.strokeRoundedPreferenceHorizontal,
      );
      await tester.tap(appearance);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('恢复默认'), findsOneWidget);
      await tester.tap(find.byTooltip('关闭歌词外观'));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('lyric page receives live cover colors and accepts no palette', (
    WidgetTester tester,
  ) async {
    _usePortraitViewport(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesControllerProvider.overrideWith(
            _FakeFavoritesController.new,
          ),
          playerControllerProvider.overrideWith(
            () => _FakePlayerController(_testItem),
          ),
          metadataControllerProvider.overrideWith(
            () => _FakeMetadataController(_testItem),
          ),
          playerCoverColorControllerProvider.overrideWith(
            _FakeCoverColorController.new,
          ),
          playerLyricSettingsLogicProvider.overrideWith(
            _FakeLyricSettingsLogic.new,
          ),
          playerDisplaySettingsLogicProvider.overrideWithValue(true),
        ],
        child: const MaterialApp(home: PlayerPage(initialItem: _testItem)),
      ),
    );
    await tester.pump();
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<PlayerLyricPanel>(find.byType(PlayerLyricPanel))
          .activeColor,
      isNull,
    );
    expect(
      tester.getCenter(find.byTooltip('歌词外观')).dx,
      greaterThan(tester.getCenter(find.byTooltip('歌词偏移')).dx),
    );
    await tester.tap(find.byTooltip('歌词外观'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('恢复默认'), findsOneWidget);
    await tester.tap(find.byTooltip('关闭歌词外观'));
    await tester.pumpAndSettle();
    final ProviderContainer container = ProviderScope.containerOf(
      tester.element(find.byType(PlayerPage)),
    );
    final _FakeCoverColorController colors =
        container.read(playerCoverColorControllerProvider.notifier)
            as _FakeCoverColorController;
    for (final Color color in <Color>[Colors.cyan, Colors.red]) {
      colors.setColor(color);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<PlayerLyricPanel>(find.byType(PlayerLyricPanel))
            .activeColor,
        color,
      );
    }
  });

  testWidgets('player page shows swipe indicator and meta page', (
    WidgetTester tester,
  ) async {
    _usePortraitViewport(tester);
    const PlayableItem item = _testItem;

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
          playerLyricSettingsLogicProvider.overrideWith(
            _FakeLyricSettingsLogic.new,
          ),
          playerDisplaySettingsLogicProvider.overrideWithValue(true),
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
    _usePortraitViewport(tester);
    const PlayableItem item = _testItem;

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
          playerLyricSettingsLogicProvider.overrideWith(
            _FakeLyricSettingsLogic.new,
          ),
          playerDisplaySettingsLogicProvider.overrideWithValue(true),
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

  testWidgets('player menu applies playback speed', (
    WidgetTester tester,
  ) async {
    _usePortraitViewport(tester);
    const PlayableItem item = _testItem;

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
          playerLyricSettingsLogicProvider.overrideWith(
            _FakeLyricSettingsLogic.new,
          ),
          playerDisplaySettingsLogicProvider.overrideWithValue(true),
        ],
        child: const MaterialApp(home: PlayerPage(initialItem: _testItem)),
      ),
    );
    await tester.pump();

    final ProviderContainer container = ProviderScope.containerOf(
      tester.element(find.byType(PlayerPage)),
      listen: false,
    );
    expect(container.read(playerControllerProvider).speed, 1.0);

    await tester.tap(find.byKey(const Key('playerMenuButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('playbackSpeedMenuEntry')), findsOneWidget);

    await tester.tap(find.byKey(const Key('playbackSpeedMenuEntry')));
    await tester.pumpAndSettle();

    expect(find.text('1.5x'), findsOneWidget);

    await tester.tap(find.text('1.5x'));
    await tester.pumpAndSettle();

    expect(container.read(playerControllerProvider).speed, 1.5);
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

void _usePortraitViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(420, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class _FakeLyricSettingsLogic extends PlayerLyricSettingsLogic {
  @override
  PlayerLyricSettings build() => const PlayerLyricSettings();

  @override
  Future<void> update(PlayerLyricSettings value) async => state = value;
}

class _FakeCoverColorController extends PlayerCoverColorController {
  @override
  Color? build() => null;

  void setColor(Color color) => state = color;
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
  Future<void> setSpeed(double speed) async {
    state = state.copyWith(speed: speed);
  }

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
