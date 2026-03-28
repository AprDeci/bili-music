import 'package:bilimusic/feature/player/domain/persisted_playback_queue.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'player_queue_local_repository.g.dart';

const String playerQueueSnapshotBoxName = 'player_queue_snapshot';
const String playerQueueSnapshotKey = 'snapshot';

@riverpod
PlayerQueueLocalRepository playerQueueLocalRepository(Ref ref) {
  return PlayerQueueLocalRepository(
    Hive.box<PersistedPlaybackQueue>(playerQueueSnapshotBoxName),
  );
}

class PlayerQueueLocalRepository {
  const PlayerQueueLocalRepository(this._box);

  final Box<PersistedPlaybackQueue> _box;

  PersistedPlaybackQueue? load() {
    final PersistedPlaybackQueue? snapshot = _box.get(playerQueueSnapshotKey);
    if (snapshot == null || !snapshot.hasQueue) {
      return null;
    }
    return snapshot;
  }

  Future<void> save(PersistedPlaybackQueue snapshot) {
    if (!snapshot.hasQueue) {
      return clear();
    }
    return _box.put(playerQueueSnapshotKey, snapshot);
  }

  Future<void> clear() {
    return _box.delete(playerQueueSnapshotKey);
  }
}
