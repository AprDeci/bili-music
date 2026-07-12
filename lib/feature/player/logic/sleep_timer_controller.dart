import 'dart:async';

import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sleep_timer_controller.g.dart';

class SleepTimerState {
  const SleepTimerState({
    required this.isActive,
    required this.expiresAt,
    required this.duration,
  });

  const SleepTimerState.inactive()
    : this(isActive: false, expiresAt: null, duration: null);

  final bool isActive;
  final DateTime? expiresAt;
  final Duration? duration;
}

@Riverpod(keepAlive: true)
class SleepTimerController extends _$SleepTimerController {
  Timer? _timer;
  bool _isDisposed = false;
  bool _isExpiring = false;
  int _generation = 0;

  @override
  SleepTimerState build() {
    ref.onDispose(() {
      _isDisposed = true;
      _generation += 1;
      _timer?.cancel();
      _timer = null;
    });

    return const SleepTimerState.inactive();
  }

  void start(Duration duration) {
    _generation += 1;
    final int generation = _generation;

    _isExpiring = false;
    _timer?.cancel();

    final Duration effectiveDuration = duration.isNegative
        ? Duration.zero
        : duration;
    final DateTime expiresAt = DateTime.now().add(effectiveDuration);

    state = SleepTimerState(
      isActive: true,
      expiresAt: expiresAt,
      duration: effectiveDuration,
    );
    _timer = Timer(effectiveDuration, () => _onExpired(generation));
  }

  void cancel() {
    _generation += 1;
    _isExpiring = false;
    _timer?.cancel();
    _timer = null;
    state = const SleepTimerState.inactive();
  }

  Future<void> expireIfDue() async {
    final DateTime? expiresAt = state.expiresAt;
    if (_isExpiring ||
        !state.isActive ||
        expiresAt == null ||
        DateTime.now().isBefore(expiresAt)) {
      return;
    }

    _generation += 1;
    final int generation = _generation;
    _isExpiring = true;
    _timer?.cancel();
    _timer = null;
    await _pauseAndClear(generation);
  }

  void _onExpired(int generation) {
    if (_isExpiring || generation != _generation) {
      return;
    }

    _isExpiring = true;
    _timer = null;
    if (_isDisposed) {
      return;
    }

    unawaited(_pauseAndClear(generation));
  }

  Future<void> _pauseAndClear(int generation) async {
    try {
      await ref.read(playerControllerProvider.notifier).pause();
    } finally {
      if (!_isDisposed && generation == _generation) {
        _isExpiring = false;
        state = const SleepTimerState.inactive();
      }
    }
  }
}
