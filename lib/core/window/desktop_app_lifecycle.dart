import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/window/desktop_hotkey_controller.dart';
import 'package:bilimusic/core/window/desktop_tray_controller.dart';
import 'package:bilimusic/core/window/desktop_window_state_controller.dart';
import 'package:bilimusic/core/window/desktop_window_state_store.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:window_manager/window_manager.dart';

class DesktopAppLifecycle {
  DesktopAppLifecycle._(this._container);

  final ProviderContainer _container;
  DesktopTrayController? _trayController;
  DesktopWindowStateController? _windowStateController;
  DesktopHotkeyController? _hotkeyController;
  bool _isShuttingDown = false;

  static Future<DesktopAppLifecycle> initialize(
    ProviderContainer container,
  ) async {
    await windowManager.ensureInitialized();

    final DesktopAppLifecycle lifecycle = DesktopAppLifecycle._(container);
    await lifecycle._attachTray();
    await lifecycle._attachWindowState();
    return lifecycle;
  }

  void attachHotkeyController(DesktopHotkeyController controller) {
    _hotkeyController = controller;
  }

  Future<void> detachHotkeyController(
    DesktopHotkeyController controller,
  ) async {
    if (!identical(_hotkeyController, controller)) {
      return;
    }
    _hotkeyController = null;
    await controller.detach();
  }

  Future<void> shutdown() async {
    if (_isShuttingDown) {
      return;
    }
    _isShuttingDown = true;

    await _tryShutdownPlayer();
    await _tryDetachHotkeys();
    await _trySaveAndDetachWindowState();
    _tryDisposeProviders();
    await _tryCloseHive();
  }

  Future<void> _attachTray() async {
    _trayController = DesktopTrayController(onExitRequested: shutdown);
    await _trayController!.attach();
  }

  Future<void> _attachWindowState() async {
    final DesktopWindowStateStore windowStateStore = DesktopWindowStateStore(
      Hive.box<String>(HiveBoxNames.prefs),
    );
    final DesktopWindowState? savedWindowState = windowStateStore.read();
    final DesktopWindowStateController controller =
        DesktopWindowStateController(windowStateStore);

    _windowStateController = controller;
    _showWindowWhenReady(savedWindowState);
    controller.attach();
  }

  void _showWindowWhenReady(DesktopWindowState? savedWindowState) {
    final WindowOptions windowOptions = WindowOptions(
      size: savedWindowState?.size ?? defaultDesktopWindowSize,
      minimumSize: defaultDesktopWindowSize,
      center: savedWindowState == null,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      if (savedWindowState != null) {
        await windowManager.setPosition(savedWindowState.position);
      }
      await windowManager.show();
      if (savedWindowState?.isMaximized == true) {
        await windowManager.maximize();
      }
      await windowManager.focus();
    });
  }

  Future<void> _tryShutdownPlayer() async {
    try {
      await _container.read(playerControllerProvider.notifier).shutdown();
    } on Object {
      // Continue shutting down even if the player fails to release cleanly.
    }
  }

  Future<void> _tryDetachHotkeys() async {
    try {
      await _hotkeyController?.detach();
    } on Object {
      // Ignore hotkey cleanup failures.
    }
    _hotkeyController = null;
  }

  Future<void> _trySaveAndDetachWindowState() async {
    try {
      await _windowStateController?.saveNow();
      _windowStateController?.detach();
    } on Object {
      // Ignore window-state cleanup failures.
    }
    _windowStateController = null;
  }

  void _tryDisposeProviders() {
    try {
      _container.dispose();
    } on Object {
      // Ignore provider disposal failures.
    }
  }

  Future<void> _tryCloseHive() async {
    try {
      await Hive.close();
    } on Object {
      // Ignore Hive cleanup failures during process shutdown.
    }
  }
}
