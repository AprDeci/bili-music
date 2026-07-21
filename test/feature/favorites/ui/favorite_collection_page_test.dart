import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/favorites/ui/favorite_collection_page.dart';
import 'package:bilimusic/feature/favorites/domain/favorited_season.dart';
import 'package:bilimusic/feature/favorites/logic/favorited_season_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('liked collection shows songs and collections tabs', (
    WidgetTester tester,
  ) async {
    final DateTime now = DateTime(2026);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesControllerProvider.overrideWithValue(
            FavoritesState(
              collections: <FavoriteCollection>[
                FavoriteCollection.liked(now: now),
              ],
            ),
          ),
          favoritedSeasonControllerProvider.overrideWithValue(<FavoritedSeason>[
            FavoritedSeason(
              seasonId: 1,
              mid: 2,
              title: '测试合集',
              coverUrl: '',
              total: 3,
              favoritedAtEpochMs: 1,
              updatedAtEpochMs: 1,
              lastSyncedAtEpochMs: 1,
            ),
          ]),
        ],
        child: const MaterialApp(
          home: FavoriteCollectionPage(
            collectionId: FavoriteCollection.likedCollectionId,
          ),
        ),
      ),
    );

    expect(find.text('歌曲'), findsOneWidget);
    expect(find.text('合集'), findsOneWidget);

    await tester.tap(find.text('合集'));
    await tester.pumpAndSettle();

    expect(find.text('测试合集'), findsOneWidget);
    expect(find.text('共 3 个视频'), findsOneWidget);
  });
}
