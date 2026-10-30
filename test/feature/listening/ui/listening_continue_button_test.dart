import 'dart:async';

import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/feature/listening/domain/listening_state.dart';
import 'package:bilimusic/feature/listening/logic/listening_progress_controller.dart';
import 'package:bilimusic/feature/listening/ui/listening_continue_button.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const PlayableItem _first = PlayableItem(
  aid: 1,
  bvid: 'BV1',
  cid: 10,
  page: 1,
  title: 'First chapter',
  author: 'Author',
  coverUrl: '',
  kind: CollectionKind.spoken,
  collectionId: 'spoken',
);
final PlayableItem _second = _first.copyWith(
  aid: 2,
  bvid: 'BV2',
  cid: 20,
  title: 'Second chapter',
);
final List<PlayableItem> _items = [_first, _second];
final PlayerState _playing = PlayerState(
  currentItem: _first,
  queue: _items,
  currentQueueIndex: 0,
  isReady: true,
  isPlaying: true,
);

typedef _Continuation = ({List<PlayableItem> items, int startIndex});

void main() {
  final Map<String, List<PlayableItem>> changedLists = {
    'filter': [_first],
    'order': [_second, _first],
    'item metadata with the same stable id': [
      _first.copyWith(title: 'Changed chapter'),
      _second,
    ],
    'a later item with the same first item and length': [
      _first,
      _second.copyWith(cid: 21, page: 2),
    ],
  };
  for (final entry in changedLists.entries) {
    testWidgets('pending continuation ignores same-collection ${entry.key}', (
      tester,
    ) async {
      final fixture = _Fixture();
      await fixture.pump(tester);
      await fixture.start(tester);

      await fixture.pump(tester, items: entry.value);
      fixture.listening.pending.complete((items: _items, startIndex: 1));
      await tester.pumpAndSettle();

      expect(fixture.played, isEmpty);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(
        tester.widget<TextButton>(find.byType(TextButton)).onPressed,
        isNotNull,
      );
    });
  }

  final Map<String, PlayerState> changedPlayers = {
    'a new music queue': PlayerState(
      currentItem: _second.copyWith(kind: CollectionKind.music),
      queue: [_second.copyWith(kind: CollectionKind.music)],
      isReady: true,
      isPlaying: true,
    ),
    'stop with the same current item and queue': _playing.copyWith(
      isReady: false,
      isPlaying: false,
    ),
    'current item metadata': _playing.copyWith(
      currentItem: _first.copyWith(title: 'Changed player item'),
    ),
    'loading': _playing.copyWith(isLoading: true),
    'readiness': _playing.copyWith(isReady: false),
    'pause': _playing.copyWith(isPlaying: false),
    'only the queue order': _playing.copyWith(queue: [_second, _first]),
  };
  for (final entry in changedPlayers.entries) {
    testWidgets('pending continuation does not override ${entry.key}', (
      tester,
    ) async {
      final fixture = _Fixture();
      await fixture.pump(tester);
      await fixture.start(tester);

      fixture.player.show(entry.value);
      await tester.pump();
      fixture.listening.pending.complete((items: _items, startIndex: 1));
      await tester.pumpAndSettle();

      expect(fixture.played, isEmpty);
      expect(fixture.container.read(playerControllerProvider), entry.value);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  }

  testWidgets('equal context applies the resolved items and start index', (
    tester,
  ) async {
    final fixture = _Fixture();
    await fixture.pump(tester);
    await fixture.start(tester);

    await fixture.pump(
      tester,
      items: [for (final item in _items) item.copyWith()],
    );
    fixture.player.show(
      _playing.copyWith(
        currentItem: _first.copyWith(),
        queue: [for (final item in _items) item.copyWith()],
        position: const Duration(seconds: 12),
      ),
    );
    final List<PlayableItem> resolved = [
      _first,
      _second.copyWith(cid: 22, page: 3),
    ];
    fixture.listening.pending.complete((items: resolved, startIndex: 1));
    await tester.pumpAndSettle();

    expect(fixture.played, [(items: resolved, startIndex: 1)]);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNotNull,
    );
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
  }

  final _Listening listening = _Listening();
  final _Player player = _Player();
  final List<_Continuation> played = [];
  late final ProviderContainer container;

  Future<void> pump(WidgetTester tester, {List<PlayableItem>? items}) =>
      tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: ListeningContinueButton(
                items: items ?? _items,
                onPlay: (items, startIndex) async {
                  played.add((items: items, startIndex: startIndex));
                },
              ),
            ),
          ),
        ),
      );

  Future<void> start(WidgetTester tester) async {
    await tester.tap(find.text('继续收听'));
    await tester.pump();
    expect(listening.requested, [_items]);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNull,
    );
    expect(played, isEmpty);
  }
}

class _Listening extends ListeningProgressController {
  final Completer<_Continuation> pending = Completer<_Continuation>();
  final List<List<PlayableItem>> requested = [];

  @override
  ListeningState build() => const ListeningState();

  @override
  Future<_Continuation> continuation(List<PlayableItem> items) {
    requested.add(List.of(items));
    return pending.future;
  }
}

class _Player extends PlayerController {
  @override
  PlayerState build() => _playing;

  void show(PlayerState value) => state = value;
}
