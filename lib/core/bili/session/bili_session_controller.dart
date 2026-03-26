import 'package:bilimusic/core/bili/net/bili_api_client.dart';
import 'package:bilimusic/core/bili/session/bili_cookie.dart';
import 'package:bilimusic/core/bili/session/bili_session.dart';
import 'package:bilimusic/core/bili/session/bili_session_store.dart';
import 'package:bilimusic/core/net/bili_client.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bili_session_controller.g.dart';

@Riverpod(keepAlive: true)
class BiliSessionController extends _$BiliSessionController {
  late final BiliSessionStore _store = ref.read(biliSessionStoreProvider);
  late final BiliClient _client = ref.read(biliClientProvider.notifier);
  late final BiliApiClient _apiClient = ref.read(biliApiClientProvider);

  @override
  BiliSession? build() {
    final BiliSession? session = _store.load();
    if (session != null && session.hasCookie) {
      _client.setCookie(session.cookie);
    } else {
      _client.clearCookie();
    }
    return session;
  }

  Future<void> setSession(BiliSession session) async {
    await _persistSession(session);
  }

  Future<void> clearSession() async {
    await _store.clear();
    _client.clearCookie();
    state = null;
  }

  Future<BiliSession?> bootstrap() async {
    await warmupBaseCookies();

    final BiliSession? currentSession = state;
    if (currentSession == null || !currentSession.isLoggedIn) {
      return state;
    }

    try {
      return await refreshSessionFromNav();
    } on Object {
      final BiliSession anonymousSession = currentSession.clearAuth();
      await _persistSession(anonymousSession);
      return anonymousSession;
    }
  }

  Future<BiliSession> warmupBaseCookies() async {
    final Response<dynamic> response = await _client.get<dynamic>(
      'https://www.bilibili.com/',
      options: Options(responseType: ResponseType.plain),
    );
    final Map<String, String> cookies = extractCookiesFromHeaders(response.headers);

    if (cookies.isEmpty) {
      return state ??
          const BiliSession(
            sessData: '',
            biliJct: '',
            dedeUserId: '',
            refreshToken: '',
            cookie: '',
          );
    }

    final BiliSession nextSession = _mergeCookiesIntoSession(
      base: state,
      nextCookies: cookies,
    );
    await _persistSession(nextSession);
    return nextSession;
  }

  Future<BiliSession> adoptAuthenticatedSession(BiliSession session) async {
    final Map<String, String> nextCookies = parseCookieHeader(session.cookie);
    final BiliSession mergedSession = _mergeCookiesIntoSession(
      base: state,
      nextCookies: nextCookies,
      fallback: session,
    ).copyWith(
      sessData: session.sessData,
      biliJct: session.biliJct,
      dedeUserId: session.dedeUserId,
      refreshToken: session.refreshToken,
      mid: session.mid,
      uname: session.uname,
      face: session.face,
      imgKey: session.imgKey,
      subKey: session.subKey,
    );

    await _persistSession(mergedSession);
    return mergedSession;
  }

  Future<BiliSession> refreshSessionFromNav() async {
    final BiliSession? currentSession = state;
    if (currentSession == null || !currentSession.isLoggedIn) {
      throw const BiliSessionException('No logged-in Bilibili session available.');
    }

    final Map<String, dynamic> json = await _apiClient.getJson(
      '/x/web-interface/nav',
      requiresAuth: true,
    );
    final Map<String, dynamic> data = _asMap(json['data']);
    final bool isLogin = data['isLogin'] as bool? ?? false;
    if (!isLogin) {
      throw const BiliSessionException('Current Bilibili cookie is no longer valid.');
    }

    final Map<String, dynamic> wbiImg = _asMap(data['wbi_img']);
    final BiliSession nextSession = currentSession.copyWith(
      mid: (data['mid'] as num?)?.toInt(),
      uname: data['uname'] as String?,
      face: data['face'] as String?,
      imgKey: _extractKeyFromUrl(wbiImg['img_url'] as String?),
      subKey: _extractKeyFromUrl(wbiImg['sub_url'] as String?),
    );

    await _persistSession(nextSession);
    return nextSession;
  }

  Future<void> _persistSession(BiliSession session) async {
    if (session.hasCookie) {
      _client.setCookie(session.cookie);
    } else {
      _client.clearCookie();
    }
    await _store.save(session);
    state = session;
  }

  BiliSession _mergeCookiesIntoSession({
    required BiliSession? base,
    required Map<String, String> nextCookies,
    BiliSession? fallback,
  }) {
    final BiliSession seed = base ??
        fallback ??
        const BiliSession(
          sessData: '',
          biliJct: '',
          dedeUserId: '',
          refreshToken: '',
          cookie: '',
        );

    final String cookie = mergeCookieHeaders(seed.cookie, nextCookies);
    return seed.copyWith(
      cookie: cookie,
      buvid3: nextCookies['buvid3'] ?? seed.buvid3,
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (dynamic key, dynamic mapValue) => MapEntry(key.toString(), mapValue),
      );
    }
    throw const BiliSessionException('Unexpected response format.');
  }

  String? _extractKeyFromUrl(String? url) {
    if (url == null || url.isEmpty) {
      return null;
    }

    final Uri uri = Uri.parse(url);
    final String lastSegment = uri.pathSegments.isEmpty
        ? ''
        : uri.pathSegments.last;
    final int dotIndex = lastSegment.lastIndexOf('.');
    return dotIndex > 0 ? lastSegment.substring(0, dotIndex) : lastSegment;
  }
}

class BiliSessionException implements Exception {
  const BiliSessionException(this.message);

  final String message;

  @override
  String toString() => message;
}
