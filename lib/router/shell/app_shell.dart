import 'package:bilimusic/common/util/screen_util.dart';
import 'package:bilimusic/router/shell/desktop_shell_scaffold.dart';
import 'package:bilimusic/router/util/mobile_chrome_config.dart';
import 'package:bilimusic/router/shell/mobile_shell_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
    required this.currentLocation,
  });

  final StatefulNavigationShell navigationShell;
  final String currentLocation;

  @override
  Widget build(BuildContext context) {
    if (ScreenUtil.shouldUseDesktopShell(context)) {
      return DesktopShellScaffold(
        navigationShell: navigationShell,
        currentLocation: currentLocation,
      );
    }

    return MobileShellScaffold(
      navigationShell: navigationShell,
      currentLocation: currentLocation,
      chrome: MobileChromeConfig.resolve(currentLocation),
    );
  }
}
