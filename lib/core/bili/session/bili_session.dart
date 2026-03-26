class BiliSession {
  const BiliSession({
    required this.sessData,
    required this.biliJct,
    required this.dedeUserId,
    required this.refreshToken,
    required this.cookie,
    this.mid,
    this.uname,
    this.face,
    this.imgKey,
    this.subKey,
    this.buvid3,
  });

  final String sessData;
  final String biliJct;
  final String dedeUserId;
  final String refreshToken;
  final String cookie;
  final int? mid;
  final String? uname;
  final String? face;
  final String? imgKey;
  final String? subKey;
  final String? buvid3;

  bool get hasCookie => cookie.isNotEmpty;
  bool get isLoggedIn =>
      sessData.isNotEmpty && biliJct.isNotEmpty && dedeUserId.isNotEmpty;
  bool get hasWbiKeys =>
      (imgKey?.isNotEmpty ?? false) && (subKey?.isNotEmpty ?? false);

  BiliSession copyWith({
    String? sessData,
    String? biliJct,
    String? dedeUserId,
    String? refreshToken,
    String? cookie,
    int? mid,
    String? uname,
    String? face,
    String? imgKey,
    String? subKey,
    String? buvid3,
  }) {
    return BiliSession(
      sessData: sessData ?? this.sessData,
      biliJct: biliJct ?? this.biliJct,
      dedeUserId: dedeUserId ?? this.dedeUserId,
      refreshToken: refreshToken ?? this.refreshToken,
      cookie: cookie ?? this.cookie,
      mid: mid ?? this.mid,
      uname: uname ?? this.uname,
      face: face ?? this.face,
      imgKey: imgKey ?? this.imgKey,
      subKey: subKey ?? this.subKey,
      buvid3: buvid3 ?? this.buvid3,
    );
  }

  BiliSession clearAuth() {
    return BiliSession(
      sessData: '',
      biliJct: '',
      dedeUserId: '',
      refreshToken: '',
      cookie: cookie,
      buvid3: buvid3,
    );
  }
}
