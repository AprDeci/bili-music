import 'package:bilimusic/core/theme/app_theme.dart';
import 'package:bilimusic/core/theme/car_theme.dart';
import 'package:bilimusic/core/theme/theme_catalog.dart';
import 'package:bilimusic/core/theme/theme_logic.dart';
import 'package:bilimusic/core/theme/theme_ui_model.dart';
import 'package:bilimusic/feature/listening/domain/listening_state.dart';
import 'package:bilimusic/feature/listening/logic/listening_progress_controller.dart';
import 'package:bilimusic/feature/setting/logic/car_ui_setting_logic.dart';
import 'package:bilimusic/myApp.dart';
import 'package:bilimusic/router/routers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('filled buttons stay neutral in light and dark themes', (
    tester,
  ) async {
    for (final definition in themeCatalog) {
      for (final brightness in Brightness.values) {
        final bool dark = brightness == Brightness.dark;
        final Color background = dark
            ? const Color(0xFF20242C)
            : Colors.grey.shade200;
        final Color foreground = dark ? const Color(0xFFF1F3F4) : Colors.black;
        for (final theme in [
          dark
              ? AppTheme.darkTheme(definition.id)
              : AppTheme.lightTheme(definition.id),
          dark ? carDarkTheme() : carLightTheme(),
        ]) {
          final style = theme.filledButtonTheme.style!;
          expect(style.backgroundColor!.resolve({}), background);
          expect(style.foregroundColor!.resolve({}), foreground);
          expect(
            style.backgroundColor!.resolve({WidgetState.disabled}),
            background,
          );
          expect(
            style.foregroundColor!.resolve({WidgetState.disabled}),
            dark ? Colors.white38 : Colors.black38,
          );
          expect(_contrast(foreground, background), greaterThanOrEqualTo(7));
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: Scaffold(
                body: Column(
                  children: [
                    FilledButton(onPressed: () {}, child: const Text('filled')),
                    FilledButton.tonal(
                      onPressed: () {},
                      child: const Text('tonal'),
                    ),
                    const FilledButton(
                      onPressed: null,
                      child: Text('disabled'),
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          for (final button in tester.widgetList<FilledButton>(
            find.byType(FilledButton),
          )) {
            final finder = find.byWidget(button);
            final material = tester.widget<Material>(
              find.descendant(of: finder, matching: find.byType(Material)),
            );
            expect(material.color, background);
            expect(
              tester
                  .widget<RichText>(
                    find.descendant(
                      of: finder,
                      matching: find.byType(RichText),
                    ),
                  )
                  .text
                  .style!
                  .color,
              button.onPressed == null
                  ? (dark ? Colors.white38 : Colors.black38)
                  : foreground,
            );
          }
        }
      }
    }
  });

  test('car light palette is neutral with accessible green accents', () {
    final ThemeData theme = carLightTheme();
    final ColorScheme colors = theme.colorScheme;
    expect(theme.brightness, Brightness.light);
    expect(colors.surface, Colors.white);
    expect(theme.cardTheme.color, Colors.white);
    expect(theme.bottomSheetTheme.backgroundColor, Colors.white);
    expect(theme.scaffoldBackgroundColor, const Color(0xFFEDEFF1));
    expect(colors.surfaceTint, Colors.transparent);
    for (final background in [
      colors.surface,
      colors.surfaceContainerLow,
      colors.primaryContainer,
    ]) {
      expect(_contrast(colors.onSurface, background), greaterThanOrEqualTo(7));
      expect(
        _contrast(colors.onSurfaceVariant, background),
        greaterThanOrEqualTo(4.5),
      );
      expect(_contrast(colors.primary, background), greaterThanOrEqualTo(3));
      expect((background.r - background.g).abs(), lessThan(0.03));
      expect((background.g - background.b).abs(), lessThan(0.03));
    }
    expect(
      _contrast(colors.primary, colors.surface),
      greaterThanOrEqualTo(4.5),
    );
    final ButtonStyle button = theme.filledButtonTheme.style!;
    expect(button.foregroundColor!.resolve({}), Colors.black);
    expect(button.backgroundColor!.resolve({}), Colors.grey.shade200);
    expect(
      _contrast(
        button.foregroundColor!.resolve({})!,
        button.backgroundColor!.resolve({})!,
      ),
      greaterThanOrEqualTo(4.5),
    );
    expect(theme.sliderTheme.activeTrackColor, colors.onSurfaceVariant);
    expect(theme.textTheme.bodyLarge!.color, colors.onSurface);
  });

  test('car dark palette keeps surfaces black and controls readable', () {
    final ThemeData theme = carDarkTheme();
    final ColorScheme colors = theme.colorScheme;
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, const Color(0xFF101318));
    expect(
      _contrast(colors.surface, theme.scaffoldBackgroundColor),
      inInclusiveRange(1.18, 1.24),
    );
    expect(theme.cardTheme.color, colors.surface);
    expect(theme.bottomSheetTheme.backgroundColor, colors.surface);
    expect(colors.surfaceTint, Colors.transparent);
    for (final background in [
      colors.surface,
      colors.surfaceContainerLow,
      colors.surfaceContainerHighest,
      colors.primaryContainer,
      colors.secondaryContainer,
    ]) {
      expect(background.computeLuminance(), lessThan(0.05));
      expect(_contrast(colors.onSurface, background), greaterThanOrEqualTo(7));
      expect(
        _contrast(colors.onSurfaceVariant, background),
        greaterThanOrEqualTo(4.5),
      );
      expect(_contrast(colors.primary, background), greaterThanOrEqualTo(4.5));
    }
    expect(
      _contrast(colors.onPrimaryContainer, colors.primaryContainer),
      greaterThanOrEqualTo(7),
    );
    expect(
      _contrast(colors.onPrimary, colors.primary),
      greaterThanOrEqualTo(7),
    );
    final ButtonStyle button = theme.filledButtonTheme.style!;
    expect(button.foregroundColor!.resolve({}), const Color(0xFFF1F3F4));
    expect(button.backgroundColor!.resolve({}), const Color(0xFF20242C));
    expect(
      _contrast(
        button.foregroundColor!.resolve({})!,
        button.backgroundColor!.resolve({})!,
      ),
      greaterThanOrEqualTo(4.5),
    );
    expect(theme.iconTheme.color, colors.onSurface);
    expect(theme.sliderTheme.activeTrackColor, colors.onSurfaceVariant);
    expect(theme.textTheme.bodyLarge!.color, colors.onSurface);
  });

  testWidgets('car mode is isolated and restores the selected app theme', (
    tester,
  ) async {
    final GoRouter router = GoRouter(
      navigatorKey: rootNavigatorKey,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('theme probe')),
        ),
      ],
    );
    addTearDown(router.dispose);
    final ProviderContainer container = ProviderContainer(
      overrides: [
        routerProvider.overrideWithValue(router),
        themeLogicProvider.overrideWith(_Theme.new),
        carUiSettingLogicProvider.overrideWith(_CarMode.new),
        listeningProgressControllerProvider.overrideWithValue(
          const ListeningState(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
    await tester.pumpAndSettle();
    ThemeData actual() => Theme.of(tester.element(find.text('theme probe')));
    final ThemeData standard = AppTheme.lightTheme('skyBlue');
    expect(actual().colorScheme, standard.colorScheme);
    await container.read(carUiSettingLogicProvider.notifier).setEnabled(true);
    await tester.pumpAndSettle();
    expect(actual().colorScheme, carLightTheme().colorScheme);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpAndSettle();
    expect(actual().colorScheme, standard.colorScheme);
    expect(container.read(carUiSettingLogicProvider), isTrue);
    expect(
      MediaQuery.sizeOf(tester.element(find.text('theme probe'))),
      const Size(390, 844),
    );
    tester.view.physicalSize = const Size(844, 390);
    await tester.pumpAndSettle();
    expect(actual().colorScheme, carLightTheme().colorScheme);
    expect(container.read(themeLogicProvider).themeVariantId, 'skyBlue');
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.darkTheme!.colorScheme, carDarkTheme().colorScheme);
    container.read(themeLogicProvider.notifier).setThemeMode(ThemeMode.dark);
    await tester.pumpAndSettle();
    expect(actual().colorScheme, carDarkTheme().colorScheme);
    container.read(themeLogicProvider.notifier).setThemeVariant('irisPurple');
    await tester.pumpAndSettle();
    expect(actual().colorScheme, carDarkTheme().colorScheme);
    container.read(themeLogicProvider.notifier).setThemeVariant('skyBlue');
    container.read(themeLogicProvider.notifier).setThemeMode(ThemeMode.system);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(actual().colorScheme, carDarkTheme().colorScheme);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pumpAndSettle();
    expect(actual().colorScheme, carLightTheme().colorScheme);
    container.read(themeLogicProvider.notifier).setThemeMode(ThemeMode.dark);
    await container.read(carUiSettingLogicProvider.notifier).setEnabled(false);
    await tester.pumpAndSettle();
    expect(actual().colorScheme, AppTheme.darkTheme('skyBlue').colorScheme);
    container.read(themeLogicProvider.notifier).setThemeMode(ThemeMode.light);
    await tester.pumpAndSettle();
    expect(actual().colorScheme, standard.colorScheme);
    expect(actual().scaffoldBackgroundColor, standard.scaffoldBackgroundColor);
    for (final definition in themeCatalog) {
      container
          .read(themeLogicProvider.notifier)
          .setThemeVariant(definition.id);
      await tester.pumpAndSettle();
      expect(
        actual().colorScheme,
        AppTheme.lightTheme(definition.id).colorScheme,
      );
    }
    expect(tester.takeException(), isNull);
  });
}

double _contrast(Color a, Color b) {
  final double first = a.computeLuminance();
  final double second = b.computeLuminance();
  return first > second
      ? (first + 0.05) / (second + 0.05)
      : (second + 0.05) / (first + 0.05);
}

class _Theme extends ThemeLogic {
  @override
  ThemeUiModel build() =>
      const ThemeUiModel(themeMode: ThemeMode.light, themeVariantId: 'skyBlue');

  @override
  void setThemeMode(ThemeMode mode) => state = state.copyWith(themeMode: mode);

  @override
  void setThemeVariant(String variantId) =>
      state = state.copyWith(themeVariantId: variantId);
}

class _CarMode extends CarUiSettingLogic {
  @override
  bool build() => false;

  @override
  Future<void> setEnabled(bool value) async => state = value;
}
