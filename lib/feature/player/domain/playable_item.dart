import 'package:freezed_annotation/freezed_annotation.dart';

part 'playable_item.freezed.dart';

@freezed
abstract class PlayableItem with _$PlayableItem {
  const PlayableItem._();

  const factory PlayableItem({
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
  }) = _PlayableItem;

  bool get hasIdentity => aid > 0 || bvid.isNotEmpty;

  List<String> get lyricSearchTitles {
    final List<String> titles = <String>[];
    final String partTitle = pageTitle?.trim() ?? '';
    final String videoTitle = title.trim();

    if (partTitle.isNotEmpty) {
      titles.add(partTitle);
    }
    if (videoTitle.isNotEmpty && !titles.contains(videoTitle)) {
      titles.add(videoTitle);
    }

    return titles;
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
}
