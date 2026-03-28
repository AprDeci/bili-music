import 'package:bilimusic/feature/player/domain/playable_item.dart';

class SearchResultItem {
  const SearchResultItem({
    required this.aid,
    required this.bvid,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.duration,
    required this.playCountText,
    required this.danmakuCountText,
    required this.publishTimeText,
    required this.tagText,
    this.description,
  });

  final int aid;
  final String bvid;
  final String title;
  final String author;
  final String coverUrl;
  final String duration;
  final String playCountText;
  final String danmakuCountText;
  final String publishTimeText;
  final String tagText;
  final String? description;

  PlayableItem toPlayableItem() {
    return PlayableItem(
      aid: aid,
      bvid: bvid,
      title: title,
      author: author,
      coverUrl: coverUrl,
      page: 1,
      durationText: duration,
      playCountText: playCountText,
      danmakuCountText: danmakuCountText,
      publishTimeText: publishTimeText,
      description: description,
    );
  }
}
