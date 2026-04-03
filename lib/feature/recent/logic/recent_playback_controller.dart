import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/recent/data/recent_playback_local_repository.dart';
import 'package:bilimusic/feature/recent/domain/recent_playback_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recent_playback_controller.g.dart';

@riverpod
class RecentPlaybackController extends _$RecentPlaybackController {
  late final RecentPlaybackLocalRepository _repository = ref.read(
    recentPlaybackLocalRepositoryProvider,
  );

  @override
  List<RecentPlaybackEntry> build() {
    return _repository.load();
  }

  Future<void> recordItem(PlayableItem item) async {
    final RecentPlaybackEntry entry = RecentPlaybackEntry.fromPlayableItem(
      item,
      playedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
    );
    final List<RecentPlaybackEntry> nextEntries = await _repository.saveEntry(
      entry,
    );
    state = nextEntries;
  }
}
