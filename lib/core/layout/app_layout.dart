import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum AppLayout {
  mobile,
  desktop,
  car;

  static const double desktopBreakpoint = 960;

  static bool get isDesktopPlatform => switch (defaultTargetPlatform) {
    TargetPlatform.windows ||
    TargetPlatform.linux ||
    TargetPlatform.macOS => true,
    _ => false,
  };

  static AppLayout resolve({
    required Size size,
    required bool isDesktop,
    required bool carEnabled,
  }) {
    if (isDesktop) {
      return size.width >= desktopBreakpoint ? desktop : mobile;
    }
    return carEnabled && size.width > size.height ? car : mobile;
  }
}

class AppLayoutScope extends InheritedWidget {
  const AppLayoutScope({super.key, required this.layout, required super.child});

  final AppLayout layout;

  static AppLayout of(BuildContext context) {
    final AppLayoutScope? scope = context
        .dependOnInheritedWidgetOfExactType<AppLayoutScope>();
    return scope?.layout ??
        AppLayout.resolve(
          size: MediaQuery.sizeOf(context),
          isDesktop: AppLayout.isDesktopPlatform,
          carEnabled: false,
        );
  }

  @override
  bool updateShouldNotify(AppLayoutScope oldWidget) =>
      layout != oldWidget.layout;
}
