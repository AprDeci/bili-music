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
import 'package:bilimusic/feature/favorites/ui/components/favorites_metadata_toolbar_buttons.dart';
import 'package:bilimusic/feature/favorites/ui/desktop/desktop_favorite_collection_page.dart';
import 'package:bilimusic/feature/favorites/ui/favorite_collection_page.dart';
import 'package:bilimusic/feature/listening/domain/listening_state.dart';
import 'package:bilimusic/feature/listening/logic/listening_progress_controller.dart';
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
          '$desktop $id empty=$empty switches type without losing view preference',
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
                listeningProgressControllerProvider.overrideWithValue(
                  const ListeningState(),
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
            expect(find.byType(FavoriteCollectionKindSelector), findsOneWidget);
            expect(find.byType(ListeningContinueButton), findsOneWidget);
            expect(find.byType(MetadataViewModeButton), findsNothing);
            expect(find.byType(MetadataBackfillButton), findsNothing);
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
              final ListeningContinueButton button = tester.widget(
                find.byType(ListeningContinueButton),
              );
              expect(button.items.single.kind, CollectionKind.spoken);
              expect(button.items.single.collectionId, id);
              if (desktop) {
                final List<PlayableItem> modified = <PlayableItem>[
                  button.items.single.copyWith(cid: 99, page: 3),
                  button.items.single.copyWith(aid: 2, bvid: 'BV2', cid: 100),
                ];
                await button.onPlay(modified, 1);
                final _Player player =
                    container.read(playerControllerProvider.notifier)
                        as _Player;
                expect(player.played, modified);
                expect(player.startIndex, 1);
                expect(player.sourceLabel, collection.name);
              }
            }
            await tester.tap(find.byType(FavoriteCollectionKindSelector));
            await tester.pumpAndSettle();
            await tester.tap(
              find.widgetWithText(CheckedPopupMenuItem<CollectionKind>, '歌曲'),
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
            expect(find.byType(ListeningContinueButton), findsNothing);
            expect(
              find.byType(MetadataViewModeButton),
              empty ? findsNothing : findsOneWidget,
            );
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
