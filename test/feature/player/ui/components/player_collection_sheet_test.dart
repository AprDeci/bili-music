import 'dart:async';

import 'package:bilimusic/common/components/cached_image.dart';
import 'package:bilimusic/common/components/car/car_side_panel.dart';
import 'package:bilimusic/core/layout/app_layout.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/ui/components/player_collection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final layout in [AppLayout.mobile, AppLayout.car]) {
    testWidgets(
      '$layout waits for additions and blocks repeated taps and dismissal',
      (WidgetTester tester) async {
        final Completer<bool> completion = Completer<bool>();
        final _Favorites favorites = _Favorites(
          (int call) =>
              call == 1 ? completion.future : Future<bool>.value(true),
        );
        bool? result;
        await _openBatchSheet(
          tester,
          favorites,
          layout: layout,
          onResult: (bool? value) => result = value,
        );

        final Finder tile = find.ancestor(
          of: find.text('目标歌单'),
          matching: find.byType(InkWell),
        );
        final VoidCallback onTap = tester.widget<InkWell>(tile).onTap!;
        onTap();
        onTap();
        await tester.pump();
        expect(favorites.addedItems, hasLength(1));
        expect(result, isNull);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(find.textContaining('已新增'), findsNothing);

        await tester.tapAt(const Offset(10, 10));
        await tester.pump();
        await tester.binding.handlePopRoute();
        await tester.pump();
        await tester.dragFrom(
          tester.getCenter(find.text('添加 2 首到歌单')),
          const Offset(0, 500),
        );
        await tester.pump();
        expect(find.text('目标歌单'), findsOneWidget);
        expect(result, isNull);

        completion.complete(true);
        await tester.pumpAndSettle();
        expect(favorites.addedItems, hasLength(2));
        expect(result, isTrue);
        expect(find.byType(DraggableScrollableSheet), findsNothing);
        expect(find.byType(CarSidePanel), findsNothing);
        expect(find.text('已新增 2 / 2 项到“目标歌单”'), findsOneWidget);
        await _dismissToast(tester);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final bool throwsError in <bool>[true, false]) {
    testWidgets(
      'keeps partial results and retries after ${throwsError ? 'exception' : 'false result'}',
      (WidgetTester tester) async {
        final _Favorites favorites = _Favorites((int call) async {
          if (call == 2) {
            if (throwsError) throw StateError('private failure details');
            return false;
          }
          return true;
        });
        bool? result;
        await _openBatchSheet(
          tester,
          favorites,
          onResult: (bool? value) => result = value,
        );
        await tester.tap(find.text('目标歌单'));
        await tester.pumpAndSettle();
        expect(result, isNull);
        expect(find.text('目标歌单'), findsOneWidget);
        expect(find.text('已新增 1 / 2 项到“目标歌单”，部分添加失败，请点击歌单重试'), findsOneWidget);
        expect(find.textContaining('private failure details'), findsNothing);
        expect(find.byType(LinearProgressIndicator), findsNothing);

        await tester.tap(find.text('目标歌单'));
        await tester.pumpAndSettle();
        expect(result, isTrue);
        expect(favorites.addedItems.map((PlayableItem item) => item.aid), <int>[
          1,
          2,
          2,
        ]);
        expect(find.text('已新增 1 / 1 项到“目标歌单”'), findsOneWidget);
        await _dismissToast(tester);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('car layout opens a right panel with large readable targets', (
    WidgetTester tester,
  ) async {
    final _Favorites favorites = _Favorites((_) async => true);
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _openBatchSheet(tester, favorites, layout: AppLayout.car);
    final Rect panel = tester.getRect(find.byType(CarSidePanel));
    expect(panel.right, 1256);
    expect(panel.left, greaterThan(1280 - panel.right));
    expect(panel.top, 24);
    expect(panel.bottom, 696);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(DraggableScrollableSheet), findsNothing);
    for (final String label in <String>['网络歌单', '本地歌单', '目标歌单']) {
      final Finder target = find.ancestor(
        of: find.text(label),
        matching: find.byType(InkWell),
      );
      expect(tester.getSize(target).height, greaterThanOrEqualTo(56));
      expect(
        tester.widget<Text>(find.text(label)).style?.fontSize,
        greaterThanOrEqualTo(20),
      );
    }
    expect(tester.widget<Text>(find.text('添加 2 首到歌单')).style?.fontSize, 24);
    expect(tester.widget<Text>(find.text('0 首')).style?.fontSize, 20);
    expect(tester.takeException(), isNull);
  });

  for (final layout in [AppLayout.mobile, AppLayout.desktop]) {
    testWidgets('$layout keeps the bottom sheet even with car styling', (
      tester,
    ) async {
      await _openBatchSheet(
        tester,
        _Favorites((_) async => true),
        layout: layout,
        carStyle: true,
      );
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(CarSidePanel), findsNothing);
      expect(
        tester
            .widget<DraggableScrollableSheet>(
              find.byType(DraggableScrollableSheet),
            )
            .initialChildSize,
        0.75,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('added collection is masked and tapping only shows a toast', (
    WidgetTester tester,
  ) async {
    final DateTime now = DateTime(2026);
    const PlayableItem syncedItem = PlayableItem(
      aid: 1,
      bvid: 'BV1',
      title: 'title',
      author: 'author',
      coverUrl: '',
      page: 1,
    );
    final FavoriteEntry entry = FavoriteEntry.fromPlayableItem(
      syncedItem,
      now: now,
    );
    final FavoritesState state = FavoritesState(
      collections: [
        FavoriteCollection(
          id: 'remote:1',
          name: '云端收藏夹',
          source: FavoriteCollectionSource.remote,
          remoteId: '1',
          itemCount: 29,
          createdAt: now,
          updatedAt: now,
        ),
        FavoriteCollection(
          id: 'remote:2',
          name: '其他收藏夹',
          source: FavoriteCollectionSource.remote,
          remoteId: '2',
          createdAt: now,
          updatedAt: now.subtract(const Duration(days: 1)),
        ),
      ],
      entries: [entry],
      memberships: [
        FavoriteMembership.create(
          collectionId: 'remote:1',
          itemId: entry.itemId,
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [favoritesControllerProvider.overrideWithValue(state)],
        child: MaterialApp(
          builder: FlutterSmartDialog.init(),
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => TextButton(
                onPressed: () => showPlayerCollectionSheet(
                  context: context,
                  item: syncedItem.copyWith(cid: 10),
                ),
                child: const Text('收藏'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('收藏'));
    await tester.pumpAndSettle();

    expect(find.text('添加 1 首到歌单'), findsOneWidget);
    expect(find.text('29 首'), findsOneWidget);
    expect(find.text('已添加'), findsNothing);
    expect(find.byType(CircleAvatar), findsNothing);
    expect(find.byIcon(Icons.add_circle_outline_rounded), findsNothing);
    expect(
      tester.getSize(find.byType(CommonCachedImage).first),
      const Size(48, 48),
    );
    expect(
      tester
          .widget<DraggableScrollableSheet>(
            find.byType(DraggableScrollableSheet),
          )
          .initialChildSize,
      0.5,
    );
    final Finder tile = find.ancestor(
      of: find.text('云端收藏夹'),
      matching: find.byType(InkWell),
    );
    expect(tester.widget<InkWell>(tile).onTap, isNotNull);
    final Finder nextTile = find.ancestor(
      of: find.text('其他收藏夹'),
      matching: find.byType(InkWell),
    );
    expect(tester.getTopLeft(nextTile).dy - tester.getBottomLeft(tile).dy, 8);
    final Finder mask = find.descendant(
      of: tile,
      matching: find.byType(ColorFiltered),
    );
    expect(mask, findsOneWidget);
    expect(
      tester.widget<ColorFiltered>(mask).colorFilter,
      ColorFilter.mode(Colors.grey.withValues(alpha: 0.5), BlendMode.srcATop),
    );
    expect(
      find.descendant(of: mask, matching: find.byType(CommonCachedImage)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: mask, matching: find.text('云端收藏夹')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: mask, matching: find.text('29 首')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: tile,
        matching: find.byWidgetPredicate(
          (Widget widget) =>
              widget is Container && widget.foregroundDecoration != null,
        ),
      ),
      findsNothing,
    );

    await tester.tap(find.text('云端收藏夹'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('已经添加过了'), findsOneWidget);
    final Finder errorIcon = find.byIcon(Icons.error_outline_rounded);
    expect(errorIcon, findsOneWidget);
    expect(tester.widget<Icon>(errorIcon).size, 40);
    expect(
      tester.getBottomLeft(errorIcon).dy,
      lessThan(tester.getTopLeft(find.text('已经添加过了')).dy),
    );
    final Finder toast = find
        .ancestor(
          of: errorIcon,
          matching: find.byWidgetPredicate(
            (Widget widget) => widget is Container && widget.decoration != null,
          ),
        )
        .first;
    expect(tester.getSize(toast).width, greaterThanOrEqualTo(160));
    expect(
      tester.getCenter(toast),
      tester.getCenter(find.byType(Navigator).first),
    );
    expect(find.text('云端收藏夹'), findsOneWidget);
    final Future<void> dismiss = SmartDialog.dismiss(status: SmartStatus.toast);
    await tester.pumpAndSettle();
    await dismiss;
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final Brightness brightness in Brightness.values) {
    testWidgets('cover list and tabs follow $brightness theme', (
      WidgetTester tester,
    ) async {
      final DateTime now = DateTime(2026);
      final ThemeData theme = ThemeData(brightness: brightness);
      final FavoritesState state = FavoritesState(
        collections: [
          FavoriteCollection(
            id: 'local:1',
            name: '纯音乐',
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [favoritesControllerProvider.overrideWithValue(state)],
          child: MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Builder(
                builder: (BuildContext context) => TextButton(
                  onPressed: () => showPlayerCollectionSheet(
                    context: context,
                    item: const PlayableItem(
                      aid: 1,
                      bvid: 'BV1',
                      title: '歌曲',
                      author: '歌手',
                      coverUrl: '',
                    ),
                  ),
                  child: const Text('收藏'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('收藏'));
      await tester.pumpAndSettle();
      expect(find.text('暂无网络歌单'), findsOneWidget);
      await tester.tap(find.text('本地歌单'));
      await tester.pumpAndSettle();

      expect(find.text('纯音乐'), findsOneWidget);
      expect(find.text('0 首'), findsOneWidget);
      expect(find.text('多选'), findsNothing);
      expect(find.byIcon(Icons.library_music_outlined), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('本地歌单')).style?.color,
        theme.colorScheme.primary,
      );
      expect(
        tester.widget<Text>(find.text('添加 1 首到歌单')).style?.color,
        theme.colorScheme.onSurfaceVariant,
      );
      expect(
        tester.widget<Text>(find.text('纯音乐')).style?.fontSize,
        Theme.of(
          tester.element(find.text('纯音乐')),
        ).textTheme.bodyMedium?.fontSize,
      );
      final Finder tile = find.ancestor(
        of: find.text('纯音乐'),
        matching: find.byType(InkWell),
      );
      expect(tester.widget<InkWell>(tile).onTap, isNotNull);
      expect(
        find.descendant(
          of: tile,
          matching: find.byWidgetPredicate(
            (Widget widget) =>
                widget is Container && widget.foregroundDecoration != null,
          ),
        ),
        findsNothing,
      );
      expect(
        tester
            .widget<ColorFiltered>(
              find.descendant(of: tile, matching: find.byType(ColorFiltered)),
            )
            .colorFilter,
        ColorFilter.mode(Colors.grey.withValues(alpha: 0), BlendMode.srcATop),
      );
      final Finder material = find
          .ancestor(of: tile, matching: find.byType(Material))
          .first;
      expect(tester.widget<Material>(material).color, Colors.transparent);
      expect(tester.takeException(), isNull);
    });
  }
}

Future<void> _openBatchSheet(
  WidgetTester tester,
  _Favorites favorites, {
  bool carStyle = false,
  AppLayout layout = AppLayout.mobile,
  ValueChanged<bool?>? onResult,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [favoritesControllerProvider.overrideWith(() => favorites)],
      child: AppLayoutScope(
        layout: layout,
        child: MaterialApp(
          builder: FlutterSmartDialog.init(),
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => TextButton(
                onPressed: () async {
                  final bool? result = await showPlayerCollectionItemsSheet(
                    context: context,
                    items: const <PlayableItem>[
                      PlayableItem(
                        aid: 1,
                        bvid: 'BV1',
                        title: '歌曲1',
                        author: '歌手',
                        coverUrl: '',
                      ),
                      PlayableItem(
                        aid: 2,
                        bvid: 'BV2',
                        title: '歌曲2',
                        author: '歌手',
                        coverUrl: '',
                      ),
                    ],
                    carStyle: carStyle,
                  );
                  onResult?.call(result);
                },
                child: const Text('收藏'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('收藏'));
  await tester.pumpAndSettle();
}

Future<void> _dismissToast(WidgetTester tester) async {
  final Future<void> dismiss = SmartDialog.dismiss(status: SmartStatus.toast);
  await tester.pumpAndSettle();
  await dismiss;
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

class _Favorites extends FavoritesController {
  _Favorites(this.onAdd);

  final Future<bool> Function(int call) onAdd;
  final List<PlayableItem> addedItems = <PlayableItem>[];

  @override
  FavoritesState build() => FavoritesState(
    collections: <FavoriteCollection>[
      FavoriteCollection(
        id: 'remote:1',
        name: '目标歌单',
        source: FavoriteCollectionSource.remote,
        remoteId: '1',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    ],
  );

  @override
  Future<bool> addToCollection({
    required String collectionId,
    required PlayableItem item,
  }) async {
    addedItems.add(item);
    final bool added = await onAdd(addedItems.length);
    if (added) {
      final FavoriteEntry entry = FavoriteEntry.fromPlayableItem(item);
      state = state.copyWith(
        entries: <FavoriteEntry>[...state.entries, entry],
        memberships: <FavoriteMembership>[
          ...state.memberships,
          FavoriteMembership.create(
            collectionId: collectionId,
            itemId: entry.itemId,
          ),
        ],
      );
    }
    return added;
  }
}
