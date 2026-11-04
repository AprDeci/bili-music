import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/player/domain/player_chapter_marker_style.dart';
import 'package:bilimusic/feature/player/logic/display/player_chapter_marker_style_logic.dart';
import 'package:bilimusic/feature/setting/ui/progress_bar_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('lists every marker style and persists the selection', (
    WidgetTester tester,
  ) async {
    final _FakeSettingsStore store = _FakeSettingsStore();
    final ProviderContainer container = ProviderContainer(
      overrides: [appSettingsStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ProgressBarSettingsPage()),
      ),
    );

    expect(find.text('章节分隔样式'), findsOneWidget);
    expect(find.text('竖线'), findsOneWidget);
    expect(find.text('圆点'), findsOneWidget);
    expect(find.text('预览'), findsOneWidget);

    await tester.tap(find.text('圆点'));
    await tester.pumpAndSettle();

    expect(store.values['player.chapter_marker_style'], 'dot');
    expect(
      container.read(playerChapterMarkerStyleLogicProvider),
      PlayerChapterMarkerStyle.dot,
    );
    expect(tester.takeException(), isNull);
  });
}

class _FakeSettingsStore implements AppSettingsStore {
  final Map<String, String> values = <String, String>{};

  @override
  String readString(String key, {required String defaultValue}) {
    return values[key] ?? defaultValue;
  }

  @override
  Future<void> writeString(String key, String value) async {
    values[key] = value;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
