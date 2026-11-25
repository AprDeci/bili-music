import 'package:bilimusic/common/components/underline_tab_switcher.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/playback_chapter.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_jump_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const PlayableItem _first = PlayableItem(
  aid: 1,
  bvid: 'BV1',
  cid: 10,
  page: 1,
  pageTitle: '第一首',
  title: '合集',
  author: 'UP',
  coverUrl: '',
);
final PlayableItem _second = _first.copyWith(
  cid: 20,
  page: 2,
  pageTitle: '第二首',
);
const List<PlaybackChapter> _chapters = <PlaybackChapter>[
  PlaybackChapter(start: Duration.zero, title: '夜曲'),
  PlaybackChapter(start: Duration(seconds: 100), title: '晴天'),
];
final PlayerState _state = PlayerState(
  currentItem: _first,
  availableParts: <PlayableItem>[_first, _second],
  chapters: _chapters,
  position: const Duration(seconds: 70),
);
final Finder _tabs = find.byType(UnderlineTabSwitcher);

void main() {
  testWidgets('mobile defaults to chapters, switches tabs and seeks on close', (
    WidgetTester tester,
  ) async {
    final _RecordingController controller = _RecordingController();
    await _open(tester, controller);

    final UnderlineTabSwitcher tabs = tester.widget(_tabs);
    expect(tabs.labels, <String>['章节', '分P']);
    expect(tabs.selectedIndex, 0);
    expect(tabs.minimumSize, const Size(24, 48));
    expect(
      tabs.textStyle,
      Theme.of(tester.element(_tabs)).textTheme.titleSmall,
    );
    expect(
      find.descendant(of: _tabs, matching: find.byType(Icon)),
      findsNothing,
    );
    final Finder indicators = find.descendant(
      of: _tabs,
      matching: find.byType(AnimatedContainer),
    );
    expect(
      (tester.widget<AnimatedContainer>(indicators.first).decoration!
              as BoxDecoration)
          .color,
      Theme.of(tester.element(_tabs)).colorScheme.primary,
    );
    expect(
      tester.getTopLeft(find.text('章节')).dx,
      lessThan(tester.getTopLeft(find.text('分P')).dx),
    );
    expect(
      tester.getBottomLeft(_tabs).dy,
      lessThanOrEqualTo(tester.getTopLeft(find.text('时间轴')).dy),
    );
    expect(find.text('夜曲'), findsOneWidget);
    expect(find.text('01:40'), findsOneWidget);
    expect(find.text('P1 · 第一首'), findsNothing);
    expect(
      tester.widget<Text>(find.text('夜曲')).style?.color,
      Theme.of(tester.element(find.text('夜曲'))).colorScheme.primary,
    );

    await tester.tap(find.text('分P'));
    await tester.pumpAndSettle();
    expect(tester.widget<UnderlineTabSwitcher>(_tabs).selectedIndex, 1);
    expect(
      (tester.widget<AnimatedContainer>(indicators.first).decoration!
              as BoxDecoration)
          .color,
      Colors.transparent,
    );
    expect(
      (tester.widget<AnimatedContainer>(indicators.last).decoration!
              as BoxDecoration)
          .color,
      Theme.of(tester.element(_tabs)).colorScheme.primary,
    );
    expect(find.text('分P列表'), findsOneWidget);
    expect(find.text('P2 · 第二首'), findsOneWidget);
    expect(find.text('夜曲'), findsNothing);

    await tester.tap(find.text('章节'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('晴天'));
    await tester.pumpAndSettle();
    expect(controller.seeked, const Duration(seconds: 100));
    expect(controller.replaced, isNull);
    expect(find.text('时间轴'), findsNothing);
    expect(_tabs, findsNothing);
    expect(find.text('打开跳转'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'desktop defaults to chapters and closes its panel before seeking',
    (WidgetTester tester) async {
      final _RecordingController controller = _RecordingController();
      await _open(tester, controller, desktop: true);
      expect(_tabs, findsOneWidget);
      expect(find.text('夜曲'), findsOneWidget);
      expect(find.text('P1 · 第一首'), findsNothing);

      await tester.tap(find.text('晴天'));
      await tester.pumpAndSettle();
      expect(controller.seeked, const Duration(seconds: 100));
      expect(find.text('时间轴'), findsNothing);
      expect(_tabs, findsNothing);
      expect(find.text('打开跳转'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('desktop part selection keeps replace-current behavior', (
    WidgetTester tester,
  ) async {
    final _RecordingController controller = _RecordingController();
    await _open(tester, controller, desktop: true);
    await tester.tap(find.text('分P'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('P2 · 第二首'));
    await tester.pumpAndSettle();
    expect(controller.replaced, _second);
    expect(controller.seeked, isNull);
    expect(find.text('分P列表'), findsNothing);
    expect(_tabs, findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('current part comes from state and closes without restarting', (
    WidgetTester tester,
  ) async {
    final _RecordingController controller = _RecordingController();
    await _open(
      tester,
      controller,
      state: _state.copyWith(currentItem: _second.copyWith(title: '更新的标题')),
    );
    await tester.tap(find.text('分P'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.text('P2 · 第二首')).style?.color,
      Theme.of(tester.element(find.text('P2 · 第二首'))).colorScheme.primary,
    );
    await tester.tap(find.text('P2 · 第二首'));
    await tester.pumpAndSettle();
    expect(controller.replaced, isNull);
    expect(find.text('分P列表'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'parts retain download and enqueue only unqueued noncurrent parts',
    (WidgetTester tester) async {
      final _RecordingController controller = _RecordingController();
      final PlayableItem third = _first.copyWith(cid: 30, page: 3);
      int downloads = 0;
      await _open(
        tester,
        controller,
        state: _state.copyWith(
          currentItem: _first.copyWith(title: '更新的标题'),
          availableParts: <PlayableItem>[_first, _second, third],
          queue: <PlayableItem>[_second],
        ),
        onDownloadAll: () => downloads++,
      );
      expect(find.byTooltip('下载全部分P'), findsNothing);
      await tester.tap(find.text('分P'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('下载全部分P'));
      await tester.pumpAndSettle();
      expect(downloads, 1);
      expect(find.text('分P列表'), findsOneWidget);
      await tester.tap(find.text('全部加入队列'));
      await tester.pumpAndSettle();
      expect(controller.enqueued, <PlayableItem>[third]);
      expect(find.text('分P列表'), findsNothing);
      final Future<void> dismiss = SmartDialog.dismiss(
        status: SmartStatus.toast,
      );
      await tester.pumpAndSettle();
      await dismiss;
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('small mobile panel switches both lists without overflowing', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final _RecordingController controller = _RecordingController();
    await _open(tester, controller, onDownloadAll: () {});
    expect(find.text('晴天').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('分P'));
    await tester.pumpAndSettle();
    expect(find.text('P2 · 第二首').hitTestable(), findsOneWidget);
    expect(find.text('全部加入队列').hitTestable(), findsOneWidget);
    expect(find.byTooltip('下载全部分P').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('章节'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('晴天'));
    await tester.pumpAndSettle();
    expect(controller.seeked, const Duration(seconds: 100));
    expect(tester.takeException(), isNull);
  });

  for (final bool chaptersOnly in <bool>[true, false]) {
    for (final int otherCount in <int>[0, 1]) {
      testWidgets(
        '${chaptersOnly ? 'chapters' : 'parts'} alone omit tabs with $otherCount other items',
        (WidgetTester tester) async {
          final _RecordingController controller = _RecordingController();
          await _open(
            tester,
            controller,
            state: _state.copyWith(
              chapters: chaptersOnly
                  ? _chapters
                  : _chapters.take(otherCount).toList(),
              availableParts: chaptersOnly
                  ? <PlayableItem>[_first].take(otherCount).toList()
                  : <PlayableItem>[_first, _second],
            ),
          );
          expect(_tabs, findsNothing);
          expect(find.text(chaptersOnly ? '时间轴' : '分P列表'), findsOneWidget);
          expect(find.text(chaptersOnly ? '分P列表' : '时间轴'), findsNothing);
          await tester.tap(find.text(chaptersOnly ? '晴天' : 'P2 · 第二首'));
          await tester.pumpAndSettle();
          if (chaptersOnly) {
            expect(controller.seeked, const Duration(seconds: 100));
          } else {
            expect(controller.replaced, _second);
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

Future<void> _open(
  WidgetTester tester,
  _RecordingController controller, {
  PlayerState? state,
  bool desktop = false,
  VoidCallback? onDownloadAll,
}) async {
  final GoRouter router = GoRouter(
    observers: <NavigatorObserver>[FlutterSmartDialog.observer],
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState routeState) => Scaffold(
          body: TextButton(
            onPressed: () =>
                (desktop
                ? showDesktopPlayerJumpSelectorPanel
                : showPlayerJumpSelector)(
                  context: context,
                  state: state ?? _state,
                  controller: controller,
                  onDownloadAll: onDownloadAll,
                ),
            child: const Text('打开跳转'),
          ),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(
      builder: FlutterSmartDialog.init(),
      routerConfig: router,
    ),
  );
  addTearDown(() async {
    final Future<void> dismiss = SmartDialog.dismiss(
      status: SmartStatus.allDialog,
    );
    final Future<void> dismissToasts = SmartDialog.dismiss(
      status: SmartStatus.toast,
    );
    await tester.pumpAndSettle();
    await dismiss;
    await dismissToasts;
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
  await tester.tap(find.text('打开跳转'));
  await tester.pumpAndSettle();
}

class _RecordingController extends PlayerController {
  Duration? seeked;
  PlayableItem? replaced;
  List<PlayableItem>? enqueued;

  @override
  Future<void> seek(Duration position) async {
    seeked = position;
  }

  @override
  Future<void> replaceCurrentQueueItem(
    PlayableItem item, {
    bool autoplay = true,
  }) async {
    replaced = item;
  }

  @override
  Future<void> enqueue(List<PlayableItem> items) async {
    enqueued = items;
  }
}
