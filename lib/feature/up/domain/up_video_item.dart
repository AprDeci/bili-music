import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/up/domain/up_video_card_data.dart';

class UpVideoItem {
  const UpVideoItem({
    required this.aid,
    required this.bvid,
    required this.title,
    required this.coverUrl,
    required this.durationText,
    required this.playCountText,
    required this.danmakuCountText,
    required this.publishTimeText,
    required this.ownerMid,
    required this.ownerName,
    this.description,
  });

  final int aid;
  final String bvid;
  final String title;
  final String coverUrl;
  final String durationText;
  final String playCountText;
  final String danmakuCountText;
  final String publishTimeText;
  final int ownerMid;
  final String ownerName;
  final String? description;

  PlayableItem toPlayableItem() {
    return PlayableItem(
      aid: aid,
      bvid: bvid,
      title: title,
      author: ownerName,
      coverUrl: coverUrl,
      ownerMid: ownerMid,
      page: 1,
      durationText: durationText,
      playCountText: playCountText,
      danmakuCountText: danmakuCountText,
      publishTimeText: publishTimeText,
      description: description,
    );
  }

  UpVideoCardData toVideoCardData() {
    return UpVideoCardData(
      title: title,
      coverUrl: coverUrl,
      durationText: durationText,
      primaryMeta: publishTimeText,
      secondaryMeta: '$playCountText 播放 · $danmakuCountText 弹幕',
    );
  }
}
