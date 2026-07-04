import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/window/desktop_hotkey_controller.dart';
import 'package:bilimusic/core/window/desktop_tray_controller.dart';
import 'package:bilimusic/core/window/desktop_window_state_controller.dart';
import 'package:bilimusic/core/window/desktop_window_state_store.dart';
import 'package:bilimusic/feature/player/logic/desktop_lyrics_settings_controller.dart';
import 'package:bilimusic/feature/player/logic/desktop_lyrics_window_controller.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
// ignore: depend_on_referenced_packages
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

class DesktopAppLifecycle {
  DesktopAppLifecycle._(this._container);

  final AppLogger _logger = AppLogger('DesktopAppLifecycle');
  final ProviderContainer _container;
  DesktopTrayController? _trayController;
  DesktopWindowStateController? _windowStateController;
  DesktopLyricsWindowController? _desktopLyricsWindowController;
  DesktopHotkeyController? _hotkeyController;
  bool _isShuttingDown = false;

  static Future<DesktopAppLifecycle> initialize(
    ProviderContainer container,
  ) async {
    await windowManager.ensureInitialized();

    final DesktopAppLifecycle lifecycle = DesktopAppLifecycle._(container);
    await lifecycle._attachTray();
    await lifecycle._attachWindowState();
    await lifecycle._tryAttachDesktopLyricsWindow();
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
    await _tryDetachDesktopLyricsWindow();
    await _trySaveAndDetachWindowState();
    _tryDisposeProviders();
    await _tryCloseHive();
  }

  Future<void> _attachTray() async {
    _trayController = DesktopTrayController(
      onExitRequested: shutdown,
      onMainWindowClosedRequested: _handleMainWindowClosed,
      onMainWindowShownRequested: _handleMainWindowShown,
      onOpenDesktopLyricsRequested: _openDesktopLyrics,
    );
    await _trayController!.attach();
  }

  Future<void> _attachWindowState() async {
    final DesktopWindowStateStore windowStateStore = DesktopWindowStateStore(
      Hive.box<String>(HiveBoxNames.prefs),
    );
    final DesktopWindowState? savedWindowState = windowStateStore.read();
    final DesktopWindowStateController controller =
        DesktopWindowStateController(windowStateStore);
    final DesktopWindowState? visibleWindowState =
        await _validatedVisibleWindowState(savedWindowState);

    _windowStateController = controller;
    _showWindowWhenReady(visibleWindowState);
    controller.attach();
  }

  Future<DesktopWindowState?> _validatedVisibleWindowState(
    DesktopWindowState? savedWindowState,
  ) async {
    if (savedWindowState == null) {
      return null;
    }

    try {
      final List<Display> displays = await screenRetriever.getAllDisplays();
      if (_isWindowVisibleOnAnyDisplay(savedWindowState, displays)) {
        return savedWindowState;
      }
    } on Object {
      return savedWindowState;
    }
    return null;
  }

  bool _isWindowVisibleOnAnyDisplay(
    DesktopWindowState state,
    List<Display> displays,
  ) {
    final Rect windowRect = state.position & state.size;
    for (final Display display in displays) {
      final Offset displayPosition = display.visiblePosition ?? Offset.zero;
      final Size displaySize = display.visibleSize ?? display.size;
      final Rect displayRect = displayPosition & displaySize;
      final Rect visibleRect = windowRect.intersect(displayRect);
      if (visibleRect.width >= 120 && visibleRect.height >= 80) {
        return true;
      }
    }
    return false;
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

  Future<void> _attachDesktopLyricsWindow() async {
    final DesktopLyricsWindowController controller =
        DesktopLyricsWindowController(_container);
    _desktopLyricsWindowController = controller;
    await controller.attach();
  }

  Future<void> _tryAttachDesktopLyricsWindow() async {
    try {
      await _attachDesktopLyricsWindow();
    } on Object catch (error, stackTrace) {
      _logger.e('Attach desktop lyrics window failed', error, stackTrace);
      _desktopLyricsWindowController = null;
    }
  }

  Future<void> _openDesktopLyrics() async {
    await _container
        .read(desktopLyricsSettingsControllerProvider.notifier)
        .setEnabled(true);
    await windowManager.hide();
    await _handleMainWindowClosed();
  }

  Future<void> _handleMainWindowClosed() async {
    await _desktopLyricsWindowController?.markMainWindowClosed();
  }

  Future<void> _handleMainWindowShown() async {
    await _desktopLyricsWindowController?.markMainWindowVisible();
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

  Future<void> _tryDetachDesktopLyricsWindow() async {
    try {
      await _desktopLyricsWindowController?.detach();
    } on Object {
      // Ignore desktop lyrics cleanup failures.
    }
    _desktopLyricsWindowController = null;
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
