import 'dart:async';

import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/feature/listening/domain/listening_progress.dart';
import 'package:bilimusic/feature/listening/domain/listening_state.dart';
import 'package:bilimusic/feature/listening/logic/listening_progress_controller.dart';
import 'package:bilimusic/feature/listening/ui/listening_progress_listener.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

const PlayableItem _chapter = PlayableItem(
  aid: 1,
  bvid: 'BV1',
  cid: 10,
  page: 1,
  title: 'Chapter',
  author: 'Author',
  coverUrl: '',
  kind: CollectionKind.spoken,
  collectionId: 'spoken',
);
const ListeningProgress _localA = ListeningProgress(
  accountId: 'account-a',
  aid: 1,
  bvid: 'BV1',
  cid: 10,
  collectionId: 'spoken',
  positionMs: 10000,
  pendingSync: true,
);
final ListeningProgress _remoteA = _localA.copyWith(
  positionMs: 20000,
  pendingSync: false,
);
final ListeningProgress _localB = _localA.copyWith(
  accountId: 'account-b',
  positionMs: 30000,
);
final ListeningProgress _remoteB = _localB.copyWith(
  positionMs: 40000,
  pendingSync: false,
);

typedef _Resolution = ({
  bool useLocal,
  ListeningProgress? expectedLocal,
  ListeningProgress? expectedRemote,
});

void main() {
  testWidgets('an old dialog cannot resolve a new account conflict', (
    tester,
  ) async {
    final fixture = _Fixture();
    await fixture.pump(tester);
    await fixture.show(tester, _localA, _remoteA);
    expect(find.textContaining('本地：0:00:10'), findsOneWidget);

    fixture.listening.currentAccount = 'account-b';
    fixture.listening.show(const ListeningState());
    await tester.pump();
    fixture.listening.show(
      ListeningState(localConflict: _localB, remoteConflict: _remoteB),
    );
    await tester.pump();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('本地：0:00:30'), findsNothing);

    await fixture.choose(tester, '使用本地');

    expect(fixture.listening.requests, [
      (useLocal: true, expectedLocal: _localA, expectedRemote: _remoteA),
    ]);
    expect(fixture.listening.resolved, isEmpty);
    expect(fixture.player.seeks, isEmpty);
    expect(
      fixture.container.read(listeningProgressControllerProvider).localConflict,
      _localB,
    );
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('本地：0:00:30'), findsOneWidget);

    await fixture.choose(tester, '使用B站');

    expect(fixture.listening.requests.last, (
      useLocal: false,
      expectedLocal: _localB,
      expectedRemote: _remoteB,
    ));
    expect(fixture.listening.resolved, [_remoteB]);
    expect(fixture.player.seeks, [const Duration(seconds: 40)]);
    expect(find.byType(AlertDialog), findsNothing);
  });

  for (final String change in ['account', 'collection', 'readiness']) {
    testWidgets('delayed conflict resolution rechecks $change before seeking', (
      tester,
    ) async {
      final fixture = _Fixture();
      await fixture.pump(tester);
      fixture.listening.pending = Completer<Duration?>();
      await fixture.show(tester, _localA, _remoteA);
      await tester.tap(find.text('使用B站'));
      await tester.pumpAndSettle();
      expect(fixture.listening.resolved, [_remoteA]);
      expect(fixture.player.seeks, isEmpty);

      switch (change) {
        case 'account':
          fixture.listening.currentAccount = 'account-b';
        case 'collection':
          fixture.player.show(
            PlayerState(
              currentItem: _chapter.copyWith(collectionId: 'other'),
              isReady: true,
            ),
          );
        case 'readiness':
          fixture.player.show(const PlayerState(currentItem: _chapter));
      }
      fixture.listening.pending!.complete(const Duration(seconds: 20));
      await tester.pumpAndSettle();

      expect(fixture.player.seeks, isEmpty);
      expect(find.byType(AlertDialog), findsNothing);
    });
  }

  testWidgets('a failed resolution releases the dialog guard for retry', (
    tester,
  ) async {
    final fixture = _Fixture();
    await fixture.pump(tester);
    fixture.listening.failNext = true;
    await fixture.show(tester, _localA, _remoteA);

    await fixture.choose(tester, '使用本地');

    expect(fixture.listening.requests, hasLength(1));
    expect(fixture.listening.resolved, isEmpty);
    expect(fixture.player.seeks, isEmpty);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('收听进度保存失败，请重试'), findsOneWidget);

    await fixture.choose(tester, '使用B站');

    expect(fixture.listening.requests, hasLength(2));
    expect(fixture.listening.resolved, [_remoteA]);
    expect(fixture.player.seeks, [const Duration(seconds: 20)]);
    expect(find.byType(AlertDialog), findsNothing);
    final Future<void> dismiss = SmartDialog.dismiss(status: SmartStatus.toast);
    await tester.pumpAndSettle();
    await dismiss;
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
}

class _Fixture {
  _Fixture() {
    container = ProviderContainer(
      overrides: [
        listeningProgressControllerProvider.overrideWith(() => listening),
        playerControllerProvider.overrideWith(() => player),
      ],
    );
    addTearDown(container.dispose);
    container.read(playerControllerProvider);
  }

  final _Listening listening = _Listening();
  final _Player player = _Player();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late final ProviderContainer container;

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        builder: (context, child) => ListeningProgressListener(
          navigatorKey: navigatorKey,
          child: FlutterSmartDialog.init()(context, child),
        ),
        home: const Scaffold(body: Text('Listening')),
      ),
    ),
  );

  Future<void> show(
    WidgetTester tester,
    ListeningProgress local,
    ListeningProgress remote,
  ) async {
    listening.show(
      ListeningState(localConflict: local, remoteConflict: remote),
    );
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
  }

  Future<void> choose(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }
}

class _Listening extends ListeningProgressController {
  String currentAccount = 'account-a';
  bool failNext = false;
  Completer<Duration?>? pending;
  final List<_Resolution> requests = [];
  final List<ListeningProgress> resolved = [];

  @override
  String get accountId => currentAccount;

  @override
  ListeningState build() => const ListeningState();

  void show(ListeningState value) => state = value;

  @override
  Future<Duration?> resolveConflict({
    required bool useLocal,
    ListeningProgress? expectedLocal,
    ListeningProgress? expectedRemote,
  }) async {
    requests.add((
      useLocal: useLocal,
      expectedLocal: expectedLocal,
      expectedRemote: expectedRemote,
    ));
    final local = state.localConflict;
    final remote = state.remoteConflict;
    if (local == null ||
        remote == null ||
        local.accountId != accountId ||
        expectedLocal != local ||
        expectedRemote != remote) {
      return null;
    }
    if (failNext) {
      failNext = false;
      throw StateError('save failed');
    }
    final ListeningProgress chosen = useLocal ? local : remote;
    resolved.add(chosen);
    state = const ListeningState();
    return pending == null ? chosen.resumePosition : await pending!.future;
  }
}

class _Player extends PlayerController {
  final List<Duration> seeks = [];

  @override
  PlayerState build() => const PlayerState(
    currentItem: _chapter,
    queue: [_chapter],
    isReady: true,
  );

  void show(PlayerState value) => state = value;

  @override
  Future<void> seek(Duration position) async {
    seeks.add(position);
  }
}
