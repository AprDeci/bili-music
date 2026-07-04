import 'dart:async';
import 'dart:convert';

import 'package:bilimusic/feature/player/domain/desktop_lyrics_payload.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DesktopLyricsWindowApp extends StatefulWidget {
  const DesktopLyricsWindowApp({
    super.key,
    required this.windowController,
    required this.initialPayload,
  });

  final WindowController windowController;
  final DesktopLyricsPayload initialPayload;

  @override
  State<DesktopLyricsWindowApp> createState() => _DesktopLyricsWindowAppState();
}

class _DesktopLyricsWindowAppState extends State<DesktopLyricsWindowApp> {
  static const MethodChannel _windowChannel = MethodChannel(
    'bilimusic/desktop_lyrics_window',
  );

  late DesktopLyricsPayload _payload = widget.initialPayload;
  bool _isConfirmingBlacklist = false;

  @override
  void initState() {
    super.initState();
    DesktopMultiWindow.setMethodHandler(_handleMethodCall);
    unawaited(_applyWindowOptions(_payload));
  }

  @override
  void dispose() {
    DesktopMultiWindow.setMethodHandler(null);
    super.dispose();
  }

  Future<dynamic> _handleMethodCall(MethodCall call, int fromWindowId) async {
    if (call.method == 'desktopLyricsSnapshot') {
      final Object? arguments = call.arguments;
      if (arguments is Map) {
        final Map<String, dynamic> json = arguments.map(
          (key, value) => MapEntry<String, dynamic>(key.toString(), value),
        );
        if (mounted) {
          setState(() {
            final DesktopLyricsPayload nextPayload =
                DesktopLyricsPayload.fromJson(json);
            if (_isConfirmingBlacklist &&
                (_payload.title != nextPayload.title || !nextPayload.hasItem)) {
              _isConfirmingBlacklist = false;
            }
            _payload = nextPayload;
            unawaited(_applyWindowOptions(nextPayload));
          });
        }
      }
    }
  }

  Future<void> _applyWindowOptions(DesktopLyricsPayload payload) async {
    try {
      await _windowChannel.invokeMethod<void>(
        'setAlwaysOnTop',
        payload.alwaysOnTop,
      );
      await _windowChannel.invokeMethod<void>('setOpacity', payload.opacity);
    } on Object {
      // Window chrome updates are best-effort for unsupported platforms.
    }
  }

  Future<void> _startDragging() async {
    try {
      await _windowChannel.invokeMethod<void>('startDragging');
    } on Object {
      // Keep the lyrics window usable even if the native drag bridge is absent.
    }
  }

  Future<void> _sendCommand(DesktopLyricsCommand command) {
    return DesktopMultiWindow.invokeMethod(
      0,
      'desktopLyricsCommand',
      command.methodName,
    );
  }

  void _requestBlacklist() {
    setState(() {
      _isConfirmingBlacklist = true;
    });
  }

  Future<void> _confirmBlacklist() async {
    setState(() {
      _isConfirmingBlacklist = false;
    });
    await _sendCommand(DesktopLyricsCommand.blacklist);
  }

  void _cancelBlacklist() {
    setState(() {
      _isConfirmingBlacklist = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.transparent,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: _DesktopLyricsWindow(
          payload: _payload,
          isConfirmingBlacklist: _isConfirmingBlacklist,
          onClose: () => _sendCommand(DesktopLyricsCommand.close),
          onStartDragging: () => unawaited(_startDragging()),
          onToggleAlwaysOnTop: () =>
              _sendCommand(DesktopLyricsCommand.toggleAlwaysOnTop),
          onToggleFavorite: () =>
              _sendCommand(DesktopLyricsCommand.toggleFavorite),
          onBlacklist: _requestBlacklist,
          onConfirmBlacklist: _confirmBlacklist,
          onCancelBlacklist: _cancelBlacklist,
          onPrevious: () => _sendCommand(DesktopLyricsCommand.previous),
          onTogglePlayback: () =>
              _sendCommand(DesktopLyricsCommand.togglePlayback),
          onNext: () => _sendCommand(DesktopLyricsCommand.next),
        ),
      ),
    );
  }
}

DesktopLyricsPayload parseDesktopLyricsInitialPayload(String rawArgs) {
  if (rawArgs.trim().isEmpty) {
    return DesktopLyricsPayload.empty;
  }
  try {
    final Object? decoded = jsonDecode(rawArgs);
    if (decoded is Map<String, dynamic>) {
      return DesktopLyricsPayload.fromJson(decoded);
    }
    if (decoded is Map) {
      return DesktopLyricsPayload.fromJson(
        decoded.map(
          (key, value) => MapEntry<String, dynamic>(key.toString(), value),
        ),
      );
    }
  } on FormatException {
    return DesktopLyricsPayload.empty;
  }
  return DesktopLyricsPayload.empty;
}

class _DesktopLyricsWindow extends StatelessWidget {
  const _DesktopLyricsWindow({
    required this.payload,
    required this.isConfirmingBlacklist,
    required this.onClose,
    required this.onStartDragging,
    required this.onToggleAlwaysOnTop,
    required this.onToggleFavorite,
    required this.onBlacklist,
    required this.onConfirmBlacklist,
    required this.onCancelBlacklist,
    required this.onPrevious,
    required this.onTogglePlayback,
    required this.onNext,
  });

  final DesktopLyricsPayload payload;
  final bool isConfirmingBlacklist;
  final VoidCallback onClose;
  final VoidCallback onStartDragging;
  final VoidCallback onToggleAlwaysOnTop;
  final VoidCallback onToggleFavorite;
  final VoidCallback onBlacklist;
  final VoidCallback onConfirmBlacklist;
  final VoidCallback onCancelBlacklist;
  final VoidCallback onPrevious;
  final VoidCallback onTogglePlayback;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42 * payload.opacity),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 8, 0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.move,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (_) => onStartDragging(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          payload.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _WindowButton(
                  tooltip: payload.alwaysOnTop ? '取消置顶' : '置顶桌面歌词',
                  icon: Icons.vertical_align_top_rounded,
                  active: payload.alwaysOnTop,
                  onPressed: onToggleAlwaysOnTop,
                ),
                _WindowButton(
                  tooltip: '关闭桌面歌词',
                  icon: Icons.close_rounded,
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      payload.currentLyric,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        height: 1.22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (payload.nextLyric.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 10),
                      Text(
                        payload.nextLyric,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 16,
                          height: 1.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: isConfirmingBlacklist
                  ? <Widget>[
                      const Flexible(
                        child: Text(
                          '确认加入黑名单并从队列移除？',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: onCancelBlacklist,
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 4),
                      FilledButton(
                        onPressed: onConfirmBlacklist,
                        child: const Text('确认'),
                      ),
                    ]
                  : <Widget>[
                      _WindowButton(
                        tooltip: payload.isFavorite ? '取消喜欢' : '喜欢',
                        icon: payload.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        active: payload.isFavorite,
                        onPressed: payload.hasItem ? onToggleFavorite : null,
                      ),
                      const SizedBox(width: 14),
                      _WindowButton(
                        tooltip: '加入黑名单',
                        icon: Icons.block_rounded,
                        onPressed: payload.hasItem ? onBlacklist : null,
                      ),
                      const SizedBox(width: 22),
                      _WindowButton(
                        tooltip: '上一首',
                        icon: Icons.skip_previous_rounded,
                        onPressed: payload.canGoPrevious ? onPrevious : null,
                      ),
                      const SizedBox(width: 10),
                      _WindowButton(
                        tooltip: payload.isPlaying ? '暂停' : '播放',
                        icon: payload.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        iconSize: 28,
                        onPressed: payload.hasItem ? onTogglePlayback : null,
                      ),
                      const SizedBox(width: 10),
                      _WindowButton(
                        tooltip: '下一首',
                        icon: Icons.skip_next_rounded,
                        onPressed: payload.canGoNext ? onNext : null,
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WindowButton extends StatelessWidget {
  const _WindowButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.active = false,
    this.iconSize = 22,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool active;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final Color color = onPressed == null
        ? Colors.white30
        : active
        ? const Color(0xFFFF6B82)
        : Colors.white70;
    return Tooltip(
      message: tooltip,
      child: IconButton(
        visualDensity: VisualDensity.compact,
        color: color,
        iconSize: iconSize,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}
