import 'dart:io';

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
import 'package:hive_ce/hive.dart';

void main() {
  late Directory directory;
  late Box<Map> box;
  late StatisticsTracker tracker;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('desktop_favorite_rows_');
    Hive.init(directory.path);
    box = await Hive.openBox<Map>('statistics');
    tracker = StatisticsTracker(
      const Stream.empty(),
      StatisticsLocalRepository(box),
    );
  });

  tearDown(() async {
    await tracker.dispose();
    await box.close();
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
          favoritesViewModeLogicProvider.overrideWithValue(
            FavoriteListViewMode.video,
          ),
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
