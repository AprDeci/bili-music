import 'dart:ui';

import 'package:bilimusic/core/devtools/dev_overlay.dart';
import 'package:bilimusic/core/theme/app_theme.dart';
import 'package:bilimusic/core/theme/theme_logic.dart';
import 'package:bilimusic/core/theme/theme_ui_model.dart';
import 'package:bilimusic/router/routers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    final GoRouter router = ref.watch(routerProvider);
    final ThemeUiModel currentTheme = ref.watch(themeLogicProvider);

    return MaterialApp.router(
      routerConfig: router,
      themeMode: currentTheme.themeMode,
      theme: AppTheme.lightTheme(currentTheme.lightThemeVariant),
      darkTheme: AppTheme.darkTheme(),
      scrollBehavior: MyBehavior(),
      builder: (BuildContext context, Widget? child) {
        return Stack(
          children: <Widget>[
            child ?? const SizedBox.shrink(),
            if (kDebugMode) const DevOverlay(),
          ],
        );
      },
    );
  }
}

class MyBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
