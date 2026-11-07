import 'dart:io';

import 'package:bilimusic/feature/download/logic/download_controller.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_view_mode_logic.dart';
import 'package:bilimusic/feature/favorites/ui/desktop/desktop_favorite_collection_page.dart';
import 'package:bilimusic/feature/favorites/ui/favorite_collection_page.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_backfill_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_backfill_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/statistics/data/statistics_local_repository.dart';
import 'package:bilimusic/feature/statistics/logic/statistics_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory directory;
  late Box<Map> box;
  late StatisticsTracker tracker;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'favorite_batch_download_',
    );
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

  for (final bool desktop in <bool>[false, true]) {
    for (final bool fails in <bool>[false, true]) {
      testWidgets(
        'batch downloads selected songs desktop=$desktop fails=$fails',
        (WidgetTester tester) async {
          await tester.binding.setSurfaceSize(Size(desktop ? 1200 : 320, 800));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final _Downloads downloads = _Downloads(fails: fails);
          final DateTime now = DateTime(2026);
          final FavoriteCollection collection = FavoriteCollection(
            id: 'local',
            name: '本地歌单',
            source: FavoriteCollectionSource.local,
            createdAt: now,
            updatedAt: now,
          );
          final List<FavoriteEntry> entries = <FavoriteEntry>[
            for (int i = 1; i <= 2; i++)
              FavoriteEntry(
                itemId: 'item-$i',
                aid: i,
                bvid: 'BV$i',
                cid: i * 10,
                page: i,
                title: '歌曲 $i',
                author: '作者',
                coverUrl: '',
                createdAt: now,
                updatedAt: now,
              ),
          ];
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                playerControllerProvider.overrideWith(_Player.new),
                statisticsTrackerProvider.overrideWithValue(tracker),
                favoritesControllerProvider.overrideWithValue(
                  FavoritesState(
                    collections: [collection],
                    entries: entries,
                    memberships: <FavoriteMembership>[
                      for (final entry in entries)
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
                home: desktop
                    ? DesktopFavoriteCollectionPage(collectionId: collection.id)
                    : FavoriteCollectionPage(collectionId: collection.id),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.longPress(find.text('歌曲 1'));
          await tester.pumpAndSettle();
          expect(find.text('已选 1 项'), findsOneWidget);
          expect(
            desktop ? find.text('添加') : find.byTooltip('添加到歌单'),
            findsOneWidget,
          );
          expect(
            desktop ? find.text('删除') : find.byTooltip('删除'),
            findsOneWidget,
          );
          await tester.tap(find.text('歌曲 1'));
          await tester.pumpAndSettle();
          expect(find.text('已选 0 项'), findsOneWidget);
          final Finder download = desktop
              ? find.widgetWithText(OutlinedButton, '下载')
              : find.byWidgetPredicate(
                  (widget) =>
                      widget is IconButton && widget.tooltip == '下载所选歌曲',
                );
          expect(
            desktop
                ? tester.widget<OutlinedButton>(download).onPressed
                : tester.widget<IconButton>(download).onPressed,
            isNull,
          );
          await tester.tap(find.text('歌曲 2'));
          await tester.pumpAndSettle();
          await tester.tap(download);
          await tester.pumpAndSettle();
          expect(downloads.items, <PlayableItem>[
            entries.last.toPlayableItem(collection: collection),
          ]);
          expect(
            find.text(fails ? '加入下载队列失败，请重试' : '已加入 1 首歌曲到下载队列'),
            findsOneWidget,
          );
          expect(find.text('已选 1 项'), fails ? findsOneWidget : findsNothing);
          expect(tester.takeException(), isNull);
          final Future<void> dismiss = SmartDialog.dismiss(
            status: SmartStatus.toast,
          );
          await tester.pumpAndSettle();
          await dismiss;
          await tester.pump(const Duration(seconds: 3));
          await tester.pumpAndSettle();
        },
      );
    }
  }
}

class _Player extends PlayerController {
  @override
  PlayerState build() => const PlayerState();
}

class _Downloads extends DownloadController {
  _Downloads({required this.fails});

  final bool fails;
  List<PlayableItem> items = <PlayableItem>[];

  @override
  DownloadState build() => const DownloadState();

  @override
  Future<int> downloadAll(List<PlayableItem> selectedItems) async {
    items = selectedItems;
    if (fails) {
      throw StateError('storage unavailable');
    }
    return selectedItems.length;
  }
}
