import 'package:bilimusic/feature/updater/logic/update_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(UpdateChecker.resetStartupCheckForTest);
  tearDown(UpdateChecker.resetStartupCheckForTest);

  testWidgets('schedules the startup update check only once', (
    WidgetTester tester,
  ) async {
    int runs = 0;
    UpdateChecker.debugStartupCheckRunner = () async {
      runs += 1;
    };

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
    );
    final BuildContext context = tester.element(find.byType(Scaffold));

    expect(UpdateChecker.startupCheckScheduled, isFalse);
    UpdateChecker.scheduleStartupCheck(context);
    UpdateChecker.scheduleStartupCheck(context);
    expect(UpdateChecker.startupCheckScheduled, isTrue);

    await tester.pump();
    await tester.pump(UpdateChecker.startupCheckDelay);
    await tester.pump();

    expect(runs, 1);
  });

  testWidgets('skips the check when the widget is unmounted', (
    WidgetTester tester,
  ) async {
    int runs = 0;
    UpdateChecker.debugStartupCheckRunner = () async {
      runs += 1;
    };

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
    );
    final BuildContext context = tester.element(find.byType(Scaffold));
    UpdateChecker.scheduleStartupCheck(context);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(UpdateChecker.startupCheckDelay);
    await tester.pump();

    expect(runs, 0);
  });
}
