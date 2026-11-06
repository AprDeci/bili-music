import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/download/domain/downloaded_track.dart';
import 'package:bilimusic/feature/download/logic/download_controller.dart';
import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:bilimusic/feature/up/logic/favorite_up_controller.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/profile/ui/desktop_profile_sidebar.dart';
import 'package:bilimusic/feature/profile/ui/profile_page.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_controller.dart';
import 'package:bilimusic/router/routers.dart' as app_routes;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('mobile 本地 quick action opens the downloads page', (
    WidgetTester tester,
  ) async {
    await _pump(tester, desktop: false);
    expect(find.text('本地'), findsOneWidget);
    await tester.tap(find.text('本地'));
    await tester.pumpAndSettle();
    expect(find.text('还没有下载的歌曲'), findsOneWidget);
  });

  testWidgets('mobile 本地 quick action shows the downloaded track count', (
    WidgetTester tester,
  ) async {
    await _pump(tester, desktop: false, downloads: _tracks(2));
    final Finder card = find.ancestor(
      of: find.text('本地'),
      matching: find.byType(Column),
    );
    expect(
      find.descendant(of: card.first, matching: find.text('2')),
      findsOneWidget,
    );
  });

  testWidgets('desktop sidebar 本地 entry opens the downloads page', (
    WidgetTester tester,
  ) async {
    await _pump(tester, desktop: true);
    expect(find.text('本地·0'), findsOneWidget);
    await tester.tap(find.text('本地·0'));
    await tester.pumpAndSettle();
    expect(find.text('还没有下载的歌曲'), findsOneWidget);
  });
}

Future<void> _pump(
  WidgetTester tester, {
  required bool desktop,
  List<DownloadedTrack> downloads = const <DownloadedTrack>[],
}) async {
  tester.view.physicalSize = desktop
      ? const Size(1000, 800)
      : const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final GoRouter router = GoRouter(
    initialLocation: '/profile',
    routes: <RouteBase>[
      GoRoute(
        path: '/profile',
        builder: (BuildContext context, GoRouterState state) => desktop
            ? const Scaffold(
                body: Align(
                  alignment: Alignment.centerLeft,
                  child: DesktopProfileSidebar(currentLocation: '/profile'),
                ),
              )
            : const ProfilePage(),
        routes:
            (desktop ? app_routes.desktopTabs : app_routes.mobileTabs)
                    .singleWhere((tab) => tab['path'] == '/profile')['routes']
                as List<RouteBase>,
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        favoritesControllerProvider.overrideWith(_Favorites.new),
        downloadControllerProvider.overrideWith(() => _Downloads(downloads)),
        favoriteUpControllerProvider.overrideWithValue(const <FavoriteUp>[]),
        biliSessionControllerProvider.overrideWithValue(null),
        recentPlaybackControllerProvider.overrideWithValue(
          const <RecentPlaybackEntry>[],
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

List<DownloadedTrack> _tracks(int count) {
  return List<DownloadedTrack>.generate(
    count,
    (int index) => DownloadedTrack(
      contentId: 'content-$index',
      aid: index,
      bvid: 'BV$index',
      cid: index,
      page: 1,
      title: '歌曲 $index',
      author: '作者',
      coverUrl: '',
      filePath: '/tmp/$index.m4a',
      byteLength: 1024,
      downloadedAtMs: index,
    ),
    growable: false,
  );
}

class _Favorites extends FavoritesController {
  @override
  FavoritesState build() => const FavoritesState();

  @override
  Future<void> refreshRemoteCollections() async {}
}

class _Downloads extends DownloadController {
  _Downloads(this._tracks);

  final List<DownloadedTrack> _tracks;

  @override
  DownloadState build() => DownloadState(tracks: _tracks);
}
