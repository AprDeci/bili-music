import 'package:bilimusic/core/bili/session/bili_cookie.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';

// 由 WebView Cookie 还原登录态；缺任一必需 Cookie 返回 null。
BiliSession? sessionFromCookies(Map<String, String> cookies) {
  final String sessData = cookies['SESSDATA'] ?? '';
  final String biliJct = cookies['bili_jct'] ?? '';
  final String dedeUserId = cookies['DedeUserID'] ?? '';
  if (sessData.isEmpty || biliJct.isEmpty || dedeUserId.isEmpty) {
    return null;
  }

  return BiliSession(
    sessData: sessData,
    biliJct: biliJct,
    dedeUserId: dedeUserId,
    refreshToken: '', // 网页登录不返回
    cookie: buildCookieHeader(cookies),
    buvid3: cookies['buvid3'],
  );
}
