import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/ui/components/player_collection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('synced cloud favorite is checked and cannot be added again', (
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
          createdAt: now,
          updatedAt: now,
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

    expect(find.text('1 首 · 已添加 1 / 1 项'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    final Finder tile = find.ancestor(
      of: find.text('云端收藏夹'),
      matching: find.byType(InkWell),
    );
    expect(tester.widget<InkWell>(tile).onTap, isNull);

    await tester.tap(find.text('云端收藏夹'));
    await tester.pumpAndSettle();
    expect(find.text('云端收藏夹'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
