import 'dart:async';

import 'package:bilimusic/feature/favorites/domain/favorite_collection.dart';
import 'package:bilimusic/feature/favorites/domain/favorites_state.dart';
import 'package:bilimusic/feature/favorites/domain/remote_collection_sync_state.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/favorites/logic/remote_collection_sync_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final provider = remoteCollectionSyncControllerProvider('remote:1');
  late _Favorites favorites;
  late ProviderContainer container;
  late RemoteCollectionSyncController controller;
  late ProviderSubscription<RemoteCollectionSyncState> subscription;
  late List<RemoteCollectionSyncState> updates;

  void setUpContainer() {
    favorites = _Favorites();
    container = ProviderContainer(
      overrides: [favoritesControllerProvider.overrideWith(() => favorites)],
    );
    updates = <RemoteCollectionSyncState>[];
    subscription = container.listen(provider, (_, next) => updates.add(next));
    controller = container.read(provider.notifier);
    addTearDown(container.dispose);
  }

  for (final RemoteCollectionSyncResult? result
      in <RemoteCollectionSyncResult?>[
        ...RemoteCollectionSyncResult.values,
        null,
      ]) {
    test('sync ignores ${result?.name ?? 'error'} after autoDispose', () async {
      setUpContainer();
      final Future<void> pending = controller.sync(force: true);
      expect(subscription.read().isSyncing, isTrue);
      subscription.close();
      await container.pump();
      expect(container.exists(provider), isFalse);

      final Future<void> completed = expectLater(pending, completes);
      if (result == null) {
        favorites.syncResult.completeError(StateError('offline'));
      } else {
        favorites.syncResult.complete(result);
      }
      await completed;

      expect(container.exists(provider), isFalse);
      expect(updates, hasLength(1));
    });
  }

  for (final bool throwsError in <bool>[false, true]) {
    testWidgets(
      '${throwsError ? 'thrown' : 'incomplete'} sync failure persists until retry',
      (WidgetTester tester) async {
        setUpContainer();
        await _initToasts(tester);
        final Future<void> pending = controller.sync(force: true);
        if (throwsError) {
          favorites.syncResult.completeError(StateError('offline'));
        } else {
          favorites.syncResult.complete(RemoteCollectionSyncResult.incomplete);
        }
        await pending;

        expect(subscription.read().hasFailed, isTrue);
        expect(container.read(favoritesControllerProvider).entries, isEmpty);
        await tester.pump(const Duration(seconds: 3));
        expect(subscription.read().hasFailed, isTrue);

        favorites.syncResult = Completer<RemoteCollectionSyncResult>();
        final Future<void> retry = controller.sync(force: true);
        expect(subscription.read().isSyncing, isTrue);
        favorites.syncResult.complete(RemoteCollectionSyncResult.completed);
        await retry;
        expect(subscription.read().status, RemoteCollectionSyncStatus.success);
        await tester.pump(const Duration(milliseconds: 350));
        expect(subscription.read().status, isNull);
      },
    );
  }

  testWidgets('successful sync clears status after 350ms', (
    WidgetTester tester,
  ) async {
    setUpContainer();
    final Future<void> pending = controller.sync(force: true);
    favorites.syncResult.complete(RemoteCollectionSyncResult.completed);
    await pending;

    expect(subscription.read().status, RemoteCollectionSyncStatus.success);
    await tester.pump(const Duration(milliseconds: 349));
    expect(subscription.read().status, RemoteCollectionSyncStatus.success);
    await tester.pump(const Duration(milliseconds: 1));
    expect(subscription.read().status, isNull);
  });

  testWidgets('disposing cancels the success status timer', (
    WidgetTester tester,
  ) async {
    setUpContainer();
    final Future<void> pending = controller.sync(force: true);
    favorites.syncResult.complete(RemoteCollectionSyncResult.completed);
    await pending;
    subscription.close();
    await tester.pump(const Duration(milliseconds: 1));
    expect(container.exists(provider), isFalse);

    await tester.pump(const Duration(seconds: 3));
    expect(container.exists(provider), isFalse);
    expect(updates, hasLength(2));
    expect(tester.takeException(), isNull);
  });
}

final FavoriteCollection _collection = FavoriteCollection(
  id: 'remote:1',
  name: 'remote',
  source: FavoriteCollectionSource.remote,
  remoteId: '1',
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

class _Favorites extends FavoritesController {
  Completer<RemoteCollectionSyncResult> syncResult =
      Completer<RemoteCollectionSyncResult>();

  @override
  FavoritesState build() => FavoritesState(collections: [_collection]);

  @override
  Future<RemoteCollectionSyncResult> syncRemoteCollectionIfStale(
    String collectionId, {
    bool force = false,
  }) => syncResult.future;
}

Future<void> _initToasts(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      builder: FlutterSmartDialog.init(),
      home: const SizedBox.shrink(),
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
}
