class PlayableItem {
  const PlayableItem({
    required this.aid,
    required this.bvid,
    required this.title,
    required this.author,
    required this.coverUrl,
    this.durationText,
  });

  final int aid;
  final String bvid;
  final String title;
  final String author;
  final String coverUrl;
  final String? durationText;

  bool get hasIdentity => aid > 0 || bvid.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is PlayableItem &&
        other.aid == aid &&
        other.bvid == bvid &&
        other.title == title &&
        other.author == author &&
        other.coverUrl == coverUrl &&
        other.durationText == durationText;
  }

  @override
  int get hashCode => Object.hash(
    aid,
    bvid,
    title,
    author,
    coverUrl,
    durationText,
  );
}
