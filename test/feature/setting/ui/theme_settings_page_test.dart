import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/setting/ui/theme_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('appearance settings expose the chapter marker style entry', (
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
        child: const MaterialApp(home: ThemeSettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('外观设置'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('章节分隔样式'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('进度条'), findsOneWidget);
    expect(find.text('章节分隔样式'), findsOneWidget);
    expect(find.text('当前：竖线'), findsOneWidget);
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
  bool readBool(String key, {required bool defaultValue}) {
    final String? raw = values[key];
    return raw == null ? defaultValue : raw == 'true';
  }

  @override
  Future<void> writeBool(String key, bool value) async {
    values[key] = value ? 'true' : 'false';
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
