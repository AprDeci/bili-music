import 'package:bilimusic/core/layout/app_layout.dart';
import 'package:bilimusic/core/theme/car_theme.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/domain/player_lyric_settings.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_provider.dart';
import 'package:bilimusic/feature/player/logic/lyrics/player_lyric_settings_logic.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/car/car_player_page.dart';
import 'package:bilimusic/feature/player/ui/car/car_player_panel.dart';
import 'package:bilimusic/feature/player/ui/components/player_artwork.dart';
import 'package:bilimusic/router/car_ui_viewport.dart';
import 'package:bilimusic/router/util/player_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _item = PlayableItem(
  aid: 1,
  bvid: 'test',
  title: '音乐',
  author: '歌手',
  coverUrl: '',
);

void main() {
  testWidgets(
    'car player uses native material route and flies artwork and controls in both directions',
    (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 140 / 160;
      addTearDown(tester.view.reset);
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(
              body: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(width: 400, child: CarPlayerPanel()),
              ),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerControllerProvider.overrideWith(_Player.new),
            playerDisplayProvider.overrideWithValue(
              const PlayerDisplayInfo(title: '音乐', artist: '歌手'),
            ),
            metadataControllerProvider.overrideWith(_Metadata.new),
            playerLyricSettingsLogicProvider.overrideWithValue(
              const PlayerLyricSettings(),
            ),
          ],
          child: AppLayoutScope(
            layout: AppLayout.car,
            child: MaterialApp.router(
              theme: carDarkTheme(),
              routerConfig: router,
              builder: (_, child) => CarUiViewport(child: child!),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final artworkHero = find.byWidgetPredicate(
        (widget) => widget is Hero && widget.tag == 'car-player-artwork',
      );
      final controlsHero = find.byWidgetPredicate(
        (widget) => widget is Hero && widget.tag == 'car-player-controls',
      );
      expect(artworkHero, findsOneWidget);
      expect(controlsHero, findsOneWidget);
      final source = tester.getRect(find.byType(PlayerArtworkFrame));
      final sourceControls = tester.getRect(find.byType(CarPlayerControls));
      expect(
        tester
            .widget<PlayerArtworkFrame>(find.byType(PlayerArtworkFrame))
            .borderRadius,
        8,
      );
      await tester.tap(find.byTooltip('打开完整播放器'));
      await tester.pump();
      for (int frame = 0; frame < 5; frame++) {
        await tester.pump(const Duration(milliseconds: 20));
        expect(tester.takeException(), isNull);
      }
      final flight = find.descendant(
        of: find.byType(Overlay),
        matching: find.byType(PlayerArtworkFrame),
      );
      expect(flight, findsOneWidget);
      final middle = tester.getRect(flight);
      final controlsFlight = find.descendant(
        of: find.byType(Overlay),
        matching: find.byType(CarPlayerControls),
      );
      expect(controlsFlight, findsOneWidget);
      final middleControls = tester.getRect(controlsFlight);
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      expect(find.byType(CarPlayerPage), findsOneWidget);
      final pageContext = tester.element(find.byType(CarPlayerPage));
      final route = ModalRoute.of(pageContext)!;
      expect(route, isA<MaterialPageRoute<void>>());
      expect(route.settings.name, playerNativeRouteName);
      expect(artworkHero, findsOneWidget);
      expect(controlsHero, findsOneWidget);
      final destination = tester.getRect(find.byType(PlayerArtworkFrame));
      expect(middle.center.dx, greaterThan(source.center.dx));
      expect(middle.center.dx, lessThan(destination.center.dx));
      expect(destination.center.dy, lessThan(1080 / (140 / 160) * 0.55));
      final controls = tester.getRect(find.byType(CarPlayerControls));
      expect(middleControls.center.dx, greaterThan(sourceControls.center.dx));
      expect(middleControls.center.dx, lessThan(controls.center.dx));
      expect(middleControls.width, greaterThan(sourceControls.width));
      expect(middleControls.width, lessThan(controls.width));
      final page = tester.getRect(find.byType(CarPlayerPage));
      expect(controls.width / page.width, inExclusiveRange(0.40, 0.53));
      expect(controls.left - page.left, greaterThan(page.width * 0.05));
      expect(
        page.bottom - controls.bottom,
        closeTo(
          24 * page.height / tester.getSize(find.byType(CarPlayerPage)).height,
          0.01,
        ),
      );
      expect(
        tester
            .widget<PlayerArtworkFrame>(find.byType(PlayerArtworkFrame))
            .borderRadius,
        8,
      );
      await tester.tap(find.byTooltip('返回'));
      await tester.pump();
      for (int frame = 0; frame < 5; frame++) {
        await tester.pump(const Duration(milliseconds: 20));
        expect(tester.takeException(), isNull);
      }
      expect(find.byType(PlayerArtworkFrame), findsOneWidget);
      expect(controlsFlight, findsOneWidget);
      final returningControls = tester.getRect(controlsFlight);
      expect(
        returningControls.center.dx,
        greaterThan(sourceControls.center.dx),
      );
      expect(returningControls.center.dx, lessThan(controls.center.dx));
      expect(returningControls.width, greaterThan(sourceControls.width));
      expect(returningControls.width, lessThan(controls.width));
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      expect(find.byType(CarPlayerPage), findsNothing);
      expect(tester.getRect(find.byType(PlayerArtworkFrame)), source);
      expect(tester.getRect(find.byType(CarPlayerControls)), sourceControls);
      expect(tester.takeException(), isNull);
    },
  );
}

class _Player extends PlayerController {
  @override
  PlayerState build() => const PlayerState(
    currentItem: _item,
    queue: [_item],
    currentQueueIndex: 0,
    isReady: true,
    duration: Duration(minutes: 3),
  );
}

class _Metadata extends MetadataController {
  @override
  MetadataState build() =>
      const MetadataState(stableId: 'bvid:test', hasSearched: true);
}
