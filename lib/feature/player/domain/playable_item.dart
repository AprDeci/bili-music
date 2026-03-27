class PlayableItem {
  const PlayableItem({
    required this.aid,
    required this.bvid,
    required this.title,
    required this.author,
    required this.coverUrl,
    this.durationText,
    this.playCountText,
    this.danmakuCountText,
    this.likeCountText,
    this.coinCountText,
    this.favoriteCountText,
    this.shareCountText,
    this.replyCountText,
    this.publishTimeText,
    this.description,
  });

  final int aid;
  final String bvid;
  final String title;
  final String author;
  final String coverUrl;
  final String? durationText;
  final String? playCountText;
  final String? danmakuCountText;
  final String? likeCountText;
  final String? coinCountText;
  final String? favoriteCountText;
  final String? shareCountText;
  final String? replyCountText;
  final String? publishTimeText;
  final String? description;

  bool get hasIdentity => aid > 0 || bvid.isNotEmpty;

  String get stableId {
    if (bvid.isNotEmpty) {
      return 'bvid:$bvid';
    }
    return 'aid:$aid';
  }

  PlayableItem copyWith({
    int? aid,
    String? bvid,
    String? title,
    String? author,
    String? coverUrl,
    String? durationText,
    String? playCountText,
    String? danmakuCountText,
    String? likeCountText,
    String? coinCountText,
    String? favoriteCountText,
    String? shareCountText,
    String? replyCountText,
    String? publishTimeText,
    String? description,
  }) {
    return PlayableItem(
      aid: aid ?? this.aid,
      bvid: bvid ?? this.bvid,
      title: title ?? this.title,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      durationText: durationText ?? this.durationText,
      playCountText: playCountText ?? this.playCountText,
      danmakuCountText: danmakuCountText ?? this.danmakuCountText,
      likeCountText: likeCountText ?? this.likeCountText,
      coinCountText: coinCountText ?? this.coinCountText,
      favoriteCountText: favoriteCountText ?? this.favoriteCountText,
      shareCountText: shareCountText ?? this.shareCountText,
      replyCountText: replyCountText ?? this.replyCountText,
      publishTimeText: publishTimeText ?? this.publishTimeText,
      description: description ?? this.description,
    );
  }

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
        other.durationText == durationText &&
        other.playCountText == playCountText &&
        other.danmakuCountText == danmakuCountText &&
        other.likeCountText == likeCountText &&
        other.coinCountText == coinCountText &&
        other.favoriteCountText == favoriteCountText &&
        other.shareCountText == shareCountText &&
        other.replyCountText == replyCountText &&
        other.publishTimeText == publishTimeText &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(
    aid,
    bvid,
    title,
    author,
    coverUrl,
    durationText,
    playCountText,
    danmakuCountText,
    likeCountText,
    coinCountText,
    favoriteCountText,
    shareCountText,
    replyCountText,
    publishTimeText,
    description,
  );
}
