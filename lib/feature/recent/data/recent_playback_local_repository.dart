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

  static const int maxEntries = 10;

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
    final List<RecentPlaybackEntry> nextEntries = <RecentPlaybackEntry>[
      entry,
      ...load().where(
        (RecentPlaybackEntry item) => item.stableId != entry.stableId,
      ),
    ].take(maxEntries).toList(growable: false);

    await _box.clear();
    await _box.addAll(nextEntries);
    return nextEntries;
  }
}
