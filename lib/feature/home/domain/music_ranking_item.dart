import 'package:bilimusic/feature/player/domain/playable_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'music_ranking_item.freezed.dart';

@freezed
class MusicRankingItem with _$MusicRankingItem {
  const MusicRankingItem({
    required this.aid,
    required this.bvid,
    required this.title,
    required this.coverUrl,
    required this.author,
    required this.tagText,
    required this.playCountText,
    required this.durationText,
  });

  final int aid;
  final String bvid;
  final String title;
  final String coverUrl;
  final String author;
  final String tagText;
  final String playCountText;
  final String durationText;

  PlayableItem toPlayableItem() {
    return PlayableItem(
      aid: aid,
      bvid: bvid,
      title: title,
      author: author,
      coverUrl: coverUrl,
      page: 1,
      durationText: durationText,
      playCountText: playCountText,
    );
  }
}
