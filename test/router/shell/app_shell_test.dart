import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_provider.dart';
import 'package:bilimusic/feature/player/logic/lyrics/desktop_lyrics_controller.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_controller.dart';
import 'package:bilimusic/feature/search/domain/search_state.dart';
import 'package:bilimusic/feature/search/logic/search_controller.dart';
import 'package:bilimusic/feature/setting/logic/appearance_setting_logic.dart';
import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:bilimusic/feature/up/logic/favorite_up_controller.dart';
import 'package:bilimusic/feature/updater/logic/update_checker.dart';
import 'package:bilimusic/router/shell/app_shell.dart';
import 'package:bilimusic/router/shell/desktop_shell_scaffold.dart';
import 'package:bilimusic/router/shell/mobile_shell_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  setUp(UpdateChecker.resetStartupCheckForTest);
  tearDown(UpdateChecker.resetStartupCheckForTest);

  for (final bool startWide in <bool>[true, false]) {
    testWidgets(
      'startup check survives ${startWide ? 'desktop to mobile' : 'mobile to desktop'} shell replacement',
      (WidgetTester tester) async {
        int runs = 0;
        UpdateChecker.debugStartupCheckRunner = () async {
          runs++;
        };
        await _pumpShell(tester, wide: startWide);
        final State<StatefulWidget> appState = tester.state(
          find.byType(AppShell),
        );
        final BuildContext originalShell = tester.element(
          find.byType(startWide ? DesktopShellScaffold : MobileShellScaffold),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(runs, 0);

        tester.view.physicalSize = Size(startWide ? 800 : 1200, 900);
        await tester.pump();
        expect(originalShell.mounted, isFalse);
        expect(tester.state(find.byType(AppShell)), same(appState));
        expect(
          find.byType(startWide ? MobileShellScaffold : DesktopShellScaffold),
          findsOneWidget,
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(runs, 1);

        tester.view.physicalSize = Size(startWide ? 1200 : 800, 900);
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(runs, 1);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
      skip: !PlatformUtil.isDesktop,
      variant: TargetPlatformVariant({TargetPlatform.macOS}),
    );
  }

  testWidgets('unmounting AppShell skips the pending startup check', (
    tester,
  ) async {
    int runs = 0;
    UpdateChecker.debugStartupCheckRunner = () async {
      runs++;
    };
    await _pumpShell(tester, wide: false);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(UpdateChecker.startupCheckDelay);
    expect(runs, 0);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpShell(WidgetTester tester, {required bool wide}) async {
  tester.view.physicalSize = Size(wide ? 1200 : 800, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  const MethodChannel windowManager = MethodChannel('window_manager');
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    windowManager,
    (call) async => call.method == 'isMaximized' ? false : null,
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      windowManager,
      null,
    ),
  );
  final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            AppShell(navigationShell: shell, currentLocation: state.uri.path),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/home',
                builder: (_, _) => const SizedBox.shrink(),
              ),
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
        playerControllerProvider.overrideWith(_Player.new),
        playerDisplayProvider.overrideWithValue(const PlayerDisplayInfo()),
        appearanceSettingLogicProvider.overrideWithValue(false),
        desktopLyricsControllerProvider.overrideWithValue(false),
        biliSessionControllerProvider.overrideWithValue(null),
        favoritesControllerProvider.overrideWith(_Favorites.new),
        recentPlaybackControllerProvider.overrideWithValue(
          const <RecentPlaybackEntry>[],
        ),
        favoriteUpControllerProvider.overrideWithValue(const <FavoriteUp>[]),
        searchPageControllerProvider.overrideWithValue(const SearchState()),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

class _Player extends PlayerController {
  @override
  PlayerState build() => const PlayerState();
}

class _Favorites extends FavoritesController {
  @override
  FavoritesState build() => const FavoritesState();
}
