enum BiliQrLoginStatus {
  initial,
  loading,
  waitingForScan,
  waitingForConfirm,
  success,
  expired,
  failure,
}

class BiliQrCodeSession {
  const BiliQrCodeSession({
    required this.url,
    required this.qrcodeKey,
  });

  final String url;
  final String qrcodeKey;
}

class BiliAuthSession {
  const BiliAuthSession({
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

  BiliAuthSession copyWith({
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
  }) {
    return BiliAuthSession(
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
    );
  }
}

class BiliAuthState {
  const BiliAuthState({
    this.status = BiliQrLoginStatus.initial,
    this.qrSession,
    this.authSession,
    this.message,
    this.lastPollCode,
  });

  final BiliQrLoginStatus status;
  final BiliQrCodeSession? qrSession;
  final BiliAuthSession? authSession;
  final String? message;
  final int? lastPollCode;

  bool get isBusy =>
      status == BiliQrLoginStatus.loading ||
      status == BiliQrLoginStatus.waitingForScan ||
      status == BiliQrLoginStatus.waitingForConfirm;

  BiliAuthState copyWith({
    BiliQrLoginStatus? status,
    BiliQrCodeSession? qrSession,
    bool clearQrSession = false,
    BiliAuthSession? authSession,
    bool clearAuthSession = false,
    String? message,
    bool clearMessage = false,
    int? lastPollCode,
    bool clearLastPollCode = false,
  }) {
    return BiliAuthState(
      status: status ?? this.status,
      qrSession: clearQrSession ? null : (qrSession ?? this.qrSession),
      authSession:
          clearAuthSession ? null : (authSession ?? this.authSession),
      message: clearMessage ? null : (message ?? this.message),
      lastPollCode:
          clearLastPollCode ? null : (lastPollCode ?? this.lastPollCode),
    );
  }
}
