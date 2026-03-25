import 'package:bilimusic/feature/auth/ui/auth_page.dart';
import 'package:bilimusic/router/ScaffoldWithNavBar.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const AuthPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
