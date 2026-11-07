import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_display_info.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/display/player_display_provider.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_queue_list.dart';
import 'package:bilimusic/feature/player/ui/components/player_queue_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _item = PlayableItem(
  aid: 1,
  bvid: 'BV1',
  title: '合集',
  author: 'UP',
  coverUrl: '',
);

void main() {
  testWidgets('queue sheet preserves compact rows and removal actions', (
    tester,
  ) async {
    final second = _item.copyWith(aid: 2, bvid: 'BV2', title: '第二首');
    final player = _Player(
      PlayerState(queue: [_item, second], currentQueueIndex: 0),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerControllerProvider.overrideWith(() => player),
          playerQueueDisplayProvider(_item).overrideWith(
            (_) async => const PlayerDisplayInfo(title: '歌曲', artist: '歌手'),
          ),
          playerQueueDisplayProvider(second).overrideWith(
            (_) async => const PlayerDisplayInfo(title: '第二首', artist: 'UP'),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showPlayerQueueSheet(
                  context: context,
                  state: player.initialState,
                ),
                child: const Text('打开队列'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开队列'));
    await tester.pumpAndSettle();
    expect(find.text('2 项 · 列表循环'), findsOneWidget);
    expect(find.text('歌曲 - 歌手', findRichText: true), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
    expect(find.byTooltip('移出队列'), findsNWidgets(2));
    expect(
      tester.getSize(find.byKey(ValueKey('queue-${_item.stableId}'))).height,
      56,
    );
    await tester.tap(find.byTooltip('移出队列').first);
    await tester.pumpAndSettle();
    expect(player.removedIndex, 0);
    expect(find.text('1 项 · 列表循环'), findsOneWidget);
    expect(find.byType(PlayerQueueList), findsOneWidget);
    await tester.tap(find.byTooltip('移出队列'));
    await tester.pumpAndSettle();
    expect(find.byType(PlayerQueueList), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final isCar in [false, true]) {
    testWidgets('queue shares playback and part labels (car: $isCar)', (
      tester,
    ) async {
      final item = _item.copyWith(cid: 10, pageTitle: '分P标题');
      final player = _Player(PlayerState(queue: [item], currentQueueIndex: 0));
      var closed = false;
      player.beforeSkip = () => expect(closed, isTrue);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerControllerProvider.overrideWith(() => player),
            playerQueueDisplayProvider(item).overrideWith(
              (_) async => const PlayerDisplayInfo(title: '歌曲', artist: '歌手'),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PlayerQueueList(
                state: player.initialState,
                controller: player,
                isCar: isCar,
                onClose: () async => closed = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        isCar ? find.text('分P标题') : find.text('分P标题 - 合集', findRichText: true),
        findsOneWidget,
      );
      expect(find.byTooltip('移出队列'), isCar ? findsNothing : findsOneWidget);
      await tester.tap(find.byKey(ValueKey('queue-${item.stableId}')));
      await tester.pumpAndSettle();
      expect(player.skippedIndex, 0);
      expect(closed, isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'compact queue waits for data and only focuses once per opening',
    (tester) async {
      final queue = List.generate(
        100,
        (index) => _item.copyWith(
          aid: index + 1,
          bvid: 'BV$index',
          title: '歌曲 $index',
        ),
      );
      final player = _Player(const PlayerState());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerControllerProvider.overrideWith(() => player),
            for (final item in queue)
              playerQueueDisplayProvider(item).overrideWith(
                (_) async =>
                    PlayerDisplayInfo(title: item.title, artist: item.author),
              ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) => PlayerQueueList(
                  state: ref.watch(playerControllerProvider),
                  controller: player,
                  onClose: () async {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('播放队列为空'), findsOneWidget);
      player.update(PlayerState(queue: queue, currentQueueIndex: 60));
      await tester.pumpAndSettle();
      expect(
        find.byKey(ValueKey('queue-${queue[60].stableId}')).hitTestable(),
        findsOneWidget,
      );
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      scrollable.position.jumpTo(0);
      await tester.pumpAndSettle();
      player.update(
        PlayerState(
          queue: queue,
          currentQueueIndex: 61,
          position: const Duration(seconds: 1),
        ),
      );
      await tester.pumpAndSettle();
      expect(scrollable.position.pixels, 0);
      expect(tester.takeException(), isNull);
    },
  );
}

class _Player extends PlayerController {
  _Player(this.initialState);

  final PlayerState initialState;
  int? removedIndex;
  int? skippedIndex;
  VoidCallback? beforeSkip;

  @override
  PlayerState build() => initialState;

  void update(PlayerState next) => state = next;

  @override
  Future<void> skipToQueueIndex(int index, {bool autoplay = true}) async {
    beforeSkip?.call();
    skippedIndex = index;
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    removedIndex = index;
    state = state.copyWith(queue: [...state.queue]..removeAt(index));
  }
}
