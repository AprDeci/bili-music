import 'package:bilimusic/common/components/underline_tab_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tabs share theme colors, selection and underline state', (
    tester,
  ) async {
    int selectedIndex = 0;
    final ThemeData theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => UnderlineTabSwitcher(
              labels: const ['歌曲', '合集'],
              selectedIndex: selectedIndex,
              onChanged: (index) => setState(() => selectedIndex = index),
            ),
          ),
        ),
      ),
    );
    final Finder songs = find.widgetWithText(TextButton, '歌曲');
    final Finder seasons = find.widgetWithText(TextButton, '合集');
    expect(
      tester.widget<TextButton>(songs).style!.foregroundColor!.resolve({}),
      theme.colorScheme.primary,
    );
    expect(
      tester.getSemantics(find.text('歌曲')),
      matchesSemantics(
        label: '歌曲',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasSelectedState: true,
        isSelected: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    await tester.tap(seasons);
    await tester.pumpAndSettle();
    expect(selectedIndex, 1);
    expect(
      tester.widget<TextButton>(songs).style!.foregroundColor!.resolve({}),
      theme.colorScheme.onSurfaceVariant,
    );
    expect(
      tester.widget<TextButton>(seasons).style!.foregroundColor!.resolve({}),
      theme.colorScheme.primary,
    );
    final indicators = tester.widgetList<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    expect(
      (indicators.first.decoration! as BoxDecoration).color,
      Colors.transparent,
    );
    expect(
      (indicators.last.decoration! as BoxDecoration).color,
      theme.colorScheme.primary,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty labels and unselected narrow tabs render safely', (
    tester,
  ) async {
    for (final labels in <List<String>>[
      [],
      ['我的', '推荐'],
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 120,
              child: UnderlineTabSwitcher(
                labels: labels,
                selectedIndex: -1,
                minimumSize: const Size(104, 56),
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      for (final indicator in tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      )) {
        expect(
          (indicator.decoration! as BoxDecoration).color,
          Colors.transparent,
        );
      }
    }
  });
}
