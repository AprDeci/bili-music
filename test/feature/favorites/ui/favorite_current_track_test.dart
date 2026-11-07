import 'package:bilimusic/common/components/selectable_auto_scroll_list_view.dart';
import 'package:bilimusic/core/layout/shell_content_insets.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorite_entry_metadata.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_view_mode_logic.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorite_current_track_overlay.dart';
import 'package:bilimusic/feature/favorites/ui/desktop/desktop_favorite_collection_page.dart';
import 'package:bilimusic/feature/favorites/ui/favorite_collection_page.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_backfill_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_backfill_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/chapters/chapter_cache_provider.dart';
import 'package:bilimusic/feature/statistics/domain/song_statistics.dart';
import 'package:bilimusic/feature/statistics/logic/statistics_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';

final DateTime _now = DateTime(2026);
final FavoriteCollection _collection = FavoriteCollection(
  id: 'local',
  name: '测试歌单',
  source: FavoriteCollectionSource.local,
  createdAt: _now,
  updatedAt: _now,
);
final List<FavoriteEntry> _entries = List<FavoriteEntry>.generate(
  100,
  (int index) => FavoriteEntry(
    itemId: 'bvid:BV$index',
    aid: index + 1,
    bvid: 'BV$index',
    title: '歌曲 $index',
    author: '作者',
    coverUrl: '',
    createdAt: _now,
    updatedAt: _now,
  ),
);

void main() {
  test('matches resolved cid and missing cid without mixing parts', () {
    final FavoriteEntry part1 = _entries.first.copyWith(
      itemId: 'first',
      page: 1,
      cid: 10,
    );
    final FavoriteEntry part2 = part1.copyWith(
      itemId: 'second',
      page: 2,
      cid: 20,
    );
    final List<FavoriteEntry> parts = <FavoriteEntry>[part1, part2];
    expect(findCurrentFavoriteEntry(parts, null), isNull);
    expect(findCurrentFavoriteEntry(parts, part2.toPlayableItem()), part2);
    expect(
      findCurrentFavoriteEntry(
        parts,
        part2.toPlayableItem().copyWith(cid: null),
      ),
      part2,
    );
    expect(
      findCurrentFavoriteEntry(parts, part2.toPlayableItem().copyWith(cid: 30)),
      isNull,
    );
    expect(
      findCurrentFavoriteEntry(<FavoriteEntry>[
        _entries.first,
      ], _entries.first.toPlayableItem().copyWith(cid: 10)),
      _entries.first,
    );
  });

  for (final bool desktop in <bool>[false, true]) {
    for (final FavoriteListViewMode mode in FavoriteListViewMode.values) {
      testWidgets(
        'locates repeatedly and clears filtered search $desktop $mode',
        (WidgetTester tester) async {
          final _Player player = await _pumpPage(tester, desktop, mode);
          final Finder button = find.byTooltip('定位当前播放');
          final Finder list = find.byType(
            SelectableAutoScrollListView<FavoriteEntry, String>,
          );
          final Finder target = find.text('歌曲 70');
          expect(target, findsNothing);
          expect(tester.getSize(button), const Size(48, 48));
          final Finder icon = find.descendant(
            of: button,
            matching: find.byType(HugeIcon),
          );
          expect(
            tester.widget<HugeIcon>(icon).icon,
            HugeIcons.strokeRoundedCircleDot,
          );
          final Finder surface = find
              .ancestor(of: icon, matching: find.byType(Material))
              .first;
          expect(tester.getSize(surface), const Size(30, 30));
          final Material material = tester.widget<Material>(surface);
          final Color primary = Theme.of(
            tester.element(button),
          ).colorScheme.primary;
          expect(material.color, primary.withValues(alpha: 0.12));
          expect(material.elevation, 0);
          expect(tester.widget<HugeIcon>(icon).size, 18);
          expect(tester.getSemantics(button).tooltip, '定位当前播放');
          final Rect buttonRect = tester.getRect(button);
          expect(buttonRect.bottom, lessThanOrEqualTo(640));
          expect(buttonRect.right, (desktop ? 1100 : 320) - 14);
          final PlayerState original = player.state;
          for (int attempt = 0; attempt < 2; attempt++) {
            await tester.tap(button);
            await tester.pumpAndSettle();
            expect(target, findsOneWidget);
            final Rect row = tester.getRect(target);
            final Rect viewport = tester.getRect(list);
            expect(row.center.dy, inExclusiveRange(viewport.top, 640));
            expect(player.state, same(original));
            await tester.drag(list, const Offset(0, 6500));
            await tester.pumpAndSettle();
          }
          await tester.enterText(find.byType(TextField), 'no results');
          await tester.pumpAndSettle();
          expect(list, findsNothing);
          expect(button, findsOneWidget);
          await tester.tap(button);
          await tester.pumpAndSettle();
          expect(
            tester.widget<TextField>(find.byType(TextField)).controller!.text,
            '',
          );
          expect(target, findsOneWidget);
          expect(player.state, same(original));
          await tester.longPress(target);
          await tester.pumpAndSettle();
          expect(button, findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      'tracks current song and hides for absent or empty player $desktop',
      (WidgetTester tester) async {
        final _Player player = await _pumpPage(
          tester,
          desktop,
          FavoriteListViewMode.video,
        );
        final Finder button = find.byTooltip('定位当前播放');
        player.change(_entries[40].toPlayableItem());
        await tester.pumpAndSettle();
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(find.text('歌曲 40'), findsOneWidget);
        player.change(_entries.first.toPlayableItem().copyWith(bvid: 'absent'));
        await tester.pumpAndSettle();
        expect(button, findsNothing);
        player.change(null);
        await tester.pumpAndSettle();
        expect(button, findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Future<_Player> _pumpPage(
  WidgetTester tester,
  bool desktop,
  FavoriteListViewMode mode,
) async {
  await tester.binding.setSurfaceSize(Size(desktop ? 1100 : 320, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final _Player player = _Player();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        playerControllerProvider.overrideWith(() => player),
        statisticsTrackerProvider.overrideWithValue(_Statistics()),
        favoritesControllerProvider.overrideWithValue(
          FavoritesState(
            collections: <FavoriteCollection>[_collection],
            entries: _entries,
            memberships: <FavoriteMembership>[
              for (final FavoriteEntry entry in _entries)
                FavoriteMembership.create(
                  collectionId: _collection.id,
                  itemId: entry.itemId,
                  addedAt: _now,
                ),
            ],
          ),
        ),
        favoritesViewModeLogicProvider(_collection.id).overrideWithValue(mode),
        metadataBackfillControllerProvider.overrideWithValue(
          const MetadataBackfillState(),
        ),
        for (final FavoriteEntry entry in _entries)
          itemIsCompilationProvider(
            entry.toPlayableItem(),
          ).overrideWithValue(false),
        for (final FavoriteEntry entry in _entries)
          favoriteEntryMetadataProvider(
            entry.contentId,
          ).overrideWith((ref) async => null),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(desktop ? 1100 : 320, 800),
            padding: const EdgeInsets.only(bottom: 160),
          ),
          child: ShellContentInsets(
            child: desktop
                ? DesktopFavoriteCollectionPage(collectionId: _collection.id)
                : FavoriteCollectionPage(collectionId: _collection.id),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return player;
}

class _Player extends PlayerController {
  @override
  PlayerState build() => PlayerState(
    currentItem: _entries[70].toPlayableItem().copyWith(cid: 700),
    position: const Duration(seconds: 42),
  );

  void change(PlayableItem? item) => state = state.copyWith(currentItem: item);
}

class _Statistics implements StatisticsTracker {
  @override
  SongStatistics? read(String stableId) => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
