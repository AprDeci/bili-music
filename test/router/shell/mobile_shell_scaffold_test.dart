import 'package:bilimusic/common/components/bottom_page_spacer.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_provider.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/mini/mini_player_bar.dart';
import 'package:bilimusic/feature/player/ui/mini/mini_player_content.dart';
import 'package:bilimusic/feature/player/ui/mini/mini_player_glass_bar.dart';
import 'package:bilimusic/feature/setting/logic/appearance_setting_logic.dart';
import 'package:bilimusic/router/shell/mobile_shell_scaffold.dart';
import 'package:bilimusic/router/util/mobile_chrome_config.dart';
import 'package:bilimusic/router/util/player_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

const PlayableItem _item = PlayableItem(
  aid: 1,
  bvid: 'BV1xx411c7mD',
  title: 'Test song',
  author: 'Test artist',
  coverUrl: '',
);
const PlayableItem _secondItem = PlayableItem(
  aid: 2,
  bvid: 'BV2xx411c7mD',
  title: 'Second song',
  author: 'Second artist',
  coverUrl: '',
);
const Key _viewportKey = Key('page viewport');
const Key _lastItemKey = Key('last item');

void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'test',
      packageName: 'test',
      version: 'invalid',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  for (final bool glass in <bool>[false, true]) {
    for (final double inset in <double>[0, 34]) {
      for (final double scale in <double>[1, 2]) {
        testWidgets('overlay glass=$glass inset=$inset scale=$scale', (
          WidgetTester tester,
        ) async {
          final GoRouter router = await _pumpShell(
            tester,
            glass: glass,
            inset: inset,
            scale: scale,
          );
          final Finder mini = find.byType(
            glass ? MiniPlayerGlassBar : MiniPlayerBar,
          );
          final Finder tabs = glass
              ? find.byType(GlassTabBar)
              : find.ancestor(
                  of: find.byIcon(Icons.home),
                  matching: find.byType(ClipRRect),
                );
          final Rect miniRect = tester.getRect(mini);
          final Rect tabsRect = tester.getRect(tabs);
          expect(tabsRect.top - miniRect.bottom, closeTo(10, 0.01));
          expect(tabsRect.height, glass ? 60 : 52);
          expect(tabsRect.width, closeTo(420 * 0.85 - 128, 0.01));
          if (scale == 1) {
            expect(miniRect.height, glass ? 48 : 50);
            expect(
              tester.getSize(find.byType(MiniPlayerArtwork)),
              const Size(36, 36),
            );
            expect(
              tester.getSize(find.byType(MiniPlayerPlaybackButton)),
              const Size(44, 44),
            );
          }
          expect(
            tabsRect.bottom,
            900 - (inset == 0 ? 10 : inset) - (glass ? 11 : 0),
          );
          expect(tester.getRect(find.byKey(_viewportKey)).bottom, 900);
          expect(_spacerHeight(tester), closeTo(900 - miniRect.top + 16, 0.01));
          if (scale == 2) {
            expect(miniRect.height, greaterThan(52));
          }

          await tester.tap(find.byType(MiniPlayerPlaybackButton));
          final _FakePlayerController controller =
              ProviderScope.containerOf(
                    tester.element(mini),
                  ).read(playerControllerProvider.notifier)
                  as _FakePlayerController;
          expect(controller.toggleCalls, 1);
          await tester.drag(find.byKey(_viewportKey), const Offset(0, -1500));
          await tester.pumpAndSettle();
          expect(
            tester.getRect(find.byKey(_lastItemKey)).bottom,
            lessThanOrEqualTo(miniRect.top - 16),
          );

          await tester.tapAt(
            Offset(tabsRect.left + tabsRect.width * 0.75, tabsRect.center.dy),
          );
          await tester.pumpAndSettle();
          expect(router.routeInformationProvider.value.uri.path, '/profile');
          router.go('/home');
          await tester.pumpAndSettle();
          expect(controller.toggleCalls, 1);
          expect(tester.takeException(), isNull);
          await _disposeShell(tester);
        });
      }
    }
  }

  for (final bool glass in <bool>[false, true]) {
    testWidgets('queue restores chrome only after sheet closes glass=$glass', (
      WidgetTester tester,
    ) async {
      await _pumpShell(tester, glass: glass, inset: 34);
      final Finder mini = find.byType(
        glass ? MiniPlayerGlassBar : MiniPlayerBar,
      );
      final Finder tabs = glass
          ? find.byType(GlassTabBar)
          : find.byIcon(Icons.home);
      final double miniY = tester.getTopLeft(mini).dy;
      final double tabsY = tester.getTopLeft(tabs).dy;
      final double spacing = _spacerHeight(tester);
      final NavigatorState root = Navigator.of(
        tester.element(mini),
        rootNavigator: true,
      );
      final MiniPlayerContent content = tester.widget(
        find.byType(MiniPlayerContent),
      );
      final _FakePlayerController player =
          ProviderScope.containerOf(
                tester.element(mini),
              ).read(playerControllerProvider.notifier)
              as _FakePlayerController;
      final Finder queueButton = find.byTooltip('播放队列');
      expect(tester.getSize(queueButton), const Size(48, 48));
      expect(tester.getSemantics(queueButton).tooltip, '播放队列');
      await tester.tap(queueButton);
      content.onOpenQueue!();
      await tester.pump();
      final ModalBottomSheetRoute<void> route =
          ModalRoute.of(tester.element(find.byType(DraggableScrollableSheet)))!
              as ModalBottomSheetRoute<void>;
      expect(route.navigator, same(root));
      expect(playerPageVisibilityListenable.value, isFalse);
      expect(player.toggleCalls, 0);
      expect(find.byType(BottomSheet), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      final double miniDelta = tester.getTopLeft(mini).dy - miniY;
      expect(miniDelta, greaterThan(0));
      expect(tester.getTopLeft(tabs).dy - tabsY, closeTo(miniDelta, 0.01));
      expect(_spacerHeight(tester), spacing);
      expect(route.animation!.value, inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(mini).dy, greaterThanOrEqualTo(900));
      final Rect sheet = tester.getRect(find.byType(BottomSheet));
      final TestGesture drag = await tester.startGesture(
        Offset(sheet.center.dx, sheet.top + 16),
      );
      await drag.moveBy(const Offset(0, 20));
      await tester.pump();
      await drag.moveBy(const Offset(0, 40));
      await tester.pump();
      expect(route.animation!.value, lessThan(1));
      await drag.cancel();
      await tester.pumpAndSettle();
      expect(route.animation!.value, 1);
      root.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      expect(route.animation!.value, inExclusiveRange(0, 1));
      expect(tester.getTopLeft(mini).dy, greaterThanOrEqualTo(900));
      expect(_spacerHeight(tester), spacing);
      await tester.pump(route.reverseTransitionDuration);
      await tester.pump();
      expect(find.byType(BottomSheet), findsNothing);
      expect(tester.getTopLeft(mini).dy, greaterThanOrEqualTo(900));
      await tester.pump(const Duration(milliseconds: 80));
      expect(tester.getTopLeft(mini).dy, inExclusiveRange(miniY, 900));
      expect(find.byType(BottomSheet), findsNothing);
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
      expect(tester.getTopLeft(mini).dy, closeTo(miniY, 0.01));
      expect(tester.getTopLeft(tabs).dy, closeTo(tabsY, 0.01));
      await tester.tap(find.byTooltip('播放队列'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 100));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
      expect(tester.getTopLeft(mini).dy, closeTo(miniY, 0.01));
      expect(tester.takeException(), isNull);
      await _disposeShell(tester);
    });

    testWidgets(
      'queue selects track and chrome survives teardown glass=$glass',
      (WidgetTester tester) async {
        await _pumpShell(tester, glass: glass, width: 320, scale: 2);
        final Finder mini = find.byType(
          glass ? MiniPlayerGlassBar : MiniPlayerBar,
        );
        final _FakePlayerController player =
            ProviderScope.containerOf(
                  tester.element(mini),
                ).read(playerControllerProvider.notifier)
                as _FakePlayerController;
        await tester.tap(find.byTooltip('播放队列'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(ValueKey<String>('queue-${_secondItem.stableId}')),
        );
        await tester.pumpAndSettle();
        expect(player.selectedIndex, 1);
        expect(find.byType(BottomSheet), findsNothing);
        expect(playerPageVisibilityListenable.value, isFalse);
        await tester.tap(find.byTooltip('播放队列'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        await _disposeShell(tester);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('queue respects reduced motion and clears without stale chrome', (
    WidgetTester tester,
  ) async {
    await _pumpShell(tester, disableAnimations: true);
    await tester.tap(find.byTooltip('播放队列'));
    await tester.pump();
    await tester.pump();
    final ModalRoute<dynamic> route = ModalRoute.of(
      tester.element(find.byType(DraggableScrollableSheet)),
    )!;
    expect(route.animation!.value, 1);
    await tester.tap(find.text('清空'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(MiniPlayerBar), findsNothing);
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _disposeShell(tester);
  });

  for (final double inset in <double>[0, 34]) {
    testWidgets('glass keeps top spacing and bottom paint room inset=$inset', (
      WidgetTester tester,
    ) async {
      await _pumpShell(tester, glass: true, inset: inset);
      final Finder content = find.byKey(
        const ValueKey<String>('glass_tab_bar_gesture_region'),
      );
      final _FakePlayerController controller =
          ProviderScope.containerOf(
                tester.element(find.byType(MiniPlayerGlassBar)),
              ).read(playerControllerProvider.notifier)
              as _FakePlayerController;

      for (final bool hasMiniPlayer in <bool>[true, false]) {
        if (!hasMiniPlayer) {
          controller.clear();
          await tester.pumpAndSettle();
        }
        final Rect contentRect = tester.getRect(content);
        expect(contentRect.height, 52);
        final Rect tabsRect = tester.getRect(find.byType(GlassTabBar));
        expect(contentRect.top - tabsRect.top, 4);
        if (hasMiniPlayer) {
          expect(
            contentRect.top -
                tester.getRect(find.byType(MiniPlayerGlassBar)).bottom,
            14,
          );
        }
        final Finder transitions = find.ancestor(
          of: content,
          matching: find.byType(SizeTransition),
        );
        expect(transitions, findsNWidgets(2));
        for (final Element transition in transitions.evaluate()) {
          final Rect clipRect = tester.getRect(
            find.byElementPredicate((Element element) => element == transition),
          );
          expect(
            clipRect.bottom - contentRect.bottom,
            greaterThanOrEqualTo(15),
          );
        }
        expect(tester.takeException(), isNull);
      }
      await _disposeShell(tester);
    });
  }

  for (final Brightness brightness in Brightness.values) {
    testWidgets('glass tint follows the $brightness theme', (tester) async {
      await _pumpShell(tester, glass: true, brightness: brightness);
      final BuildContext miniContext = tester.element(
        find.byType(MiniPlayerGlassBar),
      );
      final LiquidGlassSettings miniSettings = InheritedLiquidGlass.ofOrDefault(
        miniContext,
      );
      final LiquidGlassSettings tabSettings = tester
          .widget<GlassTabBar>(find.byType(GlassTabBar))
          .settings!;
      expect(miniSettings.glassColor.a, greaterThan(0));
      expect(tabSettings.glassColor, miniSettings.glassColor);
      expect(tabSettings.thickness, 14);
      expect(tabSettings.refractiveIndex, 1.15);
      await _disposeShell(tester);
    });
  }

  testWidgets('tabs animate out and back while the mini player moves', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await _pumpShell(tester, glass: true);
    final Finder mini = find.byType(MiniPlayerGlassBar);
    final double start = tester.getRect(mini).top;
    router.go('/search');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 110));
    expect(find.byType(GlassTabBar), findsOneWidget);
    final double middle = tester.getRect(mini).top;
    expect(middle, greaterThan(start));
    await tester.pumpAndSettle();
    expect(find.byType(GlassTabBar), findsNothing);
    expect(tester.getRect(mini).top, greaterThan(middle));
    router.go('/home');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 110));
    expect(tester.getRect(mini).top, greaterThan(start));
    await tester.pumpAndSettle();
    expect(tester.getRect(mini).top, closeTo(start, 0.01));
    expect(tester.takeException(), isNull);
    await _disposeShell(tester);
  });

  testWidgets(
    'chrome and spacing follow routes, playback and player visibility',
    (WidgetTester tester) async {
      final GoRouter router = await _pumpShell(tester);
      final _FakePlayerController controller =
          ProviderScope.containerOf(
                tester.element(find.byType(MiniPlayerBar)),
              ).read(playerControllerProvider.notifier)
              as _FakePlayerController;
      final _FakeAppearance appearance =
          ProviderScope.containerOf(
                tester.element(find.byType(MiniPlayerBar)),
              ).read(appearanceSettingLogicProvider.notifier)
              as _FakeAppearance;
      final double normalSpacing = _spacerHeight(tester);
      appearance.setGlass(true);
      await tester.pumpAndSettle();
      expect(find.byType(MiniPlayerGlassBar), findsOneWidget);
      expect(_spacerHeight(tester), normalSpacing + 17);
      appearance.setGlass(false);
      await tester.pumpAndSettle();
      controller.clear();
      await tester.pumpAndSettle();
      expect(find.byType(MiniPlayerBar), findsNothing);
      expect(_spacerHeight(tester), 78);

      controller.load();
      await tester.pumpAndSettle();
      router.go('/search');
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.home_outlined), findsNothing);
      expect(tester.getRect(find.byType(MiniPlayerBar)).bottom, 880);
      expect(_spacerHeight(tester), 86);
      expect(tester.getRect(find.byKey(_viewportKey)).bottom, 900);

      markPlayerPageVisible();
      await tester.pumpAndSettle();
      expect(find.byType(MiniPlayerBar), findsNothing);
      expect(_spacerHeight(tester), 16);
      markPlayerPageHidden();
      await tester.pumpAndSettle();
      expect(find.byType(MiniPlayerBar), findsOneWidget);

      router.go('/settings');
      await tester.pumpAndSettle();
      expect(find.byType(MiniPlayerBar), findsNothing);
      expect(_spacerHeight(tester), 16);
      router.go('/home');
      await tester.pumpAndSettle();
      expect(find.byType(MiniPlayerBar), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _disposeShell(tester);
    },
  );

  testWidgets('keyboard keeps the page usable and restores overlay spacing', (
    WidgetTester tester,
  ) async {
    await _pumpShell(tester, inset: 34);
    final double spacing = _spacerHeight(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    tester.view.padding = FakeViewPadding.zero;
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(_viewportKey)).bottom, 600);
    expect(tester.takeException(), isNull);
    tester.view.viewInsets = FakeViewPadding.zero;
    tester.view.padding = const FakeViewPadding(bottom: 34);
    await tester.pumpAndSettle();
    expect(_spacerHeight(tester), spacing);
    expect(tester.getRect(find.byKey(_viewportKey)).bottom, 900);
    await _disposeShell(tester);
  });
}

double _spacerHeight(WidgetTester tester) =>
    tester.getSize(find.byType(BottomPageSpacer)).height;

Future<GoRouter> _pumpShell(
  WidgetTester tester, {
  bool glass = false,
  Brightness brightness = Brightness.light,
  double inset = 0,
  double scale = 1,
  double width = 420,
  bool disableAnimations = false,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  tester.view.viewPadding = FakeViewPadding(bottom: inset);
  tester.view.padding = FakeViewPadding(bottom: inset);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetViewPadding);
  addTearDown(tester.view.resetPadding);
  addTearDown(markPlayerPageHidden);
  final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MobileShellScaffold(
          navigationShell: shell,
          currentLocation: state.uri.path,
          chrome: MobileChromeConfig.resolve(state.uri.path),
        ),
        branches: <StatefulShellBranch>[
          for (final String path in <String>[
            '/home',
            '/profile',
            '/search',
            '/settings',
          ])
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(path: path, builder: (_, _) => const _TestPage()),
              ],
            ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        playerControllerProvider.overrideWith(_FakePlayerController.new),
        playerDisplayProvider.overrideWithValue(
          const PlayerDisplayInfo(title: 'Test song', artist: 'Test artist'),
        ),
        appearanceSettingLogicProvider.overrideWith(
          () => _FakeAppearance(glass),
        ),
      ],
      child: MaterialApp.router(
        theme: ThemeData(brightness: brightness),
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            disableAnimations: disableAnimations,
          ),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

Future<void> _disposeShell(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}

class _TestPage extends StatelessWidget {
  const _TestPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page')),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          key: _viewportKey,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 1100),
              TextButton(
                key: _lastItemKey,
                onPressed: () {},
                child: const Text('Last item'),
              ),
              const BottomPageSpacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FakePlayerController extends PlayerController {
  int toggleCalls = 0;
  int? selectedIndex;

  @override
  PlayerState build() => const PlayerState(
    currentItem: _item,
    queue: <PlayableItem>[_item, _secondItem],
    currentQueueIndex: 0,
  );

  @override
  Future<void> skipToQueueIndex(int index, {bool autoplay = true}) async {
    selectedIndex = index;
    state = state.copyWith(
      currentQueueIndex: index,
      currentItem: state.queue[index],
    );
  }

  @override
  Future<void> clearQueue() async => clear();

  void clear() => state = const PlayerState();
  void load() => state = const PlayerState(currentItem: _item);

  @override
  Future<void> togglePlayback() async => toggleCalls++;
}

class _FakeAppearance extends AppearanceSettingLogic {
  _FakeAppearance(this.glass);
  final bool glass;

  @override
  bool build() => glass;

  void setGlass(bool value) => state = value;
}
