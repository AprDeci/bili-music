class MusicRankingItem {
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
}
