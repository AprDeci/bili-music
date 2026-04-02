import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/player/domain/player_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'persisted_playback_queue.freezed.dart';

@freezed
abstract class PersistedPlaybackQueue with _$PersistedPlaybackQueue {
  const PersistedPlaybackQueue._();

  const factory PersistedPlaybackQueue({
    @Default(<PersistedPlayableItem>[]) List<PersistedPlayableItem> queue,
    int? currentQueueIndex,
    @Default(PlayerQueueMode.sequence) PlayerQueueMode queueMode,
    String? queueSourceLabel,
    @Default(0) int resumePositionMs,
    int? savedAtEpochMs,
  }) = _PersistedPlaybackQueue;

  bool get hasQueue => queue.isNotEmpty;

  int? get sanitizedCurrentQueueIndex {
    final int? index = currentQueueIndex;
    if (index == null || queue.isEmpty) {
      return null;
    }
    if (index < 0) {
      return 0;
    }
    if (index >= queue.length) {
      return queue.length - 1;
    }
    return index;
  }
}

@freezed
abstract class PersistedPlayableItem with _$PersistedPlayableItem {
  const PersistedPlayableItem._();

  const factory PersistedPlayableItem({
    required int aid,
    required String bvid,
    required String title,
    required String author,
    required String coverUrl,
    int? cid,
    int? page,
    String? pageTitle,
    String? durationText,
    String? playCountText,
    String? danmakuCountText,
    String? likeCountText,
    String? coinCountText,
    String? favoriteCountText,
    String? shareCountText,
    int? replyCount,
    String? replyCountText,
    String? publishTimeText,
    String? description,
  }) = _PersistedPlayableItem;

  factory PersistedPlayableItem.fromPlayableItem(PlayableItem item) {
    return PersistedPlayableItem(
      aid: item.aid,
      bvid: item.bvid,
      title: item.title,
      author: item.author,
      coverUrl: item.coverUrl,
      cid: item.cid,
      page: item.page,
      pageTitle: item.pageTitle,
      durationText: item.durationText,
      playCountText: item.playCountText,
      danmakuCountText: item.danmakuCountText,
      likeCountText: item.likeCountText,
      coinCountText: item.coinCountText,
      favoriteCountText: item.favoriteCountText,
      shareCountText: item.shareCountText,
      replyCount: item.replyCount,
      replyCountText: item.replyCountText,
      publishTimeText: item.publishTimeText,
      description: item.description,
    );
  }

  PlayableItem toPlayableItem() {
    return PlayableItem(
      aid: aid,
      bvid: bvid,
      title: title,
      author: author,
      coverUrl: coverUrl,
      cid: cid,
      page: page,
      pageTitle: pageTitle,
      durationText: durationText,
      playCountText: playCountText,
      danmakuCountText: danmakuCountText,
      likeCountText: likeCountText,
      coinCountText: coinCountText,
      favoriteCountText: favoriteCountText,
      shareCountText: shareCountText,
      replyCount: replyCount,
      replyCountText: replyCountText,
      publishTimeText: publishTimeText,
      description: description,
    );
  }
}
