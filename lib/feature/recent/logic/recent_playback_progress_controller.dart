import 'dart:async';
import 'dart:convert';

import 'package:bilimusic/core/hive/hive_keys.dart';
import 'package:bilimusic/core/settings/app_settings_store.dart';
import 'package:bilimusic/feature/player/domain/player_event.dart';
import 'package:bilimusic/feature/player/logic/player_event_hub.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recent_playback_progress_controller.g.dart';

const Duration recentProgressPersistInterval = Duration(seconds: 5);
const Duration recentProgressMinimumPosition = Duration(seconds: 3);
const Duration recentProgressCompletedTail = Duration(seconds: 5);
const int recentProgressMaxEntries = 100;

@Riverpod(keepAlive: true)
class RecentPlaybackProgressController
    extends _$RecentPlaybackProgressController {
  late final AppSettingsStore _settings = ref.read(appSettingsStoreProvider);

  StreamSubscription<PlayerEvent>? _subscription;
  String? _activeStableId;
  int _activePositionMs = 0;
  int? _activeDurationMs;
  DateTime _lastPersistedAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  Map<String, int> build() {
    _subscription = ref.read(playerEventHubProvider).events.listen(_onEvent);
    ref.onDispose(() {
      _subscription?.cancel();
    });
    return _load();
  }

  int? positionFor(String stableId) {
    final int? positionMs = state[stableId];
    if (positionMs == null || positionMs <= 0) {
      return null;
    }
    return positionMs;
  }

  Future<void> remove(String stableId) async {
    if (!state.containsKey(stableId)) {
      return;
    }
    final Map<String, int> next = Map<String, int>.of(state)..remove(stableId);
    state = next;
    await _persistMap(next);
  }

  Future<void> clearAll() async {
    if (state.isEmpty) {
      return;
    }
    state = const <String, int>{};
    await _persistMap(state);
  }

  void _onEvent(PlayerEvent event) {
    switch (event.type) {
      case PlayerEventType.trackChanged:
        _flushActive(force: true);
        _activeStableId = event.item?.stableId;
        _activePositionMs = 0;
        _activeDurationMs = event.duration?.inMilliseconds;
      case PlayerEventType.position:
        if (_activeStableId == null) {
          return;
        }
        _activePositionMs = event.position.inMilliseconds;
        _activeDurationMs = event.duration?.inMilliseconds;
        _maybePersistActive();
      case PlayerEventType.seek:
        if (_activeStableId == null) {
          return;
        }
        _activePositionMs = event.position.inMilliseconds;
        _maybePersistActive(force: true);
      case PlayerEventType.playbackState:
        if (!event.isPlaying) {
          _maybePersistActive(force: true);
        }
      case PlayerEventType.duration:
        _activeDurationMs = event.duration?.inMilliseconds;
      case PlayerEventType.completed:
        _completeActive();
      case PlayerEventType.stop:
        _flushActive(force: true);
    }
  }

  void _maybePersistActive({bool force = false}) {
    final String? stableId = _activeStableId;
    if (stableId == null) {
      return;
    }
    if (!force &&
        DateTime.now().difference(_lastPersistedAt) <
            recentProgressPersistInterval) {
      return;
    }
    _flushActive(force: force);
  }

  void _flushActive({bool force = false}) {
    final String? stableId = _activeStableId;
    if (stableId == null) {
      return;
    }
    final int positionMs = _activePositionMs;
    final int? durationMs = _activeDurationMs;
    final bool nearEnd =
        durationMs != null &&
        durationMs > 0 &&
        positionMs >= durationMs - recentProgressCompletedTail.inMilliseconds;
    if (positionMs < recentProgressMinimumPosition.inMilliseconds || nearEnd) {
      _removeProgress(stableId);
      return;
    }
    _setProgress(stableId, positionMs, force: force);
  }

  void _completeActive() {
    final String? stableId = _activeStableId;
    _activeStableId = null;
    _activePositionMs = 0;
    if (stableId == null) {
      return;
    }
    _removeProgress(stableId);
  }

  void _setProgress(String stableId, int positionMs, {bool force = false}) {
    final int? current = state[stableId];
    if (!force && current != null && (current - positionMs).abs() < 1000) {
      return;
    }
    final Map<String, int> next = Map<String, int>.of(state)
      ..[stableId] = positionMs;
    final Map<String, int> trimmed = _trim(next);
    state = trimmed;
    _lastPersistedAt = DateTime.now();
    unawaited(_persistMap(trimmed));
  }

  void _removeProgress(String stableId) {
    if (!state.containsKey(stableId)) {
      return;
    }
    final Map<String, int> next = Map<String, int>.of(state)..remove(stableId);
    state = next;
    _lastPersistedAt = DateTime.now();
    unawaited(_persistMap(next));
  }

  Map<String, int> _trim(Map<String, int> source) {
    if (source.length <= recentProgressMaxEntries) {
      return source;
    }
    final List<MapEntry<String, int>> entries = source.entries.toList(
      growable: false,
    );
    return Map<String, int>.fromEntries(
      entries.sublist(entries.length - recentProgressMaxEntries),
    );
  }

  Future<void> _persistMap(Map<String, int> progress) {
    return _settings.writeString(
      HiveKeys.recentPlaybackProgress,
      jsonEncode(progress),
    );
  }

  Map<String, int> _load() {
    final String raw = _settings.readString(
      HiveKeys.recentPlaybackProgress,
      defaultValue: '{}',
    );
    if (raw.trim().isEmpty) {
      return <String, int>{};
    }
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return <String, int>{};
      }
      final Map<String, int> result = <String, int>{};
      for (final MapEntry<String, dynamic> entry in decoded.entries) {
        final int? value = entry.value is num
            ? (entry.value as num).toInt()
            : int.tryParse(entry.value.toString());
        if (value != null && value > 0) {
          result[entry.key] = value;
        }
      }
      return result;
    } on FormatException {
      return <String, int>{};
    }
  }
}
