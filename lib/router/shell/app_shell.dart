import 'package:bilimusic/common/util/screen_util.dart';
import 'package:bilimusic/feature/updater/logic/update_checker.dart';
import 'package:bilimusic/router/shell/desktop_shell_scaffold.dart';
import 'package:bilimusic/router/util/mobile_chrome_config.dart';
import 'package:bilimusic/router/shell/mobile_shell_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
    required this.currentLocation,
  });

  final StatefulNavigationShell navigationShell;
  final String currentLocation;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    UpdateChecker.scheduleStartupCheck(context);
  }

  @override
  Widget build(BuildContext context) {
    if (ScreenUtil.shouldUseDesktopShell(context)) {
      return DesktopShellScaffold(
        navigationShell: widget.navigationShell,
        currentLocation: widget.currentLocation,
      );
    }

    return MobileShellScaffold(
      navigationShell: widget.navigationShell,
      currentLocation: widget.currentLocation,
      chrome: MobileChromeConfig.resolve(widget.currentLocation),
    );
  }
}
