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
          expect(tabsRect.height, 52);
          expect(tabsRect.bottom, 900 - (inset == 0 ? 10 : inset));
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
      expect(_spacerHeight(tester), normalSpacing);
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
      expect(_spacerHeight(tester), 88);
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
}) async {
  tester.view.physicalSize = const Size(420, 900);
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
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
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

  @override
  PlayerState build() => const PlayerState(currentItem: _item);

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
