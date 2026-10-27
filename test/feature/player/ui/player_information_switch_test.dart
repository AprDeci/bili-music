import 'dart:async';

import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/domain/player_lyric_settings.dart';
import 'package:bilimusic/feature/player/domain/player_online_audience.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/lyrics/desktop_lyrics_controller.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/display/player_cover_color_provider.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_settings_logic.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_source_logic.dart';
import 'package:bilimusic/feature/player/logic/lyrics/player_lyric_settings_logic.dart';
import 'package:bilimusic/feature/player/logic/player_online_audience_controller.dart';
import 'package:bilimusic/feature/player/ui/mini/mini_player_content.dart';
import 'package:bilimusic/feature/player/ui/components/player_artwork.dart';
import 'package:bilimusic/feature/player/ui/components/player_main_page.dart';
import 'package:bilimusic/feature/player/ui/components/player_shared.dart';
import 'package:bilimusic/feature/player/ui/desktop/desktop_player_bar.dart';
import 'package:bilimusic/feature/player/ui/player_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const PlayableItem _item = PlayableItem(
  aid: 1,
  bvid: 'BV1xx411c7mD',
  title: 'Video title',
  author: 'Video UP',
  ownerMid: 123,
  coverUrl: '',
);

final Metadata _metadata = Metadata(
  stableId: _item.stableId,
  title: 'Song title',
  artist: 'Song artist',
);

void main() {
  testWidgets(
    'cover double tap switches page and mini information without artwork',
    (WidgetTester tester) async {
      final ProviderContainer container = await _pumpPlayer(tester, _metadata);

      _expectInformation(tester, 'Song title', 'Song artist', opensUp: false);
      expect(_metadata.albumArtUrl, isNull);
      expect(
        tester
            .widget<PlayerMainPage>(find.byType(PlayerMainPage))
            .display
            .canToggleSource,
        isTrue,
      );
      expect(
        tester
            .widget<PlayerArtworkFrame>(find.byType(PlayerArtworkFrame))
            .coverUrl,
        isEmpty,
      );

      await _doubleTapCover(tester);

      expect(
        container.read(playerDisplaySourceLogicProvider),
        PlayerDisplaySource.bilibili,
      );
      _expectInformation(tester, _item.title, _item.author, opensUp: true);

      await _doubleTapCover(tester);

      expect(
        container.read(playerDisplaySourceLogicProvider),
        PlayerDisplaySource.metadata,
      );
      _expectInformation(tester, 'Song title', 'Song artist', opensUp: false);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'late metadata updates both players and next item resets the switch',
    (WidgetTester tester) async {
      final ProviderContainer container = await _pumpPlayer(tester, null);
      final _FakeMetadataController metadataController =
          container.read(metadataControllerProvider.notifier)
              as _FakeMetadataController;
      final _FakePlayerController playerController =
          container.read(playerControllerProvider.notifier)
              as _FakePlayerController;
      final Completer<Metadata> result = Completer<Metadata>();
      final Future<void> pendingMetadata = metadataController.receive(
        result.future,
      );

      _expectInformation(tester, _item.title, _item.author, opensUp: true);
      expect(
        tester
            .widget<PlayerMainPage>(find.byType(PlayerMainPage))
            .display
            .canToggleSource,
        isFalse,
      );

      result.complete(_metadata);
      await pendingMetadata;
      await tester.pump();

      _expectInformation(tester, 'Song title', 'Song artist', opensUp: false);
      await _doubleTapCover(tester);
      expect(
        container.read(playerDisplaySourceLogicProvider),
        PlayerDisplaySource.bilibili,
      );
      _expectInformation(tester, _item.title, _item.author, opensUp: true);

      final PlayableItem nextItem = _item.copyWith(
        bvid: 'BV2xx411c7mD',
        title: 'Next video',
        author: 'Next UP',
        ownerMid: 456,
      );
      playerController.show(
        container
            .read(playerControllerProvider)
            .copyWith(currentItem: nextItem, queue: <PlayableItem>[nextItem]),
      );
      await tester.pump();

      expect(container.read(playerDisplaySourceLogicProvider), isNull);
      _expectInformation(
        tester,
        nextItem.title,
        nextItem.author,
        opensUp: true,
      );
      expect(
        tester
            .widget<PlayerMainPage>(find.byType(PlayerMainPage))
            .display
            .canToggleSource,
        isFalse,
      );

      metadataController.show(_metadata, stableId: nextItem.stableId);
      await tester.pump();

      _expectInformation(
        tester,
        nextItem.title,
        nextItem.author,
        opensUp: true,
      );
      expect(
        tester
            .widget<PlayerMainPage>(find.byType(PlayerMainPage))
            .display
            .canToggleSource,
        isFalse,
      );

      metadataController.show(
        Metadata(
          stableId: nextItem.stableId,
          title: 'Next song',
          artist: 'Next artist',
        ),
      );
      await tester.pump();

      _expectInformation(tester, 'Next song', 'Next artist', opensUp: false);
      playerController.show(
        container
            .read(playerControllerProvider)
            .copyWith(statusHint: PlayerStatusHint.buffering),
      );
      await tester.pump();

      final Finder miniPlayer = find.byType(MiniPlayerContent);
      expect(
        find.descendant(of: miniPlayer, matching: find.text('Next song')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: miniPlayer, matching: find.text('缓冲中...')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: miniPlayer, matching: find.text('Next artist')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'desktop bar fits title artist and actions in its existing height',
    (WidgetTester tester) async {
      final ProviderContainer container = await _pumpPlayer(
        tester,
        _metadata,
        size: const Size(1280, 900),
        home: const Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: DesktopPlayerBar(),
          ),
        ),
      );

      final Finder bar = find.byType(DesktopPlayerBar);
      expect(tester.getSize(bar).height, 76);
      expect(find.text('Song title'), findsOneWidget);
      expect(find.text('Song artist'), findsOneWidget);
      expect(
        tester.getRect(find.text('Song title')).bottom,
        lessThanOrEqualTo(tester.getRect(find.text('Song artist')).top),
      );
      expect(
        tester.getRect(find.text('Song artist')).bottom,
        lessThanOrEqualTo(tester.getRect(find.byTooltip('评论')).top),
      );
      expect(tester.takeException(), isNull);

      container.read(playerDisplaySourceLogicProvider.notifier).toggle();
      await tester.pump();

      expect(find.text(_item.title), findsOneWidget);
      expect(find.text(_item.author), findsOneWidget);
      expect(find.text('Song artist'), findsNothing);
      expect(tester.getSize(bar).height, 76);
      expect(tester.takeException(), isNull);
    },
  );
}

Future<ProviderContainer> _pumpPlayer(
  WidgetTester tester,
  Metadata? metadata, {
  Size size = const Size(420, 900),
  Widget? home,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        favoritesControllerProvider.overrideWith(_FakeFavoritesController.new),
        playerControllerProvider.overrideWith(_FakePlayerController.new),
        metadataControllerProvider.overrideWith(
          () => _FakeMetadataController(metadata),
        ),
        playerCoverColorControllerProvider.overrideWith(
          _FakeCoverColorController.new,
        ),
        playerLyricSettingsLogicProvider.overrideWith(
          _FakeLyricSettingsLogic.new,
        ),
        playerOnlineAudienceControllerProvider.overrideWith(
          _FakeOnlineAudienceController.new,
        ),
        playerDisplaySettingsLogicProvider.overrideWithValue(true),
        desktopLyricsControllerProvider.overrideWithValue(false),
      ],
      child: MaterialApp(
        home:
            home ??
            Scaffold(
              body: Column(
                children: <Widget>[
                  const Expanded(child: PlayerPage(initialItem: _item)),
                  HeroMode(
                    enabled: false,
                    child: Consumer(
                      builder:
                          (BuildContext context, WidgetRef ref, Widget? child) {
                            return MiniPlayerContent(
                              state: ref.watch(playerControllerProvider),
                              onTogglePlayback: () {},
                            );
                          },
                    ),
                  ),
                ],
              ),
            ),
      ),
    ),
  );
  await tester.pump();
  return ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
    listen: false,
  );
}

Future<void> _doubleTapCover(WidgetTester tester) async {
  final Finder cover = find.byType(PlayerArtworkFrame);
  await tester.tap(cover);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(cover);
  await tester.pump(const Duration(milliseconds: 300));
}

void _expectInformation(
  WidgetTester tester,
  String title,
  String artist, {
  required bool opensUp,
}) {
  final PlayerTrackHeader header = tester.widget<PlayerTrackHeader>(
    find.byType(PlayerTrackHeader),
  );
  expect(header.title, title);
  expect(header.subtitle, artist);
  expect(header.onSubtitleTap, opensUp ? isNotNull : isNull);
  final Finder headerWidget = find.byType(PlayerTrackHeader);
  expect(
    find.descendant(of: headerWidget, matching: find.text(title)),
    findsOneWidget,
  );
  expect(
    find.descendant(of: headerWidget, matching: find.text(artist)),
    findsOneWidget,
  );
  final Finder miniPlayer = find.byType(MiniPlayerContent);
  expect(
    find.descendant(of: miniPlayer, matching: find.text(title)),
    findsOneWidget,
  );
  expect(
    find.descendant(of: miniPlayer, matching: find.text(artist)),
    findsOneWidget,
  );
}

class _FakeFavoritesController extends FavoritesController {
  @override
  FavoritesState build() => const FavoritesState();
}

class _FakePlayerController extends PlayerController {
  @override
  PlayerState build() => const PlayerState(
    currentItem: _item,
    queue: <PlayableItem>[_item],
    currentQueueIndex: 0,
    isReady: true,
    duration: Duration(minutes: 3),
  );

  void show(PlayerState value) => state = value;
}

class _FakeMetadataController extends MetadataController {
  _FakeMetadataController(this.metadata);

  final Metadata? metadata;

  @override
  MetadataState build() => MetadataState(
    stableId: _item.stableId,
    metadata: metadata,
    isLoading: metadata == null,
    hasSearched: metadata != null,
  );

  Future<void> receive(Future<Metadata> result) async => show(await result);

  void show(Metadata value, {String? stableId}) {
    state = MetadataState(
      stableId: stableId ?? value.stableId,
      metadata: value,
      hasSearched: true,
    );
  }
}

class _FakeCoverColorController extends PlayerCoverColorController {
  @override
  Color? build() => null;
}

class _FakeLyricSettingsLogic extends PlayerLyricSettingsLogic {
  @override
  PlayerLyricSettings build() => const PlayerLyricSettings();
}

class _FakeOnlineAudienceController extends PlayerOnlineAudienceController {
  @override
  PlayerOnlineAudience? build() => null;
}
