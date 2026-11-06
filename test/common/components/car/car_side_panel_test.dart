import 'package:bilimusic/common/components/car/car_side_panel.dart';
import 'package:bilimusic/core/theme/car_theme.dart';
import 'package:bilimusic/router/car_ui_viewport.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('panel slides from left, respects insets and captures theme', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 140 / 160;
    tester.view.padding = FakeViewPadding(top: 28, bottom: 28);
    tester.view.viewPadding = FakeViewPadding(top: 28, bottom: 28);
    addTearDown(tester.view.reset);
    int backgroundTaps = 0;
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => CarUiViewport(child: child!),
        home: Theme(
          data: carDarkTheme(),
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () async {
                    backgroundTaps++;
                    result = await showCarSidePanel<String>(
                      context: context,
                      builder: (context) => TextButton(
                        onPressed: () => Navigator.of(context).pop('closed'),
                        child: const Text('panel content'),
                      ),
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    final Finder panel = find.byType(CarSidePanel);
    final Rect start = tester.getRect(panel);
    await tester.pump(const Duration(milliseconds: 120));
    final Rect middle = tester.getRect(panel);
    await tester.pumpAndSettle();
    final Rect end = tester.getRect(panel);
    expect(start.left, lessThan(middle.left));
    expect(middle.left, lessThan(end.left));
    expect(start.top, closeTo(end.top, 0.01));
    expect(end.left, closeTo(24 * 12 / 7, 0.01));
    expect(end.top, greaterThan(28 / (140 / 160)));
    expect(end.width / (1920 / (140 / 160)), inInclusiveRange(0.5, 0.65));
    expect(end.bottom, lessThan(1080 / (140 / 160)));
    final Material material = tester.widget(
      find.descendant(of: panel, matching: find.byType(Material)).first,
    );
    expect(material.color, carDarkTheme().colorScheme.surface);
    expect(find.byType(BottomSheet), findsNothing);
    await tester.tap(find.text('panel content'));
    await tester.pumpAndSettle();
    expect(panel, findsNothing);
    expect(result, 'closed');
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(2000, 500));
    await tester.pumpAndSettle();
    expect(panel, findsNothing);
    expect(backgroundTaps, 2);
    expect(result, isNull);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(panel, findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final slideFrom in [
    const Offset(-1, 0),
    const Offset(1, 0),
    const Offset(0, -1),
    const Offset(0, 1),
  ]) {
    testWidgets('panel supports top-right sizing and slide $slideFrom', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showCarSidePanel<void>(
                  context: context,
                  width: 360,
                  height: 280,
                  alignment: Alignment.topRight,
                  slideFrom: slideFrom,
                  builder: (_) => const Text('content'),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      final Finder panel = find.byType(CarSidePanel);
      final Rect start = tester.getRect(panel);
      await tester.pump(const Duration(milliseconds: 120));
      final Rect middle = tester.getRect(panel);
      await tester.pumpAndSettle();
      final Rect end = tester.getRect(panel);
      expect(end, const Rect.fromLTWH(896, 24, 360, 280));
      expect(start.left - end.left, closeTo(1280 * slideFrom.dx, 0.01));
      expect(start.top - end.top, closeTo(720 * slideFrom.dy, 0.01));
      expect(
        (middle.center - end.center).distance,
        lessThan((start.center - end.center).distance),
      );
      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      final Rect reverse = tester.getRect(panel);
      expect((reverse.center - end.center).distance, greaterThan(0));
      await tester.pumpAndSettle();
      expect(panel, findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('oversized panel is clamped to the available space', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 300,
            height: 200,
            child: CarSidePanel(
              width: 800,
              height: 600,
              child: const Text('content'),
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(CarSidePanel)), const Size(300, 200));
    expect(tester.takeException(), isNull);
  });

  testWidgets('panel fits a narrow viewport with large text', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showCarSidePanel<void>(
                context: context,
                builder: (_) => const Text('content'),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final Rect panel = tester.getRect(find.byType(CarSidePanel));
    expect(panel, const Rect.fromLTWH(24, 24, 312, 592));
    expect(tester.takeException(), isNull);
  });
}
