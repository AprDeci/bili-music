import 'dart:async';

import 'package:bilimusic/common/util/platform_util.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class DesktopTrayController with TrayListener, WindowListener {
  bool _isExitRequested = false;

  Future<void> attach() async {
    await windowManager.setPreventClose(true);
    windowManager.addListener(this);
    trayManager.addListener(this);

    await trayManager.setIcon(
      PlatformUtil.isWindows
          ? 'assets/icons/tray_icon.ico'
          : 'assets/icons/tray_icon.png',
    );
    await trayManager.setToolTip('BiliMusic');
    await trayManager.setContextMenu(
      Menu(
        items: <MenuItem>[
          MenuItem(key: 'show_window', label: '显示窗口'),
          MenuItem.separator(),
          MenuItem(key: 'exit_app', label: '退出'),
        ],
      ),
    );
  }

  void detach() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
  }

  @override
  void onWindowClose() {
    if (_isExitRequested) {
      return;
    }

    unawaited(windowManager.hide());
  }

  @override
  void onTrayIconMouseDown() {
    unawaited(_showWindow());
  }

  @override
  void onTrayIconRightMouseDown() {
    unawaited(trayManager.popUpContextMenu());
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show_window':
        unawaited(_showWindow());
      case 'exit_app':
        unawaited(_exitApp());
    }
  }

  Future<void> _showWindow() async {
    await windowManager.show();
    if (await windowManager.isMinimized()) {
      await windowManager.restore();
    }
    await windowManager.focus();
  }

  Future<void> _exitApp() async {
    _isExitRequested = true;
    await trayManager.destroy();
    await windowManager.setPreventClose(false);
    await windowManager.destroy();
  }
}
