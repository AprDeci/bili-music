import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/feature/download/domain/download_task.dart';
import 'package:bilimusic/feature/download/domain/downloaded_track.dart';
import 'package:bilimusic/feature/download/logic/download_controller.dart';
import 'package:bilimusic/feature/download/ui/downloads_page.dart';
import 'package:bilimusic/feature/download/ui/download_queue_page.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/router/routers.dart' as app_routes;
import 'package:bilimusic/router/util/mobile_chrome_config.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

void main() {
  testWidgets('shows the empty state when nothing is downloaded', (
    tester,
  ) async {
    await _pump(tester, const DownloadState());

    expect(find.text('还没有下载的歌曲'), findsOneWidget);
    expect(find.byTooltip('多选'), findsNothing);
    expect(find.byType(TextField), findsNothing);
  });

  for (final bool desktop in <bool>[false, true]) {
    for (final bool reduceMotion in <bool>[false, true]) {
      testWidgets(
        'download icon follows tasks and motion settings desktop=$desktop reduceMotion=$reduceMotion',
        (tester) async {
          await tester.binding.setSurfaceSize(Size(desktop ? 1200 : 320, 800));
          tester.platformDispatcher.accessibilityFeaturesTestValue =
              FakeAccessibilityFeatures(disableAnimations: reduceMotion);
          addTearDown(() {
            tester.binding.setSurfaceSize(null);
            tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
          });
          final controller = await _pump(
            tester,
            const DownloadState(
              tasks: <String, DownloadTask>{
                'active': DownloadTask(item: _item),
              },
            ),
          );
          await tester.runAsync(
            () => AssetLottie('assets/lottie/download_v2.json').load(),
          );
          await tester.pump();
          Lottie animation = tester.widget<Lottie>(find.byType(Lottie));
          expect(animation.composition, isNotNull);
          expect(animation.composition!.duration.inMilliseconds, 1333);
          expect(animation.repeat, isTrue);
          expect(animation.animate, !reduceMotion);
          expect(tester.getSize(find.byType(Lottie)), const Size(24, 24));
          final Color color = Theme.of(
            tester.element(find.byType(Lottie)),
          ).colorScheme.onSurfaceVariant;
          expect(
            tester
                .widget<ColorFiltered>(find.byType(ColorFiltered))
                .colorFilter,
            ColorFilter.mode(color, BlendMode.srcIn),
          );
          final double start = tester
              .widget<RawLottie>(find.byType(RawLottie))
              .progress;
          await tester.pump(const Duration(milliseconds: 500));
          final double next = tester
              .widget<RawLottie>(find.byType(RawLottie))
              .progress;
          expect(next, reduceMotion ? start : greaterThan(start));

          controller.replace(
            const DownloadState(
              tasks: <String, DownloadTask>{
                'active': DownloadTask(
                  item: _item,
                  status: DownloadTaskStatus.running,
                ),
              },
            ),
          );
          await tester.pump();
          animation = tester.widget<Lottie>(find.byType(Lottie));
          expect(animation.animate, !reduceMotion);

          controller.replace(
            const DownloadState(
              tasks: <String, DownloadTask>{
                'failed': DownloadTask(
                  item: _failedItem,
                  status: DownloadTaskStatus.failed,
                ),
              },
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(Lottie), findsNothing);
          expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);

          controller.replace(const DownloadState());
          await tester.pumpAndSettle();
          expect(find.byType(Lottie), findsNothing);
          expect(find.byIcon(Icons.download_rounded), findsOneWidget);
          expect(find.text('0 首歌曲下载失败'), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final double width in <double>[320, 1200]) {
    testWidgets('matches favorite list dimensions at width $width', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _pump(tester, DownloadState(tracks: _tracks, totalBytes: 3072));

      expect(find.textContaining('已下载 2 首'), findsOneWidget);
      expect(find.text('夜曲'), findsOneWidget);
      expect(find.textContaining('周杰伦'), findsNWidgets(2));
      expect(find.byType(TextField), findsNothing);
      expect(find.byTooltip('删除下载'), findsNothing);
      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
      final CommonCachedImage image = tester.widget<CommonCachedImage>(
        find.byType(CommonCachedImage).first,
      );
      expect(image.width, 44);
      expect(image.height, 44);
      final Finder tile = find.ancestor(
        of: find.text('夜曲'),
        matching: find.byType(ListTile),
      );
      final ListTile widget = tester.widget<ListTile>(tile);
      expect(widget.contentPadding, const EdgeInsets.symmetric(horizontal: 14));
      final double tileHeight = tester.getSize(tile).height;
      final Offset imagePosition = tester.getTopLeft(
        find.byType(CommonCachedImage).first,
      );

      await tester.longPress(find.text('夜曲'));
      await tester.pumpAndSettle();
      expect(find.text('已选 1 项'), findsOneWidget);
      expect(tester.getSize(tile).height, tileHeight);
      expect(
        tester.getTopLeft(find.byType(CommonCachedImage).first),
        imagePosition,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('supports multi-select, select all, deselect and exit', (
    tester,
  ) async {
    await _pump(tester, DownloadState(tracks: _tracks));
    await tester.tap(find.byTooltip('多选'));
    await tester.pumpAndSettle();

    expect(find.text('已选 0 项'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (widget) => widget is IconButton && widget.tooltip == '删除所选下载',
            ),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('全选'));
    await tester.pump();
    expect(find.text('已选 2 项'), findsOneWidget);
    expect(
      tester
          .widgetList<Checkbox>(find.byType(Checkbox))
          .every((box) => box.value!),
      isTrue,
    );
    await tester.tap(find.text('取消全选'));
    await tester.pump();
    expect(find.text('已选 0 项'), findsOneWidget);
    await tester.tap(find.text('夜曲'));
    await tester.pump();
    expect(find.text('已选 1 项'), findsOneWidget);
    await tester.tap(find.byTooltip('退出批量操作'));
    await tester.pumpAndSettle();
    expect(find.byType(Checkbox), findsNothing);
    await tester.tap(find.byTooltip('多选'));
    await tester.pump();
    expect(find.text('已选 0 项'), findsOneWidget);
  });

  testWidgets('confirms deletion and removes only selected tracks', (
    tester,
  ) async {
    final controller = await _pump(tester, DownloadState(tracks: _tracks));
    await tester.longPress(find.text('夜曲'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('删除所选下载'));
    await tester.pumpAndSettle();
    expect(find.text('将删除所选的 1 首歌曲文件，确认继续？'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(controller.removed, isEmpty);
    expect(find.text('已选 1 项'), findsOneWidget);

    await tester.tap(find.byTooltip('删除所选下载'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pumpAndSettle();
    expect(controller.removed, <String>['bvid:BV1:page:1']);
    expect(find.text('夜曲'), findsNothing);
    expect(find.text('晴天'), findsOneWidget);
    expect(find.byTooltip('多选'), findsOneWidget);
    final dismiss = SmartDialog.dismiss(status: SmartStatus.toast);
    await tester.pumpAndSettle();
    await dismiss;
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('clear downloads preserves active tasks', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final controller = await _pump(
      tester,
      DownloadState(
        tracks: _tracks,
        tasks: const <String, DownloadTask>{
          'new': DownloadTask(
            item: _item,
            status: DownloadTaskStatus.running,
            receivedBytes: 50,
            totalBytes: 100,
          ),
        },
      ),
    );
    expect(find.text('正在下载 1 首歌曲'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    await tester.tap(find.byTooltip('清空下载'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.widgetWithText(FilledButton, '清空'));
    await tester.pumpAndSettle();
    expect(controller.removed, hasLength(2));
    expect(find.text('夜曲'), findsNothing);
    expect(find.text('晴天'), findsNothing);
    expect(find.text('正在下载 1 首歌曲'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('还没有下载的歌曲'), findsNothing);
    final dismiss = SmartDialog.dismiss(status: SmartStatus.toast);
    await tester.pumpAndSettle();
    await dismiss;
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  for (final bool desktop in <bool>[false, true]) {
    for (final String parent in <String>['/profile', '/settings']) {
      testWidgets('queue summary navigates under $parent desktop=$desktop', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(Size(desktop ? 1200 : 320, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final GoRouter router = GoRouter(
          initialLocation: '$parent/downloads',
          routes: <RouteBase>[
            GoRoute(
              path: parent,
              builder: (context, state) => const SizedBox(),
              routes:
                  (parent == '/profile'
                              ? (desktop
                                    ? app_routes.desktopTabs
                                    : app_routes.mobileTabs)
                              : (desktop
                                    ? app_routes.desktopTabs
                                    : app_routes.mobileHiddenBranches))
                          .singleWhere((tab) => tab['path'] == parent)['routes']
                      as List<RouteBase>,
            ),
          ],
        );
        addTearDown(router.dispose);
        final controller = await _pump(
          tester,
          const DownloadState(
            tasks: <String, DownloadTask>{
              'running': DownloadTask(
                item: _item,
                status: DownloadTaskStatus.running,
                receivedBytes: 50,
                totalBytes: 100,
              ),
              'queued': DownloadTask(item: _queuedItem),
              'failed': DownloadTask(
                item: _failedItem,
                status: DownloadTaskStatus.failed,
              ),
            },
          ),
          router: router,
        );
        expect(find.text('正在下载 2 首歌曲'), findsOneWidget);
        expect(find.text('排队歌曲'), findsNothing);
        await tester.tap(find.text('正在下载 2 首歌曲'));
        await tester.pumpAndSettle();
        expect(
          GoRouterState.of(
            tester.element(find.byType(DownloadQueuePage)),
          ).uri.path,
          '$parent/downloads/queue',
        );
        expect(find.byType(DownloadQueuePage), findsOneWidget);
        expect(find.text('正在下载'), findsOneWidget);
        expect(find.text('排队歌曲 · P2 第二首'), findsOneWidget);
        expect(find.textContaining('下载中 50%'), findsOneWidget);
        expect(find.textContaining('50 B / 100 B'), findsOneWidget);
        expect(find.textContaining('等待下载'), findsOneWidget);
        expect(
          tester
              .widget<LinearProgressIndicator>(
                find.byType(LinearProgressIndicator),
              )
              .value,
          0.5,
        );
        expect(find.byType(CommonCachedImage), findsNWidgets(3));
        for (final item in <PlayableItem>[_queuedItem, _item]) {
          await tester.tap(
            find.descendant(
              of: find.byKey(ValueKey<String>(item.contentId)),
              matching: find.byTooltip('取消下载'),
            ),
          );
          await tester.pumpAndSettle();
        }
        expect(controller.cancelled, <String>[
          _queuedItem.contentId,
          _item.contentId,
        ]);
      });
    }
  }

  testWidgets('failed-only tasks stay discoverable and retry or cancel', (
    tester,
  ) async {
    final GoRouter router = GoRouter(
      initialLocation: '/profile/downloads',
      routes: <RouteBase>[
        GoRoute(
          path: '/profile/downloads',
          builder: (context, state) => const DownloadsPage(),
          routes: <RouteBase>[
            GoRoute(
              path: 'queue',
              builder: (context, state) => const DownloadQueuePage(),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    final controller = await _pump(
      tester,
      const DownloadState(
        tasks: <String, DownloadTask>{
          'failed': DownloadTask(
            item: _failedItem,
            status: DownloadTaskStatus.failed,
            errorMessage: '网络连接中断，请重试',
          ),
        },
      ),
      router: router,
    );
    expect(find.text('1 首歌曲下载失败'), findsOneWidget);
    await tester.tap(find.text('1 首歌曲下载失败'));
    await tester.pumpAndSettle();
    expect(find.text('失败歌曲'), findsOneWidget);
    expect(find.text('测试作者'), findsOneWidget);
    expect(find.text('网络连接中断，请重试'), findsOneWidget);
    await tester.tap(find.byTooltip('重试下载'));
    await tester.pumpAndSettle();
    expect(controller.retried, <String>[_failedItem.contentId]);
    await _dismissToast(tester);
    await tester.tap(find.text('重试失败项'));
    await tester.pumpAndSettle();
    expect(controller.retryFailedCalls, 1);
    await _dismissToast(tester);
    await tester.tap(find.byTooltip('取消下载'));
    await tester.pumpAndSettle();
    expect(controller.cancelled, <String>[_failedItem.contentId]);
    expect(find.text('暂无下载任务'), findsOneWidget);
  });

  testWidgets(
    'queue actions surface persistence failures without losing tasks',
    (tester) async {
      final GoRouter router = GoRouter(
        initialLocation: '/queue',
        routes: <RouteBase>[
          GoRoute(path: '/queue', builder: (_, _) => const DownloadQueuePage()),
        ],
      );
      addTearDown(router.dispose);
      final controller = await _pump(
        tester,
        const DownloadState(
          tasks: <String, DownloadTask>{
            'failed': DownloadTask(
              item: _failedItem,
              status: DownloadTaskStatus.failed,
            ),
          },
        ),
        router: router,
      );
      controller.failActions = true;
      for (final action in <String>['重试下载', '取消下载', '重试失败项']) {
        await tester.tap(
          action == '重试失败项' ? find.text(action) : find.byTooltip(action),
        );
        await tester.pumpAndSettle();
        expect(
          find.text(action == '取消下载' ? '取消下载失败，请重试' : '重试下载失败，请重试'),
          findsOneWidget,
        );
        expect(find.text('失败歌曲'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await _dismissToast(tester);
      }
    },
  );

  testWidgets('download deletion failure stays visible and can be retried', (
    tester,
  ) async {
    final controller = await _pump(tester, DownloadState(tracks: _tracks));
    controller.failActions = true;
    await tester.longPress(find.text('夜曲'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('删除所选下载'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pumpAndSettle();
    expect(find.text('删除下载失败，请重试'), findsOneWidget);
    expect(find.text('夜曲'), findsOneWidget);
    expect(find.text('已选 1 项'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _dismissToast(tester);
  });

  test('queue paths retain mobile detail chrome', () {
    expect(
      MobileChromeConfig.resolve('/profile/downloads/queue'),
      same(MobileChromeConfig.detail),
    );
    expect(
      MobileChromeConfig.resolve('/settings/downloads/queue'),
      same(MobileChromeConfig.fullScreen),
    );
  });

  testWidgets('prunes selection when downloads change externally', (
    tester,
  ) async {
    final controller = await _pump(tester, DownloadState(tracks: _tracks));
    await tester.longPress(find.text('夜曲'));
    await tester.pumpAndSettle();
    controller.replace(DownloadState(tracks: <DownloadedTrack>[_tracks.last]));
    await tester.pumpAndSettle();
    expect(find.text('已选 0 项'), findsOneWidget);
    controller.replace(const DownloadState());
    await tester.pumpAndSettle();
    expect(find.text('还没有下载的歌曲'), findsOneWidget);
    expect(find.byTooltip('退出批量操作'), findsNothing);
  });
}

Future<_DownloadController> _pump(
  WidgetTester tester,
  DownloadState state, {
  GoRouter? router,
}) async {
  final controller = _DownloadController(state);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [downloadControllerProvider.overrideWith(() => controller)],
      child: router == null
          ? MaterialApp(
              builder: FlutterSmartDialog.init(),
              home: const DownloadsPage(),
            )
          : MaterialApp.router(
              builder: FlutterSmartDialog.init(),
              routerConfig: router,
            ),
    ),
  );
  await tester.pump();
  return controller;
}

class _DownloadController extends DownloadController {
  _DownloadController(this.initialState);

  final DownloadState initialState;
  final List<String> removed = <String>[];
  final List<String> cancelled = <String>[];
  final List<String> retried = <String>[];
  int retryFailedCalls = 0;
  bool failActions = false;

  void _checkFailure() {
    if (failActions) throw StateError('storage unavailable');
  }

  @override
  Future<void> cancel(String contentId) async {
    _checkFailure();
    cancelled.add(contentId);
    state = state.copyWith(
      tasks: <String, DownloadTask>{
        for (final entry in state.tasks.entries)
          if (entry.value.contentId != contentId) entry.key: entry.value,
      },
    );
  }

  @override
  Future<bool> retry(String contentId) async {
    _checkFailure();
    retried.add(contentId);
    return true;
  }

  @override
  Future<int> retryFailed() async {
    _checkFailure();
    retryFailedCalls++;
    return 1;
  }

  @override
  DownloadState build() => initialState;

  void replace(DownloadState next) => state = next;

  @override
  Future<void> removeTrack(DownloadedTrack track) async {
    _checkFailure();
    removed.add(track.contentId);
    state = state.copyWith(
      tracks: state.tracks
          .where((item) => item.contentId != track.contentId)
          .toList(),
    );
  }
}

Future<void> _dismissToast(WidgetTester tester) async {
  final dismiss = SmartDialog.dismiss(status: SmartStatus.toast);
  await tester.pumpAndSettle();
  await dismiss;
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

const PlayableItem _item = PlayableItem(
  aid: 3,
  bvid: 'BV3',
  title: '下载歌曲',
  author: '测试作者',
  coverUrl: '',
);
const PlayableItem _queuedItem = PlayableItem(
  aid: 4,
  bvid: 'BV4',
  title: '排队歌曲',
  page: 2,
  pageTitle: '第二首',
  author: '测试作者',
  coverUrl: '',
);
const PlayableItem _failedItem = PlayableItem(
  aid: 5,
  bvid: 'BV5',
  title: '失败歌曲',
  author: '测试作者',
  coverUrl: '',
);

final List<DownloadedTrack> _tracks = <DownloadedTrack>[
  for (int index = 1; index <= 2; index++)
    DownloadedTrack(
      contentId: 'bvid:BV$index:page:1',
      aid: index,
      bvid: 'BV$index',
      cid: index * 10,
      page: 1,
      title: index == 1 ? '夜曲' : '晴天',
      author: '周杰伦',
      coverUrl: '',
      filePath: '/unused/$index.m4a',
      byteLength: 1024 * index,
      downloadedAtMs: index,
      qualityLabel: '192K',
    ),
];
