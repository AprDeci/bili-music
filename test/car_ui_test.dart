import 'dart:io';

import 'package:bilimusic/myApp.dart';
import 'package:bilimusic/feature/comment/domain/comment_state.dart';
import 'package:bilimusic/feature/comment/domain/comment_target.dart';
import 'package:bilimusic/feature/comment/logic/comment_controller.dart';
import 'package:bilimusic/feature/comment/ui/comment_page.dart';
import 'package:bilimusic/feature/player/domain/audio_stream_info.dart';
import 'package:bilimusic/core/layout/app_layout.dart';
import 'package:bilimusic/feature/player/logic/lyrics/desktop_lyrics_controller.dart';
import 'package:bilimusic/feature/player/ui/desktop/desktop_player_page.dart';
import 'package:bilimusic/feature/player/ui/player_page.dart';
import 'package:bilimusic/feature/player/ui/mini/mini_player_bar.dart';
import 'package:bilimusic/feature/player/ui/mini/mini_player_glass_bar.dart';
import 'package:bilimusic/router/util/player_navigation.dart';
import 'package:bilimusic/router/util/mobile_branch_navigator_keys.dart';
import 'package:bilimusic/router/routers.dart';
import 'package:bilimusic/router/shell/app_shell.dart';
import 'package:bilimusic/router/shell/mobile_shell_scaffold.dart';
import 'package:bilimusic/feature/listening/domain/listening_state.dart';
import 'package:bilimusic/feature/listening/logic/listening_progress_controller.dart';

import 'package:bilimusic/common/components/cached_avatar.dart';
import 'package:bilimusic/common/components/car/car_side_panel.dart';
import 'package:bilimusic/common/components/car/car_cover_glow.dart';
import 'package:bilimusic/feature/player/ui/lyrics/player_lyric_panel.dart';
import 'package:bilimusic/feature/player/ui/car/car_player_queue_panel.dart';
import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/theme/car_theme.dart';
import 'package:bilimusic/core/theme/theme_logic.dart';
import 'package:bilimusic/core/theme/theme_ui_model.dart';
import 'package:bilimusic/feature/setting/logic/appearance_setting_logic.dart';
import 'package:bilimusic/feature/setting/ui/theme_settings_page.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_view_mode_logic.dart';
import 'package:bilimusic/feature/favorites/ui/car/car_favorite_collection_page.dart';
import 'package:bilimusic/feature/home/domain/music_ranking_item.dart';
import 'package:bilimusic/feature/home/logic/music_ranking_controller.dart';
import 'package:bilimusic/common/components/car/car_content_widgets.dart';
import 'package:bilimusic/feature/home/ui/car/car_home_page.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/domain/player_lyric_settings.dart';
import 'package:bilimusic/feature/player/logic/lyrics/player_lyric_settings_logic.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_provider.dart';
import 'package:bilimusic/feature/player/logic/display/player_cover_color_provider.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/car/car_player_panel.dart';
import 'package:bilimusic/feature/player/ui/car/car_player_page.dart';
import 'package:bilimusic/feature/player/ui/components/player_artwork.dart';
import 'package:bilimusic/feature/player/ui/components/player_controls.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/router/shell/car_shell_scaffold.dart';
import 'package:bilimusic/feature/profile/ui/car/car_profile_page.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_controller.dart';
import 'package:bilimusic/feature/recent/ui/car/car_recent_playback_page.dart';
import 'package:bilimusic/feature/setting/logic/car_ui_setting_logic.dart';
import 'package:bilimusic/router/car_ui_page.dart';
import 'package:bilimusic/router/car_ui_viewport.dart';
import 'package:bilimusic/feature/player/logic/sleep_timer_controller.dart';
import 'package:bilimusic/feature/player/ui/sleep_timer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';

const _item = PlayableItem(
  aid: 1,
  bvid: 'test',
  title: '旅途中的音乐',
  author: '测试歌手',
  coverUrl: '',
);

void main() {
  test('car UI defaults off and persists across containers', () async {
    final Directory directory = await Directory.systemTemp.createTemp(
      'car-ui-',
    );
    Hive.init(directory.path);
    final prefs = await Hive.openBox<String>('car-ui-test');
    ProviderContainer container = ProviderContainer(
      overrides: [
        appSettingsStoreProvider.overrideWithValue(AppSettingsStore(prefs)),
      ],
    );
    try {
      expect(container.read(carUiSettingLogicProvider), isFalse);
      await container.read(carUiSettingLogicProvider.notifier).setEnabled(true);
      expect(prefs.get(HiveKeys.carUiEnabled), 'true');
      container.dispose();
      container = ProviderContainer(
        overrides: [
          appSettingsStoreProvider.overrideWithValue(AppSettingsStore(prefs)),
        ],
      );
      expect(container.read(carUiSettingLogicProvider), isTrue);
      await container
          .read(carUiSettingLogicProvider.notifier)
          .setEnabled(false);
      expect(container.read(carUiSettingLogicProvider), isFalse);
    } finally {
      container.dispose();
      await prefs.close();
      await directory.delete(recursive: true);
    }
  });

  testWidgets('page mode changes in place without rebuilding the router', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => CarUiPage(
            carBuilder: (_) => const Text('car'),
            standardBuilder: (_) => const Text('standard'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    final container = ProviderContainer(
      overrides: [
        carUiSettingLogicProvider.overrideWith(_Mode.new),
        routerProvider.overrideWithValue(router),
        themeLogicProvider.overrideWithValue(const ThemeUiModel()),
        listeningProgressControllerProvider.overrideWithValue(
          const ListeningState(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
    expect(find.text('standard'), findsOneWidget);
    await container.read(carUiSettingLogicProvider.notifier).setEnabled(true);
    await tester.pump();
    expect(find.text('car'), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/');
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pump();
    expect(find.text('standard'), findsOneWidget);
    expect(container.read(carUiSettingLogicProvider), isTrue);
    tester.view.physicalSize = const Size(844, 390);
    await tester.pump();
    expect(find.text('car'), findsOneWidget);
    await container.read(carUiSettingLogicProvider.notifier).setEnabled(false);
    await tester.pump();
    expect(find.text('standard'), findsOneWidget);
  });

  for (final size in [
    const Size(360, 640),
    const Size(600, 280),
    const Size(1000, 520),
  ]) {
    testWidgets('content pages fit $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final page in [
        const CarHomePage(),
        const CarProfilePage(),
        const CarRecentPlaybackPage(),
      ]) {
        await tester.pumpWidget(_scope(Scaffold(body: page)));
        await tester.pump();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });
  }

  testWidgets('content pages fit the 1080p 140 DPI car viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 140 / 160;
    addTearDown(tester.view.reset);
    for (final page in [
      const CarHomePage(),
      const CarProfilePage(),
      const CarRecentPlaybackPage(),
    ]) {
      await tester.pumpWidget(_scope(Scaffold(body: page)));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('car playlists put remote first with adjacent add buttons', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 140 / 160;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_scope(const Scaffold(body: CarProfilePage())));
    await tester.pumpAndSettle();
    final Finder remoteTitle = find.text('网络歌单').first;
    final Finder localTitle = find.text('自建歌单');
    expect(
      tester.getTopLeft(remoteTitle).dy,
      lessThan(tester.getTopLeft(localTitle).dy),
    );
    for (final title in ['网络歌单', '自建歌单']) {
      final Rect label = tester.getRect(find.text(title).first);
      final Rect button = tester.getRect(find.byTooltip('添加$title'));
      expect((button.left - label.right) * 140 / 160, closeTo(12, 0.01));
      expect(button.center.dy, closeTo(label.center.dy, 0.01));
      expect(button.shortestSide * 140 / 160, greaterThanOrEqualTo(84));
    }
    await tester.tap(find.byTooltip('添加网络歌单'));
    await tester.pumpAndSettle();
    expect(find.text('登录后可用'), findsOneWidget);
    expect(find.text('网络歌单需要登录 B 站账号'), findsOneWidget);
    await tester.tap(find.text('以后再说'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final remote in [false, true]) {
    testWidgets('car add playlist creates ${remote ? 'remote' : 'local'}', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 140 / 160;
      addTearDown(tester.view.reset);
      final favorites = _Favorites();
      await tester.pumpWidget(
        _scope(
          const Scaffold(body: CarProfilePage()),
          favorites: favorites,
          session: remote
              ? const BiliSession(
                  sessData: 'test',
                  biliJct: 'test',
                  dedeUserId: '1',
                  refreshToken: '',
                  cookie: '',
                )
              : null,
        ),
      );
      await tester.pumpAndSettle();
      expect(favorites.refreshCount, remote ? 1 : 0);
      expect(find.byTooltip('刷新网络歌单'), findsNothing);
      expect(find.byType(RefreshIndicator), findsNothing);
      await tester.tap(find.byTooltip(remote ? '添加网络歌单' : '添加自建歌单'));
      await tester.pumpAndSettle();
      if (remote) {
        expect(find.text('导入已有收藏夹'), findsOneWidget);
        await tester.tap(find.text('新建网络歌单'));
        await tester.pumpAndSettle();
      }
      await tester.enterText(find.byType(TextField), '旅途歌单');
      await tester.tap(find.text('创建'));
      await tester.pumpAndSettle();
      expect(find.text('选择歌单类型'), findsOneWidget);
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();
      expect(favorites.createdRemote, remote);
      expect(favorites.createdKind, CollectionKind.music);
      expect(find.text('旅途歌单'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'song row highlights current track and keeps a large tap target',
    (tester) async {
      await tester.pumpWidget(
        _scope(
          Scaffold(
            body: CarSongTile(item: _item, index: 0, onTap: () {}),
          ),
        ),
      );
      final row = find.byType(CarSongTile);
      expect(tester.getSize(row).height, greaterThanOrEqualTo(88));
      expect(find.byIcon(Icons.equalizer_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'car viewport scales controls and preserves accessibility metrics',
    (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 140 / 160;
      tester.view.padding = FakeViewPadding(top: 28, bottom: 28);
      tester.view.viewPadding = FakeViewPadding(top: 28, bottom: 28);
      addTearDown(tester.view.reset);
      MediaQueryData? actual;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.5),
              viewInsets: const EdgeInsets.only(bottom: 160),
            ),
            child: CarUiViewport(child: child!),
          ),
          home: Builder(
            builder: (context) {
              actual = MediaQuery.of(context);
              return const Scaffold(
                body: Center(child: SizedBox(width: 56, height: 56)),
              );
            },
          ),
        ),
      );
      expect(actual!.size.width, closeTo(1280, 0.01));
      expect(actual!.size.height, closeTo(720, 0.01));
      expect(actual!.devicePixelRatio, closeTo(1.5, 0.01));
      expect(actual!.textScaler.scale(16), 24);
      expect(
        actual!.viewInsets.bottom * actual!.devicePixelRatio,
        closeTo(160 * 140 / 160, 0.01),
      );
      expect(actual!.padding.top * actual!.devicePixelRatio, closeTo(28, 0.01));
      final target = find.byWidgetPredicate(
        (widget) =>
            widget is SizedBox && widget.width == 56 && widget.height == 56,
      );
      expect(tester.getRect(target).width * 140 / 160, closeTo(84, 0.01));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('recent playback has an explicit empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [recentPlaybackControllerProvider.overrideWithValue([])],
        child: const MaterialApp(home: Scaffold(body: CarRecentPlaybackPage())),
      ),
    );
    expect(find.text('还没有最近播放'), findsOneWidget);
  });

  testWidgets('remote collection sync failure can be retried', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 140 / 160;
    addTearDown(tester.view.reset);
    final favorites = _Favorites()..fail = true;
    await tester.pumpWidget(
      _scope(
        const Scaffold(
          body: CarFavoriteCollectionPage(collectionId: 'remote:1'),
        ),
        favorites: favorites,
      ),
    );
    await tester.pumpAndSettle();
    expect(favorites.syncCount, 1);
    final viewToggle = find.byTooltip('切换到元信息视图');
    final syncButton = find.byTooltip('同步歌单');
    expect(
      tester.getRect(viewToggle).right,
      lessThanOrEqualTo(tester.getRect(syncButton).left),
    );
    expect(tester.getRect(viewToggle).shortestSide, greaterThanOrEqualTo(56));
    expect(find.textContaining('播放全部'), findsNothing);
    expect(find.text('多选'), findsNothing);
    expect(find.text('歌单同步失败'), findsOneWidget);
    favorites.fail = false;
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(favorites.syncCount, 2);
    expect(find.text('这个歌单还是空的'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('car glow follows cover color and fades away without a cover', (
    tester,
  ) async {
    final cover = _CoverColor();
    int taps = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerCoverColorControllerProvider.overrideWith(() => cover),
        ],
        child: MaterialApp(
          theme: carLightTheme(),
          home: Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                TextButton(onPressed: () => taps++, child: const Text('tap')),
                const CarCoverGlow(),
              ],
            ),
          ),
        ),
      ),
    );
    final Finder container = find.descendant(
      of: find.byType(CarCoverGlow),
      matching: find.byType(AnimatedContainer),
    );
    RadialGradient gradient() =>
        (tester.widget<AnimatedContainer>(container).decoration!
                    as BoxDecoration)
                .gradient!
            as RadialGradient;
    expect(gradient().colors.first.a, 0);
    cover.setColor(Colors.red);
    await tester.pumpAndSettle();
    expect(gradient().center, const Alignment(-1.0, 1.0));
    final Color red = gradient().colors.first;
    expect(red.r, greaterThan(red.b));
    expect(red.a, closeTo(0.30, 0.01));
    expect(gradient().colors.last.a, 0);
    await tester.tap(find.text('tap'));
    expect(taps, 1);
    cover.setColor(Colors.blue);
    await tester.pump();
    final AnimatedContainer animation = tester.widget(container);
    expect(animation.duration, const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();
    final Color blue = gradient().colors.first;
    expect(blue.b, greaterThan(blue.r));
    cover.setColor(null);
    await tester.pumpAndSettle();
    expect(gradient().colors.first.a, 0);
    expect(tester.takeException(), isNull);
  });

  for (final entry in ['mobile', 'car', 'reopen']) {
    testWidgets(
      'settings keeps back navigation after car toggle, entry=$entry',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 140 / 160;
        addTearDown(tester.view.reset);
        final settings = mobileHiddenBranches.last;
        final router = GoRouter(
          navigatorKey: rootNavigatorKey,
          initialLocation: '/profile',
          routes: [
            StatefulShellRoute.indexedStack(
              builder: (context, state, shell) => AppShell(
                navigationShell: shell,
                currentLocation: state.uri.path,
              ),
              branches: [
                StatefulShellBranch(
                  routes: [
                    GoRoute(path: '/home', builder: (_, _) => const Scaffold()),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/profile',
                      builder: (context, _) => Scaffold(
                        body: TextButton(
                          onPressed: () => context.push('/settings'),
                          child: const Text('打开设置'),
                        ),
                      ),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: settings['path'] as String,
                      builder: settings['builder'] as GoRouterWidgetBuilder,
                      routes: settings['routes'] as List<RouteBase>,
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
              routerProvider.overrideWithValue(router),
              carUiSettingLogicProvider.overrideWith(_Mode.new),
              themeLogicProvider.overrideWithValue(const ThemeUiModel()),
              appearanceSettingLogicProvider.overrideWithValue(false),
              listeningProgressControllerProvider.overrideWithValue(
                const ListeningState(),
              ),
              playerControllerProvider.overrideWith(_Player.new),
              playerDisplayProvider.overrideWithValue(
                const PlayerDisplayInfo(title: '音乐'),
              ),
              biliSessionControllerProvider.overrideWith(_Session.new),
            ],
            child: const MyApp(),
          ),
        );
        await tester.pumpAndSettle();
        if (entry == 'car') {
          final container = ProviderScope.containerOf(
            tester.element(find.byType(MyApp)),
          );
          await container
              .read(carUiSettingLogicProvider.notifier)
              .setEnabled(true);
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('设置'));
        } else {
          await tester.tap(find.text('打开设置'));
        }
        await tester.pumpAndSettle();
        expect(
          find.byType(BackButton),
          entry == 'car' ? findsNothing : findsOneWidget,
        );
        if (entry == 'car') {
          await tester.tap(find.byTooltip('设置'));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text('外观设置'));
        await tester.pumpAndSettle();
        if (entry != 'car') {
          await tester.tap(find.text('启用车机 UI'));
          await tester.pumpAndSettle();
        }
        if (entry == 'reopen') {
          final route = ModalRoute.of(
            tester.element(find.byType(ThemeSettingsPage)),
          );
          await tester.tap(find.byTooltip('设置'));
          await tester.pumpAndSettle();
          expect(
            ModalRoute.of(tester.element(find.byType(ThemeSettingsPage))),
            same(route),
          );
        }
        await tester.tap(find.text('启用车机 UI'));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(find.text('外观设置'), findsOneWidget);
        expect(find.byType(BackButton), findsOneWidget);
        if (entry == 'car') {
          await tester.binding.handlePopRoute();
        } else {
          await tester.tap(find.byType(BackButton));
        }
        await tester.pumpAndSettle();
        expect(find.text('打开设置'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets('car settings survive enabling on the reset phone display', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2280);
    tester.view.devicePixelRatio = 440 / 160;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(
      overrides: [
        carUiSettingLogicProvider.overrideWith(_Mode.new),
        themeLogicProvider.overrideWithValue(const ThemeUiModel()),
        appearanceSettingLogicProvider.overrideWithValue(false),
        listeningProgressControllerProvider.overrideWithValue(
          const ListeningState(),
        ),
        playerControllerProvider.overrideWith(_Player.new),
        playerDisplayProvider.overrideWithValue(
          const PlayerDisplayInfo(title: '音乐'),
        ),
        biliSessionControllerProvider.overrideWith(_Session.new),
      ],
    );
    addTearDown(container.dispose);
    final router = GoRouter(
      initialLocation: '/settings/theme',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) =>
              AppShell(navigationShell: shell, currentLocation: state.uri.path),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/settings/theme',
                  builder: (_, _) => const ThemeSettingsPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    final appContainer = ProviderContainer(
      parent: container,
      overrides: [routerProvider.overrideWithValue(router)],
    );
    addTearDown(appContainer.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: appContainer, child: const MyApp()),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('启用车机 UI'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(container.read(carUiSettingLogicProvider), isTrue);
    expect(router.routeInformationProvider.value.uri.path, '/settings/theme');
    for (final size in [
      const Size(1080, 2280),
      const Size(2280, 1080),
      const Size(1080, 2280),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final bool landscape = size.width > size.height;
      expect(
        find.byType(CarShellScaffold),
        landscape ? findsOneWidget : findsNothing,
      );
      expect(
        find.byType(MobileShellScaffold),
        landscape ? findsNothing : findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) => widget is CarUiViewport && widget.enabled,
        ),
        landscape ? findsOneWidget : findsNothing,
      );
      expect(container.read(carUiSettingLogicProvider), isTrue);
      expect(container.read(playerControllerProvider).queue, [_item]);
      expect(router.routeInformationProvider.value.uri.path, '/settings/theme');
      expect(find.text('跟随系统').hitTestable(), findsOneWidget);
    }
    await tester.tap(find.text('启用车机 UI'));
    await tester.pumpAndSettle();
    expect(container.read(carUiSettingLogicProvider), isFalse);
    expect(find.byType(CarShellScaffold), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    appContainer.dispose();
    container.dispose();
  });

  for (final bool fromMiniPlayer in <bool>[false, true]) {
    testWidgets(
      'open player stays fullscreen across rotation, miniPlayer=$fromMiniPlayer',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2280);
        tester.view.devicePixelRatio = 440 / 160;
        addTearDown(tester.view.reset);
        final router = GoRouter(
          navigatorKey: rootNavigatorKey,
          routes: [
            StatefulShellRoute.indexedStack(
              builder: (context, state, shell) => AppShell(
                navigationShell: shell,
                currentLocation: state.uri.path,
              ),
              branches: [
                StatefulShellBranch(
                  navigatorKey: mobileBranchNavigatorKeys.first,
                  routes: [
                    GoRoute(
                      path: '/',
                      builder: (context, _) => Scaffold(
                        body: TextButton(
                          onPressed: () => openPlayerPage(context),
                          child: const Text('打开播放器'),
                        ),
                      ),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/profile',
                      builder: (_, _) => const Scaffold(),
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
              routerProvider.overrideWithValue(router),
              carUiSettingLogicProvider.overrideWithValue(true),
              appearanceSettingLogicProvider.overrideWithValue(false),
              biliSessionControllerProvider.overrideWith(_Session.new),
              themeLogicProvider.overrideWithValue(const ThemeUiModel()),
              listeningProgressControllerProvider.overrideWithValue(
                const ListeningState(),
              ),
              favoritesControllerProvider.overrideWith(_Favorites.new),
              playerControllerProvider.overrideWith(_Player.new),
              playerDisplayProvider.overrideWithValue(
                const PlayerDisplayInfo(title: '音乐'),
              ),
              playerCoverColorControllerProvider.overrideWith(_CoverColor.new),
              metadataControllerProvider.overrideWith(_Metadata.new),
              playerLyricSettingsLogicProvider.overrideWithValue(
                const PlayerLyricSettings(),
              ),
            ],
            child: const MyApp(),
          ),
        );
        await tester.pumpAndSettle();
        if (fromMiniPlayer) {
          tester.widget<MiniPlayerBar>(find.byType(MiniPlayerBar)).onTap();
        } else {
          await tester.tap(find.text('打开播放器'));
        }
        await tester.pumpAndSettle();
        final route = ModalRoute.of(tester.element(find.byType(PlayerPage)));
        expect(route!.navigator, same(rootNavigatorKey.currentState));
        for (final size in [
          const Size(1080, 2280),
          const Size(2280, 1080),
          const Size(1080, 2280),
        ]) {
          tester.view.physicalSize = size;
          await tester.pumpAndSettle();
          final bool landscape = size.width > size.height;
          expect(
            find.byType(PlayerPage),
            landscape ? findsNothing : findsOneWidget,
          );
          expect(
            find.byType(CarPlayerPage),
            landscape ? findsOneWidget : findsNothing,
          );
          expect(
            ModalRoute.of(
              tester.element(
                find.byType(landscape ? CarPlayerPage : PlayerPage),
              ),
            ),
            same(route),
          );
          final container = ProviderScope.containerOf(
            tester.element(find.byType(MyApp)),
          );
          expect(container.read(carUiSettingLogicProvider), isTrue);
          expect(container.read(playerControllerProvider).queue, [_item]);
          final Rect playerRect = tester.getRect(
            find.byType(landscape ? CarPlayerPage : PlayerPage),
          );
          final Size screenSize =
              tester.view.physicalSize / tester.view.devicePixelRatio;
          expect(playerRect.left, closeTo(0, 0.01));
          expect(playerRect.top, closeTo(0, 0.01));
          expect(playerRect.width, closeTo(screenSize.width, 0.01));
          expect(playerRect.height, closeTo(screenSize.height, 0.01));
          expect(find.byType(CarPlayerPanel), findsNothing);
          expect(playerPageVisibilityListenable.value, isTrue);
          expect(find.byType(MiniPlayerBar), findsNothing);
          expect(find.byType(MiniPlayerGlassBar), findsNothing);
          expect(tester.takeException(), isNull);
        }
        Navigator.of(tester.element(find.byType(PlayerPage))).pop();
        await tester.pumpAndSettle();
        expect(find.text('打开播放器'), findsOneWidget);
        expect(playerPageVisibilityListenable.value, isFalse);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets('shell rotation preserves nested navigation and page state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final branchKey = GlobalKey<NavigatorState>();
    final probeKey = GlobalKey<_ShellProbeState>();
    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) =>
              AppShell(navigationShell: shell, currentLocation: state.uri.path),
          branches: [
            StatefulShellBranch(
              navigatorKey: branchKey,
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (_, _) => _ShellProbe(key: probeKey),
                  routes: [
                    GoRoute(
                      path: 'detail',
                      builder: (_, _) =>
                          const Scaffold(body: Text('nested detail')),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (_, _) =>
                      const Scaffold(body: Text('profile probe')),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    final container = ProviderContainer(
      overrides: [
        routerProvider.overrideWithValue(router),
        carUiSettingLogicProvider.overrideWith(_Mode.new),
        themeLogicProvider.overrideWithValue(const ThemeUiModel()),
        appearanceSettingLogicProvider.overrideWithValue(false),
        listeningProgressControllerProvider.overrideWithValue(
          const ListeningState(),
        ),
        playerControllerProvider.overrideWith(_Player.new),
        playerDisplayProvider.overrideWithValue(
          const PlayerDisplayInfo(title: '音乐'),
        ),
        biliSessionControllerProvider.overrideWith(_Session.new),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'preserved input');
    await tester.drag(find.byType(ListView), const Offset(0, -220));
    await tester.pumpAndSettle();
    final probe = probeKey.currentState!;
    final offset = probe.scroll.offset;
    final navigator = branchKey.currentState!;
    final root = rootNavigatorKey.currentState;
    final player = container.read(playerControllerProvider);
    final controller = container.read(playerControllerProvider.notifier);
    router.push('/home/detail');
    await tester.pumpAndSettle();
    final detail = ModalRoute.of(tester.element(find.text('nested detail')));
    await container.read(carUiSettingLogicProvider.notifier).setEnabled(true);
    for (final size in [
      const Size(844, 390),
      const Size(390, 844),
      const Size(844, 390),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      expect(rootNavigatorKey.currentState, same(root));
      expect(branchKey.currentState, same(navigator));
      expect(probeKey.currentState, same(probe));
      expect(probe.text.text, 'preserved input');
      expect(probe.scroll.offset, offset);
      expect(
        ModalRoute.of(tester.element(find.text('nested detail'))),
        same(detail),
      );
      expect(container.read(playerControllerProvider), same(player));
      expect(
        container.read(playerControllerProvider.notifier),
        same(controller),
      );
      expect(
        GoRouterState.of(tester.element(find.text('nested detail'))).uri.path,
        '/home/detail',
      );
      expect(tester.takeException(), isNull);
    }
    await container.read(carUiSettingLogicProvider.notifier).setEnabled(false);
    await tester.pumpAndSettle();
    expect(branchKey.currentState, same(navigator));
    router.pop();
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    expect(probeKey.currentState, same(probe));
    expect(probe.text.text, 'preserved input');
    expect(probe.scroll.offset, offset);
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
  });

  testWidgets(
    'desktop ignores saved car mode at every window size',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final router = GoRouter(
        navigatorKey: rootNavigatorKey,
        routes: [
          GoRoute(path: '/', builder: (_, _) => const ThemeSettingsPage()),
          desktopRoutes.firstWhere(
            (route) => route is GoRoute && route.path == '/player',
          ),
        ],
      );
      addTearDown(router.dispose);
      final container = ProviderContainer(
        overrides: [
          routerProvider.overrideWithValue(router),
          carUiSettingLogicProvider.overrideWithValue(true),
          themeLogicProvider.overrideWithValue(const ThemeUiModel()),
          appearanceSettingLogicProvider.overrideWithValue(false),
          listeningProgressControllerProvider.overrideWithValue(
            const ListeningState(),
          ),
          favoritesControllerProvider.overrideWith(_Favorites.new),
          playerControllerProvider.overrideWith(_Player.new),
          playerDisplayProvider.overrideWithValue(
            const PlayerDisplayInfo(title: '音乐'),
          ),
          playerCoverColorControllerProvider.overrideWith(_CoverColor.new),
          desktopLyricsControllerProvider.overrideWithValue(false),
          metadataControllerProvider.overrideWith(_Metadata.new),
          playerLyricSettingsLogicProvider.overrideWithValue(
            const PlayerLyricSettings(),
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const MyApp()),
      );
      await tester.pumpAndSettle();
      expect(find.text('启用车机 UI'), findsNothing);
      expect(find.text('主题颜色'), findsOneWidget);
      final context = tester.element(find.byType(ThemeSettingsPage));
      expect(AppLayoutScope.of(context), AppLayout.desktop);
      openPlayerPage(context);
      await tester.pumpAndSettle();
      final route = ModalRoute.of(
        tester.element(find.byType(DesktopPlayerPage)),
      );
      for (final width in [959.0, 960.0, 1280.0]) {
        tester.view.physicalSize = Size(width, 900);
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(DesktopPlayerPage));
        expect(
          AppLayoutScope.of(context),
          width < 960 ? AppLayout.mobile : AppLayout.desktop,
        );
        expect(ModalRoute.of(context), same(route));
        expect(find.byType(CarPlayerPage), findsNothing);
        expect(
          find.byWidgetPredicate(
            (widget) => widget is CarUiViewport && widget.enabled,
          ),
          findsNothing,
        );
        expect(container.read(carUiSettingLogicProvider), isTrue);
        expect(GoRouterState.of(context).uri.path, '/player');
        expect(tester.takeException(), isNull);
      }
      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('启用车机 UI'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
    variant: TargetPlatformVariant({TargetPlatform.macOS}),
  );

  testWidgets('car shell keeps full controls in the car viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 140 / 160;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/auth', builder: (_, _) => const Text('登录页面')),
        GoRoute(path: '/search', builder: (_, _) => const Text('搜索页面')),
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => CarShellScaffold(
            navigationShell: shell,
            currentLocation: state.uri.path,
          ),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (_, _) => const CarRecentPlaybackPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (_, _) => const Text('我的页面'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/settings',
                  builder: (_, _) => const Text('设置页面'),
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
          playerDisplayProvider.overrideWithValue(
            const PlayerDisplayInfo(title: '音乐'),
          ),
          recentPlaybackControllerProvider.overrideWithValue([]),
          biliSessionControllerProvider.overrideWith(_Session.new),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: carLightTheme(),
          builder: (context, child) => CarUiViewport(child: child!),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final Rect panel = tester.getRect(find.byType(CarPlayerPanel));
    final BuildContext shellContext = tester.element(
      find.byType(CarShellScaffold),
    );
    final double viewportScale = MediaQuery.devicePixelRatioOf(shellContext);
    expect(
      panel.top * 140 / 160,
      closeTo(
        (MediaQuery.paddingOf(shellContext).top + 16) * viewportScale,
        0.01,
      ),
    );
    expect(find.byType(CarCoverGlow), findsOneWidget);
    final Material panelMaterial = tester.widget(
      find
          .descendant(
            of: find.byType(CarPlayerPanel),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(panelMaterial.color, Colors.transparent);
    final double screenWidth = 1920 / (140 / 160);
    expect(panel.width / screenWidth, inInclusiveRange(0.28, 0.31));
    expect(
      tester.getRect(find.byTooltip('设置')).width * 140 / 160,
      greaterThanOrEqualTo(84),
    );
    expect(find.byTooltip('播放进度').hitTestable(), findsOneWidget);
    expect(find.byTooltip('暂停').hitTestable(), findsOneWidget);
    expect(find.byTooltip('播放队列（1 首）').hitTestable(), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('我的')).dx,
      lessThan(tester.getTopLeft(find.text('推荐')).dx),
    );
    expect(find.byTooltip('退出车机 UI'), findsNothing);
    expect(find.byIcon(Icons.exit_to_app_rounded), findsNothing);
    expect(find.byIcon(Icons.library_music_outlined), findsNothing);
    expect(find.byIcon(Icons.explore_outlined), findsNothing);
    final Finder myTab = find.widgetWithText(TextButton, '我的');
    final Finder recommendedTab = find.widgetWithText(TextButton, '推荐');
    final ThemeData theme = Theme.of(tester.element(myTab));
    expect(
      tester
          .widget<TextButton>(recommendedTab)
          .style!
          .foregroundColor!
          .resolve({}),
      theme.colorScheme.primary,
    );
    expect(
      tester.widget<TextButton>(myTab).style!.backgroundColor?.resolve({}),
      Colors.transparent,
    );
    expect(
      tester.getRect(find.byTooltip('搜索')).left -
          tester.getRect(recommendedTab).right,
      closeTo(tester.getRect(recommendedTab).height * 8 / 56, 0.01),
    );
    expect(
      tester.getRect(find.widgetWithText(TextButton, '登录')).left,
      greaterThan(tester.getRect(find.byTooltip('搜索')).right),
    );
    await tester.tap(find.text('登录'));
    await tester.pumpAndSettle();
    expect(find.text('登录页面'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(CarShellScaffold)),
    );
    (container.read(biliSessionControllerProvider.notifier) as _Session)
        .logIn();
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextButton, '登录'), findsNothing);
    expect(find.byTooltip('退出登录').hitTestable(), findsOneWidget);
    expect(
      tester
          .widget<CommonCachedAvatar>(find.byType(CommonCachedAvatar))
          .imageUrl,
      '',
    );
    await tester.tap(find.byTooltip('退出登录'));
    await tester.pumpAndSettle();
    expect(find.text('确认退出当前 B 站账号吗？'), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/home');
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byTooltip('退出登录'), findsOneWidget);
    expect(tester.getRect(myTab).height * 140 / 160, greaterThanOrEqualTo(84));
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/profile');
    expect(find.text('我的页面'), findsOneWidget);
    expect(
      tester.widget<TextButton>(myTab).style!.foregroundColor!.resolve({}),
      theme.colorScheme.primary,
    );
    expect(
      tester
          .widget<TextButton>(recommendedTab)
          .style!
          .foregroundColor!
          .resolve({}),
      theme.colorScheme.onSurfaceVariant,
    );
    await tester.tap(find.text('推荐'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/home');
    await tester.tap(find.byTooltip('设置'));
    await tester.pumpAndSettle();
    expect(
      GoRouterState.of(tester.element(find.text('设置页面'))).uri.path,
      '/settings',
    );
    expect(router.canPop(), isTrue);
    expect(find.text('设置页面'), findsOneWidget);
    for (final tab in ['推荐', '我的']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
      expect(find.text('设置页面'), findsNothing);
      expect(find.text(tab == '推荐' ? '最近播放' : '我的页面'), findsOneWidget);
      await tester.tap(find.byTooltip('设置'));
      await tester.pumpAndSettle();
      expect(find.text('设置页面'), findsOneWidget);
      for (final destination in [tab, tab == '推荐' ? '我的' : '推荐', tab]) {
        await tester.tap(find.text(destination));
        await tester.pumpAndSettle();
        expect(find.text('设置页面'), findsNothing);
        expect(
          find.text(destination == '推荐' ? '最近播放' : '我的页面'),
          findsOneWidget,
        );
      }
    }
    await tester.tap(find.byTooltip('搜索'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/search');
    expect(find.text('搜索页面'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final bool dark in <bool>[false, true]) {
    testWidgets(
      'car player lyrics and bottom glow follow cover color ($dark)',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 140 / 160;
        addTearDown(tester.view.reset);
        final cover = _CoverColor();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              playerCoverColorControllerProvider.overrideWith(() => cover),
              playerControllerProvider.overrideWith(_Player.new),
              playerDisplayProvider.overrideWithValue(
                const PlayerDisplayInfo(title: '音乐'),
              ),
              metadataControllerProvider.overrideWith(_Metadata.new),
              playerLyricSettingsLogicProvider.overrideWithValue(
                const PlayerLyricSettings(),
              ),
            ],
            child: MaterialApp(
              theme: dark ? carDarkTheme() : carLightTheme(),
              home: const CarPlayerPage(),
              builder: (_, child) => CarUiViewport(child: child!),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final container = find.descendant(
          of: find.byType(CarCoverGlow),
          matching: find.byType(AnimatedContainer),
        );
        LinearGradient gradient() =>
            (tester.widget<AnimatedContainer>(container).decoration!
                        as BoxDecoration)
                    .gradient!
                as LinearGradient;
        Color? lyricColor() => tester
            .widget<PlayerLyricPanel>(find.byType(PlayerLyricPanel))
            .activeColor;
        expect(gradient().colors.first.a, 0);
        expect(lyricColor(), isNull);
        for (final color in <Color>[Colors.orange, Colors.blue]) {
          cover.setColor(color);
          await tester.pumpAndSettle();
          expect(lyricColor(), color);
          expect(gradient().begin, Alignment.bottomCenter);
          expect(gradient().end, Alignment.topCenter);
          expect(gradient().stops!.last, lessThan(0.65));
          expect(gradient().colors.first.a, closeTo(dark ? 0.18 : 0.30, 0.01));
          expect(gradient().colors.last.a, 0);
          expect(
            HSLColor.fromColor(gradient().colors.first).hue,
            closeTo(HSLColor.fromColor(color).hue, 0.5),
          );
          expect(find.byTooltip('暂停').hitTestable(), findsOneWidget);
          expect(find.byTooltip('播放进度').hitTestable(), findsOneWidget);
        }
        cover.setColor(null);
        await tester.pumpAndSettle();
        expect(lyricColor(), isNull);
        expect(gradient().colors.first.a, 0);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'full player retains queue and shows full controls in the car viewport',
    (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 140 / 160;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerControllerProvider.overrideWith(_Player.new),
            playerDisplayProvider.overrideWithValue(
              const PlayerDisplayInfo(title: '音乐'),
            ),
            playerCoverColorControllerProvider.overrideWith(_CoverColor.new),
            metadataControllerProvider.overrideWith(_Metadata.new),
            playerLyricSettingsLogicProvider.overrideWithValue(
              const PlayerLyricSettings(),
            ),
          ],
          child: MaterialApp(
            home: const CarPlayerPage(initialItem: _item),
            builder: (context, child) => CarUiViewport(child: child!),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byTooltip('暂停').hitTestable(), findsOneWidget);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CarPlayerPage)),
      );
      expect(container.read(playerControllerProvider).queue, [_item]);
      final Finder lyricPanel = find.byType(PlayerLyricPanel);
      final Rect leftPanel = tester.getRect(
        find.ancestor(of: lyricPanel, matching: find.byType(Column)).first,
      );
      final Finder layout = find
          .ancestor(of: lyricPanel, matching: find.byType(LayoutBuilder))
          .first;
      final Rect content = tester.getRect(layout);
      final double scale = content.height / tester.getSize(layout).height;
      expect(leftPanel.top - content.top, closeTo(8 * scale, 0.01));
      expect(content.bottom - leftPanel.bottom, closeTo(24 * scale, 0.01));
      final Rect progress = tester.getRect(find.byTooltip('播放进度'));
      for (final label in ['手动匹配歌词', '歌词偏移']) {
        final Finder button = find.byTooltip(label);
        expect(button.hitTestable(), findsOneWidget);
        final Rect bounds = tester.getRect(button);
        expect(bounds.bottom, lessThanOrEqualTo(progress.top));
        expect(bounds.shortestSide, greaterThanOrEqualTo(56));
      }
      expect(find.byTooltip('歌词外观'), findsNothing);
      await tester.tap(find.byTooltip('歌词偏移'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('歌词延后 0.5 秒'), findsOneWidget);
      Navigator.of(tester.element(find.byType(CarPlayerPage))).pop();
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 140 / 160;
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byTooltip('暂停').hitTestable(), findsOneWidget);
      expect(find.byTooltip('播放进度').hitTestable(), findsOneWidget);
    },
  );

  testWidgets('car player menu opens on the right and applies actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerControllerProvider.overrideWith(_Player.new),
          playerDisplayProvider.overrideWithValue(
            const PlayerDisplayInfo(title: '音乐'),
          ),
          playerCoverColorControllerProvider.overrideWith(_CoverColor.new),
          metadataControllerProvider.overrideWith(_Metadata.new),
          playerLyricSettingsLogicProvider.overrideWithValue(
            const PlayerLyricSettings(),
          ),
        ],
        child: MaterialApp(theme: carDarkTheme(), home: const CarPlayerPage()),
      ),
    );
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(CarPlayerPage)),
    );
    final menu = find.byTooltip('播放器菜单');
    expect(tester.getRect(menu).center.dx, greaterThan(1200));
    expect(tester.getSize(menu).shortestSide, greaterThanOrEqualTo(56));
    await tester.tap(menu);
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byType(CarSidePanel)),
      const Rect.fromLTWH(896, 24, 360, 392),
    );
    expect(find.text('定时关闭'), findsOneWidget);
    for (final label in ['歌词设置', '音质设置', '添加到歌单', '查看评论']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('外部应用打开'), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    final buttons = find.descendant(
      of: find.byType(CarSidePanel),
      matching: find.byType(FilledButton),
    );
    expect(buttons, findsNWidgets(6));
    for (int index = 0; index < 6; index++) {
      final button = tester.widget<FilledButton>(buttons.at(index));
      final shape = button.style!.shape!.resolve({})! as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(12));
      expect(button.style!.backgroundColor, isNull);
      expect(button.style!.foregroundColor, isNull);
      final material = tester.widget<Material>(
        find.descendant(of: buttons.at(index), matching: find.byType(Material)),
      );
      expect(material.color, const Color(0xFF20242C));
      final rect = tester.getRect(buttons.at(index));
      expect(rect.shortestSide, greaterThanOrEqualTo(56));
      if (index.isOdd) {
        final previous = tester.getRect(buttons.at(index - 1));
        expect(rect.top, previous.top);
        expect(rect.left - previous.right, 12);
      } else if (index >= 2) {
        final previousRow = tester.getRect(buttons.at(index - 2));
        expect(rect.left, previousRow.left);
        expect(rect.top - previousRow.bottom, 12);
      }
    }
    await tester.tap(find.text('倍速播放'));
    await tester.pumpAndSettle();
    expect(find.text('1.0x'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    await tester.tap(find.text('1.5x'));
    await tester.pumpAndSettle();
    expect(container.read(playerControllerProvider).speed, 1.5);
    expect(find.byType(CarSidePanel), findsNothing);
    await tester.tap(menu);
    await tester.pumpAndSettle();
    await tester.tap(find.text('定时关闭'));
    await tester.pumpAndSettle();
    expect(find.byType(SleepTimerPage), findsOneWidget);
    expect(find.byType(CarSidePanel), findsOneWidget);
    await tester.tap(find.text('15分钟'));
    await tester.pump();
    expect(
      container.read(sleepTimerControllerProvider).duration,
      const Duration(minutes: 15),
    );
    container.read(sleepTimerControllerProvider.notifier).cancel();
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(CarSidePanel), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final label in ['歌词设置', '音质设置', '添加到歌单', '查看评论']) {
    testWidgets('car player menu opens $label', (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final player = _QualityPlayer();
      final favorites = _Favorites();
      final comments = _Comments();
      final target = CommentTarget.video(
        aid: _item.aid,
        bvid: _item.bvid,
        title: _item.title,
        coverUrl: _item.coverUrl,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerControllerProvider.overrideWith(() => player),
            playerDisplayProvider.overrideWithValue(
              const PlayerDisplayInfo(title: '音乐'),
            ),
            playerCoverColorControllerProvider.overrideWith(_CoverColor.new),
            metadataControllerProvider.overrideWith(_Metadata.new),
            playerLyricSettingsLogicProvider.overrideWithValue(
              const PlayerLyricSettings(),
            ),
            favoritesControllerProvider.overrideWith(() => favorites),
            commentControllerProvider(target).overrideWith(() => comments),
          ],
          child: MaterialApp(
            theme: carDarkTheme(),
            home: const CarPlayerPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('播放器菜单'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      switch (label) {
        case '歌词设置':
          expect(find.text('歌词外观'), findsOneWidget);
          expect(find.byKey(const Key('lyricActiveFontSize')), findsOneWidget);
          await tester.tap(find.byTooltip('关闭歌词外观'));
        case '音质设置':
          expect(find.text('192K'), findsOneWidget);
          expect(find.byIcon(Icons.check_rounded), findsOneWidget);
          await tester.tap(find.text('132K'));
          await tester.pumpAndSettle();
          expect(player.switchedQuality, 30216);
        case '添加到歌单':
          expect(find.text('添加 1 首到歌单'), findsOneWidget);
          await tester.tap(find.text('网络歌单').last);
          await tester.pumpAndSettle();
          expect(favorites.addedItem, _item);
          expect(find.textContaining('部分添加失败'), findsOneWidget);
          await tester.binding.handlePopRoute();
        case '查看评论':
          expect(
            tester.widget<CommentPage>(find.byType(CommentPage)).target,
            target,
          );
          expect(comments.loadCount, 1);
          final panel = find.byType(CarSidePanel);
          expect(panel, findsOneWidget);
          expect(
            tester.getRect(panel),
            rectMoreOrLessEquals(const Rect.fromLTWH(516.8, 24, 739.2, 672)),
          );
          expect(
            tester.getRect(find.byType(CommentPage)),
            tester.getRect(panel),
          );
          expect(find.byType(BottomSheet), findsNothing);
          await tester.tap(find.byType(BackButton));
      }
      await tester.pumpAndSettle();
      expect(find.byType(CarSidePanel), findsNothing);
      expect(find.byType(CarPlayerPage), findsOneWidget);
      expect(
        ProviderScope.containerOf(
          tester.element(find.byType(CarPlayerPage)),
        ).read(playerControllerProvider).currentItem,
        _item,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('car player menu disables unavailable track actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerControllerProvider.overrideWith(_EmptyPlayer.new),
          playerDisplayProvider.overrideWithValue(const PlayerDisplayInfo()),
          playerCoverColorControllerProvider.overrideWith(_CoverColor.new),
          playerLyricSettingsLogicProvider.overrideWithValue(
            const PlayerLyricSettings(),
          ),
        ],
        child: MaterialApp(theme: carDarkTheme(), home: const CarPlayerPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('播放器菜单'));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(CarSidePanel)).height, 232);
    for (final label in ['音质设置', '添加到歌单', '查看评论']) {
      await tester.scrollUntilVisible(
        find.text(label),
        80,
        scrollable: find.descendant(
          of: find.byType(CarSidePanel),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, label),
      );
      expect(button.onPressed, isNull);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('car artwork stays neutral while standard artwork is unchanged', (
    tester,
  ) async {
    await tester.pumpWidget(
      _scope(
        const Scaffold(
          body: SizedBox(width: 320, height: 600, child: CarPlayerPanel()),
        ),
      ),
    );
    expect(find.byType(PlayerArtworkFallback), findsNothing);
    final PlayerArtworkFrame artwork = tester.widget(
      find.byType(PlayerArtworkFrame),
    );
    final ColoredBox fallback = artwork.fallback as ColoredBox;
    expect(fallback.color, carLightTheme().colorScheme.surfaceContainerHighest);
    expect(
      (fallback.child! as Icon).color,
      carLightTheme().colorScheme.onSurfaceVariant,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: carLightTheme(),
        home: const Scaffold(body: PlayerArtworkFrame(coverUrl: '')),
      ),
    );
    expect(find.byType(PlayerArtworkFallback), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('car sidebar aligns artwork title and progress edges', (
    tester,
  ) async {
    await tester.pumpWidget(
      _scope(
        const Scaffold(
          body: SizedBox(width: 400, height: 700, child: CarPlayerPanel()),
        ),
      ),
    );
    final artwork = tester.getRect(find.byType(PlayerArtworkFrame));
    final title = tester.getRect(find.text('旅途中的音乐'));
    final slider = tester.getRect(find.byType(Slider));
    expect(title.left, closeTo(artwork.left, 0.01));
    expect(slider.left, closeTo(artwork.left, 0.01));
    expect(slider.right, closeTo(artwork.right, 0.01));
    final queueButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.queue_music_rounded),
    );
    final queueIcon = tester.getRect(find.byWidget(queueButton.icon));
    final repeatButton = tester.widget<IconButton>(
      find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.tooltip == '顺序播放，切换播放模式',
      ),
    );
    final repeatIcon = tester.getRect(find.byWidget(repeatButton.icon));
    final repeatBounds = tester.getRect(find.byWidget(repeatButton));
    final queueBounds = tester.getRect(find.byWidget(queueButton));
    expect(repeatIcon.left, closeTo(artwork.left, 0.01));
    expect(queueIcon.right, closeTo(artwork.right, 0.01));
    expect(repeatIcon.center, repeatBounds.center);
    expect(queueIcon.center, queueBounds.center);
    expect(tester.takeException(), isNull);
  });

  testWidgets('car controls reuse mobile progress and center playback', (
    tester,
  ) async {
    await tester.pumpWidget(
      _scope(
        const Scaffold(
          body: Center(child: SizedBox(width: 320, child: CarPlayerControls())),
        ),
      ),
    );
    expect(find.byType(PlayerProgressSection), findsOneWidget);
    final SliderTheme sliderTheme = tester.widget(
      find
          .ancestor(of: find.byType(Slider), matching: find.byType(SliderTheme))
          .first,
    );
    expect(sliderTheme.data.trackHeight, 2);
    final controls = tester.getRect(find.byType(CarPlayerControls));
    final sliderBounds = tester.getRect(find.byType(Slider));
    final repeatButton = tester.widget<IconButton>(
      find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.tooltip == '顺序播放，切换播放模式',
      ),
    );
    final queueButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.queue_music_rounded),
    );
    expect(
      tester.getRect(find.byWidget(repeatButton.icon)).left,
      closeTo(sliderBounds.left, 0.01),
    );
    expect(
      tester.getRect(find.byWidget(queueButton.icon)).right,
      closeTo(sliderBounds.right, 0.01),
    );
    final buttons = [
      find.byTooltip('顺序播放，切换播放模式'),
      find.byTooltip('上一首'),
      find.byTooltip('暂停'),
      find.byTooltip('下一首'),
      find.byTooltip('播放队列（1 首）'),
    ].map(tester.getRect).toList();
    expect(buttons[2].center.dx, closeTo(controls.center.dx, 0.01));
    for (final button in tester.widgetList<IconButton>(
      find.descendant(
        of: find.byType(CarPlayerControls),
        matching: find.byType(IconButton),
      ),
    )) {
      final inkWell = find.descendant(
        of: find.byWidget(button),
        matching: find.byType(InkWell),
      );
      expect(
        tester.getCenter(find.byWidget(button.icon)),
        tester.getCenter(inkWell),
      );
      expect(
        find.byWidget(button).hitTestable(at: const Alignment(-0.9, 0)),
        findsOneWidget,
      );
      expect(
        find.byWidget(button).hitTestable(at: const Alignment(0.9, 0)),
        findsOneWidget,
      );
    }
    for (int index = 1; index < buttons.length; index++) {
      expect(
        buttons[index].left,
        greaterThanOrEqualTo(buttons[index - 1].right),
      );
      expect(buttons[index].center.dy, closeTo(buttons[0].center.dy, 0.01));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('car queue uses the left panel and selects the tapped item', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 140 / 160;
    addTearDown(tester.view.reset);
    final player = _Player();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerControllerProvider.overrideWith(() => player),
          playerQueueDisplayProvider(_item).overrideWith(
            (_) async => const PlayerDisplayInfo(title: '队列歌曲', artist: '队列歌手'),
          ),
        ],
        child: MaterialApp(
          theme: carDarkTheme(),
          builder: (context, child) => CarUiViewport(child: child!),
          home: const Scaffold(
            body: Center(
              child: SizedBox(width: 320, child: CarPlayerControls()),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('播放队列（1 首）'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(CarSidePanel), findsOneWidget);
    expect(find.byType(CarPlayerQueueContent), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('播放队列'), findsOneWidget);
    final Finder segmented = find.byWidgetPredicate(
      (widget) => widget is SegmentedButton,
    );
    final Finder header = find
        .ancestor(of: segmented, matching: find.byType(Row))
        .first;
    expect(
      tester.getSize(segmented).width,
      lessThan(tester.getSize(header).width - 56 - 20),
    );
    expect(tester.getSize(segmented).height, greaterThanOrEqualTo(48));
    final SegmentedButton<dynamic> tabs = tester.widget(segmented);
    final RoundedRectangleBorder shape =
        tabs.style!.shape!.resolve({})! as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(12));
    final Material listMaterial = tester.widget(
      find
          .ancestor(of: find.byType(ListView), matching: find.byType(Material))
          .first,
    );
    expect(listMaterial.color, carDarkTheme().colorScheme.surface);
    expect(listMaterial.clipBehavior, Clip.hardEdge);
    expect(
      tester.getRect(find.byWidget(listMaterial)),
      tester.getRect(find.byType(ListView)),
    );
    expect(find.text('队列歌曲'), findsOneWidget);
    final ListTile row = tester.widget(find.byType(ListTile));
    expect(row.selected, isTrue);
    expect(
      tester.getRect(find.byType(ListTile)).height * 140 / 160,
      greaterThanOrEqualTo(84),
    );
    await tester.tap(find.byTooltip('关闭'));
    await tester.pumpAndSettle();
    expect(find.byType(CarSidePanel), findsNothing);
    expect(player.skippedIndex, isNull);
    await tester.tap(find.byTooltip('播放队列（1 首）'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('队列歌曲'));
    await tester.pumpAndSettle();
    expect(player.skippedIndex, 0);
    expect(find.byType(CarSidePanel), findsNothing);
    expect(find.byType(CarPlayerControls), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final int? currentIndex in <int?>[0, 60, 99, null]) {
    testWidgets('car queue focuses current item $currentIndex on opening', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 140 / 160;
      addTearDown(tester.view.reset);
      final queue = List<PlayableItem>.generate(
        100,
        (index) => _item.copyWith(
          aid: index + 1,
          bvid: 'queue-$index',
          title: '歌曲 $index',
        ),
      );
      final player = _QueuePlayer(
        PlayerState(
          queue: queue,
          currentQueueIndex: currentIndex,
          currentItem: currentIndex == null ? null : queue[currentIndex],
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerControllerProvider.overrideWith(() => player),
            for (final item in queue)
              playerQueueDisplayProvider(item).overrideWith(
                (_) async =>
                    PlayerDisplayInfo(title: item.title, artist: item.author),
              ),
          ],
          child: MaterialApp(
            theme: carDarkTheme(),
            builder: (context, child) => CarUiViewport(child: child!),
            home: const Scaffold(body: CarPlayerControls()),
          ),
        ),
      );
      await tester.tap(find.byTooltip('播放队列（100 首）'));
      await tester.pumpAndSettle();
      if (currentIndex == null) {
        expect(find.text('歌曲 0').hitTestable(), findsOneWidget);
        player.update(
          PlayerState(
            queue: queue,
            currentQueueIndex: 60,
            currentItem: queue[60],
          ),
        );
        await tester.pumpAndSettle();
      }
      final int index = currentIndex ?? 60;
      expect(find.text('歌曲 $index').hitTestable(), findsOneWidget);
      expect(
        tester
            .widget<ListTile>(find.widgetWithText(ListTile, '歌曲 $index'))
            .selected,
        isTrue,
      );
      final scrollable = tester.state<ScrollableState>(
        find.descendant(
          of: find.byType(CarPlayerQueueContent),
          matching: find.byType(Scrollable),
        ),
      );
      scrollable.position.jumpTo(0);
      await tester.pumpAndSettle();
      player.update(
        PlayerState(
          queue: queue,
          currentQueueIndex: index,
          currentItem: queue[index],
          position: const Duration(seconds: 1),
        ),
      );
      await tester.pumpAndSettle();
      expect(scrollable.position.pixels, 0);
      await tester.tap(find.byTooltip('关闭'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('播放队列（100 首）'));
      await tester.pumpAndSettle();
      expect(find.text('歌曲 $index').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final int? currentIndex in <int?>[0, 60, 99, null]) {
    testWidgets('car parts focus current item $currentIndex on opening', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 140 / 160;
      addTearDown(tester.view.reset);
      final parts = List<PlayableItem>.generate(
        100,
        (index) => _item.copyWith(
          cid: index + 1,
          page: index + 1,
          pageTitle: '分P $index',
        ),
      );
      final player = _QueuePlayer(
        PlayerState(
          queue: [_item],
          currentQueueIndex: 0,
          availableParts: parts,
          currentItem: currentIndex == null
              ? _item
              : parts[currentIndex].copyWith(title: '更新后的标题'),
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerControllerProvider.overrideWith(() => player),
            playerQueueDisplayProvider(_item).overrideWith(
              (_) async =>
                  const PlayerDisplayInfo(title: '队列歌曲', artist: '队列歌手'),
            ),
          ],
          child: MaterialApp(
            theme: carDarkTheme(),
            builder: (context, child) => CarUiViewport(child: child!),
            home: const Scaffold(body: CarPlayerControls()),
          ),
        ),
      );
      await tester.tap(find.byTooltip('播放队列（1 首）'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('分P'));
      await tester.pumpAndSettle();
      if (currentIndex == null) {
        expect(find.text('P1 · 分P 0').hitTestable(), findsOneWidget);
        player.update(player.initialState.copyWith(currentItem: parts[60]));
        await tester.pumpAndSettle();
      }
      final int index = currentIndex ?? 60;
      final Finder current = find.widgetWithText(
        ListTile,
        'P${index + 1} · 分P $index',
      );
      expect(current.hitTestable(), findsOneWidget);
      expect(tester.widget<ListTile>(current).selected, isTrue);
      final scrollable = tester.state<ScrollableState>(
        find.descendant(
          of: find.byType(CarPlayerQueueContent),
          matching: find.byType(Scrollable),
        ),
      );
      scrollable.position.jumpTo(0);
      await tester.pumpAndSettle();
      player.update(
        player.initialState.copyWith(
          currentItem: parts[index],
          position: const Duration(seconds: 1),
        ),
      );
      await tester.pumpAndSettle();
      expect(scrollable.position.pixels, 0);
      await tester.tap(find.text('播放队列'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('分P'));
      await tester.pumpAndSettle();
      expect(current.hitTestable(), findsOneWidget);
      await tester.tap(find.byTooltip('关闭'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('播放队列（1 首）'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('分P'));
      await tester.pumpAndSettle();
      expect(current.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('player panel always shows full car controls', (tester) async {
    await tester.pumpWidget(
      _scope(
        const Scaffold(
          body: SizedBox(width: 400, height: 600, child: CarPlayerPanel()),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byTooltip('暂停').hitTestable(), findsOneWidget);
    expect(find.byTooltip('播放进度').hitTestable(), findsOneWidget);
    expect(find.byTooltip('顺序播放，切换播放模式').hitTestable(), findsOneWidget);
    expect(find.byTooltip('播放队列（1 首）').hitTestable(), findsOneWidget);
    expect(
      tester.getSize(find.byTooltip('暂停')).shortestSide,
      greaterThanOrEqualTo(56),
    );
    expect(tester.takeException(), isNull);
  });
}

Widget _scope(Widget child, {_Favorites? favorites, BiliSession? session}) =>
    ProviderScope(
      overrides: [
        favoritesControllerProvider.overrideWith(
          () => favorites ?? _Favorites(),
        ),
        favoritesViewModeLogicProvider(
          'remote:1',
        ).overrideWith(_FavoriteViewMode.new),
        recentPlaybackControllerProvider.overrideWithValue([
          RecentPlaybackEntry.fromPlayableItem(_item, playedAtEpochMs: 1),
        ]),
        musicRankingControllerProvider.overrideWith(_Ranking.new),
        biliSessionControllerProvider.overrideWithValue(session),
        playerControllerProvider.overrideWith(_Player.new),
        playerDisplayProvider.overrideWithValue(
          const PlayerDisplayInfo(title: '旅途中的音乐', artist: '测试歌手'),
        ),
      ],
      child: MaterialApp(
        theme: carLightTheme(),
        home: child,
        builder: (context, child) => CarUiViewport(child: child!),
      ),
    );

class _ShellProbe extends StatefulWidget {
  const _ShellProbe({super.key});

  @override
  State<_ShellProbe> createState() => _ShellProbeState();
}

class _ShellProbeState extends State<_ShellProbe> {
  final TextEditingController text = TextEditingController();
  final ScrollController scroll = ScrollController();

  @override
  void dispose() {
    text.dispose();
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ListView(
      controller: scroll,
      children: [
        TextField(controller: text),
        const SizedBox(height: 1600),
      ],
    ),
  );
}

class _Session extends BiliSessionController {
  @override
  BiliSession? build() => null;

  void logIn() => state = const BiliSession(
    sessData: 'test',
    biliJct: 'test',
    dedeUserId: '1',
    refreshToken: '',
    cookie: '',
    face: '',
  );
}

class _CoverColor extends PlayerCoverColorController {
  @override
  Color? build() => null;

  void setColor(Color? color) => state = color;
}

class _Metadata extends MetadataController {
  @override
  MetadataState build() =>
      const MetadataState(stableId: 'bvid:test', hasSearched: true);
}

class _FavoriteViewMode extends FavoritesViewModeLogic {
  @override
  FavoriteListViewMode build(String collectionId) => FavoriteListViewMode.video;
}

class _Mode extends CarUiSettingLogic {
  @override
  bool build() => false;
  @override
  Future<void> setEnabled(bool value) async {
    state = value;
  }
}

class _Player extends PlayerController {
  int? skippedIndex;

  @override
  Future<void> setSpeed(double speed) async {
    state = state.copyWith(speed: speed);
  }

  @override
  Future<void> skipToQueueIndex(int index, {bool autoplay = true}) async {
    skippedIndex = index;
  }

  @override
  PlayerState build() => const PlayerState(
    currentItem: _item,
    queue: [_item],
    currentQueueIndex: 0,
    isReady: true,
    isPlaying: true,
    duration: Duration(minutes: 3),
  );
}

class _QueuePlayer extends _Player {
  _QueuePlayer(this.initialState);

  final PlayerState initialState;

  @override
  PlayerState build() => initialState;

  void update(PlayerState next) => state = next;
}

class _QualityPlayer extends _Player {
  int? switchedQuality;

  @override
  PlayerState build() => super.build().copyWith(
    audioStream: const AudioStreamInfo(
      streamUrl: '',
      backupUrls: [],
      headers: {},
      cid: 1,
      duration: null,
      bandwidth: 192000,
      availableQualities: [
        AudioQualityOption(
          qualityId: 30280,
          bandwidth: 192000,
          label: '192K',
          isSelected: true,
        ),
        AudioQualityOption(qualityId: 30216, bandwidth: 132000, label: '132K'),
      ],
    ),
  );

  @override
  Future<void> switchCurrentAudioQuality(int? qualityId) async {
    switchedQuality = qualityId;
  }
}

class _EmptyPlayer extends _Player {
  @override
  PlayerState build() => const PlayerState();
}

class _Comments extends CommentController {
  int loadCount = 0;

  @override
  CommentState build(CommentTarget target) => CommentState(target: target);

  @override
  Future<void> loadInitial() async {
    loadCount++;
  }
}

class _Ranking extends MusicRankingController {
  @override
  Future<List<MusicRankingItem>> build() async => [];
}

class _Favorites extends FavoritesController {
  bool fail = false;
  int syncCount = 0;
  int refreshCount = 0;
  bool? createdRemote;
  CollectionKind? createdKind;
  PlayableItem? addedItem;

  @override
  Future<bool> addToCollection({
    required String collectionId,
    required PlayableItem item,
  }) async {
    addedItem = item;
    return false;
  }

  @override
  Future<void> refreshRemoteCollections() async {
    refreshCount++;
  }

  @override
  Future<FavoriteCollection?> createCollection(
    String name, {
    CollectionKind kind = CollectionKind.music,
  }) async {
    createdKind = kind;
    createdRemote ??= false;
    final collection = FavoriteCollection(
      id: createdRemote! ? 'remote:2' : 'local:1',
      name: name,
      source: createdRemote!
          ? FavoriteCollectionSource.remote
          : FavoriteCollectionSource.local,
      kind: kind,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    state = state.copyWith(collections: [...state.collections, collection]);
    return collection;
  }

  @override
  Future<FavoriteCollection?> createRemoteCollection(
    String name, {
    CollectionKind kind = CollectionKind.music,
  }) {
    createdRemote = true;
    return createCollection(name, kind: kind);
  }

  @override
  FavoritesState build() => FavoritesState(
    collections: [
      FavoriteCollection.liked(),
      FavoriteCollection(
        id: 'remote:1',
        name: '网络歌单',
        source: FavoriteCollectionSource.remote,
        remoteId: '1',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    ],
  );
  @override
  Future<RemoteCollectionSyncResult> syncRemoteCollectionIfStale(
    String collectionId, {
    bool force = false,
  }) async {
    syncCount++;
    if (fail) {
      throw StateError('offline');
    }
    return RemoteCollectionSyncResult.skipped;
  }
}
