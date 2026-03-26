import 'package:bilimusic/feature/auth/ui/auth_page.dart';
import 'package:bilimusic/feature/home/ui/home_page.dart';
import 'package:bilimusic/feature/profile/ui/profile_page.dart';
import 'package:bilimusic/router/ScaffoldWithNavBar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'routers.g.dart';

@riverpod
GoRouter router(Ref ref) => GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        ...tabs
            .map(
              (tab) => StatefulShellBranch(
          routes: [
            GoRoute(
              path: tab['path'], builder: tab['builder'],
            ),
          ],
              ),
            )
            .toList(),
      ],
    ),
  ],
);

final List<Map<String, dynamic>> tabs = [
  {
    'path': '/home',
    'builder': (context, state) => const HomePage(),
    'icon': Icons.home,
    'label': '首页',
  },
  {
    'path': '/profile',
    'builder': (context, state) => const ProfilePage(),
    'icon': Icons.person,
    'label': '我的',
  },
];
