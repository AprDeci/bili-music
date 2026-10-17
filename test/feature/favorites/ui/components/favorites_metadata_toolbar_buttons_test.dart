import 'package:bilimusic/feature/favorites/ui/components/favorites_metadata_toolbar_buttons.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_backfill_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_backfill_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

  testWidgets('clamps arrow near the right edge without overflow', (
    WidgetTester tester,
  ) async {
    await _pumpPopup(
      tester,
      state: const MetadataBackfillState(),
      arrowCenterX: 260,
    );

    expect(find.text('扫描完成'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpPopup(
  WidgetTester tester, {
  required MetadataBackfillState state,
  double arrowCenterX = 134,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        metadataBackfillControllerProvider.overrideWith(
          () => _FakeBackfillController(state),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: MetadataScanPopup(
              foundCount: 26,
              arrowCenterX: arrowCenterX,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

class _FakeBackfillController extends MetadataBackfillController {
  _FakeBackfillController(this._initial);

  final MetadataBackfillState _initial;

  @override
  MetadataBackfillState build() => _initial;
}
