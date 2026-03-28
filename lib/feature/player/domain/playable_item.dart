class PlayableItem {
  const PlayableItem({
    required this.aid,
    required this.bvid,
    required this.title,
    required this.author,
    required this.coverUrl,
    this.cid,
    this.page,
    this.pageTitle,
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

  static const Object _sentinel = Object();

  final int aid;
  final String bvid;
  final String title;
  final String author;
  final String coverUrl;
  final int? cid;
  final int? page;
  final String? pageTitle;
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

  PlayableItem copyWith({
    int? aid,
    String? bvid,
    String? title,
    String? author,
    String? coverUrl,
    Object? cid = _sentinel,
    Object? page = _sentinel,
    Object? pageTitle = _sentinel,
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
      cid: identical(cid, _sentinel) ? this.cid : cid as int?,
      page: identical(page, _sentinel) ? this.page : page as int?,
      pageTitle: identical(pageTitle, _sentinel)
          ? this.pageTitle
          : pageTitle as String?,
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
        other.cid == cid &&
        other.page == page &&
        other.pageTitle == pageTitle &&
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
    cid,
    page,
    pageTitle,
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
