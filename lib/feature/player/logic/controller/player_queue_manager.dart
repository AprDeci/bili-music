import 'dart:math';

import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';

import '../../domain/player_state.dart';

class PlayerQueueManager {
  PlayerQueueManager({Random? random}) : _random = random ?? Random();

  final Random _random;
  final List<String> _shuffleOrderStableIds = <String>[];
  final List<String> _shuffleHistoryStableIds = <String>[];
  int? _shuffleCursor;

  void resetForQueue({required int? currentIndex}) {
    _shuffleOrderStableIds.clear();
    _shuffleHistoryStableIds.clear();
    _shuffleCursor = null;
  }

  void resetForMode({
    required PlayerQueueMode mode,
    required int? currentIndex,
  }) {
    _shuffleOrderStableIds.clear();
    _shuffleHistoryStableIds.clear();
    _shuffleCursor = null;
  }

  void recordVisit({
    required List<PlayableItem> queue,
    required PlayerQueueMode mode,
    required int index,
  }) {
    if (mode != PlayerQueueMode.shuffle) {
      return;
    }
    _syncShuffleOrder(queue: queue, currentIndex: index);
    _recordShuffleHistory(queue[index].stableId);
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
      PlayerQueueMode.sequence || PlayerQueueMode.singleRepeat => _wrapQueueIndex(
        currentIndex + 1,
        queue.length,
      ),
      PlayerQueueMode.shuffle => _resolveShuffleNextIndex(
        queue: queue,
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
      return _wrapQueueIndex(currentIndex - 1, queue.length);
    }

    if (mode == PlayerQueueMode.shuffle) {
      _syncShuffleOrder(queue: queue, currentIndex: currentIndex);
      final String currentId = queue[currentIndex].stableId;
      _discardCurrentShuffleHistory(currentId);

      while (_shuffleHistoryStableIds.isNotEmpty) {
        final String previousId = _shuffleHistoryStableIds.removeLast();
        if (previousId == currentId) {
          continue;
        }
        final int? previousIndex = _queueIndexOfStableId(queue, previousId);
        if (previousIndex != null) {
          _syncShuffleOrder(queue: queue, currentIndex: previousIndex);
          return previousIndex;
        }
      }

      final int? fallbackIndex = _resolveShuffleFallbackPreviousIndex(
        queue: queue,
        currentIndex: currentIndex,
      );
      if (fallbackIndex != null) {
        _syncShuffleOrder(queue: queue, currentIndex: fallbackIndex);
        return fallbackIndex;
      }
      return currentIndex;
    }

    if (queue.length == 1) {
      return currentIndex;
    }

    return _wrapQueueIndex(currentIndex - 1, queue.length);
  }

  int? resolveNextAvailableIndex({
    required List<PlayableItem> queue,
    required int failedIndex,
    required PlayerQueueMode mode,
    required Set<String> skippedStableIds,
  }) {
    if (queue.isEmpty || failedIndex < 0 || failedIndex >= queue.length) {
      return null;
    }

    if (mode == PlayerQueueMode.shuffle) {
      int? candidateIndex = failedIndex;
      for (int attempt = 0; attempt < queue.length; attempt += 1) {
        candidateIndex = resolveNextIndex(
          queue: queue,
          currentIndex: candidateIndex,
          mode: mode,
        );
        if (candidateIndex == null) {
          return null;
        }
        if (!skippedStableIds.contains(queue[candidateIndex].stableId)) {
          return candidateIndex;
        }
      }
      return null;
    }

    for (int offset = 1; offset <= queue.length; offset += 1) {
      final int candidateIndex = _wrapQueueIndex(
        failedIndex + offset,
        queue.length,
      );
      if (!skippedStableIds.contains(queue[candidateIndex].stableId)) {
        return candidateIndex;
      }
    }

    return null;
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

    if (removedIndex >= 0 && removedIndex < queue.length) {
      final String removedId = queue[removedIndex].stableId;
      _shuffleOrderStableIds.remove(removedId);
      _shuffleHistoryStableIds.removeWhere((String id) => id == removedId);
      _clampShuffleCursor();
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

  int _resolveShuffleNextIndex({
    required List<PlayableItem> queue,
    required int currentIndex,
  }) {
    if (queue.length <= 1) {
      return currentIndex;
    }

    _syncShuffleOrder(queue: queue, currentIndex: currentIndex);
    final int cursor = _shuffleCursor ?? 0;

    if (cursor + 1 < _shuffleOrderStableIds.length) {
      _shuffleCursor = cursor + 1;
      return _queueIndexOfStableId(
            queue,
            _shuffleOrderStableIds[_shuffleCursor!],
          ) ??
          currentIndex;
    }

    _startNextShuffleRound(queue: queue, currentIndex: currentIndex);
    return _queueIndexOfStableId(
          queue,
          _shuffleOrderStableIds[_shuffleCursor!],
        ) ??
        currentIndex;
  }

  void _recordShuffleHistory(String stableId) {
    if (_shuffleHistoryStableIds.isEmpty ||
        _shuffleHistoryStableIds.last != stableId) {
      _shuffleHistoryStableIds.add(stableId);
    }
  }

  void _discardCurrentShuffleHistory(String currentId) {
    if (_shuffleHistoryStableIds.isNotEmpty &&
        _shuffleHistoryStableIds.last == currentId) {
      _shuffleHistoryStableIds.removeLast();
    }
  }

  int? _resolveShuffleFallbackPreviousIndex({
    required List<PlayableItem> queue,
    required int currentIndex,
  }) {
    if (queue.length <= 1) {
      return currentIndex;
    }

    final int? cursor = _shuffleCursor;
    if (cursor != null && cursor > 0) {
      final int? previousIndex = _queueIndexOfStableId(
        queue,
        _shuffleOrderStableIds[cursor - 1],
      );
      if (previousIndex != null && previousIndex != currentIndex) {
        _shuffleCursor = cursor - 1;
        return previousIndex;
      }
    }

    final int wrappedIndex = _wrapQueueIndex(currentIndex - 1, queue.length);
    if (wrappedIndex != currentIndex) {
      return wrappedIndex;
    }
    return null;
  }

  void _syncShuffleOrder({
    required List<PlayableItem> queue,
    required int currentIndex,
  }) {
    if (queue.isEmpty || currentIndex < 0 || currentIndex >= queue.length) {
      _shuffleOrderStableIds.clear();
      _shuffleCursor = null;
      return;
    }

    final Set<String> queueIds = queue
        .map((PlayableItem item) => item.stableId)
        .toSet();
    final String currentId = queue[currentIndex].stableId;

    if (_shuffleOrderStableIds.isEmpty) {
      final List<String> remainingIds =
          queue
              .map((PlayableItem item) => item.stableId)
              .where((String id) => id != currentId)
              .toList(growable: false)
            ..shuffle(_random);
      _shuffleOrderStableIds
        ..add(currentId)
        ..addAll(remainingIds);
      _shuffleCursor = 0;
      return;
    }

    _shuffleOrderStableIds.removeWhere((String id) => !queueIds.contains(id));

    final Set<String> orderedIds = _shuffleOrderStableIds.toSet();
    final List<String> missingIds =
        queue
            .map((PlayableItem item) => item.stableId)
            .where((String id) => !orderedIds.contains(id))
            .toList(growable: false)
          ..shuffle(_random);
    _shuffleOrderStableIds.addAll(missingIds);

    if (_shuffleOrderStableIds.isEmpty) {
      _shuffleOrderStableIds.add(currentId);
    }

    int cursor = _shuffleOrderStableIds.indexOf(currentId);
    if (cursor < 0) {
      final int insertIndex = (_shuffleCursor ?? 0).clamp(
        0,
        _shuffleOrderStableIds.length,
      );
      _shuffleOrderStableIds.insert(insertIndex, currentId);
      cursor = insertIndex;
    }
    _shuffleCursor = cursor;
  }

  void _startNextShuffleRound({
    required List<PlayableItem> queue,
    required int currentIndex,
  }) {
    final String currentId = queue[currentIndex].stableId;
    final List<String> nextOrder =
        queue.map((PlayableItem item) => item.stableId).toList(growable: false)
          ..shuffle(_random);

    if (nextOrder.length > 1 && nextOrder.first == currentId) {
      final int swapIndex = 1 + _random.nextInt(nextOrder.length - 1);
      final String first = nextOrder.first;
      nextOrder[0] = nextOrder[swapIndex];
      nextOrder[swapIndex] = first;
    }

    _shuffleOrderStableIds
      ..clear()
      ..addAll(nextOrder);
    _shuffleCursor = 0;
  }

  int? _queueIndexOfStableId(List<PlayableItem> queue, String stableId) {
    for (int index = 0; index < queue.length; index += 1) {
      if (queue[index].stableId == stableId) {
        return index;
      }
    }
    return null;
  }

  void _clampShuffleCursor() {
    final int? cursor = _shuffleCursor;
    if (_shuffleOrderStableIds.isEmpty) {
      _shuffleCursor = null;
    } else if (cursor == null) {
      _shuffleCursor = null;
    } else if (cursor >= _shuffleOrderStableIds.length) {
      _shuffleCursor = _shuffleOrderStableIds.length - 1;
    }
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
