import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/ui/components/player_part_selector.dart';
import 'package:bilimusic/feature/player/ui/components/player_playback_waveform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const PlayableItem _first = PlayableItem(
  aid: 1,
  bvid: 'BV1',
  cid: 10,
  page: 1,
  pageTitle: '第一首',
  title: '合集',
  author: 'UP',
  coverUrl: '',
);
final PlayableItem _second = _first.copyWith(
  cid: 20,
  page: 2,
  pageTitle: '第二首',
);

void main() {
  testWidgets('parts use compact rows and a themed playback indicator', (
    WidgetTester tester,
  ) async {
    final _RecordingController controller = _RecordingController();
    await _open(tester, controller, isPlaying: true);

    expect(find.text('分P列表'), findsOneWidget);
    expect(find.text('2 项'), findsOneWidget);
    expect(find.byType(CircleAvatar), findsNothing);
    expect(find.byType(ListTile), findsNothing);
    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    final Text selected = tester.widget<Text>(find.text('P1 · 第一首'));
    final BuildContext context = tester.element(find.text('P1 · 第一首'));
    expect(selected.style?.color, Theme.of(context).colorScheme.primary);
    expect(selected.maxLines, 1);
    expect(selected.overflow, TextOverflow.ellipsis);
    expect(
      tester
          .getSize(find.byKey(ValueKey('part-selector-${_first.stableId}')))
          .height,
      56,
    );
    expect(
      tester
          .widget<PlayerPlaybackWaveform>(find.byType(PlayerPlaybackWaveform))
          .isPlaying,
      isTrue,
    );

    await tester.tap(find.text('P2 · 第二首'));
    await tester.pumpAndSettle();
    expect(controller.replaced, _second);
    expect(find.text('分P列表'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('paused current part closes without restarting playback', (
    WidgetTester tester,
  ) async {
    final _RecordingController controller = _RecordingController();
    await _open(tester, controller);

    expect(
      tester
          .widget<PlayerPlaybackWaveform>(find.byType(PlayerPlaybackWaveform))
          .isPlaying,
      isFalse,
    );
    await tester.tap(find.text('P1 · 第一首'));
    await tester.pumpAndSettle();
    expect(controller.replaced, isNull);
    expect(find.text('分P列表'), findsNothing);
  });

  testWidgets('add all stays in the header and disables when already queued', (
    WidgetTester tester,
  ) async {
    final _RecordingController controller = _RecordingController();
    await _open(tester, controller);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, '全部加入队列'))
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.text('P1 · 第一首'));
    await tester.pumpAndSettle();

    await _open(tester, controller, queue: [_first, _second]);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, '全部加入队列'))
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('P1 · 第一首'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'initial scroll finds a distant selected part without hiding header',
    (WidgetTester tester) async {
      final List<PlayableItem> parts = List.generate(
        80,
        (int index) => _first.copyWith(
          cid: index + 1,
          page: index + 1,
          pageTitle: '歌曲 ${index + 1}',
        ),
      );
      await _open(
        tester,
        _RecordingController(),
        parts: parts,
        currentItem: parts[60],
      );
      expect(find.text('P61 · 歌曲 61').hitTestable(), findsOneWidget);
      expect(find.text('全部加入队列').hitTestable(), findsOneWidget);
      await tester.tap(find.text('P61 · 歌曲 61'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> _open(
  WidgetTester tester,
  _RecordingController controller, {
  bool isPlaying = false,
  List<PlayableItem>? queue,
  List<PlayableItem>? parts,
  PlayableItem currentItem = _first,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () => showPlayerPartSelector(
              context: context,
              parts: parts ?? [_first, _second],
              currentItem: currentItem,
              state: PlayerState(
                currentItem: currentItem,
                queue: queue ?? [currentItem],
                isPlaying: isPlaying,
              ),
              controller: controller,
            ),
            child: const Text('打开分P'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('打开分P'));
  await tester.pump();
  if (isPlaying) {
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));
  } else {
    await tester.pumpAndSettle();
  }
}

class _RecordingController extends PlayerController {
  PlayableItem? replaced;

  @override
  Future<void> replaceCurrentQueueItem(
    PlayableItem item, {
    bool autoplay = true,
  }) async {
    replaced = item;
  }
}
