import 'package:bilimusic/feature/favorites/logic/favorites_view_mode_logic.dart';
import 'package:bilimusic/feature/favorites/ui/components/favorites_metadata_toolbar_buttons.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_backfill_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_backfill_controller.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';

void main() {
  for (final FavoriteListViewMode mode in FavoriteListViewMode.values) {
    testWidgets('toolbar uses selected Hugeicons for $mode', (tester) async {
      int calls = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            metadataBackfillControllerProvider.overrideWithValue(
              const MetadataBackfillState(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Row(
                children: [
                  MetadataViewModeButton(
                    viewMode: mode,
                    onPressed: () => calls++,
                  ),
                  const MetadataBackfillButton(items: []),
                ],
              ),
            ),
          ),
        ),
      );
      final List<HugeIcon> icons = tester
          .widgetList<HugeIcon>(find.byType(HugeIcon))
          .toList();
      expect(icons, hasLength(2));
      expect(
        icons.first.icon,
        mode == FavoriteListViewMode.metadata
            ? HugeIcons.strokeRoundedMusicNoteSquare01
            : HugeIcons.strokeRoundedPlaySquare,
      );
      expect(icons.last.icon, HugeIcons.strokeRoundedMagicWand01);
      expect(
        find.byTooltip(
          mode == FavoriteListViewMode.metadata ? '切换到视频视图' : '切换到元信息视图',
        ),
        findsOneWidget,
      );
      await tester.tap(find.byType(MetadataViewModeButton));
      expect(calls, 1);
      expect(tester.takeException(), isNull);
    });
  }

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
