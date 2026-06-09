import 'package:bilimusic/common/components/error_page.dart';
import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/feature/comment/domain/comment_target.dart';
import 'package:bilimusic/feature/comment/ui/comment_page.dart';
import 'package:bilimusic/feature/auth/ui/auth_page.dart';
import 'package:bilimusic/feature/favorites/ui/desktop/desktop_favorite_collection_page.dart';
import 'package:bilimusic/feature/favorites/ui/favorite_collection_page.dart';
import 'package:bilimusic/feature/home/ui/home_page.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/ui/desktop_player_page.dart';
import 'package:bilimusic/feature/player/ui/player_page.dart';
import 'package:bilimusic/feature/favorites/ui/import/import_page.dart';
import 'package:bilimusic/feature/profile/ui/profile_page.dart';
import 'package:bilimusic/feature/search/ui/search_page.dart';
import 'package:bilimusic/feature/setting/ui/about_settings_page.dart';
import 'package:bilimusic/feature/setting/ui/cache_settings_page.dart';
import 'package:bilimusic/feature/setting/ui/app_transfer_page.dart';
import 'package:bilimusic/feature/setting/ui/hotkey_settings_page.dart';
import 'package:bilimusic/feature/setting/ui/player_settings_page.dart';
import 'package:bilimusic/feature/setting/ui/setting_page.dart';
import 'package:bilimusic/feature/setting/ui/theme_settings_page.dart';
import 'package:bilimusic/feature/up/ui/collection_detail_page.dart';
import 'package:bilimusic/feature/up/ui/up_page.dart';
import 'package:bilimusic/router/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'routers.g.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;

@riverpod
GoRouter router(Ref ref) => GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: PlatformUtil.isDesktop ? desktopRoutes : mobileRoutes,
);

final List<Map<String, dynamic>> mobileTabs = [
  {
    'path': '/home',
    'builder': (context, state) => const HomePage(),
    'icon': HugeIcon(icon: HugeIcons.strokeRoundedHome07),
    'label': '首页',
  },
  {
    'path': '/profile',
    'builder': (context, state) => const ProfilePage(),
    'routes': <RouteBase>[
      GoRoute(path: 'import', builder: (context, state) => const ImportPage()),
      GoRoute(
        path: 'favorites/:collectionId',
        builder: (context, state) {
          final String collectionId = state.pathParameters['collectionId']!;
          return PlatformUtil.isDesktop
              ? DesktopFavoriteCollectionPage(collectionId: collectionId)
              : FavoriteCollectionPage(collectionId: collectionId);
        },
      ),
    ],
    'icon': HugeIcon(icon: HugeIcons.strokeRoundedUser),
    'label': '我的',
  },
];

final List<Map<String, dynamic>> mobileHiddenBranches = [
  {'path': '/search', 'builder': (context, state) => const SearchPage()},
  {
    'path': '/up',
    'builder': (context, state) =>
        const ErrorPageStatefulWidget(message: 'Up Page Not Found'),
    'routes': [
      GoRoute(
        path: ':mid',
        builder: (context, state) {
          final mid = int.parse(state.pathParameters['mid']!);
          return UpPage(mid: mid);
        },
        routes: [
          GoRoute(
            path: 'collection/:seasonId', // 完整路径 /up/:mid/collection/:seasonId
            builder: (context, state) {
              final mid = int.parse(state.pathParameters['mid']!);
              final seasonId = int.parse(state.pathParameters['seasonId']!);
              return CollectionDetailPage(mid: mid, seasonId: seasonId);
            },
          ),
        ],
      ),
    ],
  },
  {
    'path': '/player',
    'builder': (context, state) {
      final PlayableItem? item = state.extra as PlayableItem?;
      return PlayerPage(initialItem: item);
    },
  },
  {
    'path': '/comments',
    'builder': (context, state) {
      final CommentTarget target = state.extra! as CommentTarget;
      return CommentPage(target: target);
    },
  },
  {
    'path': '/settings',
    'builder': (context, state) => const SettingPage(),
    'routes': <RouteBase>[
      GoRoute(
        path: 'theme',
        builder: (context, state) => const ThemeSettingsPage(),
      ),
      GoRoute(
        path: 'cache',
        builder: (context, state) => const CacheSettingsPage(),
      ),
      GoRoute(
        path: 'player',
        builder: (context, state) => const PlayerSettingsPage(),
      ),
      GoRoute(
        path: 'app-transfer',
        builder: (context, state) => const AppTransferPage(),
      ),
      GoRoute(
        path: 'hotkeys',
        builder: (context, state) => const HotkeySettingsPage(),
      ),
      GoRoute(
        path: 'about',
        builder: (context, state) => const AboutSettingsPage(),
      ),
    ],
  },
];

final List<Map<String, dynamic>> desktopTabs = [
  ...mobileTabs,
  {
    'path': '/search',
    'builder': (context, state) => const SearchPage(),
    'icon': Icons.search,
    'label': '搜索',
  },
  {
    'path': '/settings',
    'builder': (context, state) => const SettingPage(),
    'routes': <RouteBase>[
      GoRoute(
        path: 'theme',
        builder: (context, state) => const ThemeSettingsPage(),
      ),
      GoRoute(
        path: 'cache',
        builder: (context, state) => const CacheSettingsPage(),
      ),
      GoRoute(
        path: 'player',
        builder: (context, state) => const PlayerSettingsPage(),
      ),
      GoRoute(
        path: 'app-transfer',
        builder: (context, state) => const AppTransferPage(),
      ),
      GoRoute(
        path: 'hotkeys',
        builder: (context, state) => const HotkeySettingsPage(),
      ),
      GoRoute(
        path: 'about',
        builder: (context, state) => const AboutSettingsPage(),
      ),
    ],
    'icon': Icons.settings,
    'label': '设置',
  },
  {
    'path': '/comments',
    'builder': (context, state) {
      final CommentTarget target = state.extra! as CommentTarget;
      return CommentPage(target: target);
    },
  },
];

final List<RouteBase> mobileRoutes = [
  GoRoute(path: '/auth', builder: (context, state) => const AuthPage()),
  StatefulShellRoute.indexedStack(
    parentNavigatorKey: _rootNavigatorKey,
    builder: (context, state, navigationShell) {
      return AppShell(
        navigationShell: navigationShell,
        currentLocation: state.uri.path,
      );
    },
    branches: [
      ...<Map<String, dynamic>>[...mobileTabs, ...mobileHiddenBranches].map(
        (tab) => StatefulShellBranch(
          routes: [
            GoRoute(
              path: tab['path'] as String,
              builder: tab['builder'] as GoRouterWidgetBuilder,
              routes: tab['routes'] as List<RouteBase>? ?? const <RouteBase>[],
            ),
          ],
        ),
      ),
    ],
  ),
];

final List<RouteBase> desktopRoutes = [
  GoRoute(path: '/auth', builder: (context, state) => const AuthPage()),
  GoRoute(
    path: '/player',
    parentNavigatorKey: _rootNavigatorKey,
    pageBuilder: (context, state) {
      final PlayableItem? item = state.extra as PlayableItem?;
      return CustomTransitionPage<void>(
        key: state.pageKey,
        child: DesktopPlayerPage(initialItem: item),
        transitionDuration: const Duration(milliseconds: 450),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final Animation<Offset> offsetAnimation =
              Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                ),
              );

          return SlideTransition(position: offsetAnimation, child: child);
        },
      );
    },
  ),
  StatefulShellRoute.indexedStack(
    parentNavigatorKey: _rootNavigatorKey,
    builder: (context, state, navigationShell) {
      return AppShell(
        navigationShell: navigationShell,
        currentLocation: state.uri.path,
      );
    },
    branches: [
      ...desktopTabs.map(
        (tab) => StatefulShellBranch(
          routes: [
            GoRoute(
              path: tab['path'] as String,
              builder: tab['builder'] as GoRouterWidgetBuilder,
              routes: tab['routes'] as List<RouteBase>? ?? const <RouteBase>[],
            ),
          ],
        ),
      ),
    ],
  ),
];
