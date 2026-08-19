import 'package:bilimusic/common/util/platform_util.dart';
import 'package:bilimusic/feature/player/logic/app_audio_handler.dart';
import 'package:flutter/services.dart';

class WindowsTaskbarThumbnailToolbar {
  WindowsTaskbarThumbnailToolbar._();

  static final WindowsTaskbarThumbnailToolbar instance =
      WindowsTaskbarThumbnailToolbar._();

  static const MethodChannel _channel = MethodChannel(
    'bilimusic/windows_taskbar_thumbnail_toolbar',
  );

  PlayerCommandTarget? _target;

  void attachTarget(PlayerCommandTarget target) {
    if (!PlatformUtil.isWindows) {
      return;
    }
    _target = target;
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  void detachTarget(PlayerCommandTarget target) {
    if (!PlatformUtil.isWindows || !identical(_target, target)) {
      return;
    }
    _target = null;
    _channel.setMethodCallHandler(null);
  }

  void publish({
    required bool isPlaying,
    required bool hasPrevious,
    required bool hasNext,
  }) {
    if (!PlatformUtil.isWindows) {
      return;
    }
    _channel.invokeMethod<void>('updatePlaybackState', <String, bool>{
      'isPlaying': isPlaying,
      'hasPrevious': hasPrevious,
      'hasNext': hasNext,
    });
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    final PlayerCommandTarget? target = _target;
    if (target == null || call.method != 'command') {
      return;
    }

    switch (call.arguments) {
      case 'previous':
        await target.skipToPrevious();
      case 'play':
        await target.play();
      case 'pause':
        await target.pause();
      case 'next':
        await target.skipToNext();
    }
  }
}
