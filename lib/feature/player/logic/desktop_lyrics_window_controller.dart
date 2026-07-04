import 'dart:async';
import 'dart:convert';

import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/common/util/player_util.dart';
import 'package:bilimusic/feature/favorites/logic/favorites_controller.dart';
import 'package:bilimusic/feature/metadata/domain/metadata.dart';
import 'package:bilimusic/feature/metadata/domain/metadata_state.dart';
import 'package:bilimusic/feature/metadata/logic/metadata_controller.dart';
import 'package:bilimusic/feature/player/domain/desktop_lyrics_payload.dart';
import 'package:bilimusic/feature/player/domain/desktop_lyrics_settings.dart';
import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/desktop_lyrics_settings_controller.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

class DesktopLyricsWindowController with WindowListener {
  DesktopLyricsWindowController(this._container);

  final AppLogger _logger = AppLogger('DesktopLyricsWindowController');
  final ProviderContainer _container;
  final List<ProviderSubscription<dynamic>> _subscriptions =
      <ProviderSubscription<dynamic>>[];

  WindowController? _window;
  bool _isMainWindowClosed = false;
  bool _isDisposed = false;
  DesktopLyricsPayload _lastPayload = DesktopLyricsPayload.empty;
  String? _lastSentPayloadJson;
  Timer? _sendRetryTimer;
  Future<void>? _activeSync;
  bool _pendingSync = false;

  Future<void> attach() async {
    windowManager.addListener(this);
    DesktopMultiWindow.setMethodHandler(_handleMethodCall);

    _subscriptions.add(
      _container.listen<PlayerState>(
        playerControllerProvider,
        (_, _) => _scheduleSync(),
        fireImmediately: true,
      ),
    );
    _subscriptions.add(
      _container.listen<MetadataState>(
        metadataControllerProvider,
        (_, _) => _scheduleSync(),
        fireImmediately: true,
      ),
    );
    _subscriptions.add(
      _container.listen<DesktopLyricsSettings>(
        desktopLyricsSettingsControllerProvider,
        (_, _) => _scheduleSync(),
        fireImmediately: true,
      ),
    );
    _subscriptions.add(
      _container.listen(
        favoritesControllerProvider,
        (_, _) => _scheduleSync(),
        fireImmediately: true,
      ),
    );

    // The main window is still being prepared during bootstrap. Treat it as
    // visible so a persisted "desktop lyrics enabled" setting cannot create a
    // child window before the primary window is ready.
    _isMainWindowClosed = false;
    await _syncSafely();
  }

  Future<void> detach() async {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    _sendRetryTimer?.cancel();
    _sendRetryTimer = null;
    windowManager.removeListener(this);
    DesktopMultiWindow.setMethodHandler(null);
    for (final ProviderSubscription<dynamic> subscription in _subscriptions) {
      subscription.close();
    }
    _subscriptions.clear();
    await _closeWindow();
  }

  @override
  void onWindowFocus() {
    unawaited(markMainWindowVisible());
  }

  Future<void> markMainWindowClosed() async {
    _isMainWindowClosed = true;
    await _syncSafely();
  }

  Future<void> markMainWindowVisible() async {
    _isMainWindowClosed = false;
    await _syncSafely();
  }

  Future<dynamic> _handleMethodCall(MethodCall call, int fromWindowId) async {
    if (call.method != 'desktopLyricsCommand') {
      return null;
    }
    final String commandName = call.arguments?.toString() ?? '';
    final DesktopLyricsCommand? command = desktopLyricsCommandFromMethodName(
      commandName,
    );
    if (command == null) {
      return null;
    }
    await _handleCommand(command);
    return true;
  }

  Future<void> _handleCommand(DesktopLyricsCommand command) async {
    final PlayerController playerController = _container.read(
      playerControllerProvider.notifier,
    );
    final PlayableItem? item = _container
        .read(playerControllerProvider)
        .currentItem;

    switch (command) {
      case DesktopLyricsCommand.toggleFavorite:
        if (item != null) {
          await _container
              .read(favoritesControllerProvider.notifier)
              .toggleLiked(item);
        }
      case DesktopLyricsCommand.blacklist:
        if (item != null) {
          await playerController.blacklistItem(item);
        }
      case DesktopLyricsCommand.previous:
        await playerController.skipToPrevious();
      case DesktopLyricsCommand.togglePlayback:
        await playerController.togglePlayback();
      case DesktopLyricsCommand.next:
        await playerController.skipToNext();
      case DesktopLyricsCommand.toggleAlwaysOnTop:
        final DesktopLyricsSettings settings = _container.read(
          desktopLyricsSettingsControllerProvider,
        );
        await _container
            .read(desktopLyricsSettingsControllerProvider.notifier)
            .setAlwaysOnTop(!settings.alwaysOnTop);
      case DesktopLyricsCommand.close:
        await _container
            .read(desktopLyricsSettingsControllerProvider.notifier)
            .setEnabled(false);
        await _closeWindow();
    }
    await _syncSafely();
  }

  void _scheduleSync() {
    unawaited(_syncSafely());
  }

  Future<void> _syncSafely() async {
    final Future<void>? activeSync = _activeSync;
    if (activeSync != null) {
      _pendingSync = true;
      await activeSync;
      return;
    }

    final Future<void> syncFuture = _drainSyncQueue();
    _activeSync = syncFuture;
    try {
      await syncFuture;
    } finally {
      if (identical(_activeSync, syncFuture)) {
        _activeSync = null;
        if (_pendingSync && !_isDisposed) {
          _scheduleSync();
        }
      }
    }
  }

  Future<void> _drainSyncQueue() async {
    do {
      _pendingSync = false;
      try {
        await _sync();
      } on Object catch (error, stackTrace) {
        _logger.e('Sync desktop lyrics window failed', error, stackTrace);
      }
    } while (_pendingSync && !_isDisposed);
  }

  void _requestFollowUpSync() {
    if (_activeSync != null) {
      _pendingSync = true;
      return;
    }
    _scheduleSync();
  }

  Future<void> _sync() async {
    if (_isDisposed) {
      return;
    }
    final DesktopLyricsSettings settings = _container.read(
      desktopLyricsSettingsControllerProvider,
    );
    if (!settings.enabled) {
      await _closeWindow();
      return;
    }

    _lastPayload = _buildPayload(settings);
    if (!_isMainWindowClosed) {
      await _window?.hide();
      return;
    }

    await _showWindowWithPayload();
  }

  Future<void> _showWindowWithPayload({bool didRetry = false}) async {
    final WindowController window = await _ensureWindow();
    try {
      await window.show();
      await _sendPayload(window);
    } on Object catch (error) {
      if (_isTargetWindowMissing(error) && !didRetry) {
        _forgetWindow(window);
        await _showWindowWithPayload(didRetry: true);
        return;
      }
      rethrow;
    }
  }

  Future<WindowController> _ensureWindow() async {
    final WindowController? existingWindow = _window;
    if (existingWindow != null) {
      if (await _isKnownSubWindow(existingWindow)) {
        await _closeDuplicateSubWindows(keepWindowId: existingWindow.windowId);
        return existingWindow;
      }
      _forgetWindow(existingWindow);
    }

    final WindowController? adoptedWindow = await _adoptExistingWindow();
    if (adoptedWindow != null) {
      return adoptedWindow;
    }

    final WindowController window = await DesktopMultiWindow.createWindow(
      jsonEncode(<String, dynamic>{
        'window': 'desktopLyrics',
        ..._lastPayload.toJson(),
      }),
    );
    await window.setTitle('桌面歌词');
    await window.setFrame(await _defaultWindowFrame());
    _window = window;
    return window;
  }

  Future<WindowController?> _adoptExistingWindow() async {
    final List<int> windowIds = await _safeSubWindowIds();
    if (windowIds.isEmpty) {
      return null;
    }

    final WindowController window = WindowController.fromWindowId(
      windowIds.first,
    );
    _window = window;
    await _closeDuplicateSubWindows(keepWindowId: window.windowId);
    _lastSentPayloadJson = null;
    return window;
  }

  Future<Rect> _defaultWindowFrame() async {
    const Size windowSize = Size(760, 190);
    try {
      final Display display = await screenRetriever.getPrimaryDisplay();
      final Offset displayPosition = display.visiblePosition ?? Offset.zero;
      final Size displaySize = display.visibleSize ?? display.size;
      return Rect.fromLTWH(
        displayPosition.dx + (displaySize.width - windowSize.width) / 2,
        displayPosition.dy + displaySize.height - windowSize.height - 88,
        windowSize.width,
        windowSize.height,
      );
    } on Object {
      return const Offset(80, 80) & windowSize;
    }
  }

  Future<void> _sendPayload(WindowController window) async {
    final Map<String, dynamic> payloadJson = _lastPayload.toJson();
    final String encodedPayload = jsonEncode(payloadJson);
    if (_lastSentPayloadJson == encodedPayload) {
      return;
    }
    try {
      await DesktopMultiWindow.invokeMethod(
        window.windowId,
        'desktopLyricsSnapshot',
        payloadJson,
      );
      _lastSentPayloadJson = encodedPayload;
    } on Object catch (error) {
      // The child window may not have installed its method handler yet.
      if (_isTargetWindowMissing(error)) {
        _forgetWindow(window);
        _requestFollowUpSync();
      } else {
        _schedulePayloadRetry(window);
      }
    }
  }

  void _schedulePayloadRetry(WindowController window) {
    if (_isDisposed || _sendRetryTimer?.isActive == true) {
      return;
    }
    _sendRetryTimer = Timer(const Duration(milliseconds: 250), () {
      _sendRetryTimer = null;
      if (_isDisposed || !identical(_window, window)) {
        return;
      }
      unawaited(_sendPayload(window));
    });
  }

  Future<void> _closeWindow() async {
    final WindowController? window = _window;
    if (window != null) {
      _forgetWindow(window);
    } else {
      _lastSentPayloadJson = null;
      _sendRetryTimer?.cancel();
      _sendRetryTimer = null;
    }
    if (window == null) {
      return;
    }
    try {
      await window.close();
    } on Object {
      // Ignore stale child-window failures.
    }
  }

  Future<bool> _isKnownSubWindow(WindowController window) async {
    try {
      final List<int> windowIds = await _safeSubWindowIds();
      return windowIds.contains(window.windowId);
    } on Object catch (error, stackTrace) {
      _logger.w(
        'Check desktop lyrics window existence failed',
        error,
        stackTrace,
      );
      return true;
    }
  }

  Future<List<int>> _safeSubWindowIds() async {
    try {
      return await DesktopMultiWindow.getAllSubWindowIds();
    } on Object catch (error, stackTrace) {
      _logger.w('List desktop lyrics windows failed', error, stackTrace);
      return const <int>[];
    }
  }

  Future<void> _closeDuplicateSubWindows({required int keepWindowId}) async {
    final List<int> windowIds = await _safeSubWindowIds();
    for (final int windowId in windowIds) {
      if (windowId == keepWindowId) {
        continue;
      }
      try {
        await WindowController.fromWindowId(windowId).close();
      } on Object {
        // Ignore stale duplicate-window failures.
      }
    }
  }

  void _forgetWindow(WindowController window) {
    if (!identical(_window, window)) {
      return;
    }
    _window = null;
    _lastSentPayloadJson = null;
    _sendRetryTimer?.cancel();
    _sendRetryTimer = null;
  }

  bool _isTargetWindowMissing(Object error) {
    return error is PlatformException && error.code == '-1';
  }

  DesktopLyricsPayload _buildPayload(DesktopLyricsSettings settings) {
    final PlayerState playerState = _container.read(playerControllerProvider);
    final MetadataState metadataState = _container.read(
      metadataControllerProvider,
    );
    final PlayableItem? item = playerState.currentItem;
    final _LyricPair lyricPair = _resolveLyricPair(playerState, metadataState);
    final bool isFavorite = item != null
        ? _container.read(favoritesControllerProvider).isLiked(item)
        : false;

    return DesktopLyricsPayload(
      title: _resolveTitle(item, metadataState.metadata),
      currentLyric: lyricPair.current,
      nextLyric: lyricPair.next,
      isPlaying: playerState.isPlaying,
      isFavorite: isFavorite,
      canGoPrevious: playerState.isReady && playerState.hasPrevious,
      canGoNext:
          playerState.isReady &&
          (playerState.queueMode == PlayerQueueMode.singleRepeat ||
              playerState.hasNext),
      hasItem: item != null,
      opacity: settings.opacity,
      alwaysOnTop: settings.alwaysOnTop,
    );
  }

  String _resolveTitle(PlayableItem? item, Metadata? metadata) {
    if (item == null) {
      return '桌面歌词';
    }
    if (metadata?.stableId == item.stableId) {
      final String metadataTitle = metadata?.title?.trim() ?? '';
      if (metadataTitle.isNotEmpty) {
        return metadataTitle;
      }
    }
    return item.displayTitle;
  }

  _LyricPair _resolveLyricPair(
    PlayerState playerState,
    MetadataState metadataState,
  ) {
    if (playerState.currentItem == null) {
      return const _LyricPair(current: '暂无播放内容', next: '');
    }
    if (metadataState.isLoading) {
      return const _LyricPair(current: '正在查找歌词', next: '');
    }
    if (metadataState.hasError) {
      return const _LyricPair(current: '歌词查询失败', next: '');
    }

    final Metadata? metadata = metadataState.metadata;
    final String rawLyrics =
        metadata?.metaLyrics?.preferredMainLyric?.trim() ??
        metadata?.lyrics?.trim() ??
        '';
    final String? renderableLyrics = PlayerUtil.buildRenderableLyrics(
      rawLyrics,
      playerState.duration,
    );
    final List<_TimedLyricLine> mainLines = _parseTimedLyrics(
      renderableLyrics ?? '',
    );
    if (mainLines.isEmpty) {
      final List<String> plainLines = _plainLyricLines(renderableLyrics ?? '');
      if (plainLines.isNotEmpty) {
        return _LyricPair(
          current: plainLines.first,
          next: plainLines.length > 1 ? plainLines[1] : '',
        );
      }
      return const _LyricPair(current: '暂无歌词', next: '');
    }

    final List<_TimedLyricLine> translationLines = _parseTimedLyrics(
      metadata?.metaLyrics?.preferredTranslationLyric ?? '',
    );
    final Duration position =
        playerState.position +
        Duration(milliseconds: metadata?.lyricOffsetMs ?? 0);
    final int index = _activeLyricIndex(mainLines, position);
    final _TimedLyricLine currentLine = mainLines[index];
    final String translation = _translationFor(
      translationLines: translationLines,
      line: currentLine,
    );
    return _LyricPair(
      current: translation.isEmpty
          ? currentLine.text
          : '${currentLine.text}\n$translation',
      next: index + 1 < mainLines.length ? mainLines[index + 1].text : '',
    );
  }

  List<_TimedLyricLine> _parseTimedLyrics(String lyrics) {
    final RegExp lrcTimestampPattern = RegExp(
      r'\[(\d{1,2}):(\d{2})(?:[.:](\d{1,3}))?\]',
    );
    final RegExp qrcTimestampPattern = RegExp(r'\[(\d+),(\d+)\]');
    final List<_TimedLyricLine> lines = <_TimedLyricLine>[];
    for (final String rawLine in lyrics.split('\n')) {
      final Iterable<RegExpMatch> qrcMatches = qrcTimestampPattern.allMatches(
        rawLine,
      );
      if (qrcMatches.isNotEmpty) {
        final String text = _stripLyricTimingMarks(
          rawLine.replaceAll(qrcTimestampPattern, ''),
        );
        if (text.isEmpty) {
          continue;
        }
        for (final RegExpMatch match in qrcMatches) {
          final int milliseconds = int.tryParse(match.group(1) ?? '') ?? 0;
          lines.add(
            _TimedLyricLine(
              time: Duration(milliseconds: milliseconds),
              text: text,
            ),
          );
        }
        continue;
      }

      final Iterable<RegExpMatch> lrcMatches = lrcTimestampPattern.allMatches(
        rawLine,
      );
      if (lrcMatches.isEmpty) {
        continue;
      }
      final String text = _stripLyricTimingMarks(
        rawLine.replaceAll(lrcTimestampPattern, ''),
      );
      if (text.isEmpty) {
        continue;
      }
      for (final RegExpMatch match in lrcMatches) {
        final int minutes = int.tryParse(match.group(1) ?? '') ?? 0;
        final int seconds = int.tryParse(match.group(2) ?? '') ?? 0;
        final String fraction = match.group(3) ?? '0';
        final int milliseconds = _fractionToMilliseconds(fraction);
        lines.add(
          _TimedLyricLine(
            time: Duration(
              minutes: minutes,
              seconds: seconds,
              milliseconds: milliseconds,
            ),
            text: text,
          ),
        );
      }
    }
    lines.sort(
      (_TimedLyricLine a, _TimedLyricLine b) => a.time.compareTo(b.time),
    );
    return lines;
  }

  List<String> _plainLyricLines(String lyrics) {
    return lyrics
        .split('\n')
        .map(_stripLyricTimingMarks)
        .where((String line) => line.isNotEmpty)
        .toList(growable: false);
  }

  String _stripLyricTimingMarks(String line) {
    return line
        .replaceAll(RegExp(r'\(\d+,\d+\)'), '')
        .replaceAll(RegExp(r'<\d+,\d+>'), '')
        .trim();
  }

  int _fractionToMilliseconds(String fraction) {
    if (fraction.length >= 3) {
      return int.tryParse(fraction.substring(0, 3)) ?? 0;
    }
    if (fraction.length == 2) {
      return (int.tryParse(fraction) ?? 0) * 10;
    }
    return (int.tryParse(fraction) ?? 0) * 100;
  }

  int _activeLyricIndex(List<_TimedLyricLine> lines, Duration position) {
    int activeIndex = 0;
    for (int index = 0; index < lines.length; index += 1) {
      if (lines[index].time > position) {
        break;
      }
      activeIndex = index;
    }
    return activeIndex;
  }

  String _translationFor({
    required List<_TimedLyricLine> translationLines,
    required _TimedLyricLine line,
  }) {
    for (final _TimedLyricLine translationLine in translationLines) {
      if ((translationLine.time - line.time).abs() <=
          const Duration(milliseconds: 600)) {
        return translationLine.text;
      }
    }
    return '';
  }
}

class _LyricPair {
  const _LyricPair({required this.current, required this.next});

  final String current;
  final String next;
}

class _TimedLyricLine {
  const _TimedLyricLine({required this.time, required this.text});

  final Duration time;
  final String text;
}
