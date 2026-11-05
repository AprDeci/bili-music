import 'package:bilimusic/feature/favorites/ui/components/favorites_metadata_toolbar_buttons.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_backfill_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_backfill_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('backfill passes the collection playback context unchanged', (
    tester,
  ) async {
    const PlayableItem item = PlayableItem(
      aid: 1,
      bvid: 'BV1',
      title: 'Title',
      author: 'Author',
      coverUrl: '',
      collectionId: 'target',
    );
    final backfill = _FakeBackfillController(const MetadataBackfillState());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metadataBackfillControllerProvider.overrideWith(() => backfill),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Center(child: MetadataBackfillButton(items: [item])),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(MetadataBackfillButton));
    await tester.pumpAndSettle();
    expect(backfill.items, [item]);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows scanning title and live counts', (
    WidgetTester tester,
  ) async {
    await _pumpPopup(
      tester,
      state: const MetadataBackfillState(
        isRunning: true,
        processed: 2,
        total: 5,
        matched: 1,
      ),
    );

    expect(find.text('正在扫描'), findsOneWidget);
    expect(find.text('已找到 26，待更新 3，已更新 1'), findsOneWidget);
  });

  testWidgets('shows completed title when idle', (WidgetTester tester) async {
    await _pumpPopup(
      tester,
      state: const MetadataBackfillState(processed: 5, total: 5, matched: 4),
    );

    expect(find.text('扫描完成'), findsOneWidget);
    expect(find.text('已找到 26，待更新 0，已更新 4'), findsOneWidget);
  });

  testWidgets('renders without overflow', (WidgetTester tester) async {
    await _pumpPopup(tester, state: const MetadataBackfillState());

    expect(find.text('扫描完成'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpPopup(
  WidgetTester tester, {
  required MetadataBackfillState state,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        metadataBackfillControllerProvider.overrideWith(
          () => _FakeBackfillController(state),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(body: Center(child: MetadataScanPopup(foundCount: 26))),
      ),
    ),
  );
  await tester.pump();
}

class _FakeBackfillController extends MetadataBackfillController {
  _FakeBackfillController(this._initial);

  final MetadataBackfillState _initial;
  List<PlayableItem> items = [];

  @override
  MetadataBackfillState build() => _initial;

  @override
  Future<int> backfillMissing(Iterable<PlayableItem> items) async {
    this.items = items.toList();
    return this.items.length;
  }
}
