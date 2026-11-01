import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/feature/favorites/ui/components/collection_kind_tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';

void main() {
  for (final Brightness brightness in Brightness.values) {
    for (final CollectionKind kind in CollectionKind.values) {
      testWidgets('$brightness $kind tag is labeled and not interactive', (
        WidgetTester tester,
      ) async {
        final SemanticsHandle semantics = tester.ensureSemantics();
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: Scaffold(
              body: Center(child: CollectionKindTag(kind: kind)),
            ),
          ),
        );
        final HugeIcon icon = tester.widget(find.byType(HugeIcon));
        expect(
          icon.icon,
          kind == CollectionKind.music
              ? HugeIcons.strokeRoundedMusicNote02
              : HugeIcons.strokeRoundedHeadphones,
        );
        expect(find.text(kind.label), findsOneWidget);
        expect(find.byType(PopupMenuButton<CollectionKind>), findsNothing);
        expect(
          tester.getSemantics(find.byType(CollectionKindTag)),
          matchesSemantics(label: '歌单类型：${kind.label}'),
        );
        expect(
          tester
              .getSemantics(find.byType(CollectionKindTag))
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          isFalse,
        );
        await tester.tap(find.byType(CollectionKindTag));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(tester.takeException(), isNull);
        semantics.dispose();
      });
    }
  }
}
