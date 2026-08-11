import 'dart:async';

import 'package:bilimusic/common/logger.dart';
import 'package:bilimusic/feature/player/domain/player_event.dart';
import 'package:bilimusic/feature/player/logic/player_event_hub.dart';
import 'package:bilimusic/feature/statistics/data/statistics_local_repository.dart';
import 'package:bilimusic/feature/statistics/domain/playback_tracking_state.dart';
import 'package:bilimusic/feature/statistics/domain/song_statistics.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'statistics_tracker.g.dart';

@Riverpod(keepAlive: true)
StatisticsTracker statisticsTracker(Ref ref) {
  final StatisticsTracker tracker = StatisticsTracker(
    ref.read(playerEventHubProvider).events,
    StatisticsLocalRepository(Hive.box<Map>(songStatisticsBoxName)),
  );
  ref.onDispose(tracker.dispose);
  return tracker;
}

class StatisticsTracker with WidgetsBindingObserver {
  StatisticsTracker(this._events, this._repository) {
    _subscription = _events.listen(_onEvent);
    WidgetsBinding.instance.addObserver(this);
  }

  final Stream<PlayerEvent> _events;
  final StatisticsLocalRepository _repository;
  final AppLogger _logger = AppLogger('Statistics');
  late final StreamSubscription<PlayerEvent> _subscription;
  Future<void> _eventQueue = Future<void>.value();
  PlaybackTrackingState _tracking = const PlaybackTrackingState();

  PlaybackTrackingState get tracking => _tracking;

  void _onEvent(PlayerEvent event) {
    unawaited(
      _enqueue(
        () => _handleEvent(event),
        errorMessage: 'event handling failed',
      ),
    );
  }

  Future<void> _enqueue(
    Future<void> Function() task, {
    required String errorMessage,
  }) {
    final Future<void> queued = _eventQueue.then((_) async {
      try {
        await task();
      } on Object catch (error, stackTrace) {
        _logger.e(errorMessage, error, stackTrace);
      }
    });
    _eventQueue = queued;
    return queued;
  }

  Future<void> onEvent(PlayerEvent event) async {
    await _enqueue(
      () => _handleEvent(event),
      errorMessage: 'event handling failed',
    );
  }

  Future<void> _handleEvent(PlayerEvent event) async {
    final String? stableId = event.item?.stableId;
    if (event.type == PlayerEventType.trackChanged && stableId != null) {
      if (_isIdentityUpgrade(stableId)) {
        _tracking = _tracking.copyWith(stableId: stableId);
        _logger.d('tracking identity upgraded to $stableId');
        return;
      }
      await _commit(resetAttempt: true);
      _tracking = PlaybackTrackingState(
        stableId: stableId,
        title: event.item!.title,
        author: event.item!.author,
        coverUrl: event.item!.coverUrl,
        durationMs: event.duration?.inMilliseconds ?? 0,
        lastPositionMs: event.position.inMilliseconds,
        isPlaying: event.isPlaying,
      );
      _logger.d('tracking song $stableId');
      return;
    }
    if (stableId == null || stableId != _tracking.stableId) return;

    if (event.type == PlayerEventType.position && _tracking.isPlaying) {
      final int positionMs = event.position.inMilliseconds;
      final int delta = positionMs - _tracking.lastPositionMs;
      if (delta > 0 && delta <= 3000) {
        _tracking = _tracking.copyWith(
          playedMs: _tracking.playedMs + delta,
          attemptPlayedMs: _tracking.attemptPlayedMs + delta,
        );
      } else if (delta > 3000 || delta < 0) {
        _logger.d('ignored seek jump for $stableId: ${delta}ms');
      }
      _tracking = _tracking.copyWith(lastPositionMs: positionMs);
    }
    if (event.type == PlayerEventType.duration && event.duration != null) {
      _tracking = _tracking.copyWith(
        durationMs: event.duration!.inMilliseconds,
      );
    }
    if (event.type == PlayerEventType.seek) {
      _tracking = _tracking.copyWith(
        lastPositionMs: event.position.inMilliseconds,
      );
    }
    if (event.type == PlayerEventType.playbackState) {
      _tracking = _tracking.copyWith(
        isPlaying: event.isPlaying,
        lastPositionMs: event.isPlaying
            ? event.position.inMilliseconds
            : _tracking.lastPositionMs,
      );
    }
    if (event.type == PlayerEventType.stop ||
        event.type == PlayerEventType.completed) {
      await _commit(resetAttempt: true);
    } else if (event.type == PlayerEventType.playbackState &&
        !event.isPlaying) {
      await _commit();
    }
  }

  Future<void> flush() => _enqueue(() async {
    await _commit();
  }, errorMessage: 'lifecycle flush failed');

  SongStatistics? read(String stableId) {
    final SongStatistics? exact = _repository.read(stableId);
    if (exact != null || stableId.contains(':cid:')) return exact;
    final SongStatistics? compatible = _repository.readCompatible(stableId);
    if (compatible != null) {
      _logger.d(
        'statistics query fallback: $stableId -> ${compatible.stableId}',
      );
    }
    return compatible;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      unawaited(flush());
    }
  }

  Future<void> _commit({bool resetAttempt = false}) async {
    final String? stableId = _tracking.stableId;
    if (stableId == null) return;
    if (_tracking.playedMs <= 0) {
      if (resetAttempt) _resetAttempt();
      return;
    }
    final DateTime now = DateTime.now();
    final SongStatistics current =
        _repository.read(stableId) ?? SongStatistics(stableId: stableId);
    final int oldPlayCount = current.playCount;
    final bool qualifies =
        _tracking.durationMs > 0 &&
        _tracking.attemptPlayedMs >= (_tracking.durationMs * 0.1).ceil();
    final SongStatistics next = current.copyWith(
      title: _tracking.title,
      author: _tracking.author,
      coverUrl: _tracking.coverUrl,
      playCount: current.playCount + (qualifies && !_tracking.counted ? 1 : 0),
      totalPlayedMs: current.totalPlayedMs + _tracking.playedMs,
      firstPlayedAtEpochMs: qualifies
          ? current.firstPlayedAtEpochMs ?? now.millisecondsSinceEpoch
          : current.firstPlayedAtEpochMs,
      lastPlayedAtEpochMs: qualifies
          ? now.millisecondsSinceEpoch
          : current.lastPlayedAtEpochMs,
    );
    try {
      await _repository.write(next);
    } on Object catch (error, stackTrace) {
      _logger.e('repository write failed for $stableId', error, stackTrace);
      return;
    }
    _logger.d(
      'committed $stableId: playCount $oldPlayCount->${next.playCount}, '
      '+${_tracking.playedMs}ms, total=${next.totalPlayedMs}',
    );
    if (resetAttempt) {
      _resetAttempt();
    } else {
      _tracking = _tracking.copyWith(
        playedMs: 0,
        counted: _tracking.counted || qualifies,
      );
    }
  }

  void _resetAttempt() {
    _tracking = _tracking.copyWith(
      playedMs: 0,
      attemptPlayedMs: 0,
      counted: false,
      lastPositionMs: 0,
      isPlaying: false,
    );
  }

  bool _isIdentityUpgrade(String stableId) {
    final String? current = _tracking.stableId;
    if (current == null || current == stableId) return false;
    if (current.contains(':cid:') || !stableId.contains(':cid:')) return false;
    return current == stableId.split(':cid:').first;
  }

  Future<void> dispose() async {
    await _subscription.cancel();
    await _eventQueue;
    WidgetsBinding.instance.removeObserver(this);
  }
}
