import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/player/domain/player_ui_style.dart';
import 'package:bilimusic/feature/player/logic/player_ui_style_logic.dart';
import 'package:bilimusic/feature/setting/ui/player_style_settings_page.dart';
import 'package:bilimusic/feature/setting/ui/theme_settings_page.dart';
import 'package:bilimusic/router/routers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  late _MemorySettingsStore store;
  late ProviderContainer container;

  setUp(() {
    store = _MemorySettingsStore();
    container = ProviderContainer(
      overrides: [appSettingsStoreProvider.overrideWithValue(store)],
    );
  });

  tearDown(() => container.dispose());

  Widget wrap(Widget child) => UncontrolledProviderScope(
    container: container,
    child: MaterialApp(home: child),
  );

  testWidgets(
    'preview and radio both select and persist without leaving page',
    (WidgetTester tester) async {
      await tester.pumpWidget(wrap(const PlayerStyleSettingsPage()));
      await tester.runAsync(() async {
        for (final PlayerUiStyle style in PlayerUiStyle.values) {
          await precacheImage(
            AssetImage('assets/player_styles/${style.storageValue}.webp'),
            tester.element(find.byType(PlayerStyleSettingsPage)),
            onError: (error, stack) => fail('Preview failed to load: $error'),
          );
        }
      });
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsNWidgets(PlayerUiStyle.values.length));
      expect(find.byType(RadioListTile<PlayerUiStyle>), findsNWidgets(2));
      expect(
        tester
            .widget<RadioGroup<PlayerUiStyle>>(
              find.byType(RadioGroup<PlayerUiStyle>),
            )
            .groupValue,
        PlayerUiStyle.classic,
      );

      await tester.tap(find.bySemanticsLabel('选择Apple Music风格'));
      await tester.pumpAndSettle();
      expect(
        container.read(playerUiStyleLogicProvider),
        PlayerUiStyle.appleMusic,
      );
      expect(store.values[HiveKeys.playerUiStyle], 'appleMusic');
      expect(find.byType(PlayerStyleSettingsPage), findsOneWidget);

      await tester.tap(find.text('经典'));
      await tester.pumpAndSettle();
      expect(container.read(playerUiStyleLogicProvider), PlayerUiStyle.classic);
      expect(store.values[HiveKeys.playerUiStyle], 'classic');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('restores the saved style as the selected radio', (
    WidgetTester tester,
  ) async {
    store.values[HiveKeys.playerUiStyle] = 'appleMusic';
    await tester.pumpWidget(wrap(const PlayerStyleSettingsPage()));
    await tester.pumpAndSettle();

    final RadioListTile<PlayerUiStyle> apple = tester.widget(
      find.widgetWithText(RadioListTile<PlayerUiStyle>, 'Apple Music'),
    );
    expect(apple.selected, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('two previews fit a narrow dark screen with large text', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: ThemeData.dark(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: const PlayerStyleSettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Finder previews = find.byType(Image);
    expect(
      tester.getTopLeft(previews.first).dy,
      tester.getTopLeft(previews.last).dy,
    );
    await tester.ensureVisible(find.text('Apple Music'));
    await tester.tap(find.text('Apple Music'));
    await tester.pumpAndSettle();
    expect(
      container.read(playerUiStyleLogicProvider),
      PlayerUiStyle.appleMusic,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile appearance route opens and returns from style selector', (
    WidgetTester tester,
  ) async {
    final Map<String, dynamic> settings = mobileHiddenBranches.firstWhere(
      (entry) => entry['path'] == '/settings',
    );
    final GoRoute themeRoute = (settings['routes'] as List<RouteBase>)
        .whereType<GoRoute>()
        .firstWhere((route) => route.path == 'theme');
    final GoRouter router = GoRouter(
      initialLocation: '/settings/theme',
      routes: [
        GoRoute(
          path: '/settings',
          builder: (_, _) => const SizedBox(),
          routes: [themeRoute],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ThemeSettingsPage), findsOneWidget);

    router.push<void>('/settings/theme/player-style');
    await tester.pumpAndSettle();
    expect(find.byType(PlayerStyleSettingsPage), findsOneWidget);
    await tester.tap(find.text('Apple Music'));
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();
    expect(find.byType(ThemeSettingsPage), findsOneWidget);
    expect(store.values[HiveKeys.playerUiStyle], 'appleMusic');
  });
}

class _MemorySettingsStore implements AppSettingsStore {
  final Map<String, String> values = <String, String>{};

  @override
  String readString(String key, {required String defaultValue}) =>
      values[key] ?? defaultValue;

  @override
  bool readBool(String key, {required bool defaultValue}) =>
      values[key] == null ? defaultValue : values[key] == 'true';

  @override
  Future<void> writeString(String key, String value) async {
    values[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
