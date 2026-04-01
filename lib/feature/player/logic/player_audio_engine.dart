import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart' as audio;

class PlayerAudioEngine {
  PlayerAudioEngine()
    : _audioPlayer = audio.AudioPlayer(
        useProxyForRequestHeaders: !_shouldDisableRequestHeadersProxy,
      );

  final audio.AudioPlayer _audioPlayer;

  static bool get _shouldDisableRequestHeadersProxy {
    if (kIsWeb) {
      return true;
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.windows => true,
      TargetPlatform.linux => true,
      _ => false,
    };
  }

  bool get playing => _audioPlayer.playing;
  Duration get position => _audioPlayer.position;
  audio.ProcessingState get processingState => _audioPlayer.processingState;

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration> get bufferedPositionStream =>
      _audioPlayer.bufferedPositionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<audio.PlayerException> get errorStream => _audioPlayer.errorStream;
  Stream<audio.PlayerState> get playerStateStream =>
      _audioPlayer.playerStateStream;

  Future<Duration?> setRemoteSource({
    required Uri uri,
    Map<String, String>? headers,
    dynamic tag,
    Duration? initialPosition,
  }) {
    return _audioPlayer.setAudioSource(
      audio.AudioSource.uri(uri, headers: headers, tag: tag),
      initialPosition: initialPosition,
    );
  }

  Future<Duration?> setFileSource({
    required String filePath,
    dynamic tag,
    Duration? initialPosition,
  }) {
    return _audioPlayer.setAudioSource(
      audio.AudioSource.file(filePath, tag: tag),
      initialPosition: initialPosition,
    );
  }

  Future<void> play() {
    return _audioPlayer.play();
  }

  Future<void> pause() {
    return _audioPlayer.pause();
  }

  Future<void> stop() {
    return _audioPlayer.stop();
  }

  Future<void> seek(Duration position) {
    return _audioPlayer.seek(position);
  }

  Future<void> dispose() {
    return _audioPlayer.dispose();
  }
}
