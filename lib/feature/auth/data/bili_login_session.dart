import 'package:bilimusic/core/bili/session/bili_cookie.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';

/// 从 WebView 的 Cookie 构造登录态。
///
/// 缺少任一必需 Cookie 时返回 null，调用方据此判断「还没登录完成」。
/// WebView 登录拿不到 `refresh_token`（网页登录不返回），所以留空。
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
    refreshToken: '',
    cookie: buildCookieHeader(cookies),
    buvid3: cookies['buvid3'],
  );
}
