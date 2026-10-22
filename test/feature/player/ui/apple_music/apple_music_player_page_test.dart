import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/common/domain/meta_lyrics.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/player_cover_color_provider.dart';
import 'package:bilimusic/feature/player/logic/player_cover_logic.dart';
import 'package:bilimusic/feature/player/logic/player_cover_settings_logic.dart';
import 'package:bilimusic/feature/player/logic/player_progress_provider.dart';
import 'package:bilimusic/feature/player/ui/apple_music/apple_music_player_page.dart';
import 'package:bilimusic/feature/player/ui/components/player_lyric_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const PlayableItem _item = PlayableItem(
  aid: 42,
  bvid: 'BV1appleMusic',
  title: '雨后晴天',
  author: '周杰伦',
  coverUrl: '',
  durationText: '04:29',
);

const PlayableItem _otherItem = PlayableItem(
  aid: 7,
  bvid: 'BV1otherA',
  title: '稻香',
  author: '周杰伦',
  coverUrl: '',
  durationText: '03:43',
);

const PlayableItem _otherItem2 = PlayableItem(
  aid: 8,
  bvid: 'BV1otherB',
  title: '夜曲',
  author: '周杰伦',
  coverUrl: '',
  durationText: '03:46',
);

Widget _wrap(_FakePlayerController fake, Widget child) {
  return ProviderScope(
    overrides: [
      playerControllerProvider.overrideWith(() => fake),
      favoritesControllerProvider.overrideWith(_FakeFavoritesController.new),
      metadataControllerProvider.overrideWith(_FakeMetadataController.new),
      playerCoverSettingsLogicProvider.overrideWithValue(true),
      playerCoverLogicProvider.overrideWithValue(null),
      playerCoverColorControllerProvider.overrideWithValue(
        const Color(0xFF7A6255),
      ),
      playerProgressProvider.overrideWithValue(
        AsyncValue<PlayerProgressSnapshot>.data((
          position: const Duration(seconds: 41),
          duration: const Duration(minutes: 4, seconds: 29),
          isReady: true,
        )),
      ),
    ],
    child: child,
  );
}

double _artworkWidth(WidgetTester tester) {
  final Finder artwork = find.bySemanticsLabel('专辑封面');
  return tester.getSize(artwork).width;
}

void main() {
  testWidgets('mobile shows artwork, title/author, transport and bottom bar', (
    WidgetTester tester,
  ) async {
    final _FakePlayerController fake = _FakePlayerController(
      _item,
      isReady: true,
    );

    await tester.pumpWidget(
      _wrap(
        fake,
        const MaterialApp(home: AppleMusicPlayerPage(initialItem: _item)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('雨后晴天'), findsOneWidget);
    expect(find.text('周杰伦'), findsOneWidget);
    expect(find.bySemanticsLabel('专辑封面'), findsOneWidget);
    expect(find.byKey(const Key('appleMusicFavoriteButton')), findsOneWidget);
    expect(find.byKey(const Key('appleMusicMoreButton')), findsOneWidget);
    expect(find.byIcon(Icons.fast_rewind_rounded), findsOneWidget);
    expect(find.byIcon(Icons.fast_forward_rounded), findsOneWidget);
    expect(find.byKey(const Key('appleMusicPlayPause')), findsOneWidget);
    expect(find.byKey(const Key('appleMusicLyricsToggle')), findsOneWidget);
  });

  testWidgets('artwork keeps ~5.5% margins (about 89% of screen width)', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 853);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final _FakePlayerController fake = _FakePlayerController(
      _item,
      isReady: true,
    );

    await tester.pumpWidget(
      _wrap(
        fake,
        const MaterialApp(home: AppleMusicPlayerPage(initialItem: _item)),
      ),
    );
    await tester.pumpAndSettle();

    final double width = _artworkWidth(tester);
    expect(width, closeTo(393 * 0.89, 2.0));
  });

  testWidgets('mobile switches between artwork and lyrics', (
    WidgetTester tester,
  ) async {
    final _FakePlayerController fake = _FakePlayerController(
      _item,
      isReady: true,
    );

    await tester.pumpWidget(
      _wrap(
        fake,
        const MaterialApp(home: AppleMusicPlayerPage(initialItem: _item)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('专辑封面'), findsOneWidget);

    // 滚动到底栏后再点击。
    await tester.ensureVisible(find.byKey(const Key('appleMusicLyricsToggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('appleMusicLyricsToggle')));
    await tester.pumpAndSettle();

    expect(find.byType(PlayerLyricPanel), findsOneWidget);
    expect(find.bySemanticsLabel('专辑封面'), findsNothing);
  });

  testWidgets('mobile exposes a real volume slider and mute control', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 853);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final _FakePlayerController fake = _FakePlayerController(
      _item,
      isReady: true,
    );

    await tester.pumpWidget(
      _wrap(
        fake,
        const MaterialApp(home: AppleMusicPlayerPage(initialItem: _item)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Slider), findsWidgets);
    expect(find.byTooltip('静音'), findsOneWidget);
    final Finder volume = find.byType(Slider).last;
    await tester.ensureVisible(volume);
    await tester.pumpAndSettle();
    await tester.drag(volume, const Offset(40, 0));
    await tester.pumpAndSettle();
    expect(fake.lastSeekVolume, greaterThan(0.6));
  });

  testWidgets('mobile surfaces playback errors', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(393, 853);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final _FakePlayerController fake = _FakePlayerController(
      _item,
      isReady: true,
      errorMessage: '播放失败：网络错误',
    );

    await tester.pumpWidget(
      _wrap(
        fake,
        const MaterialApp(home: AppleMusicPlayerPage(initialItem: _item)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('播放失败：网络错误'), findsWidgets);
  });

  testWidgets('shows empty state when there is no current item', (
    WidgetTester tester,
  ) async {
    final _FakePlayerController fake = _FakePlayerController(null);

    await tester.pumpWidget(
      _wrap(fake, const MaterialApp(home: AppleMusicPlayerPage())),
    );
    await tester.pumpAndSettle();

    expect(find.text('还没有选择播放内容'), findsOneWidget);
    expect(find.bySemanticsLabel('专辑封面'), findsNothing);
  });

  testWidgets('opening more menu exposes real secondary actions', (
    WidgetTester tester,
  ) async {
    final _FakePlayerController fake = _FakePlayerController(
      _item,
      isReady: true,
    );

    await tester.pumpWidget(
      _wrap(
        fake,
        const MaterialApp(home: AppleMusicPlayerPage(initialItem: _item)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('appleMusicMoreButton')));
    await tester.pumpAndSettle();

    expect(find.text('定时关闭'), findsOneWidget);
    expect(find.text('倍速播放'), findsOneWidget);
    expect(find.text('收藏到歌单'), findsOneWidget);
    expect(find.text('手动匹配歌词'), findsOneWidget);
    expect(find.text('外部应用打开'), findsOneWidget);
    expect(find.text('1.0x'), findsOneWidget);
  });

  testWidgets('renders without overflow on a small screen with large text', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final _FakePlayerController fake = _FakePlayerController(
      _item,
      isReady: true,
    );

    await tester.pumpWidget(
      _wrap(
        fake,
        const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(1.6)),
          child: MaterialApp(home: AppleMusicPlayerPage(initialItem: _item)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('雨后晴天'), findsOneWidget);
  });

  testWidgets('does not reload queue when item is already playing', (
    WidgetTester tester,
  ) async {
    final _FakePlayerController fake = _FakePlayerController(
      _item,
      isReady: true,
    );

    await tester.pumpWidget(
      _wrap(
        fake,
        const MaterialApp(home: AppleMusicPlayerPage(initialItem: _item)),
      ),
    );
    await tester.pumpAndSettle();

    expect(fake.setQueueCallCount, 0);
  });

  testWidgets(
    'does not clear a multi-item queue when same item is still loading',
    (WidgetTester tester) async {
      final _FakePlayerController fake = _FakePlayerController(
        _item,
        isReady: false,
        isLoading: true,
        queue: <PlayableItem>[_item, _otherItem, _otherItem2],
      );

      await tester.pumpWidget(
        _wrap(
          fake,
          const MaterialApp(home: AppleMusicPlayerPage(initialItem: _item)),
        ),
      );
      // 无限加载动画不能用 pumpAndSettle。
      await tester.pump();
      await tester.pump();

      expect(fake.setQueueCallCount, 0);
    },
  );

  testWidgets('loads initial item only when nothing matching is ready', (
    WidgetTester tester,
  ) async {
    final _FakePlayerController fake = _FakePlayerController(
      null,
      isReady: false,
    );

    await tester.pumpWidget(
      _wrap(
        fake,
        const MaterialApp(home: AppleMusicPlayerPage(initialItem: _item)),
      ),
    );
    await tester.pumpAndSettle();

    expect(fake.setQueueCallCount, 1);
    expect(fake.lastQueued?.stableId, _item.stableId);
  });

  testWidgets(
    'menu 译文 toggles real showTranslation state instead of only opening lyrics',
    (WidgetTester tester) async {
      final _FakePlayerController fake = _FakePlayerController(
        _item,
        isReady: true,
      );

      await tester.pumpWidget(
        _wrap(
          fake,
          const MaterialApp(home: AppleMusicPlayerPage(initialItem: _item)),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('appleMusicMoreButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('appleMusicMoreButton')));
      await tester.pumpAndSettle();
      final Finder translateTile = find.byKey(
        const Key('appleMusicTranslationToggle'),
      );
      expect(translateTile, findsOneWidget);

      await tester.ensureVisible(translateTile);
      await tester.pumpAndSettle();
      await tester.tap(translateTile);
      await tester.pumpAndSettle();
      expect(find.byType(PlayerLyricPanel), findsOneWidget);
      expect(
        tester
            .widget<PlayerLyricPanel>(find.byType(PlayerLyricPanel))
            .showTranslation,
        isFalse,
      );

      await tester.ensureVisible(find.byKey(const Key('appleMusicMoreButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('appleMusicMoreButton')));
      await tester.pumpAndSettle();
      final Finder translateTile2 = find.byKey(
        const Key('appleMusicTranslationToggle'),
      );
      await tester.ensureVisible(translateTile2);
      await tester.pumpAndSettle();
      await tester.tap(translateTile2);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<PlayerLyricPanel>(find.byType(PlayerLyricPanel))
            .showTranslation,
        isTrue,
      );
    },
  );

  testWidgets(
    'cover sits near the top and title/progress match the reference rhythm',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(393, 853);
      tester.view.devicePixelRatio = 1.0;
      tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);

      final _FakePlayerController fake = _FakePlayerController(
        _item,
        isReady: true,
      );
      await tester.pumpWidget(
        _wrap(
          fake,
          const MaterialApp(home: AppleMusicPlayerPage(initialItem: _item)),
        ),
      );
      await tester.pumpAndSettle();

      final Rect artwork = tester.getRect(find.bySemanticsLabel('专辑封面'));
      final double titleTop = tester.getRect(find.text('雨后晴天')).top;

      expect(artwork.width, closeTo(393 * 0.89, 4.0));
      expect(artwork.top, lessThan(130));
      expect(titleTop, greaterThan(460));
      expect(titleTop, lessThan(545));
      expect(titleTop - artwork.bottom, greaterThan(28));
      expect(titleTop - artwork.bottom, lessThan(64));
    },
  );
}

class _FakePlayerController extends PlayerController {
  _FakePlayerController(
    this.item, {
    this.isReady = false,
    this.isLoading = false,
    this.errorMessage,
    List<PlayableItem>? queue,
  }) : queue =
           queue ??
           (item == null ? const <PlayableItem>[] : <PlayableItem>[item]);

  final PlayableItem? item;
  final bool isReady;
  final bool isLoading;
  final String? errorMessage;
  final List<PlayableItem> queue;

  int setQueueCallCount = 0;
  PlayableItem? lastQueued;
  double lastSeekVolume = -1;

  @override
  PlayerState build() {
    return PlayerState(
      currentItem: item,
      queue: queue,
      currentQueueIndex: item == null ? null : 0,
      isReady: isReady,
      isLoading: isLoading,
      isPlaying: isReady,
      volume: 0.6,
      duration: const Duration(minutes: 4, seconds: 29),
      statusHint: errorMessage == null ? null : PlayerStatusHint.error,
      errorMessage: errorMessage,
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
    lastQueued = items.isEmpty ? null : items[startIndex];
  }

  @override
  Future<void> setVolume(double volume) async {
    lastSeekVolume = volume;
  }

  @override
  Future<double> toggleMute() async => 0;

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
    return MetadataState(
      stableId: _item.stableId,
      hasSearched: true,
      metadata: const Metadata(
        stableId: 'BV1appleMusic',
        metaLyrics: MetaLyrics(
          lyric: '[00:00.00]I feel the lavender haze',
          translatedLyric: '[00:00.00]薰衣草薄雾',
        ),
      ),
    );
  }
}
