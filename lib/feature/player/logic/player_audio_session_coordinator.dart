import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:bilimusic/feature/player/logic/player_audio_engine.dart';

typedef AllowMixWithOthersReader = bool Function();
typedef BoolStateReader = bool Function();
typedef AsyncVoidCallback = Future<void> Function();

class PlayerAudioSessionCoordinator {
  PlayerAudioSessionCoordinator({
    required this._audioEngine,
    required this._readAllowMixWithOthers,
    required this._readHasQueue,
    required this._readIsPlaying,
    required this._readIsReady,
    required this._readIsLoading,
    required this._readHasError,
    required this._play,
    required this._pause,
  });

  static const double _unknownInterruptionDuckVolume = 0.35;

  final PlayerAudioEngine _audioEngine;
  final AllowMixWithOthersReader _readAllowMixWithOthers;
  final BoolStateReader _readHasQueue;
  final BoolStateReader _readIsPlaying;
  final BoolStateReader _readIsReady;
  final BoolStateReader _readIsLoading;
  final BoolStateReader _readHasError;
  final AsyncVoidCallback _play;
  final AsyncVoidCallback _pause;

  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];

  bool _isBound = false;
  bool _isDisposed = false;
  bool _isDuckedForUnknownInterruption = false;
  bool _resumeAfterInterruption = false;
  double _volumeBeforeUnknownInterruption = 1.0;

  Future<void> bind() async {
    if (_isBound || _isDisposed) {
      return;
    }

    final AudioSession session = await AudioSession.instance;
    if (_isDisposed) {
      return;
    }

    _subscriptions.add(
      session.interruptionEventStream.listen((AudioInterruptionEvent event) {
        unawaited(_handleAudioInterruption(event));
      }),
    );
    _subscriptions.add(
      session.becomingNoisyEventStream.listen((_) {
        unawaited(_handleBecomingNoisy());
      }),
    );
    _isBound = true;
  }

  Future<void> refreshConfiguration() async {
    final AudioSession session = await AudioSession.instance;
    await session.configure(
      _audioSessionConfiguration(_readAllowMixWithOthers()),
    );
  }

  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }

    _isDisposed = true;
    for (final StreamSubscription<dynamic> subscription in _subscriptions) {
      await subscription.cancel();
    }
  }

  Future<void> _handleAudioInterruption(AudioInterruptionEvent event) async {
    if (_isDisposed || !_readHasQueue()) {
      return;
    }

    final bool allowMixWithOthers = _readAllowMixWithOthers();

    if (event.begin) {
      if (event.type == AudioInterruptionType.unknown) {
        if (allowMixWithOthers && _shouldDuckUnknownInterruption()) {
          _resumeAfterInterruption = false;
          await _duckForUnknownInterruption();
          return;
        }

        _resumeAfterInterruption = false;
        await _restoreVolumeAfterUnknownInterruption();
        await _pause();
        return;
      }

      if (allowMixWithOthers) {
        if (event.type == AudioInterruptionType.pause) {
          _resumeAfterInterruption = true;
          await _restoreVolumeAfterUnknownInterruption();
          await _pause();
        } else {
          _resumeAfterInterruption = false;
        }
        return;
      }

      if (!_readIsPlaying()) {
        _resumeAfterInterruption = false;
        return;
      }

      _resumeAfterInterruption = event.type == AudioInterruptionType.pause;
      await _pause();
      return;
    }

    await _restoreVolumeAfterUnknownInterruption();

    if (!_resumeAfterInterruption) {
      return;
    }

    _resumeAfterInterruption = false;

    if (_readHasQueue() && !_readIsPlaying()) {
      await _play();
    }
  }

  Future<void> _handleBecomingNoisy() async {
    if (_isDisposed || !_readIsPlaying()) {
      return;
    }

    _resumeAfterInterruption = false;
    await _restoreVolumeAfterUnknownInterruption();
    await _pause();
  }

  bool _shouldDuckUnknownInterruption() {
    return _readIsPlaying() &&
        _readIsReady() &&
        !_readIsLoading() &&
        !_readHasError() &&
        Platform.isAndroid;
  }

  Future<void> _duckForUnknownInterruption() async {
    if (_isDuckedForUnknownInterruption) {
      return;
    }

    _volumeBeforeUnknownInterruption = _audioEngine.volume;
    _isDuckedForUnknownInterruption = true;
    // await _audioEngine.setVolume(
    //   _volumeBeforeUnknownInterruption <= _unknownInterruptionDuckVolume
    //       ? _volumeBeforeUnknownInterruption
    //       : _unknownInterruptionDuckVolume,
    // );
  }

  Future<void> _restoreVolumeAfterUnknownInterruption() async {
    if (!_isDuckedForUnknownInterruption) {
      return;
    }

    _isDuckedForUnknownInterruption = false;
    await _audioEngine.setVolume(_volumeBeforeUnknownInterruption);
  }

  AudioSessionConfiguration _audioSessionConfiguration(
    bool allowMixWithOthers,
  ) {
    if (!allowMixWithOthers) {
      return const AudioSessionConfiguration.music();
    }

    return const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: false,
    );
  }
}
