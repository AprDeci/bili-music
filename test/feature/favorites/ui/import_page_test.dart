import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_controller.dart';
import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/domain/import/favorites_import_candidate.dart';
import 'package:bilimusic/feature/favorites/domain/import/favorites_import_platform.dart';
import 'package:bilimusic/feature/favorites/domain/import/favorites_import_playlist_request.dart';
import 'package:bilimusic/feature/favorites/domain/import/favorites_import_result.dart';
import 'package:bilimusic/feature/favorites/domain/import/favorites_import_status.dart';
import 'package:bilimusic/feature/favorites/domain/import/favorites_import_track.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/favorites/logic/import/favorites_import_controller.dart';
import 'package:bilimusic/feature/favorites/logic/import/favorites_import_state.dart';
import 'package:bilimusic/feature/favorites/ui/import/import_page.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

const FavoritesImportCandidate _candidate = FavoritesImportCandidate(
  aid: 1,
  bvid: 'BV1',
  title: '匹配视频',
  author: 'UP主',
  coverUrl: '',
  durationText: '03:00',
  durationMs: 180000,
  score: 0,
);

void main() {
  for (final bool remote in <bool>[false, true]) {
    final String target = remote ? '网络' : '本地';
    testWidgets(
      'mobile new $target import confirms spoken kind before saving',
      (WidgetTester tester) async {
        final _Favorites favorites = _Favorites();
        final ProviderContainer container = await _pumpImport(
          tester,
          favorites,
        );
        await _chooseDestination(tester, '新建$target歌单');
        await tester.enterText(find.byType(TextField), '新的$target歌单');
        await tester.tap(find.text('保存'));
        await tester.pumpAndSettle();

        expect(find.text('选择歌单类型'), findsOneWidget);
        expect(find.text('歌曲'), findsOneWidget);
        expect(find.text('听声'), findsOneWidget);
        expect(find.text('适合音乐。支持匹配歌曲信息、封面和歌词。'), findsOneWidget);
        expect(
          find.text('适合播客、相声、有声书等长内容。保留原视频信息，不匹配歌曲信息和歌词，并记住收听进度。'),
          findsOneWidget,
        );
        expect(
          tester
              .widget<RadioGroup<CollectionKind>>(
                find.byType(RadioGroup<CollectionKind>),
              )
              .groupValue,
          CollectionKind.music,
        );
        await tester.tap(find.text('听声'));
        await tester.pumpAndSettle();
        expect(favorites.creates, isEmpty);
        expect(favorites.additions, isEmpty);

        await tester.tap(find.text('确定'));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        expect(
          favorites.creates,
          <({bool remote, String name, CollectionKind kind})>[
            (remote: remote, name: '新的$target歌单', kind: CollectionKind.spoken),
          ],
        );
        final FavoriteCollection collection = container
            .read(favoritesControllerProvider)
            .collections
            .single;
        expect(collection.kind, CollectionKind.spoken);
        expect(favorites.additions, hasLength(1));
        expect(favorites.additions.single.collectionId, collection.id);
        expect(favorites.additions.single.items, <PlayableItem>[
          _candidate.toPlayableItem(),
        ]);
        expect(favorites.kindChanges, isEmpty);
        expect(find.text('选择歌单类型'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('mobile new $target import cancellation writes nothing', (
      WidgetTester tester,
    ) async {
      final _Favorites favorites = _Favorites();
      final ProviderContainer container = await _pumpImport(tester, favorites);
      await _chooseDestination(tester, '新建$target歌单');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();
      expect(find.text('选择歌单类型'), findsOneWidget);
      await tester.tap(find.text('听声'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(favorites.creates, isEmpty);
      expect(favorites.additions, isEmpty);
      expect(favorites.kindChanges, isEmpty);
      expect(container.read(favoritesControllerProvider).collections, isEmpty);
      expect(tester.takeException(), isNull);
    });

    for (final CollectionKind kind in CollectionKind.values) {
      testWidgets(
        'mobile existing $target $kind import skips kind dialog and preserves kind',
        (WidgetTester tester) async {
          final FavoriteCollection collection = _collection(
            remote: remote,
            kind: kind,
          );
          final FavoritesState initial = FavoritesState(
            collections: <FavoriteCollection>[collection],
          );
          final _Favorites favorites = _Favorites(initial: initial);
          final ProviderContainer container = await _pumpImport(
            tester,
            favorites,
          );
          await _chooseDestination(tester, '添加到已有$target歌单');
          expect(find.text(collection.name), findsOneWidget);
          await tester.tap(find.text('保存'));
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 3));
          await tester.pumpAndSettle();

          expect(find.text('选择歌单类型'), findsNothing);
          expect(find.byType(RadioGroup<CollectionKind>), findsNothing);
          expect(find.byType(AlertDialog), findsNothing);
          expect(favorites.creates, isEmpty);
          expect(favorites.kindChanges, isEmpty);
          expect(favorites.additions, hasLength(1));
          expect(favorites.additions.single.collectionId, collection.id);
          expect(favorites.additions.single.items, <PlayableItem>[
            _candidate.toPlayableItem(),
          ]);
          expect(container.read(favoritesControllerProvider), initial);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

Future<ProviderContainer> _pumpImport(
  WidgetTester tester,
  _Favorites favorites,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final ProviderContainer container = ProviderContainer(
    overrides: [
      favoritesControllerProvider.overrideWith(() => favorites),
      favoritesImportControllerProvider.overrideWith(_ImportResults.new),
      biliSessionControllerProvider.overrideWithValue(
        const BiliSession(
          sessData: 'test',
          biliJct: 'test',
          dedeUserId: '1',
          refreshToken: '',
          cookie: '',
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        builder: FlutterSmartDialog.init(),
        home: const ImportPage(),
      ),
    ),
  );
  addTearDown(() async {
    final Future<void> dismiss = SmartDialog.dismiss(
      status: SmartStatus.allToast,
    );
    await tester.pumpAndSettle();
    await dismiss;
    await tester.pumpWidget(const SizedBox.shrink());
  });
  await tester.pumpAndSettle();
  expect(find.text('匹配队列'), findsOneWidget);
  expect(find.text(_candidate.title), findsOneWidget);
  return container;
}

Future<void> _chooseDestination(WidgetTester tester, String target) async {
  await tester.tap(find.text('导入歌单'));
  await tester.pumpAndSettle();
  expect(find.text('保存到歌单'), findsOneWidget);
  await tester.tap(find.text(target));
  await tester.pumpAndSettle();
}

FavoriteCollection _collection({
  required bool remote,
  required CollectionKind kind,
  String name = '已有歌单',
}) {
  final DateTime now = DateTime(2026);
  return FavoriteCollection(
    id: remote ? 'remote:1' : 'local',
    name: name,
    source: remote
        ? FavoriteCollectionSource.remote
        : FavoriteCollectionSource.local,
    remoteId: remote ? '1' : null,
    kind: kind,
    createdAt: now,
    updatedAt: now,
  );
}

class _ImportResults extends FavoritesImportController {
  @override
  FavoritesImportState build() => FavoritesImportState(
    request: const FavoritesImportPlaylistRequest(
      playlistId: '123',
      platform: FavoritesImportPlatform.netease,
    ),
    status: FavoritesImportStatus.completed,
    totalCount: 1,
    processedCount: 1,
    matchedCount: 1,
    results: <FavoritesImportResult>[
      FavoritesImportResult(
        track: const FavoritesImportTrack(
          id: 'external:1',
          title: '外部歌曲',
          author: '外部歌手',
          durationMs: 180000,
        ),
        status: FavoritesImportStatus.completed,
        candidate: _candidate,
        finishedAt: DateTime(2026),
      ),
    ],
  );
}

class _Favorites extends FavoritesController {
  _Favorites({this.initial = const FavoritesState()});

  final FavoritesState initial;
  final List<({bool remote, String name, CollectionKind kind})> creates = [];
  final List<({String collectionId, List<PlayableItem> items})> additions = [];
  final List<({String collectionId, CollectionKind kind})> kindChanges = [];

  @override
  FavoritesState build() => initial;

  @override
  Future<FavoriteCollection?> createCollection(
    String name, {
    CollectionKind kind = CollectionKind.music,
  }) async => _create(name, remote: false, kind: kind);

  @override
  Future<FavoriteCollection?> createRemoteCollection(
    String name, {
    CollectionKind kind = CollectionKind.music,
  }) async => _create(name, remote: true, kind: kind);

  FavoriteCollection _create(
    String name, {
    required bool remote,
    required CollectionKind kind,
  }) {
    creates.add((remote: remote, name: name, kind: kind));
    final FavoriteCollection collection = _collection(
      remote: remote,
      kind: kind,
      name: name,
    );
    state = state.copyWith(collections: [...state.collections, collection]);
    return collection;
  }

  @override
  Future<int> addItemsToCollection({
    required String collectionId,
    required Iterable<PlayableItem> items,
  }) async {
    final List<PlayableItem> importedItems = items.toList();
    additions.add((collectionId: collectionId, items: importedItems));
    return importedItems.length;
  }

  @override
  Future<bool> setCollectionKind({
    required String collectionId,
    required CollectionKind kind,
  }) async {
    kindChanges.add((collectionId: collectionId, kind: kind));
    return true;
  }
}
