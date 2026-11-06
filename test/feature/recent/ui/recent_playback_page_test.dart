import 'dart:async';

import 'package:bilimusic/common/components/selectable_auto_scroll_list_view.dart';
import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_controller.dart';
import 'package:bilimusic/feature/recent/ui/desktop/desktop_recent_playback_page.dart';
import 'package:bilimusic/feature/recent/ui/recent_playback_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const List<RecentPlaybackEntry> _entries = <RecentPlaybackEntry>[
  RecentPlaybackEntry(
    aid: 1,
    bvid: 'BV1',
    cid: 11,
    page: 1,
    pageTitle: '第一分P',
    title: '最近歌曲一',
    author: '作者一',
    coverUrl: '',
    playedAtEpochMs: 3000,
  ),
  RecentPlaybackEntry(
    aid: 1,
    bvid: 'BV1',
    cid: 12,
    page: 2,
    pageTitle: '第二分P',
    title: '最近歌曲二',
    author: '作者二',
    coverUrl: '',
    kind: CollectionKind.spoken,
    collectionId: 'spoken-collection',
    playedAtEpochMs: 2000,
  ),
  RecentPlaybackEntry(
    aid: 3,
    bvid: 'BV3',
    cid: 31,
    title: '最近歌曲三',
    author: '作者三',
    coverUrl: '',
    playedAtEpochMs: 1000,
  ),
];

void main() {
  for (final bool desktop in <bool>[false, true]) {
    final String platform = desktop ? 'desktop' : 'mobile';

    testWidgets(
      '$platform plays rows and trailing buttons, resets selection, and deletes all',
      (WidgetTester tester) async {
        final _Fixture fixture = await _pumpPage(tester, desktop: desktop);
        expect(
          find.byType(
            SelectableAutoScrollListView<RecentPlaybackEntry, String>,
          ),
          findsOneWidget,
        );
        expect(find.byTooltip('播放'), findsNWidgets(3));
        expect(
          find.byWidgetPredicate((Widget widget) => widget is PopupMenuButton),
          findsNothing,
        );
        expect(find.textContaining('清空'), findsNothing);
        final Finder entry = _textButton('多选');
        expect(entry, findsOneWidget);
        expect(
          find.descendant(of: entry, matching: find.byType(Icon)),
          findsOneWidget,
        );

        await _tap(tester, find.text(_entries[1].title));
        _expectPlayback(fixture.player, calls: 1, startIndex: 1);
        await _tap(tester, find.byTooltip('播放').at(2));
        _expectPlayback(fixture.player, calls: 2, startIndex: 2);

        await _tap(tester, entry);
        _expectSelection(tester, <int>{});
        expect(
          tester
              .widget<IconButton>(
                find.byWidgetPredicate(
                  (widget) => widget is IconButton && widget.tooltip == '删除',
                ),
              )
              .onPressed,
          isNull,
        );
        await _tap(tester, find.byTooltip('删除'));
        expect(find.byType(AlertDialog), findsNothing);
        expect(fixture.recent.removeCalls, isEmpty);

        await _tap(tester, _textButton('全选'));
        _expectSelection(tester, <int>{0, 1, 2});
        expect(_textButton('取消全选'), findsOneWidget);
        await _tap(tester, _textButton('取消全选'));
        _expectSelection(tester, <int>{});
        await _tap(tester, find.text(_entries[1].title));
        _expectSelection(tester, <int>{1});
        await _tap(tester, find.byTooltip('退出批量操作'));
        expect(find.byType(CheckboxListTile), findsNothing);
        expect(find.text('已选 1 项'), findsNothing);
        await _tap(tester, _textButton('多选'));
        _expectSelection(tester, <int>{});
        expect(
          tester
              .widget<IconButton>(
                find.byWidgetPredicate(
                  (widget) => widget is IconButton && widget.tooltip == '删除',
                ),
              )
              .onPressed,
          isNull,
        );
        expect(fixture.player.calls, 2);

        await _tap(tester, _textButton('全选'));
        await _openDelete(tester, count: 3);
        await _tap(tester, _dialogButton('删除'));
        expect(fixture.recent.removeCalls, <Set<String>>[
          _entries.map((RecentPlaybackEntry entry) => entry.stableId).toSet(),
        ]);
        expect(
          fixture.container.read(recentPlaybackControllerProvider),
          isEmpty,
        );
        expect(find.text('还没有最近播放'), findsOneWidget);
        expect(find.byType(CheckboxListTile), findsNothing);
        expect(find.text('已选 3 项'), findsNothing);
        expect(find.textContaining('清空'), findsNothing);
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant({TargetPlatform.macOS}),
    );

    for (final int count in <int>[1, 2]) {
      testWidgets(
        '$platform long press and checkboxes only select; cancel and confirm $count deletions',
        (WidgetTester tester) async {
          final _Fixture fixture = await _pumpPage(tester, desktop: desktop);
          await tester.longPress(find.text(_entries[0].title));
          await tester.pumpAndSettle();
          _expectSelection(tester, <int>{0});
          expect(find.byTooltip('播放'), findsNothing);
          expect(fixture.player.calls, 0);

          await _tap(tester, _checkbox(1));
          _expectSelection(tester, <int>{0, 1});
          await _tap(tester, find.text(_entries[0].title));
          _expectSelection(tester, <int>{1});
          await _tap(tester, find.text(_entries[0].title));
          if (count == 1) {
            await _tap(tester, _checkbox(1));
          }
          final Set<int> selected = <int>{0, if (count == 2) 1};
          _expectSelection(tester, selected);
          expect(fixture.player.calls, 0);
          expect(
            tester
                .widget<IconButton>(
                  find.byWidgetPredicate(
                    (widget) => widget is IconButton && widget.tooltip == '删除',
                  ),
                )
                .onPressed,
            isNotNull,
          );

          await _openDelete(tester, count: count);
          expect(fixture.recent.removeCalls, isEmpty);
          await _tap(tester, _dialogButton('取消'));
          expect(find.byType(AlertDialog), findsNothing);
          _expectSelection(tester, selected);
          expect(fixture.recent.removeCalls, isEmpty);
          expect(
            fixture.container.read(recentPlaybackControllerProvider),
            _entries,
          );

          await _openDelete(tester, count: count);
          await _tap(tester, _dialogButton('删除'));
          expect(fixture.recent.removeCalls, <Set<String>>[
            selected.map((int index) => _entries[index].stableId).toSet(),
          ]);
          expect(
            fixture.container.read(recentPlaybackControllerProvider),
            _entries.skip(count).toList(),
          );
          for (int index = 0; index < _entries.length; index++) {
            expect(
              find.text(_entries[index].title),
              index < count ? findsNothing : findsOneWidget,
            );
          }
          expect(find.byType(CheckboxListTile), findsNothing);
          expect(find.byTooltip('退出批量操作'), findsNothing);
          expect(_textButton('多选'), findsOneWidget);
          expect(fixture.player.calls, 0);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('$platform failed deletion preserves selection for retry', (
      WidgetTester tester,
    ) async {
      final _Fixture fixture = await _pumpPage(tester, desktop: desktop);
      fixture.recent.failNextRemoval = true;
      await tester.longPress(find.text(_entries[0].title));
      await tester.pumpAndSettle();
      await _tap(tester, _checkbox(1));
      await _openDelete(tester, count: 2);
      await _tap(tester, _dialogButton('删除'));

      final Set<String> selectedIds = <String>{
        _entries[0].stableId,
        _entries[1].stableId,
      };
      expect(fixture.recent.removeCalls, <Set<String>>[selectedIds]);
      expect(
        fixture.container.read(recentPlaybackControllerProvider),
        _entries,
      );
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.widgetWithText(SnackBar, '删除失败，请重试'), findsOneWidget);
      _expectSelection(tester, <int>{0, 1});
      expect(
        tester
            .widget<IconButton>(
              find.byWidgetPredicate(
                (widget) => widget is IconButton && widget.tooltip == '删除',
              ),
            )
            .onPressed,
        isNotNull,
      );
      expect(tester.takeException(), isNull);

      await _openDelete(tester, count: 2);
      await _tap(tester, _dialogButton('删除'));
      expect(fixture.recent.removeCalls, <Set<String>>[
        selectedIds,
        selectedIds,
      ]);
      expect(
        fixture.container.read(recentPlaybackControllerProvider),
        <RecentPlaybackEntry>[_entries[2]],
      );
      expect(find.text(_entries[2].title), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsNothing);
      expect(find.byTooltip('退出批量操作'), findsNothing);
      expect(fixture.player.calls, 0);
      expect(tester.takeException(), isNull);
    });

    for (final bool fail in <bool>[false, true]) {
      testWidgets(
        '$platform deletion completing after disposal is safe ($fail)',
        (WidgetTester tester) async {
          final _Fixture fixture = await _pumpPage(tester, desktop: desktop);
          final Completer<void> removal = Completer<void>();
          fixture.recent.pendingRemoval = removal;
          await _tap(tester, _textButton('多选'));
          await _tap(tester, _checkbox(0));
          await _openDelete(tester, count: 1);
          await tester.tap(_dialogButton('删除'));
          await tester.pump();
          expect(fixture.recent.removeCalls, <Set<String>>[
            <String>{_entries[0].stableId},
          ]);

          await tester.pumpWidget(const SizedBox.shrink());
          if (fail) {
            removal.completeError(StateError('delete failed'));
          } else {
            removal.complete();
          }
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

Future<_Fixture> _pumpPage(WidgetTester tester, {required bool desktop}) async {
  tester.view.physicalSize = desktop
      ? const Size(1200, 800)
      : const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final _RecentPlayback recent = _RecentPlayback();
  final _Player player = _Player();
  final ProviderContainer container = ProviderContainer(
    overrides: [
      recentPlaybackControllerProvider.overrideWith(() => recent),
      playerControllerProvider.overrideWith(() => player),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: desktop
            ? const DesktopRecentPlaybackPage()
            : const RecentPlaybackPage(),
      ),
    ),
  );
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  return _Fixture(container, recent, player);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Finder _textButton(String label) => find.ancestor(
  of: find.text(label),
  matching: find.byWidgetPredicate((Widget widget) => widget is TextButton),
);

Finder _selectionTile(int index) =>
    find.widgetWithText(CheckboxListTile, _entries[index].title);

Finder _checkbox(int index) =>
    find.descendant(of: _selectionTile(index), matching: find.byType(Checkbox));

Finder _dialogButton(String label) =>
    find.descendant(of: find.byType(AlertDialog), matching: find.text(label));

void _expectSelection(WidgetTester tester, Set<int> selected) {
  expect(find.text('已选 ${selected.length} 项'), findsOneWidget);
  expect(find.byType(CheckboxListTile), findsNWidgets(3));
  for (int index = 0; index < _entries.length; index++) {
    final CheckboxListTile tile = tester.widget<CheckboxListTile>(
      _selectionTile(index),
    );
    expect(tile.value, selected.contains(index));
    expect(tile.controlAffinity, ListTileControlAffinity.trailing);
  }
}

Future<void> _openDelete(WidgetTester tester, {required int count}) async {
  await _tap(tester, find.byTooltip('删除'));
  expect(find.byType(AlertDialog), findsOneWidget);
  expect(find.text('删除最近播放？'), findsOneWidget);
  expect(find.text('确定删除选中的 $count 条最近播放记录吗？此操作无法恢复。'), findsOneWidget);
  expect(_dialogButton('取消'), findsOneWidget);
  expect(_dialogButton('删除'), findsOneWidget);
}

void _expectPlayback(
  _Player player, {
  required int calls,
  required int startIndex,
}) {
  expect(player.calls, calls);
  expect(
    player.played,
    _entries
        .map((RecentPlaybackEntry entry) => entry.toPlayableItem())
        .toList(),
  );
  expect(player.startIndex, startIndex);
  expect(player.sourceLabel, '最近播放');
  expect(player.autoplay, isTrue);
}

class _Fixture {
  const _Fixture(this.container, this.recent, this.player);

  final ProviderContainer container;
  final _RecentPlayback recent;
  final _Player player;
}

class _RecentPlayback extends RecentPlaybackController {
  final List<Set<String>> removeCalls = <Set<String>>[];
  bool failNextRemoval = false;
  Completer<void>? pendingRemoval;

  @override
  List<RecentPlaybackEntry> build() => _entries;

  @override
  Future<void> removeEntries(Set<String> stableIds) async {
    removeCalls.add(Set<String>.of(stableIds));
    await pendingRemoval?.future;
    if (failNextRemoval) {
      failNextRemoval = false;
      throw StateError('delete failed');
    }
    if (!ref.mounted) return;
    state = state
        .where(
          (RecentPlaybackEntry entry) => !stableIds.contains(entry.stableId),
        )
        .toList(growable: false);
  }
}

class _Player extends PlayerController {
  int calls = 0;
  List<PlayableItem>? played;
  int? startIndex;
  String? sourceLabel;
  bool? autoplay;

  @override
  PlayerState build() => const PlayerState();

  @override
  Future<void> setQueue(
    List<PlayableItem> items, {
    int startIndex = 0,
    String? sourceLabel,
    bool autoplay = true,
  }) async {
    calls++;
    played = List<PlayableItem>.of(items);
    this.startIndex = startIndex;
    this.sourceLabel = sourceLabel;
    this.autoplay = autoplay;
  }
}
