import 'dart:math';

import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:bilimusic/feature/player/logic/playback/player_queue_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayerQueueManager shuffle', () {
    test('next does not repeat before every other queue item is covered', () {
      final PlayerQueueManager manager = PlayerQueueManager(random: Random(42));
      final List<PlayableItem> queue = _queue(5);
      int currentIndex = 0;
      final List<int> nextIndices = <int>[];

      for (int step = 0; step < queue.length - 1; step += 1) {
        final int? nextIndex = manager.resolveNextIndex(
          queue: queue,
          currentIndex: currentIndex,
          mode: PlayerQueueMode.shuffle,
        );

        expect(nextIndex, isNotNull);
        expect(nextIndex, isNot(currentIndex));
        nextIndices.add(nextIndex!);
        currentIndex = nextIndex;
      }

      expect(nextIndices.toSet(), hasLength(queue.length - 1));
      expect(nextIndices, isNot(contains(0)));
    });

    test('first item of next round is not the previous round current item', () {
      final PlayerQueueManager manager = PlayerQueueManager(random: Random(42));
      final List<PlayableItem> queue = _queue(5);
      int currentIndex = 0;

      for (int step = 0; step < queue.length - 1; step += 1) {
        currentIndex = manager.resolveNextIndex(
          queue: queue,
          currentIndex: currentIndex,
          mode: PlayerQueueMode.shuffle,
        )!;
      }

      final int previousRoundCurrentIndex = currentIndex;
      final int? nextRoundFirstIndex = manager.resolveNextIndex(
        queue: queue,
        currentIndex: currentIndex,
        mode: PlayerQueueMode.shuffle,
      );

      expect(nextRoundFirstIndex, isNotNull);
      expect(nextRoundFirstIndex, isNot(previousRoundCurrentIndex));
    });

    test('previous walks back through the shuffle sequence', () {
      final PlayerQueueManager manager = PlayerQueueManager(random: Random(42));
      final List<PlayableItem> queue = _queue(6);
      final List<int> visitedIndices = <int>[0];
      int currentIndex = 0;

      for (int step = 0; step < 4; step += 1) {
        currentIndex = manager.resolveNextIndex(
          queue: queue,
          currentIndex: currentIndex,
          mode: PlayerQueueMode.shuffle,
        )!;
        visitedIndices.add(currentIndex);
      }

      for (
        int expectedPosition = visitedIndices.length - 2;
        expectedPosition >= 0;
        expectedPosition -= 1
      ) {
        final int? previousIndex = manager.resolvePreviousIndex(
          queue: queue,
          currentIndex: currentIndex,
          mode: PlayerQueueMode.shuffle,
        );

        expect(previousIndex, visitedIndices[expectedPosition]);
        currentIndex = previousIndex!;
      }
    });

    test('previous uses recorded playback history first', () {
      final PlayerQueueManager manager = PlayerQueueManager(random: Random(42));
      final List<PlayableItem> queue = _queue(6);
      final List<int> visitedIndices = <int>[0];
      int currentIndex = 0;

      manager.recordVisit(
        queue: queue,
        mode: PlayerQueueMode.shuffle,
        index: currentIndex,
      );
      for (int step = 0; step < 4; step += 1) {
        currentIndex = manager.resolveNextIndex(
          queue: queue,
          currentIndex: currentIndex,
          mode: PlayerQueueMode.shuffle,
        )!;
        manager.recordVisit(
          queue: queue,
          mode: PlayerQueueMode.shuffle,
          index: currentIndex,
        );
        visitedIndices.add(currentIndex);
      }

      for (
        int expectedPosition = visitedIndices.length - 2;
        expectedPosition >= 0;
        expectedPosition -= 1
      ) {
        final int? previousIndex = manager.resolvePreviousIndex(
          queue: queue,
          currentIndex: currentIndex,
          mode: PlayerQueueMode.shuffle,
        );

        expect(previousIndex, visitedIndices[expectedPosition]);
        currentIndex = previousIndex!;
        manager.recordVisit(
          queue: queue,
          mode: PlayerQueueMode.shuffle,
          index: currentIndex,
        );
      }
    });

    test('previous without prior history returns a different queue item', () {
      final PlayerQueueManager manager = PlayerQueueManager(random: Random(42));
      final List<PlayableItem> queue = _queue(6);

      final int? previousIndex = manager.resolvePreviousIndex(
        queue: queue,
        currentIndex: 0,
        mode: PlayerQueueMode.shuffle,
      );

      expect(previousIndex, isNotNull);
      expect(previousIndex, isNot(0));
    });

    test('previous ignores removed items in recorded history', () {
      final PlayerQueueManager manager = PlayerQueueManager(random: Random(42));
      final List<PlayableItem> queue = _queue(5);

      manager.recordVisit(
        queue: queue,
        mode: PlayerQueueMode.shuffle,
        index: 0,
      );
      manager.recordVisit(
        queue: queue,
        mode: PlayerQueueMode.shuffle,
        index: 1,
      );
      manager.recordVisit(
        queue: queue,
        mode: PlayerQueueMode.shuffle,
        index: 2,
      );

      final QueueRemovalResult removal = manager.removeAt(
        queue: queue,
        currentIndex: 2,
        removedIndex: 1,
      );

      final int? previousIndex = manager.resolvePreviousIndex(
        queue: removal.queue,
        currentIndex: removal.nextCurrentIndex,
        mode: PlayerQueueMode.shuffle,
      );

      expect(previousIndex, isNotNull);
      expect(removal.queue[previousIndex!].stableId, isNot(queue[1].stableId));
    });

    test('next available follows shuffle order instead of queue order', () {
      final List<PlayableItem> queue = _queue(7);
      final List<int> shuffleSequence = _shuffleSequence(
        queue: queue,
        seed: 42,
      );
      final ({int failedPosition, int expectedIndex}) fixture =
          _firstNonSequentialShuffleStep(shuffleSequence, queue.length);
      final int failedIndex = shuffleSequence[fixture.failedPosition];
      final PlayerQueueManager manager = PlayerQueueManager(random: Random(42));
      int currentIndex = shuffleSequence.first;

      for (int step = 0; step < fixture.failedPosition; step += 1) {
        currentIndex = manager.resolveNextIndex(
          queue: queue,
          currentIndex: currentIndex,
          mode: PlayerQueueMode.shuffle,
        )!;
      }

      expect(currentIndex, failedIndex);

      final int? nextAvailableIndex = manager.resolveNextAvailableIndex(
        queue: queue,
        failedIndex: failedIndex,
        mode: PlayerQueueMode.shuffle,
        skippedStableIds: <String>{queue[failedIndex].stableId},
      );

      expect(nextAvailableIndex, fixture.expectedIndex);
      expect(nextAvailableIndex, isNot((failedIndex + 1) % queue.length));
    });

    test(
      'next available returns null when every remaining item is skipped',
      () {
        final List<PlayableItem> queue = _queue(7);
        final List<int> shuffleSequence = _shuffleSequence(
          queue: queue,
          seed: 42,
        );
        final int failedPosition = 3;
        final int failedIndex = shuffleSequence[failedPosition];
        final PlayerQueueManager manager = PlayerQueueManager(
          random: Random(42),
        );
        int currentIndex = shuffleSequence.first;

        for (int step = 0; step < failedPosition; step += 1) {
          currentIndex = manager.resolveNextIndex(
            queue: queue,
            currentIndex: currentIndex,
            mode: PlayerQueueMode.shuffle,
          )!;
        }

        expect(currentIndex, failedIndex);

        final int? nextAvailableIndex = manager.resolveNextAvailableIndex(
          queue: queue,
          failedIndex: failedIndex,
          mode: PlayerQueueMode.shuffle,
          skippedStableIds: queue
              .map((PlayableItem item) => item.stableId)
              .toSet(),
        );

        expect(nextAvailableIndex, isNull);
      },
    );
  });

  group('PlayerQueueManager queue modes', () {
    test('sequence wraps forward and backward', () {
      final PlayerQueueManager manager = PlayerQueueManager(random: Random(42));
      final List<PlayableItem> queue = _queue(3);

      expect(
        manager.resolveNextIndex(
          queue: queue,
          currentIndex: 2,
          mode: PlayerQueueMode.sequence,
        ),
        0,
      );
      expect(
        manager.resolvePreviousIndex(
          queue: queue,
          currentIndex: 0,
          mode: PlayerQueueMode.sequence,
        ),
        2,
      );
    });

    test('single repeat keeps manual queue navigation available', () {
      final PlayerQueueManager manager = PlayerQueueManager(random: Random(42));
      final List<PlayableItem> queue = _queue(3);

      expect(
        manager.resolveNextIndex(
          queue: queue,
          currentIndex: 1,
          mode: PlayerQueueMode.singleRepeat,
        ),
        2,
      );
      expect(
        manager.resolvePreviousIndex(
          queue: queue,
          currentIndex: 1,
          mode: PlayerQueueMode.singleRepeat,
        ),
        0,
      );
    });
  });
}

List<PlayableItem> _queue(int length) {
  return List<PlayableItem>.generate(
    length,
    (int index) => PlayableItem(
      aid: index + 1,
      bvid: 'BVTEST$index',
      cid: 1000 + index,
      title: 'Song $index',
      author: 'author',
      coverUrl: 'https://example.com/cover-$index.jpg',
    ),
  );
}

List<int> _shuffleSequence({
  required List<PlayableItem> queue,
  required int seed,
}) {
  final PlayerQueueManager manager = PlayerQueueManager(random: Random(seed));
  final List<int> visitedIndices = <int>[0];
  int currentIndex = 0;

  for (int step = 0; step < queue.length - 1; step += 1) {
    currentIndex = manager.resolveNextIndex(
      queue: queue,
      currentIndex: currentIndex,
      mode: PlayerQueueMode.shuffle,
    )!;
    visitedIndices.add(currentIndex);
  }

  return visitedIndices;
}

({int failedPosition, int expectedIndex}) _firstNonSequentialShuffleStep(
  List<int> shuffleSequence,
  int queueLength,
) {
  for (int position = 0; position < shuffleSequence.length - 1; position += 1) {
    final int failedIndex = shuffleSequence[position];
    final int expectedIndex = shuffleSequence[position + 1];
    if (expectedIndex != (failedIndex + 1) % queueLength) {
      return (failedPosition: position, expectedIndex: expectedIndex);
    }
  }

  fail('Fixed shuffle seed did not produce a non-sequential step.');
}
