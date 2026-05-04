import 'package:freezed_annotation/freezed_annotation.dart';

part 'bili_session.freezed.dart';

@freezed
class BiliSession with _$BiliSession {
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

  @override
  final String sessData;
  @override
  final String biliJct;
  @override
  final String dedeUserId;
  @override
  final String refreshToken;
  @override
  final String cookie;
  @override
  final int? mid;
  @override
  final String? uname;
  @override
  final String? face;
  @override
  final String? imgKey;
  @override
  final String? subKey;
  @override
  final String? buvid3;

  bool get hasCookie => cookie.isNotEmpty;
  bool get isLoggedIn =>
      sessData.isNotEmpty && biliJct.isNotEmpty && dedeUserId.isNotEmpty;
  bool get hasProfile => mid != null || (uname?.isNotEmpty ?? false);
  bool get hasWbiKeys =>
      (imgKey?.isNotEmpty ?? false) && (subKey?.isNotEmpty ?? false);
  bool get isReady => isLoggedIn && hasProfile && hasWbiKeys;


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
