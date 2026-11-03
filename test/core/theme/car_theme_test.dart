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
    expect(button.foregroundColor!.resolve({}), colors.onPrimary);
    expect(button.foregroundColor!.resolve({}), Colors.white);
    expect(button.backgroundColor!.resolve({}), colors.primary);
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
    expect(button.foregroundColor!.resolve({}), Colors.white);
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
