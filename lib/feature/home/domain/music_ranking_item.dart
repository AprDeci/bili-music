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

  @override
  final int aid;
  @override
  final String bvid;
  @override
  final String title;
  @override
  final String coverUrl;
  @override
  final String author;
  @override
  final String tagText;
  @override
  final String playCountText;
  @override
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
