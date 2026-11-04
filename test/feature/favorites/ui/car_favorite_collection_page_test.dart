import 'package:bilimusic/common/components/car/car_content_widgets.dart';
import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/core/theme/car_theme.dart';
import 'package:bilimusic/core/layout/app_layout.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorite_entry_metadata.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_view_mode_logic.dart';
import 'package:bilimusic/feature/favorites/ui/car/car_favorite_collection_page.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorites_metadata_toolbar_buttons.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

const _items = <PlayableItem>[
  PlayableItem(aid: 1, bvid: 'BV1', title: '视频一', author: '作者一', coverUrl: ''),
  PlayableItem(aid: 2, bvid: 'BV2', title: '视频二', author: '作者二', coverUrl: ''),
];
final _entries = [
  for (final item in _items)
    FavoriteEntry.fromPlayableItem(item, now: DateTime(2026)),
];

void main() {
  testWidgets('video and metadata toggle keeps unresolved entry fallback', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.textContaining('播放全部'), findsNothing);
    expect(find.text('多选'), findsNothing);
    expect(find.text('视频视图'), findsNothing);
    expect(find.text('元数据视图'), findsNothing);
    expect(find.byType(MetadataViewModeButton), findsOneWidget);
    expect(find.byTooltip('切换到元信息视图'), findsOneWidget);
    expect(find.text('视频一'), findsOneWidget);
    expect(find.text('视频二'), findsOneWidget);
    expect(find.text('歌曲一'), findsNothing);

    await tester.tap(find.byTooltip('切换到元信息视图'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('切换到视频视图'), findsOneWidget);
    expect(find.text('歌曲一'), findsOneWidget);
    expect(find.text('歌手一'), findsOneWidget);
    expect(find.text('视频一'), findsNothing);
    expect(find.text('视频二'), findsOneWidget);
    expect(find.text('作者二 · 未解析'), findsOneWidget);
    expect(
      tester
          .widgetList<CarSongTile>(find.byType(CarSongTile))
          .map((tile) => tile.coverUrl),
      everyElement(''),
    );

    await tester.tap(find.byTooltip('切换到视频视图'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('切换到元信息视图'), findsOneWidget);
    expect(find.text('视频一'), findsOneWidget);
    expect(find.text('作者二'), findsOneWidget);
    expect(find.text('歌曲一'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shared car song list has no play-all and keeps the full queue', (
    tester,
  ) async {
    final player = _Player();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [playerControllerProvider.overrideWith(() => player)],
        child: const AppLayoutScope(
          layout: AppLayout.car,
          child: MaterialApp(
            home: Scaffold(
              body: CarSongList(items: _items, sourceLabel: '最近播放'),
            ),
          ),
        ),
      ),
    );
    expect(find.textContaining('播放全部'), findsNothing);
    expect(find.byType(CarSongTile), findsNWidgets(2));
    await tester.tap(find.text('视频二'));
    await tester.pumpAndSettle();
    expect(player.playCount, 1);
    expect(player.queuedItems, _items);
    expect(player.startIndex, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a collection song keeps the full queue', (tester) async {
    final player = _Player();
    await _pump(tester, player: player);
    await tester.tap(find.text('视频二'));
    await tester.pumpAndSettle();
    expect(player.playCount, 1);
    expect(
      player.queuedItems.map((item) => item.stableId),
      _items.map((item) => item.stableId),
    );
    expect(player.startIndex, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('spoken collection stays in video view without toggle', (
    tester,
  ) async {
    final favorites = _Favorites(kind: CollectionKind.spoken);
    await _pump(tester, favorites: favorites);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(CarFavoriteCollectionPage)),
    );
    await container
        .read(favoritesViewModeLogicProvider('local:1').notifier)
        .setViewMode(FavoriteListViewMode.metadata);
    await tester.pumpAndSettle();
    expect(find.text('视频视图'), findsNothing);
    expect(find.text('元数据视图'), findsNothing);
    expect(find.byType(MetadataViewModeButton), findsNothing);
    expect(find.text('视频一'), findsOneWidget);
    expect(find.text('视频二'), findsOneWidget);
    expect(find.text('歌曲一'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long press, select all and deselect never start playback', (
    tester,
  ) async {
    final player = _Player();
    await _pump(tester, player: player);
    await tester.longPress(find.text('视频一'));
    await tester.pumpAndSettle();
    expect(find.text('已选 1 项'), findsOneWidget);
    expect(_checked(tester), 1);
    await tester.tap(find.text('全选'));
    await tester.pumpAndSettle();
    expect(find.text('已选 2 项'), findsOneWidget);
    expect(_checked(tester), 2);
    await tester.tap(find.text('视频一'));
    await tester.pumpAndSettle();
    expect(find.text('已选 1 项'), findsOneWidget);
    expect(_checked(tester), 1);
    await tester.tap(find.text('全选'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('取消全选'));
    await tester.pumpAndSettle();
    expect(find.text('已选 0 项'), findsOneWidget);
    expect(_checked(tester), 0);
    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();
    expect(find.byType(Checkbox), findsNothing);
    expect(find.textContaining('播放全部'), findsNothing);
    expect(player.playCount, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'delete cancellation preserves selection and confirmation removes',
    (tester) async {
      final favorites = _Favorites();
      final player = _Player();
      await _pump(tester, favorites: favorites, player: player);
      await tester.longPress(find.text('视频一'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('全选'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle();
      expect(find.text('确定从“测试歌单”移除 2 项吗？'), findsOneWidget);
      expect(favorites.removedIds, isEmpty);
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('已选 2 项'), findsOneWidget);
      expect(favorites.removedIds, isEmpty);
      expect(_checked(tester), 2);

      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, '删除'));
      await tester.pumpAndSettle();
      expect(
        favorites.removedIds,
        unorderedEquals(_entries.map((e) => e.itemId)),
      );
      expect(favorites.state.itemsForCollection('local:1'), isEmpty);
      expect(find.text('这个歌单还是空的'), findsOneWidget);
      expect(find.byType(Checkbox), findsNothing);
      expect(player.playCount, 0);
      await _dismissToast(tester);
      expect(tester.takeException(), isNull);
    },
  );

  for (final throws in [false, true]) {
    testWidgets(
      'partial delete ${throws ? 'exception' : 'false'} retains failure',
      (tester) async {
        final favorites = _Favorites()
          ..failedId = _entries.last.itemId
          ..throwOnFailure = throws;
        await _pump(tester, favorites: favorites);
        await tester.longPress(find.text('视频一'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('全选'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('删除'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, '删除'));
        await tester.pumpAndSettle();
        expect(find.text('视频一'), findsNothing);
        expect(find.text('视频二'), findsOneWidget);
        expect(find.text('已选 1 项'), findsOneWidget);
        expect(_checked(tester), 1);
        expect(find.text('已移除 1 / 2 项，未移除项已保留选中，请重试。'), findsOneWidget);
        expect(favorites.state.itemsForCollection('local:1'), [_entries.last]);
        await _dismissToast(tester);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'selected songs are added through the shared car playlist sheet',
    (tester) async {
      final favorites = _Favorites();
      await _pump(tester, favorites: favorites);
      await tester.longPress(find.text('视频一'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('添加到歌单'));
      await tester.pumpAndSettle();
      expect(find.text('添加 1 首到歌单'), findsOneWidget);
      await tester.tap(find.text('本地歌单'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('目标歌单'));
      await tester.pumpAndSettle();
      expect(favorites.addedIds, [_entries.first.itemId]);
      expect(favorites.state.itemsForCollection('local:3'), [_entries.first]);
      expect(favorites.state.itemsForCollection('local:1'), _entries);
      expect(find.byType(Checkbox), findsNothing);
      expect(find.text('多选'), findsNothing);
      await _dismissToast(tester);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('switching collection in place resets selection', (tester) async {
    final collectionId = ValueNotifier('local:1');
    addTearDown(collectionId.dispose);
    await _pump(tester, collectionId: collectionId);
    final pageState = tester.state(find.byType(CarFavoriteCollectionPage));
    await tester.longPress(find.text('视频一'));
    await tester.pumpAndSettle();
    expect(find.text('已选 1 项'), findsOneWidget);
    collectionId.value = 'local:2';
    await tester.pumpAndSettle();
    expect(
      tester.state(find.byType(CarFavoriteCollectionPage)),
      same(pageState),
    );
    expect(find.text('另一个歌单'), findsOneWidget);
    expect(find.byType(Checkbox), findsNothing);
    expect(find.text('多选'), findsNothing);
    await tester.longPress(find.text('视频一'));
    await tester.pumpAndSettle();
    expect(find.text('已选 1 项'), findsOneWidget);
    expect(_checked(tester), 1);
    expect(tester.takeException(), isNull);
  });
}

int _checked(WidgetTester tester) => tester
    .widgetList<Checkbox>(find.byType(Checkbox))
    .where((checkbox) => checkbox.value == true)
    .length;

Future<void> _pump(
  WidgetTester tester, {
  _Favorites? favorites,
  _Player? player,
  ValueNotifier<String>? collectionId,
}) async {
  tester.view.physicalSize = const Size(1280, 720);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        favoritesControllerProvider.overrideWith(
          () => favorites ?? _Favorites(),
        ),
        playerControllerProvider.overrideWith(() => player ?? _Player()),
        for (final id in ['local:1', 'local:2'])
          favoritesViewModeLogicProvider(id).overrideWith(_ViewMode.new),
        favoriteEntryMetadataProvider(_entries.first.contentId).overrideWith(
          (ref) async => Metadata(
            stableId: _entries.first.contentId,
            title: ' 歌曲一 ',
            artist: ' 歌手一 ',
          ),
        ),
        favoriteEntryMetadataProvider(
          _entries.last.contentId,
        ).overrideWith((ref) async => null),
      ],
      child: MaterialApp(
        theme: carLightTheme(),
        builder: FlutterSmartDialog.init(),
        home: AppLayoutScope(
          layout: AppLayout.car,
          child: Scaffold(
            body: collectionId == null
                ? const CarFavoriteCollectionPage(collectionId: 'local:1')
                : ValueListenableBuilder<String>(
                    valueListenable: collectionId,
                    builder: (_, id, _) =>
                        CarFavoriteCollectionPage(collectionId: id),
                  ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _dismissToast(WidgetTester tester) async {
  final dismiss = SmartDialog.dismiss(status: SmartStatus.toast);
  await tester.pumpAndSettle();
  await dismiss;
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

class _ViewMode extends FavoritesViewModeLogic {
  @override
  FavoriteListViewMode build(String collectionId) => FavoriteListViewMode.video;

  @override
  Future<void> setViewMode(FavoriteListViewMode mode) async => state = mode;
}

class _Player extends PlayerController {
  int playCount = 0;
  List<PlayableItem> queuedItems = [];
  int? startIndex;

  @override
  PlayerState build() => const PlayerState();

  @override
  Future<void> setQueue(
    List<PlayableItem> items, {
    int startIndex = 0,
    String? sourceLabel,
    bool autoplay = true,
  }) async {
    playCount++;
    queuedItems = items;
    this.startIndex = startIndex;
  }
}

class _Favorites extends FavoritesController {
  _Favorites({this.kind = CollectionKind.music});

  final CollectionKind kind;
  final removedIds = <String>[];
  final addedIds = <String>[];
  String? failedId;
  bool throwOnFailure = false;

  @override
  FavoritesState build() => FavoritesState(
    collections: [
      FavoriteCollection(
        id: 'local:3',
        name: '目标歌单',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
      for (final id in ['local:1', 'local:2'])
        FavoriteCollection(
          id: id,
          name: id == 'local:1' ? '测试歌单' : '另一个歌单',
          kind: kind,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
    ],
    entries: _entries,
    memberships: [
      for (final id in ['local:1', 'local:2'])
        for (final entry in _entries)
          FavoriteMembership.create(
            collectionId: id,
            itemId: entry.itemId,
            addedAt: DateTime(2026),
          ),
    ],
  );

  @override
  Future<bool> addToCollection({
    required String collectionId,
    required PlayableItem item,
  }) async {
    addedIds.add(item.stableId);
    state = state.copyWith(
      memberships: [
        ...state.memberships,
        FavoriteMembership.create(
          collectionId: collectionId,
          itemId: item.stableId,
        ),
      ],
    );
    return true;
  }

  @override
  Future<bool> removeFromCollection({
    required String collectionId,
    required String itemId,
  }) async {
    removedIds.add(itemId);
    if (itemId == failedId) {
      if (throwOnFailure) throw StateError('delete failed');
      return false;
    }
    state = state.copyWith(
      memberships: state.memberships
          .where((m) => m.collectionId != collectionId || m.itemId != itemId)
          .toList(),
    );
    return true;
  }
}
