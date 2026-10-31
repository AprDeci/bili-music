import 'package:bilimusic/common/components/common_attach_menu.dart';
import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/profile/ui/desktop_profile_sidebar.dart';
import 'package:bilimusic/feature/profile/ui/profile_page.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:bilimusic/feature/recent/logic/recent_playback_controller.dart';
import 'package:bilimusic/feature/up/domain/favorite_up.dart';
import 'package:bilimusic/feature/up/logic/favorite_up_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final bool desktop in <bool>[true, false]) {
    for (final String id in <String>[
      'local',
      'remote:1',
      FavoriteCollection.likedCollectionId,
    ]) {
      testWidgets(
        '${desktop ? 'desktop secondary-click' : 'mobile long-press'} $id keeps types last and changes kind',
        (WidgetTester tester) async {
          tester.view.physicalSize = desktop
              ? const Size(1000, 800)
              : const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final DateTime now = DateTime(2026);
          final FavoriteCollection collection = FavoriteCollection(
            id: id,
            name: '测试歌单',
            source: id.startsWith('remote:')
                ? FavoriteCollectionSource.remote
                : FavoriteCollectionSource.local,
            remoteId: id.startsWith('remote:') ? '1' : null,
            isSystem: id == FavoriteCollection.likedCollectionId,
            createdAt: now,
            updatedAt: now,
          );
          final ProviderContainer container = ProviderContainer(
            overrides: [
              favoritesControllerProvider.overrideWith(
                () => _Favorites(FavoritesState(collections: [collection])),
              ),
              biliSessionControllerProvider.overrideWithValue(null),
              favoriteUpControllerProvider.overrideWithValue(
                const <FavoriteUp>[],
              ),
              recentPlaybackControllerProvider.overrideWithValue(
                const <RecentPlaybackEntry>[],
              ),
            ],
          );
          addTearDown(container.dispose);
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                builder: desktop ? FlutterSmartDialog.init() : null,
                home: desktop
                    ? const Scaffold(
                        body: Align(
                          alignment: Alignment.centerLeft,
                          child: DesktopProfileSidebar(
                            currentLocation: '/profile',
                          ),
                        ),
                      )
                    : const ProfilePage(),
              ),
            ),
          );
          if (desktop) {
            addTearDown(() async {
              final Future<void> dismiss = SmartDialog.dismiss();
              await tester.pumpAndSettle();
              await dismiss;
            });
          }
          await tester.pumpAndSettle();
          if (collection.isLocal && !collection.isSystem) {
            await tester.tap(find.text('本地歌单'));
            await tester.pumpAndSettle();
          }
          final Finder collectionTile = find.text(
            collection.isSystem ? (desktop ? '喜欢·0' : '收藏') : collection.name,
          );
          final List<String> actions = <String>[
            if (!collection.isSystem) '重命名',
            if (desktop && collection.isRemote) '同步',
            if (collection.isRemote) '移除',
            if (!collection.isSystem) '删除',
            '歌曲',
            '听声',
          ];
          for (final CollectionKind kind in <CollectionKind>[
            CollectionKind.spoken,
            CollectionKind.music,
          ]) {
            if (desktop) {
              await tester.tap(
                collectionTile,
                kind: PointerDeviceKind.mouse,
                buttons: kSecondaryMouseButton,
              );
            } else {
              await tester.longPress(collectionTile);
            }
            await tester.pumpAndSettle();
            final Finder menuText = find.descendant(
              of: find.byWidgetPredicate(
                (Widget widget) => desktop
                    ? widget is CommonAttachMenu<Object?>
                    : widget is PopupMenuEntry<Object?>,
              ),
              matching: find.byType(Text),
            );
            final List<String> renderedActions = tester
                .widgetList<Text>(menuText)
                .map((Text text) => text.data!)
                .toList();
            expect(renderedActions, actions);
            for (int index = 1; index < actions.length; index++) {
              expect(
                tester.getCenter(find.text(actions[index - 1])).dy,
                lessThan(tester.getCenter(find.text(actions[index])).dy),
              );
            }
            await tester.tap(
              desktop
                  ? find.text(kind.label)
                  : find.ancestor(
                      of: find.text(kind.label),
                      matching: find.byWidgetPredicate(
                        (Widget widget) =>
                            widget is CheckedPopupMenuItem<Object?>,
                      ),
                    ),
            );
            await tester.pumpAndSettle();
            expect(
              container
                  .read(favoritesControllerProvider)
                  .collections
                  .single
                  .kind,
              kind,
            );
            expect(find.text('听声'), findsNothing);
          }
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }
}

class _Favorites extends FavoritesController {
  _Favorites(this.initial);

  final FavoritesState initial;

  @override
  FavoritesState build() => initial;

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
