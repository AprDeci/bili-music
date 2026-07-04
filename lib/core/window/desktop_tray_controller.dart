import 'dart:async';

import 'package:bilimusic/common/util/platform_util.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class DesktopTrayController with TrayListener, WindowListener {
  DesktopTrayController({
    required this.onExitRequested,
    required this.onMainWindowClosedRequested,
    required this.onMainWindowShownRequested,
    required this.onOpenDesktopLyricsRequested,
  });

  final Future<void> Function() onExitRequested;
  final Future<void> Function() onMainWindowClosedRequested;
  final Future<void> Function() onMainWindowShownRequested;
  final Future<void> Function() onOpenDesktopLyricsRequested;

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
          MenuItem(key: 'open_desktop_lyrics', label: '打开桌面歌词'),
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

  Future<void> requestExit() => _exitApp();

  @override
  void onWindowClose() {
    if (_isExitRequested) {
      return;
    }

    unawaited(_closeMainWindow());
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
      case 'open_desktop_lyrics':
        unawaited(onOpenDesktopLyricsRequested());
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
    await onMainWindowShownRequested();
  }

  Future<void> _closeMainWindow() async {
    await windowManager.hide();
    await onMainWindowClosedRequested();
  }

  Future<void> _exitApp() async {
    if (_isExitRequested) {
      return;
    }
    _isExitRequested = true;
    await windowManager.hide();
    await onExitRequested();
    detach();
    await trayManager.destroy();
    await windowManager.setPreventClose(false);
    await windowManager.destroy();
  }
}
