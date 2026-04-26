import 'dart:async';

import 'package:bilimusic/core/window/desktop_window_state_store.dart';
import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

class DesktopWindowStateController with WindowListener {
  DesktopWindowStateController(this._store);

  final DesktopWindowStateStore _store;
  Timer? _saveTimer;

  void attach() {
    windowManager.addListener(this);
  }

  void detach() {
    _saveTimer?.cancel();
    windowManager.removeListener(this);
  }

  @override
  void onWindowMove() {
    _scheduleSave();
  }

  @override
  void onWindowResize() {
    _scheduleSave();
  }

  @override
  void onWindowMaximize() {
    unawaited(_saveMaximizedState(true));
  }

  @override
  void onWindowUnmaximize() {
    unawaited(_saveMaximizedState(false));
    _scheduleSave();
  }

  @override
  void onWindowClose() {
    _saveTimer?.cancel();
    unawaited(_saveNow());
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 400), () {
      unawaited(_saveNow());
    });
  }

  Future<void> _saveMaximizedState(bool isMaximized) async {
    final DesktopWindowState? currentState = _store.read();
    if (currentState == null) {
      await _saveNow(isMaximizedOverride: isMaximized);
      return;
    }

    await _store.write(
      DesktopWindowState(
        position: currentState.position,
        size: currentState.size,
        isMaximized: isMaximized,
      ),
    );
  }

  Future<void> _saveNow({bool? isMaximizedOverride}) async {
    if (await windowManager.isMinimized()) {
      return;
    }

    final bool isMaximized =
        isMaximizedOverride ?? await windowManager.isMaximized();
    if (isMaximized) {
      final DesktopWindowState? currentState = _store.read();
      if (currentState != null) {
        await _store.write(
          DesktopWindowState(
            position: currentState.position,
            size: currentState.size,
            isMaximized: true,
          ),
        );
      }
      return;
    }

    final Offset position = await windowManager.getPosition();
    final Size size = await windowManager.getSize();
    await _store.write(
      DesktopWindowState(
        position: position,
        size: Size(
          size.width.clamp(defaultDesktopWindowSize.width, double.infinity),
          size.height.clamp(defaultDesktopWindowSize.height, double.infinity),
        ),
        isMaximized: false,
      ),
    );
  }
}
