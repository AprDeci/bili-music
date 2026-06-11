import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:bilimusic/feature/up/domain/up_video_card_data.dart';

class UpCollectionItem {
  const UpCollectionItem({
    required this.aid,
    required this.bvid,
    required this.title,
    required this.coverUrl,
    required this.durationText,
    required this.playCountText,
    required this.publishTimeText,
  });

  final int aid;
  final String bvid;
  final String title;
  final String coverUrl;
  final String durationText;
  final String playCountText;
  final String publishTimeText;

  PlayableItem toPlayableItem({
    required int ownerMid,
    required String ownerName,
  }) {
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
      publishTimeText: publishTimeText,
    );
  }

  UpVideoCardData toVideoCardData() {
    return UpVideoCardData(
      title: title,
      coverUrl: coverUrl,
      durationText: durationText,
      primaryMeta: publishTimeText,
      secondaryMeta: '$playCountText 播放',
    );
  }
}
