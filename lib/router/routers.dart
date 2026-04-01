import 'package:bilimusic/feature/auth/ui/auth_page.dart';
import 'package:bilimusic/feature/favorites/ui/favorite_collection_page.dart';
import 'package:bilimusic/feature/home/ui/home_page.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/ui/player_page.dart';
import 'package:bilimusic/feature/profile/ui/profile_page.dart';
import 'package:bilimusic/feature/search/ui/search_page.dart';
import 'package:bilimusic/feature/setting/ui/about_settings_page.dart';
import 'package:bilimusic/feature/setting/ui/setting_page.dart';
import 'package:bilimusic/feature/setting/ui/theme_settings_page.dart';
import 'package:bilimusic/router/ScaffoldWithNavBar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'routers.g.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;

@riverpod
GoRouter router(Ref ref) => GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/auth', builder: (context, state) => const AuthPage()),
    // GoRoute(
    //   path: '/search',
    //   parentNavigatorKey: _rootNavigatorKey,
    //   builder: (context, state) => const SearchPage(),
    // ),
    GoRoute(
      path: '/player',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final PlayableItem? item = state.extra as PlayableItem?;
        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: PlayerPage(initialItem: item),
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
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingPage(),
    ),
    GoRoute(
      path: '/settings/theme',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ThemeSettingsPage(),
    ),
    GoRoute(
      path: '/settings/about',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AboutSettingsPage(),
    ),
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(
          navigationShell: navigationShell,
          currentLocation: state.uri.path,
        );
      },
      branches: [
        ...tabs.map(
          (tab) => StatefulShellBranch(
            routes: [
              GoRoute(
                path: tab['path'] as String,
                builder: tab['builder'] as GoRouterWidgetBuilder,
                routes:
                    tab['routes'] as List<RouteBase>? ?? const <RouteBase>[],
              ),
            ],
          ),
        ),
      ],
    ),
  ],
);

final List<Map<String, dynamic>> tabs = [
  {
    'path': '/home',
    'builder': (context, state) => const HomePage(),
    'routes': const <RouteBase>[],
    'icon': Icons.home,
    'label': '首页',
  },
  {
    'path': '/profile',
    'builder': (context, state) => const ProfilePage(),
    'routes': <RouteBase>[
      GoRoute(
        path: 'favorites/:collectionId',
        builder: (context, state) {
          final String collectionId = state.pathParameters['collectionId']!;
          return FavoriteCollectionPage(collectionId: collectionId);
        },
      ),
    ],
    'icon': Icons.person,
    'label': '我的',
  },
  {
    'path': '/search',
    'builder': (context, state) => const SearchPage(),
    'routes': const <RouteBase>[],
    'icon': Icons.search,
    'label': '搜索',
  },
];
