import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/favorites/ui/favorite_collection_page.dart';
import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:bilimusic/feature/up/logic/favorite_up_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('liked collection only exposes songs and UP tabs', (
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
          favoriteUpControllerProvider.overrideWithValue(const <FavoriteUp>[]),
        ],
        child: const MaterialApp(
          home: FavoriteCollectionPage(
            collectionId: FavoriteCollection.likedCollectionId,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(Tab, '歌曲'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'UP主'), findsOneWidget);
    expect(find.text('合集'), findsNothing);

    await tester.tap(find.text('UP主'));
    await tester.pumpAndSettle();
    expect(find.text('还没有收藏UP主'), findsOneWidget);
  });
}
