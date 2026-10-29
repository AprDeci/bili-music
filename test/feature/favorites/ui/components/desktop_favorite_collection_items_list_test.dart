import 'dart:io';

import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
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
