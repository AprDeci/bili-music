import 'dart:math';

import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';

class PlayerQueueManager {
  PlayerQueueManager({Random? random}) : _random = random ?? Random();

  final Random _random;
  final List<int> _shuffleHistory = <int>[];

  void resetForQueue({required int? currentIndex}) {
    _shuffleHistory
      ..clear()
      ..addAll(currentIndex == null ? const <int>[] : <int>[currentIndex]);
  }

  void resetForMode({
    required PlayerQueueMode mode,
    required int? currentIndex,
  }) {
    _shuffleHistory.clear();
    if (mode == PlayerQueueMode.shuffle && currentIndex != null) {
      _shuffleHistory.add(currentIndex);
    }
  }

  void recordVisit({required PlayerQueueMode mode, required int index}) {
    if (mode != PlayerQueueMode.shuffle) {
      return;
    }
    if (_shuffleHistory.isEmpty || _shuffleHistory.last != index) {
      _shuffleHistory.add(index);
    }
  }

  int? resolveNextIndex({
    required List<PlayableItem> queue,
    required int? currentIndex,
    required PlayerQueueMode mode,
  }) {
    if (currentIndex == null || queue.isEmpty) {
      return null;
    }

    return switch (mode) {
      PlayerQueueMode.singleRepeat => currentIndex,
      PlayerQueueMode.sequence => _wrapQueueIndex(
        currentIndex + 1,
        queue.length,
      ),
      PlayerQueueMode.shuffle => _pickRandomNextIndex(
        length: queue.length,
        currentIndex: currentIndex,
      ),
    };
  }

  int? resolvePreviousIndex({
    required List<PlayableItem> queue,
    required int? currentIndex,
    required PlayerQueueMode mode,
  }) {
    if (currentIndex == null || queue.isEmpty) {
      return null;
    }

    if (mode == PlayerQueueMode.singleRepeat) {
      return currentIndex;
    }

    if (mode == PlayerQueueMode.shuffle) {
      if (_shuffleHistory.length >= 2) {
        _shuffleHistory.removeLast();
        return _shuffleHistory.last;
      }
      return currentIndex;
    }

    if (queue.length == 1) {
      return currentIndex;
    }

    return _wrapQueueIndex(currentIndex - 1, queue.length);
  }

  QueueRemovalResult removeAt({
    required List<PlayableItem> queue,
    required int? currentIndex,
    required int removedIndex,
  }) {
    final List<PlayableItem> nextQueue = List<PlayableItem>.of(queue)
      ..removeAt(removedIndex);

    if (nextQueue.isEmpty) {
      resetForQueue(currentIndex: null);
      return const QueueRemovalResult(
        queue: <PlayableItem>[],
        nextCurrentIndex: null,
        removedCurrentItem: false,
      );
    }

    int? nextCurrentIndex = currentIndex;
    bool removedCurrentItem = false;

    if (nextCurrentIndex != null) {
      if (removedIndex < nextCurrentIndex) {
        nextCurrentIndex -= 1;
      } else if (removedIndex == nextCurrentIndex) {
        removedCurrentItem = true;
        nextCurrentIndex = nextCurrentIndex >= nextQueue.length
            ? nextQueue.length - 1
            : nextCurrentIndex;
      }
    }

    _shuffleHistory.removeWhere((int value) => value == removedIndex);
    for (int index = 0; index < _shuffleHistory.length; index += 1) {
      if (_shuffleHistory[index] > removedIndex) {
        _shuffleHistory[index] = _shuffleHistory[index] - 1;
      }
    }

    return QueueRemovalResult(
      queue: List<PlayableItem>.unmodifiable(nextQueue),
      nextCurrentIndex: nextCurrentIndex,
      removedCurrentItem: removedCurrentItem,
    );
  }

  QueueReorderResult reorder({
    required List<PlayableItem> queue,
    required int? currentIndex,
    required int oldIndex,
    required int newIndex,
  }) {
    if (oldIndex < 0 || oldIndex >= queue.length) {
      return QueueReorderResult(
        queue: List<PlayableItem>.unmodifiable(queue),
        nextCurrentIndex: currentIndex,
      );
    }

    final int resolvedNewIndex = newIndex.clamp(0, queue.length - 1);

    if (oldIndex == resolvedNewIndex) {
      return QueueReorderResult(
        queue: List<PlayableItem>.unmodifiable(queue),
        nextCurrentIndex: currentIndex,
      );
    }

    final List<PlayableItem> nextQueue = List<PlayableItem>.of(queue);
    final PlayableItem movedItem = nextQueue.removeAt(oldIndex);
    nextQueue.insert(resolvedNewIndex, movedItem);

    int? nextCurrentIndex = currentIndex;
    if (nextCurrentIndex != null) {
      if (nextCurrentIndex == oldIndex) {
        nextCurrentIndex = resolvedNewIndex;
      } else if (oldIndex < nextCurrentIndex &&
          resolvedNewIndex >= nextCurrentIndex) {
        nextCurrentIndex -= 1;
      } else if (oldIndex > nextCurrentIndex &&
          resolvedNewIndex <= nextCurrentIndex) {
        nextCurrentIndex += 1;
      }
    }

    for (int index = 0; index < _shuffleHistory.length; index += 1) {
      final int value = _shuffleHistory[index];
      if (value == oldIndex) {
        _shuffleHistory[index] = resolvedNewIndex;
      } else if (oldIndex < value && resolvedNewIndex >= value) {
        _shuffleHistory[index] = value - 1;
      } else if (oldIndex > value && resolvedNewIndex <= value) {
        _shuffleHistory[index] = value + 1;
      }
    }

    return QueueReorderResult(
      queue: List<PlayableItem>.unmodifiable(nextQueue),
      nextCurrentIndex: nextCurrentIndex,
    );
  }

  int _wrapQueueIndex(int value, int length) {
    if (length <= 0) {
      return 0;
    }
    return ((value % length) + length) % length;
  }

  int _pickRandomNextIndex({required int length, required int currentIndex}) {
    if (length <= 0) {
      return 0;
    }
    if (length == 1) {
      return currentIndex;
    }

    int nextIndex = currentIndex;
    while (nextIndex == currentIndex) {
      nextIndex = _random.nextInt(length);
    }
    return nextIndex;
  }
}

class QueueRemovalResult {
  const QueueRemovalResult({
    required this.queue,
    required this.nextCurrentIndex,
    required this.removedCurrentItem,
  });

  final List<PlayableItem> queue;
  final int? nextCurrentIndex;
  final bool removedCurrentItem;
}

class QueueReorderResult {
  const QueueReorderResult({
    required this.queue,
    required this.nextCurrentIndex,
  });

  final List<PlayableItem> queue;
  final int? nextCurrentIndex;
}
