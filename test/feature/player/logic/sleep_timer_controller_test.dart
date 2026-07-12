import 'dart:async';

import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/player_controller.dart';
import 'package:bilimusic/feature/player/logic/sleep_timer_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults to inactive state', () {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(_FakePlayerController.new),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(sleepTimerControllerProvider),
      isA<SleepTimerState>()
          .having((SleepTimerState state) => state.isActive, 'isActive', false)
          .having(
            (SleepTimerState state) => state.expiresAt,
            'expiresAt',
            isNull,
          ),
    );
  });

  test('start sets active state with expiration time', () {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(_FakePlayerController.new),
      ],
    );
    addTearDown(container.dispose);

    final DateTime before = DateTime.now();
    container
        .read(sleepTimerControllerProvider.notifier)
        .start(const Duration(seconds: 5));
    final DateTime after = DateTime.now();

    final SleepTimerState state = container.read(sleepTimerControllerProvider);

    expect(state.isActive, isTrue);
    expect(state.expiresAt, isNotNull);
    expect(
      state.expiresAt!.millisecondsSinceEpoch,
      inInclusiveRange(
        before.add(const Duration(seconds: 5)).millisecondsSinceEpoch,
        after.add(const Duration(seconds: 5)).millisecondsSinceEpoch,
      ),
    );
  });

  test('starting again replaces the old timer', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(_FakePlayerController.new),
      ],
    );
    addTearDown(container.dispose);

    final _FakePlayerController fakePlayer =
        container.read(playerControllerProvider.notifier)
            as _FakePlayerController;

    container
        .read(sleepTimerControllerProvider.notifier)
        .start(const Duration(milliseconds: 50));
    final DateTime? firstExpiry = container
        .read(sleepTimerControllerProvider)
        .expiresAt;

    await Future<void>.delayed(const Duration(milliseconds: 10));

    container
        .read(sleepTimerControllerProvider.notifier)
        .start(const Duration(milliseconds: 20));
    final SleepTimerState restartedState = container.read(
      sleepTimerControllerProvider,
    );

    expect(restartedState.isActive, isTrue);
    expect(restartedState.expiresAt, isNot(firstExpiry));

    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(fakePlayer.pauseCallCount, 1);
    expect(container.read(sleepTimerControllerProvider).isActive, isFalse);
  });

  test('cancel clears state and prevents expiration pause', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(_FakePlayerController.new),
      ],
    );
    addTearDown(container.dispose);

    final _FakePlayerController fakePlayer =
        container.read(playerControllerProvider.notifier)
            as _FakePlayerController;

    container
        .read(sleepTimerControllerProvider.notifier)
        .start(const Duration(milliseconds: 20));
    container.read(sleepTimerControllerProvider.notifier).cancel();

    expect(container.read(sleepTimerControllerProvider).isActive, isFalse);
    expect(container.read(sleepTimerControllerProvider).expiresAt, isNull);

    await Future<void>.delayed(const Duration(milliseconds: 40));

    expect(fakePlayer.pauseCallCount, 0);
  });

  test('expiration pauses exactly once and clears state', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(_FakePlayerController.new),
      ],
    );
    addTearDown(container.dispose);

    final _FakePlayerController fakePlayer =
        container.read(playerControllerProvider.notifier)
            as _FakePlayerController;

    container
        .read(sleepTimerControllerProvider.notifier)
        .start(const Duration(milliseconds: 1));

    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(fakePlayer.pauseCallCount, 1);
    expect(container.read(sleepTimerControllerProvider).isActive, isFalse);
    expect(container.read(sleepTimerControllerProvider).expiresAt, isNull);
  });

  test(
    'old expiry completion does not clear replacement timer state',
    () async {
      final ProviderContainer container = ProviderContainer(
        overrides: [
          playerControllerProvider.overrideWith(_FakePlayerController.new),
        ],
      );
      addTearDown(container.dispose);

      final _FakePlayerController fakePlayer =
          container.read(playerControllerProvider.notifier)
              as _FakePlayerController;
      fakePlayer.autoCompletePause = false;

      container
          .read(sleepTimerControllerProvider.notifier)
          .start(Duration.zero);

      await fakePlayer.waitForPauseCall(1);

      expect(container.read(sleepTimerControllerProvider).isActive, isTrue);

      container
          .read(sleepTimerControllerProvider.notifier)
          .start(const Duration(seconds: 1));
      final DateTime? replacementExpiry = container
          .read(sleepTimerControllerProvider)
          .expiresAt;

      fakePlayer.completeNextPause();
      await Future<void>.delayed(Duration.zero);

      final SleepTimerState stateAfterOldCompletion = container.read(
        sleepTimerControllerProvider,
      );

      expect(fakePlayer.pauseCallCount, 1);
      expect(stateAfterOldCompletion.isActive, isTrue);
      expect(stateAfterOldCompletion.expiresAt, replacementExpiry);
    },
  );

  test('zero or negative duration expires safely', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(_FakePlayerController.new),
      ],
    );
    addTearDown(container.dispose);

    final _FakePlayerController fakePlayer =
        container.read(playerControllerProvider.notifier)
            as _FakePlayerController;

    container
        .read(sleepTimerControllerProvider.notifier)
        .start(const Duration(milliseconds: -1));

    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(fakePlayer.pauseCallCount, 1);
    expect(container.read(sleepTimerControllerProvider).isActive, isFalse);
  });

  test('expireIfDue pauses once and clears an overdue timer', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(_FakePlayerController.new),
      ],
    );
    addTearDown(container.dispose);

    final _FakePlayerController fakePlayer =
        container.read(playerControllerProvider.notifier)
            as _FakePlayerController;

    container.read(sleepTimerControllerProvider.notifier).start(Duration.zero);

    await container.read(sleepTimerControllerProvider.notifier).expireIfDue();
    await Future<void>.delayed(Duration.zero);

    expect(fakePlayer.pauseCallCount, 1);
    expect(container.read(sleepTimerControllerProvider).isActive, isFalse);
  });

  test('expireIfDue does not duplicate an in-flight expiry pause', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(_FakePlayerController.new),
      ],
    );
    addTearDown(container.dispose);

    final _FakePlayerController fakePlayer =
        container.read(playerControllerProvider.notifier)
            as _FakePlayerController;
    fakePlayer.autoCompletePause = false;

    container.read(sleepTimerControllerProvider.notifier).start(Duration.zero);
    await fakePlayer.waitForPauseCall(1);

    await container.read(sleepTimerControllerProvider.notifier).expireIfDue();

    expect(fakePlayer.pauseCallCount, 1);

    fakePlayer.completeNextPause();
    await Future<void>.delayed(Duration.zero);

    expect(container.read(sleepTimerControllerProvider).isActive, isFalse);
  });

  test('dispose cancels timer and prevents callback', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        playerControllerProvider.overrideWith(_FakePlayerController.new),
      ],
    );

    final _FakePlayerController fakePlayer =
        container.read(playerControllerProvider.notifier)
            as _FakePlayerController;

    container
        .read(sleepTimerControllerProvider.notifier)
        .start(const Duration(milliseconds: 30));

    container.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 60));

    expect(fakePlayer.pauseCallCount, 0);
  });
}

class _FakePlayerController extends PlayerController {
  int pauseCallCount = 0;
  bool autoCompletePause = true;
  final List<Completer<void>> _pauseCompleters = <Completer<void>>[];

  @override
  PlayerState build() {
    return const PlayerState();
  }

  @override
  Future<void> pause() async {
    pauseCallCount += 1;
    final Completer<void> completer = Completer<void>();
    _pauseCompleters.add(completer);
    if (autoCompletePause) {
      completer.complete();
    }
    await completer.future;
  }

  Future<void> waitForPauseCall(int expectedCount) async {
    while (pauseCallCount < expectedCount) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  void completeNextPause() {
    final Completer<void> completer = _pauseCompleters.removeAt(0);
    completer.complete();
  }
}
