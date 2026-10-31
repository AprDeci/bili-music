import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_entry.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_membership.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/domain/favorited_season.dart';
import 'package:bilimusic/feature/favorites/logic/favorite_entry_metadata.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_view_mode_logic.dart';
import 'package:bilimusic/feature/favorites/logic/favorited_season_controller.dart';
import 'package:bilimusic/feature/favorites/ui/components/desktop/desktop_favorite_collection_items_list.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorite_collection_items_list.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorite_collection_kind_selector.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorite_collection_search_field.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorites_metadata_toolbar_buttons.dart';
import 'package:bilimusic/feature/favorites/ui/desktop/desktop_favorite_collection_page.dart';
import 'package:bilimusic/feature/favorites/ui/favorite_collection_page.dart';
import 'package:bilimusic/feature/listening/ui/listening_continue_button.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_backfill_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_backfill_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/statistics/domain/song_statistics.dart';
import 'package:bilimusic/feature/statistics/logic/statistics_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final bool desktop in <bool>[false, true]) {
    for (final String id in <String>[
      'local',
      'remote:1',
      FavoriteCollection.likedCollectionId,
    ]) {
      for (final bool empty in <bool>[false, true]) {
        testWidgets(
          '$desktop $id empty=$empty preserves the original header across type changes',
          (tester) async {
            if (!desktop) {
              tester.view.physicalSize = const Size(320, 568);
              tester.view.devicePixelRatio = 1;
              addTearDown(tester.view.resetPhysicalSize);
              addTearDown(tester.view.resetDevicePixelRatio);
            }
            final DateTime now = DateTime(2026);
            final FavoriteCollection collection = FavoriteCollection(
              id: id,
              name: '测试收藏',
              source: id.startsWith('remote:')
                  ? FavoriteCollectionSource.remote
                  : FavoriteCollectionSource.local,
              remoteId: id.startsWith('remote:') ? '1' : null,
              lastSyncedAt: now,
              isSystem: id == 'liked',
              kind: CollectionKind.spoken,
              createdAt: now,
              updatedAt: now,
            );
            final FavoriteEntry entry = FavoriteEntry(
              itemId: 'bvid:BV1:cid:10',
              aid: 1,
              bvid: 'BV1',
              cid: 10,
              title: '原始标题',
              author: 'UP主',
              coverUrl: '',
              createdAt: now,
              updatedAt: now,
            );
            final container = ProviderContainer(
              overrides: [
                favoritesControllerProvider.overrideWith(
                  () => _Favorites(
                    FavoritesState(
                      collections: <FavoriteCollection>[collection],
                      entries: <FavoriteEntry>[if (!empty) entry],
                      memberships: <FavoriteMembership>[
                        if (!empty)
                          FavoriteMembership.create(
                            collectionId: id,
                            itemId: entry.itemId,
                            addedAt: now,
                          ),
                      ],
                    ),
                  ),
                ),
                favoritesViewModeLogicProvider(
                  id,
                ).overrideWithValue(FavoriteListViewMode.metadata),
                favoriteEntryMetadataProvider(
                  entry.contentId,
                ).overrideWith((ref) async => null),
                metadataBackfillControllerProvider.overrideWithValue(
                  const MetadataBackfillState(),
                ),
                favoritedSeasonControllerProvider.overrideWithValue(
                  const <FavoritedSeason>[],
                ),
                statisticsTrackerProvider.overrideWithValue(_Statistics()),
                playerControllerProvider.overrideWith(_Player.new),
              ],
            );
            addTearDown(container.dispose);
            await tester.pumpWidget(
              UncontrolledProviderScope(
                container: container,
                child: MaterialApp(
                  home: desktop
                      ? DesktopFavoriteCollectionPage(collectionId: id)
                      : FavoriteCollectionPage(collectionId: id),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(find.byType(FavoriteCollectionKindSelector), findsNothing);
            expect(find.byType(ListeningContinueButton), findsNothing);
            expect(
              find.byType(FavoriteCollectionSearchField),
              empty ? findsNothing : findsOneWidget,
            );
            expect(find.byType(MetadataViewModeButton), findsNothing);
            expect(find.byType(MetadataBackfillButton), findsNothing);
            if (id == FavoriteCollection.likedCollectionId) {
              expect(find.text('歌曲'), findsOneWidget);
              expect(find.text('听声'), findsNothing);
            }
            if (!empty) {
              final FavoriteListViewMode mode = desktop
                  ? tester
                        .widget<DesktopFavoriteCollectionItemsList>(
                          find.byType(DesktopFavoriteCollectionItemsList),
                        )
                        .viewMode
                  : tester
                        .widget<FavoriteCollectionItemsList>(
                          find.byType(FavoriteCollectionItemsList),
                        )
                        .viewMode;
              expect(mode, FavoriteListViewMode.video);
              if (desktop) {
                final list = tester.widget<DesktopFavoriteCollectionItemsList>(
                  find.byType(DesktopFavoriteCollectionItemsList),
                );
                list.onPlayItem(0, entry);
                await tester.pumpAndSettle();
                final _Player player =
                    container.read(playerControllerProvider.notifier)
                        as _Player;
                expect(player.played!.single.kind, CollectionKind.spoken);
                expect(player.played!.single.collectionId, id);
                expect(player.startIndex, 0);
                expect(player.sourceLabel, collection.name);
              }
            }
            await container
                .read(favoritesControllerProvider.notifier)
                .setCollectionKind(
                  collectionId: id,
                  kind: CollectionKind.music,
                );
            await tester.pumpAndSettle();
            expect(
              container
                  .read(favoritesControllerProvider)
                  .collections
                  .single
                  .kind,
              CollectionKind.music,
            );
            expect(
              container.read(favoritesViewModeLogicProvider(id)),
              FavoriteListViewMode.metadata,
            );
            expect(find.byType(FavoriteCollectionKindSelector), findsNothing);
            expect(find.byType(ListeningContinueButton), findsNothing);
            expect(
              find.byType(MetadataViewModeButton),
              empty ? findsNothing : findsOneWidget,
            );
            expect(
              find.byType(MetadataBackfillButton),
              empty ? findsNothing : findsOneWidget,
            );
            if (!empty) {
              final Rect search = tester.getRect(
                find.byType(FavoriteCollectionSearchField),
              );
              final Rect view = tester.getRect(
                find.byType(MetadataViewModeButton),
              );
              final Rect backfill = tester.getRect(
                find.byType(MetadataBackfillButton),
              );
              expect(search.center.dy, view.center.dy);
              expect(view.center.dy, backfill.center.dy);
              expect(view.left - search.right, desktop ? 8 : 6);
              expect(backfill.left - view.right, desktop ? 8 : 2);
              await tester.enterText(find.byType(TextField), 'no match');
              await tester.pumpAndSettle();
              expect(find.byType(MetadataViewModeButton), findsOneWidget);
              expect(find.byType(MetadataBackfillButton), findsOneWidget);
            }
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox.shrink());
          },
        );
      }
    }
  }
}

class _Favorites extends FavoritesController {
  _Favorites(this.initial);
  final FavoritesState initial;

  @override
  FavoritesState build() => initial;

  @override
  Future<RemoteCollectionSyncResult> syncRemoteCollectionIfStale(
    String collectionId, {
    bool force = false,
  }) async => RemoteCollectionSyncResult.skipped;

  @override
  Future<bool> setCollectionKind({
    required String collectionId,
    required CollectionKind kind,
  }) async {
    state = state.copyWith(
      collections: <FavoriteCollection>[
        for (final FavoriteCollection collection in state.collections)
          if (collection.id == collectionId)
            collection.copyWith(kind: kind)
          else
            collection,
      ],
    );
    return true;
  }
}

class _Statistics implements StatisticsTracker {
  @override
  SongStatistics? read(String stableId) => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Player extends PlayerController {
  List<PlayableItem>? played;
  int? startIndex;
  String? sourceLabel;

  @override
  PlayerState build() => const PlayerState();

  @override
  Future<void> setQueue(
    List<PlayableItem> items, {
    int startIndex = 0,
    String? sourceLabel,
    bool autoplay = true,
  }) async {
    played = items;
    this.startIndex = startIndex;
    this.sourceLabel = sourceLabel;
  }
}
