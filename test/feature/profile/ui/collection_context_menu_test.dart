import 'package:bilimusic/common/components/common_attach_menu.dart';
import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/download/logic/download_controller.dart';
import 'package:bilimusic/feature/favorites/domain/bili_favorite_collection_page.dart';
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
        '${desktop ? 'desktop secondary-click' : 'mobile long-press'} $id opens type dialog and saves only on confirmation',
        (WidgetTester tester) async {
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
          final ProviderContainer container = await _pumpProfile(
            tester,
            desktop: desktop,
            favorites: _Favorites(FavoritesState(collections: [collection])),
          );
          final Finder collectionTile = find.text(
            collection.isSystem ? (desktop ? '喜欢·0' : '收藏') : collection.name,
          );
          final List<String> actions = <String>[
            if (!collection.isSystem) '重命名',
            if (desktop && collection.isRemote) '同步',
            if (collection.isRemote) '移除',
            if (!collection.isSystem) '删除',
            '修改类型',
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
            final CollectionKind currentKind = container
                .read(favoritesControllerProvider)
                .collections
                .single
                .kind;
            expect(find.text('歌曲'), findsNothing);
            expect(find.text('听声'), findsNothing);
            for (int index = 1; index < actions.length; index++) {
              expect(
                tester.getCenter(find.text(actions[index - 1])).dy,
                lessThan(tester.getCenter(find.text(actions[index])).dy),
              );
            }
            await tester.tap(find.text('修改类型'));
            await tester.pumpAndSettle();
            expect(
              tester
                  .widget<RadioGroup<CollectionKind>>(
                    find.byType(RadioGroup<CollectionKind>),
                  )
                  .groupValue,
              currentKind,
            );
            expect(find.textContaining('歌词'), findsNWidgets(2));
            expect(find.textContaining('收听进度'), findsOneWidget);
            await tester.tap(find.text(kind.label));
            await tester.pumpAndSettle();
            expect(
              container
                  .read(favoritesControllerProvider)
                  .collections
                  .single
                  .kind,
              currentKind,
            );
            await tester.tap(find.text('确定'));
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
    testWidgets(
      '${desktop ? 'desktop' : 'mobile'} cancel or unchanged confirmation does not save kind',
      (WidgetTester tester) async {
        final _Favorites favorites = _Favorites(
          FavoritesState(collections: [FavoriteCollection.liked()]),
        );
        final ProviderContainer container = await _pumpProfile(
          tester,
          desktop: desktop,
          favorites: favorites,
        );
        for (final String action in ['取消', '确定']) {
          final Finder tile = find.text(desktop ? '喜欢·0' : '收藏');
          if (desktop) {
            await tester.tap(
              tile,
              kind: PointerDeviceKind.mouse,
              buttons: kSecondaryMouseButton,
            );
          } else {
            await tester.longPress(tile);
          }
          await tester.pumpAndSettle();
          await tester.tap(find.text('修改类型'));
          await tester.pumpAndSettle();
          if (action == '取消') await tester.tap(find.text('听声'));
          await tester.tap(find.text(action));
          await tester.pumpAndSettle();
          expect(favorites.kindSaveCalls, 0);
          expect(
            container.read(favoritesControllerProvider).collections.single.kind,
            CollectionKind.music,
          );
        }
        expect(tester.takeException(), isNull);
      },
    );
    for (final bool throwsOnSave in <bool>[false, true]) {
      testWidgets(
        '${desktop ? 'desktop' : 'mobile'} shows kind save failure on ${throwsOnSave ? 'exception' : 'false'}',
        (WidgetTester tester) async {
          final ProviderContainer container = await _pumpProfile(
            tester,
            desktop: desktop,
            favorites: _Favorites(
              FavoritesState(collections: [FavoriteCollection.liked()]),
              saveResult: false,
              throwsOnSave: throwsOnSave,
            ),
          );
          final Finder collectionTile = find.text(desktop ? '喜欢·0' : '收藏');
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
          await tester.tap(find.text('修改类型'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('听声'));
          await tester.tap(find.text('确定'));
          await tester.pumpAndSettle();
          expect(find.text('类型保存失败，请重试'), findsOneWidget);
          expect(find.text('听声'), findsNothing);
          expect(
            container.read(favoritesControllerProvider).collections.single.kind,
            CollectionKind.music,
          );
          expect(tester.takeException(), isNull);
          await tester.pump(const Duration(seconds: 3));
          await tester.pumpAndSettle();
        },
      );
    }
    for (final String flow in <String>['local', 'remote', 'import']) {
      for (final bool confirm in <bool>[true, false]) {
        testWidgets(
          '${desktop ? 'desktop' : 'mobile'} $flow ${confirm ? 'uses selected kind' : 'cancels before writing'}',
          (WidgetTester tester) async {
            final _Favorites favorites = _Favorites(const FavoritesState());
            final ProviderContainer container = await _pumpProfile(
              tester,
              desktop: desktop,
              favorites: favorites,
              loggedIn: true,
            );
            if (flow == 'local') {
              await tester.tap(find.text('本地歌单'));
              await tester.pumpAndSettle();
            }
            await tester.tap(
              desktop ? find.byTooltip('新建歌单') : find.byIcon(Icons.add_rounded),
            );
            await tester.pumpAndSettle();
            if (flow != 'local') {
              await tester.tap(
                find.text(flow == 'import' ? '导入已有收藏夹' : '新建网络歌单'),
              );
              await tester.pumpAndSettle();
            }
            if (flow == 'import') {
              await tester.tap(find.text('待导入收藏夹'));
            } else {
              await tester.enterText(find.byType(TextField), '新的歌单');
              await tester.tap(find.text('创建'));
            }
            await tester.pumpAndSettle();
            expect(find.text('选择歌单类型'), findsOneWidget);
            expect(find.textContaining('收听进度'), findsOneWidget);
            expect(favorites.createCalls, 0);
            expect(favorites.bindCalls, 0);
            expect(favorites.refreshCalls, 0);
            await tester.tap(find.text('听声'));
            await tester.tap(find.text(confirm ? '确定' : '取消'));
            await tester.pumpAndSettle();
            if (confirm) {
              final FavoriteCollection collection = container
                  .read(favoritesControllerProvider)
                  .collections
                  .single;
              expect(collection.kind, CollectionKind.spoken);
              expect(collection.isRemote, flow != 'local');
              expect(favorites.createCalls, flow == 'import' ? 0 : 1);
              expect(favorites.bindCalls, flow == 'import' ? 1 : 0);
              expect(favorites.refreshCalls, flow == 'import' ? 1 : 0);
            } else {
              expect(
                container.read(favoritesControllerProvider).collections,
                isEmpty,
              );
              expect(favorites.createCalls, 0);
              expect(favorites.bindCalls, 0);
              expect(favorites.refreshCalls, 0);
            }
            expect(find.text('选择歌单类型'), findsNothing);
            expect(tester.takeException(), isNull);
            await tester.pump(const Duration(seconds: 3));
            await tester.pumpAndSettle();
          },
        );
      }
    }
  }
}

Future<ProviderContainer> _pumpProfile(
  WidgetTester tester, {
  required bool desktop,
  required _Favorites favorites,
  bool loggedIn = false,
}) async {
  tester.view.physicalSize = desktop
      ? const Size(1000, 800)
      : const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final ProviderContainer container = ProviderContainer(
    overrides: [
      favoritesControllerProvider.overrideWith(() => favorites),
      biliSessionControllerProvider.overrideWithValue(
        loggedIn
            ? const BiliSession(
                sessData: 'test',
                biliJct: 'test',
                dedeUserId: '1',
                refreshToken: '',
                cookie: '',
              )
            : null,
      ),
      favoriteUpControllerProvider.overrideWithValue(const <FavoriteUp>[]),
      recentPlaybackControllerProvider.overrideWithValue(
        const <RecentPlaybackEntry>[],
      ),
      downloadControllerProvider.overrideWith(_EmptyDownloads.new),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        builder: FlutterSmartDialog.init(),
        home: desktop
            ? const Scaffold(
                body: Align(
                  alignment: Alignment.centerLeft,
                  child: DesktopProfileSidebar(currentLocation: '/profile'),
                ),
              )
            : const ProfilePage(),
      ),
    ),
  );
  addTearDown(() async {
    final Future<void> dismiss = SmartDialog.dismiss();
    final Future<void> dismissToasts = SmartDialog.dismiss(
      status: SmartStatus.allToast,
    );
    await tester.pumpAndSettle();
    await dismiss;
    await dismissToasts;
    await tester.pumpWidget(const SizedBox.shrink());
  });
  await tester.pumpAndSettle();
  if (favorites.initial.collections.any(
    (collection) => collection.isLocal && !collection.isSystem,
  )) {
    await tester.tap(find.text('本地歌单'));
    await tester.pumpAndSettle();
  }
  return container;
}

class _Favorites extends FavoritesController {
  _Favorites(this.initial, {this.saveResult = true, this.throwsOnSave = false});

  final FavoritesState initial;
  final bool saveResult;
  final bool throwsOnSave;
  int kindSaveCalls = 0;
  int createCalls = 0;
  int bindCalls = 0;
  int refreshCalls = 0;

  @override
  FavoritesState build() => initial;

  @override
  Future<void> refreshRemoteCollections() async {}

  @override
  Future<FavoriteCollection?> createCollection(
    String name, {
    CollectionKind kind = CollectionKind.music,
  }) async {
    createCalls++;
    final DateTime now = DateTime(2026);
    final FavoriteCollection collection = FavoriteCollection(
      id: 'new_local',
      name: name,
      kind: kind,
      createdAt: now,
      updatedAt: now,
    );
    state = state.copyWith(collections: [...state.collections, collection]);
    return collection;
  }

  @override
  Future<FavoriteCollection?> createRemoteCollection(
    String name, {
    CollectionKind kind = CollectionKind.music,
  }) async {
    createCalls++;
    final FavoriteCollection collection = _remoteCollection.copyWith(
      name: name,
      kind: kind,
    );
    state = state.copyWith(collections: [...state.collections, collection]);
    return collection;
  }

  FavoriteCollection get _remoteCollection => FavoriteCollection(
    id: 'remote:2',
    name: '待导入收藏夹',
    source: FavoriteCollectionSource.remote,
    remoteId: '2',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  @override
  Future<List<FavoriteCollection>> fetchImportableRemoteCollections() async => [
    _remoteCollection,
  ];

  @override
  Future<void> bindRemoteCollection(FavoriteCollection collection) async {
    bindCalls++;
    state = state.copyWith(collections: [...state.collections, collection]);
  }

  @override
  Future<BiliFavoriteCollectionPage?> refreshRemoteCollectionItems({
    required String collectionId,
    int pageNumber = 1,
  }) async {
    refreshCalls++;
    return null;
  }

  @override
  Future<bool> setCollectionKind({
    required String collectionId,
    required CollectionKind kind,
  }) async {
    kindSaveCalls++;
    if (throwsOnSave) {
      throw StateError('kind save failed');
    }
    if (!saveResult) {
      return false;
    }
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

class _EmptyDownloads extends DownloadController {
  @override
  DownloadState build() => const DownloadState();
}
