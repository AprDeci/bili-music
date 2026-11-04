import 'dart:async';
import 'dart:ui';

import 'package:bilimusic/core/devtools/dev_overlay.dart';
import 'package:bilimusic/core/layout/app_layout.dart';
import 'package:bilimusic/core/theme/app_theme.dart';
import 'package:bilimusic/core/theme/car_theme.dart';
import 'package:bilimusic/core/theme/theme_logic.dart';
import 'package:bilimusic/core/theme/theme_ui_model.dart';
import 'package:bilimusic/feature/listening/ui/listening_progress_listener.dart';
import 'package:bilimusic/feature/setting/logic/car_ui_setting_logic.dart';
import 'package:bilimusic/feature/updater/logic/update_checker.dart';
import 'package:bilimusic/router/car_ui_viewport.dart';
import 'package:bilimusic/router/routers.dart';
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
  Timer? _updateCheck;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateCheck = Timer(const Duration(milliseconds: 600), () {
        final BuildContext? navigatorContext = rootNavigatorKey.currentContext;
        if (mounted && navigatorContext != null) {
          unawaited(UpdateChecker.checkAndPrompt(navigatorContext));
        }
      });
    });
  }

  @override
  void dispose() {
    _updateCheck?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GoRouter router = ref.watch(routerProvider);
    final ThemeUiModel currentTheme = ref.watch(themeLogicProvider);
    final bool carUi = ref.watch(carUiSettingLogicProvider);

    return MediaQuery.fromView(
      view: View.of(context),
      child: Builder(
        builder: (context) {
          final AppLayout layout = AppLayout.resolve(
            size: MediaQuery.sizeOf(context),
            isDesktop: AppLayout.isDesktopPlatform,
            carEnabled: carUi,
          );
          final bool useCarLayout = layout == AppLayout.car;
          return AppLayoutScope(
            layout: layout,
            child: MaterialApp.router(
              routerConfig: router,
              themeMode: currentTheme.themeMode,
              theme: useCarLayout
                  ? carLightTheme()
                  : AppTheme.lightTheme(currentTheme.themeVariantId),
              darkTheme: useCarLayout
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
                      CarUiViewport(enabled: useCarLayout, child: content),
                      if (kDebugMode) const DevOverlay(),
                    ],
                  );
                },
              ),
            ),
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
