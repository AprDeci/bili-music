import 'dart:io';

import 'package:bilimusic/feature/download/logic/download_controller.dart';
import 'package:bilimusic/feature/player/data/chapter_cache_repository.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';

import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorite_collection_search_field.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorites_metadata_toolbar_buttons.dart';
import 'package:bilimusic/feature/favorites/ui/desktop/desktop_favorite_collection_page.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_backfill_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_backfill_controller.dart';
import 'package:bilimusic/feature/favorites/logic/favorite_entry_metadata.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_view_mode_logic.dart';
import 'package:bilimusic/feature/favorites/ui/components/desktop/desktop_favorite_collection_items_list.dart';
import 'package:bilimusic/feature/statistics/data/statistics_local_repository.dart';
import 'package:bilimusic/feature/statistics/logic/statistics_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hive_ce/hive.dart';

class _Player extends PlayerController {
  @override
  PlayerState build() => const PlayerState();
}

void main() {
  late Directory directory;
  late Box<Map> box;
  late StatisticsTracker tracker;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('desktop_favorite_rows_');
    Hive.init(directory.path);
    await Hive.openBox<String>(chapterCacheBoxName);
    box = await Hive.openBox<Map>('statistics');
    tracker = StatisticsTracker(
      const Stream.empty(),
      StatisticsLocalRepository(box),
    );
  });

  tearDown(() async {
    await tracker.dispose();
    await box.close();
    await Hive.box<String>(chapterCacheBoxName).close();
    await directory.delete(recursive: true);
  });

  testWidgets('desktop search leaves equal spacing between toolbar buttons', (
    WidgetTester tester,
  ) async {
    final DateTime now = DateTime.now();
    final FavoriteCollection collection = FavoriteCollection(
      id: 'remote:1',
      name: '测试收藏夹',
      source: FavoriteCollectionSource.remote,
      lastSyncedAt: now,
      createdAt: now,
      updatedAt: now,
    );
    final FavoriteEntry entry = FavoriteEntry(
      itemId: 'item-1',
      aid: 1,
      bvid: 'BV1',
      title: '测试歌曲',
      author: '测试歌手',
      coverUrl: '',
      createdAt: now,
      updatedAt: now,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerControllerProvider.overrideWith(_Player.new),
          statisticsTrackerProvider.overrideWithValue(tracker),
          favoritesControllerProvider.overrideWithValue(
            FavoritesState(
              collections: [collection],
              entries: [entry],
              memberships: [
                FavoriteMembership.create(
                  collectionId: collection.id,
                  itemId: entry.itemId,
                  addedAt: now,
                ),
              ],
            ),
          ),
          favoritesViewModeLogicProvider(
            collection.id,
          ).overrideWithValue(FavoriteListViewMode.video),
          metadataBackfillControllerProvider.overrideWithValue(
            const MetadataBackfillState(),
          ),
        ],
        child: MaterialApp(
          home: DesktopFavoriteCollectionPage(collectionId: collection.id),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Rect search = tester.getRect(
      find.byType(FavoriteCollectionSearchField),
    );
    final Rect view = tester.getRect(find.byType(MetadataViewModeButton));
    final Rect backfill = tester.getRect(find.byType(MetadataBackfillButton));
    final Rect sync = tester.getRect(find.byTooltip('同步网络歌单'));
    expect(view.left - search.right, 8);
    expect(backfill.left - view.right, 8);
    expect(sync.left - backfill.right, 8);
    expect(view.size, backfill.size);
    expect(sync.size, view.size);
    expect(tester.takeException(), isNull);
  });

  for (final bool queued in <bool>[true, false]) {
    testWidgets('desktop download action reports queued=$queued', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final DateTime now = DateTime.now();
      final FavoriteCollection collection = FavoriteCollection(
        id: 'local',
        name: '测试收藏夹',
        source: FavoriteCollectionSource.local,
        createdAt: now,
        updatedAt: now,
      );
      final FavoriteEntry entry = FavoriteEntry(
        itemId: 'item-1',
        aid: 1,
        bvid: 'BV1',
        cid: 10,
        page: 2,
        pageTitle: '第二首',
        title: '测试歌曲',
        author: '测试歌手',
        coverUrl: '',
        createdAt: now,
        updatedAt: now,
      );
      final _Downloads downloads = _Downloads(queued);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerControllerProvider.overrideWith(_Player.new),
            statisticsTrackerProvider.overrideWithValue(tracker),
            favoritesControllerProvider.overrideWithValue(
              FavoritesState(
                collections: [collection],
                entries: [entry],
                memberships: [
                  FavoriteMembership.create(
                    collectionId: collection.id,
                    itemId: entry.itemId,
                    addedAt: now,
                  ),
                ],
              ),
            ),
            favoritesViewModeLogicProvider(
              collection.id,
            ).overrideWithValue(FavoriteListViewMode.video),
            metadataBackfillControllerProvider.overrideWithValue(
              const MetadataBackfillState(),
            ),
            downloadControllerProvider.overrideWith(() => downloads),
          ],
          child: MaterialApp(
            builder: FlutterSmartDialog.init(),
            home: DesktopFavoriteCollectionPage(collectionId: collection.id),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('更多'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, '下载'), findsOneWidget);
      await tester.tap(find.text('下载'));
      await tester.pumpAndSettle();

      expect(downloads.items, <PlayableItem>[
        entry.toPlayableItem(collection: collection),
      ]);
      expect(find.widgetWithText(ListTile, '下载'), findsNothing);
      expect(find.text(queued ? '已加入下载队列' : '已下载或正在下载'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final Future<void> dismiss = SmartDialog.dismiss(
        status: SmartStatus.toast,
      );
      await tester.pumpAndSettle();
      await dismiss;
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });
  }

  for (final Brightness brightness in Brightness.values) {
    for (final FavoriteListViewMode mode in FavoriteListViewMode.values) {
      testWidgets('$brightness $mode restores alternating desktop rows', (
        WidgetTester tester,
      ) async {
        final ThemeData theme = ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: brightness,
          ),
          scaffoldBackgroundColor: brightness == Brightness.light
              ? Colors.white
              : Colors.black,
        );
        final List<FavoriteEntry> items = List.generate(
          3,
          (int index) => FavoriteEntry(
            itemId: 'item-$index',
            aid: index + 1,
            bvid: 'BV$index',
            title: '视频 $index',
            author: 'UP主 $index',
            coverUrl: '',
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              playerControllerProvider.overrideWith(_Player.new),
              statisticsTrackerProvider.overrideWithValue(tracker),
              for (final FavoriteEntry item in items)
                favoriteEntryMetadataProvider(
                  item.contentId,
                ).overrideWith((ref) async => null),
            ],
            child: MaterialApp(
              theme: theme,
              home: Scaffold(
                body: DesktopFavoriteCollectionItemsList(
                  items: items,
                  footer: const SizedBox.shrink(),
                  onNotification: (_) => false,
                  selectedItemIds: const {},
                  selectionMode: false,
                  onSelectionModeChanged: (_) {},
                  onSelectionChanged: (_) {},
                  onTapItem: (_, _) {},
                  onPlayItem: (_, _) {},
                  onMoreItem: (_, _) {},
                  viewMode: mode,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final List<Ink> rows = tester
            .widgetList<Ink>(
              find.descendant(
                of: find.byType(ListTile),
                matching: find.byType(Ink),
              ),
            )
            .toList();
        expect(rows, hasLength(3));
        for (int index = 0; index < rows.length; index++) {
          final ShapeDecoration decoration =
              rows[index].decoration! as ShapeDecoration;
          expect(
            decoration.color,
            index.isEven
                ? Colors.transparent
                : Color.alphaBlend(
                    const Color(0xFFBDBDBD).withValues(alpha: 0.1),
                    theme.colorScheme.surface,
                  ),
          );
          expect(
            decoration.shape,
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          );
        }
        for (final Element element in find.byType(ListTile).evaluate()) {
          expect(Material.of(element).color, Colors.transparent);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}

class _Downloads extends DownloadController {
  _Downloads(this.queued);

  final bool queued;
  final List<PlayableItem> items = <PlayableItem>[];

  @override
  DownloadState build() => const DownloadState();

  @override
  Future<bool> download(PlayableItem item) async {
    items.add(item);
    return queued;
  }
}
