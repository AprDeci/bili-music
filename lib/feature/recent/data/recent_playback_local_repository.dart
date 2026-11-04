import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recent_playback_local_repository.g.dart';

const String recentPlaybackBoxName = 'recent_playback';

@riverpod
RecentPlaybackLocalRepository recentPlaybackLocalRepository(Ref ref) {
  return RecentPlaybackLocalRepository(
    Hive.box<RecentPlaybackEntry>(recentPlaybackBoxName),
  );
}

class RecentPlaybackLocalRepository {
  const RecentPlaybackLocalRepository(this._box);

  static const int maxEntries = 100;

  final Box<RecentPlaybackEntry> _box;

  List<RecentPlaybackEntry> load() {
    final List<RecentPlaybackEntry> entries =
        _box.values.toList(growable: false)..sort(
          (RecentPlaybackEntry a, RecentPlaybackEntry b) =>
              b.playedAtEpochMs.compareTo(a.playedAtEpochMs),
        );

    if (entries.length <= maxEntries) {
      return entries;
    }

    return entries.take(maxEntries).toList(growable: false);
  }

  Future<List<RecentPlaybackEntry>> saveEntry(RecentPlaybackEntry entry) async {
    await _deleteByStableId(entry.stableId);
    await _box.put(entry.stableId, entry);
    await _trimOverflow();
    return load();
  }

  Future<List<RecentPlaybackEntry>> removeEntry(String stableId) async {
    await _deleteByStableId(stableId);
    return load();
  }

  Future<void> clearAll() {
    return _box.clear();
  }

  Future<void> _deleteByStableId(String stableId) async {
    final List<dynamic> keys = _box.keys.toList(growable: false);
    for (final dynamic key in keys) {
      final RecentPlaybackEntry? value = _box.get(key);
      if (value != null && value.stableId == stableId) {
        await _box.delete(key);
      }
    }
  }

  Future<void> _trimOverflow() async {
    final List<RecentPlaybackEntry> sorted = _box.values.toList(growable: false)
      ..sort(
        (RecentPlaybackEntry a, RecentPlaybackEntry b) =>
            b.playedAtEpochMs.compareTo(a.playedAtEpochMs),
      );
    if (sorted.length <= maxEntries) {
      return;
    }
    for (final RecentPlaybackEntry stale in sorted.skip(maxEntries)) {
      await _deleteByStableId(stale.stableId);
    }
  }
}
