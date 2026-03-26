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
}
