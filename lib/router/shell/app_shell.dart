import 'package:bilimusic/common/util/screen_util.dart';
import 'package:bilimusic/feature/setting/logic/car_ui_setting_logic.dart';
import 'package:bilimusic/router/shell/car_shell_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bilimusic/router/shell/desktop_shell_scaffold.dart';
import 'package:bilimusic/router/util/mobile_chrome_config.dart';
import 'package:bilimusic/router/shell/mobile_shell_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends ConsumerWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
    required this.currentLocation,
  });

  final StatefulNavigationShell navigationShell;
  final String currentLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(carUiSettingLogicProvider)) {
      return CarShellScaffold(
        navigationShell: navigationShell,
        currentLocation: currentLocation,
      );
    }
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
