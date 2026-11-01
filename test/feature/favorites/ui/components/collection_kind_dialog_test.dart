import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/feature/favorites/ui/components/collection_kind_dialog.dart';
import 'package:bilimusic/feature/favorites/ui/components/collection_kind_tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final bool smallScreen in [true, false]) {
    for (final CollectionKind initialKind in CollectionKind.values) {
      testWidgets(
        '${smallScreen ? 'small screen' : 'desktop'} preselects $initialKind and commits only on confirmation',
        (WidgetTester tester) async {
          tester.view.physicalSize = smallScreen
              ? const Size(320, 568)
              : const Size(1000, 800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final List<CollectionKind?> results = [];
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (BuildContext context) => Scaffold(
                  body: TextButton(
                    onPressed: () async {
                      results.add(
                        await showCollectionKindDialog(
                          context: context,
                          initialKind: initialKind,
                        ),
                      );
                    },
                    child: const Text('打开'),
                  ),
                ),
              ),
            ),
          );
          final CollectionKind otherKind = initialKind == CollectionKind.music
              ? CollectionKind.spoken
              : CollectionKind.music;
          for (final bool confirm in [false, true]) {
            await tester.tap(find.text('打开'));
            await tester.pumpAndSettle();
            expect(
              tester
                  .widget<RadioGroup<CollectionKind>>(
                    find.byType(RadioGroup<CollectionKind>),
                  )
                  .groupValue,
              initialKind,
            );
            expect(find.textContaining('匹配歌曲信息'), findsNWidgets(2));
            expect(find.textContaining('收听进度'), findsOneWidget);
            expect(
              tester
                  .widgetList<CollectionKindIcon>(
                    find.byType(CollectionKindIcon),
                  )
                  .map((icon) => icon.kind),
              CollectionKind.values,
            );
            await tester.ensureVisible(find.text(otherKind.label));
            await tester.tap(find.text(otherKind.label));
            await tester.pumpAndSettle();
            expect(
              tester
                  .widget<RadioGroup<CollectionKind>>(
                    find.byType(RadioGroup<CollectionKind>),
                  )
                  .groupValue,
              otherKind,
            );
            await tester.tap(find.text(confirm ? '确定' : '取消'));
            await tester.pumpAndSettle();
          }
          expect(results, [null, otherKind]);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
