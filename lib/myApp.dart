import 'dart:ui';

import 'package:bilimusic/core/devtools/dev_overlay.dart';
import 'package:bilimusic/core/theme/app_theme.dart';
import 'package:bilimusic/core/theme/car_theme.dart';
import 'package:bilimusic/core/theme/theme_logic.dart';
import 'package:bilimusic/core/theme/theme_ui_model.dart';
import 'package:bilimusic/router/routers.dart';
import 'package:bilimusic/router/car_ui_viewport.dart';
import 'package:bilimusic/feature/setting/logic/car_ui_setting_logic.dart';
import 'package:bilimusic/feature/listening/ui/listening_progress_listener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
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
    final bool carUi = ref.watch(carUiSettingLogicProvider);

    return MaterialApp.router(
      routerConfig: router,
      themeMode: currentTheme.themeMode,
      theme: carUi
          ? carLightTheme()
          : AppTheme.lightTheme(currentTheme.themeVariantId),
      darkTheme: carUi
          ? carDarkTheme()
          : AppTheme.darkTheme(currentTheme.themeVariantId),
      scrollBehavior: MyBehavior(),
      builder: FlutterSmartDialog.init(
        builder: (BuildContext context, Widget? child) {
          final Widget content = ListeningProgressListener(
            navigatorKey: rootNavigatorKey,
            child: child ?? const SizedBox.shrink(),
          );
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (carUi) CarUiViewport(child: content) else content,
              if (kDebugMode) const DevOverlay(),
            ],
          );
        },
      ),
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
