import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'recent_playback_entry.freezed.dart';

@freezed
abstract class RecentPlaybackEntry with _$RecentPlaybackEntry {
  const RecentPlaybackEntry._();

  const factory RecentPlaybackEntry({
    required int aid,
    required String bvid,
    required String title,
    required String author,
    required String coverUrl,
    int? cid,
    String? pageTitle,
    required int playedAtEpochMs,
  }) = _RecentPlaybackEntry;

  factory RecentPlaybackEntry.fromPlayableItem(
    PlayableItem item, {
    required int playedAtEpochMs,
  }) {
    return RecentPlaybackEntry(
      aid: item.aid,
      bvid: item.bvid,
      title: item.title,
      author: item.author,
      coverUrl: item.coverUrl,
      cid: item.cid,
      pageTitle: item.pageTitle,
      playedAtEpochMs: playedAtEpochMs,
    );
  }

  String get stableId {
    final int? resolvedCid = cid;
    if (resolvedCid != null && resolvedCid > 0) {
      if (bvid.isNotEmpty) {
        return 'bvid:$bvid:cid:$resolvedCid';
      }
      return 'aid:$aid:cid:$resolvedCid';
    }
    if (bvid.isNotEmpty) {
      return 'bvid:$bvid';
    }
    return 'aid:$aid';
  }

  PlayableItem toPlayableItem() {
    return PlayableItem(
      aid: aid,
      bvid: bvid,
      title: title,
      author: author,
      coverUrl: coverUrl,
      cid: cid,
      pageTitle: pageTitle,
    );
  }
}
