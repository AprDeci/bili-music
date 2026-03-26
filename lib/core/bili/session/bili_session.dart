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
